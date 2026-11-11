package com.swp391.util;

import javax.imageio.ImageIO;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.InputStream;
import java.net.URL;
import java.util.Base64;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * High-performance Multi-tier Visual Feature Matching Engine for Audio Products.
 * Analyzes Subject Bounding Box (auto-cropping), 8x8 Spatial Block Luminance,
 * Foreground Color Space Histogram (64 bins, ignoring white background),
 * and 256-bit dHash to accurately compare user query images with store product images.
 */
public class VisualSearchEngine {

    private static final Logger LOGGER = Logger.getLogger(VisualSearchEngine.class.getName());

    // In-memory cache for product image visual fingerprints
    private static final Map<String, VisualFingerprint> PRODUCT_FINGERPRINT_CACHE = new ConcurrentHashMap<>();

    public static class VisualFingerprint {
        public final float[] blockLuminance;   // 64 floats (8x8 grid)
        public final float[] foregroundColor;   // 64 bins (4x4x4 RGB subject colors)
        public final long[] dhash;             // 4 longs = 256 bits
        public final float aspectRatio;

        public VisualFingerprint(float[] blockLuminance, float[] foregroundColor, long[] dhash, float aspectRatio) {
            this.blockLuminance = blockLuminance;
            this.foregroundColor = foregroundColor;
            this.dhash = dhash;
            this.aspectRatio = aspectRatio;
        }
    }

    /**
     * Decodes Base64 string into a BufferedImage.
     */
    public static BufferedImage decodeBase64ToImage(String base64Str) {
        if (base64Str == null || base64Str.trim().isEmpty()) {
            return null;
        }
        try {
            String clean = base64Str;
            if (clean.contains(",")) {
                clean = clean.substring(clean.indexOf(",") + 1);
            }
            clean = clean.replaceAll("\\s+", "");
            byte[] bytes = Base64.getDecoder().decode(clean);
            try (ByteArrayInputStream bais = new ByteArrayInputStream(bytes)) {
                return ImageIO.read(bais);
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to decode base64 image: " + e.getMessage());
            return null;
        }
    }

    /**
     * Automatically crops image to the subject bounding box, trimming excess white or transparent borders.
     */
    public static BufferedImage cropToSubject(BufferedImage img) {
        if (img == null) return null;
        int w = img.getWidth();
        int h = img.getHeight();

        int minX = w, maxX = 0, minY = h, maxY = 0;
        boolean found = false;

        for (int y = 0; y < h; y++) {
            for (int x = 0; x < w; x++) {
                int rgb = img.getRGB(x, y);
                int a = (rgb >> 24) & 0xFF;
                int r = (rgb >> 16) & 0xFF;
                int g = (rgb >> 8) & 0xFF;
                int b = rgb & 0xFF;

                // Subject pixel: non-transparent and not white background
                if (a > 30 && (r < 240 || g < 240 || b < 240)) {
                    if (x < minX) minX = x;
                    if (x > maxX) maxX = x;
                    if (y < minY) minY = y;
                    if (y > maxY) maxY = y;
                    found = true;
                }
            }
        }

        if (!found || minX >= maxX || minY >= maxY) {
            return img; // Fallback to original
        }

        int cropW = maxX - minX + 1;
        int cropH = maxY - minY + 1;
        return img.getSubimage(minX, minY, cropW, cropH);
    }

    /**
     * Extracts multi-tier visual fingerprint from an image.
     */
    public static VisualFingerprint extractFingerprint(BufferedImage rawImg) {
        if (rawImg == null) {
            return null;
        }

        // 1. Crop to subject to normalize bounding box
        BufferedImage img = cropToSubject(rawImg);
        int width = img.getWidth();
        int height = img.getHeight();
        float aspectRatio = (float) width / (float) Math.max(1, height);

        // 2. Compute 8x8 Spatial Block Luminance (64 blocks, normalized)
        BufferedImage blockImg = new BufferedImage(8, 8, BufferedImage.TYPE_BYTE_GRAY);
        Graphics2D gBlock = blockImg.createGraphics();
        gBlock.drawImage(img.getScaledInstance(8, 8, Image.SCALE_SMOOTH), 0, 0, null);
        gBlock.dispose();

        float[] blockLum = new float[64];
        float sumBlockSq = 0.0f;
        int bIdx = 0;
        for (int y = 0; y < 8; y++) {
            for (int x = 0; x < 8; x++) {
                int val = blockImg.getRaster().getSample(x, y, 0);
                blockLum[bIdx] = (float) val;
                sumBlockSq += blockLum[bIdx] * blockLum[bIdx];
                bIdx++;
            }
        }
        float blockNorm = (float) Math.sqrt(sumBlockSq);
        if (blockNorm > 0) {
            for (int i = 0; i < 64; i++) blockLum[i] /= blockNorm;
        }

        // 3. Compute Foreground Color Space Histogram (64 bins, ignores white background)
        float[] fgColor = new float[64];
        int fgPixelCount = 0;
        for (int y = 0; y < height; y++) {
            for (int x = 0; x < width; x++) {
                int rgb = img.getRGB(x, y);
                int a = (rgb >> 24) & 0xFF;
                int r = (rgb >> 16) & 0xFF;
                int g = (rgb >> 8) & 0xFF;
                int b = rgb & 0xFF;

                if (a > 30 && (r < 240 || g < 240 || b < 240)) {
                    int rBin = Math.min(3, r / 64);
                    int gBin = Math.min(3, g / 64);
                    int bBin = Math.min(3, b / 64);
                    fgColor[rBin * 16 + gBin * 4 + bBin] += 1.0f;
                    fgPixelCount++;
                }
            }
        }
        if (fgPixelCount > 0) {
            float sumColorSq = 0.0f;
            for (float v : fgColor) sumColorSq += v * v;
            float colorNorm = (float) Math.sqrt(sumColorSq);
            if (colorNorm > 0) {
                for (int i = 0; i < 64; i++) fgColor[i] /= colorNorm;
            }
        }

        // 4. Compute 256-bit dHash (17 x 16 grayscale)
        BufferedImage grayScaled = new BufferedImage(17, 16, BufferedImage.TYPE_BYTE_GRAY);
        Graphics2D gDhash = grayScaled.createGraphics();
        gDhash.drawImage(img.getScaledInstance(17, 16, Image.SCALE_SMOOTH), 0, 0, null);
        gDhash.dispose();

        long[] dhash = new long[4];
        int bitIdx = 0;
        for (int y = 0; y < 16; y++) {
            for (int x = 0; x < 16; x++) {
                int left = grayScaled.getRaster().getSample(x, y, 0);
                int right = grayScaled.getRaster().getSample(x + 1, y, 0);
                if (right > left) {
                    int longIdx = bitIdx / 64;
                    int shift = bitIdx % 64;
                    dhash[longIdx] |= (1L << shift);
                }
                bitIdx++;
            }
        }

        return new VisualFingerprint(blockLum, fgColor, dhash, aspectRatio);
    }

    /**
     * Compares two visual fingerprints and returns a composite similarity score from 0.0 to 1.0.
     * High values (>= 0.95) indicate a direct photo/style match.
     */
    public static double compareFingerprints(VisualFingerprint f1, VisualFingerprint f2) {
        if (f1 == null || f2 == null) {
            return 0.0;
        }

        // 1. Spatial 8x8 Block Luminance Cosine Similarity
        double blockDot = 0.0;
        for (int i = 0; i < 64; i++) {
            blockDot += f1.blockLuminance[i] * f2.blockLuminance[i];
        }
        double blockSim = Math.max(0.0, Math.min(1.0, blockDot));

        // 2. Foreground Color Histogram Cosine Similarity
        double colorDot = 0.0;
        for (int i = 0; i < 64; i++) {
            colorDot += f1.foregroundColor[i] * f2.foregroundColor[i];
        }
        double colorSim = Math.max(0.0, Math.min(1.0, colorDot));

        // 3. dHash Hamming Distance Similarity (256 bits)
        int hammingDist = 0;
        for (int i = 0; i < 4; i++) {
            hammingDist += Long.bitCount(f1.dhash[i] ^ f2.dhash[i]);
        }
        double dHashSim = Math.max(0.0, 1.0 - ((double) hammingDist / 256.0));

        // 4. Combined Similarity
        // If both spatial structure and subject colors match strongly -> Absolute direct match!
        if (blockSim >= 0.92 && colorSim >= 0.96) {
            double boost = 0.96 + (blockSim - 0.92) * 0.3 + (colorSim - 0.96) * 0.4;
            return Math.min(0.995, Math.max(0.96, boost));
        }

        double composite = (0.50 * blockSim) + (0.35 * colorSim) + (0.15 * dHashSim);
        return Math.max(0.0, Math.min(1.0, composite));
    }

    /**
     * Resolves product image file and obtains or calculates its cached VisualFingerprint.
     */
    public static VisualFingerprint getProductFingerprint(String imageUrl, String contextRealPath) {
        if (imageUrl == null || imageUrl.trim().isEmpty()) {
            return null;
        }

        String normalizedUrl = imageUrl.trim().replace('\\', '/');
        if (normalizedUrl.startsWith("/")) {
            normalizedUrl = normalizedUrl.substring(1);
        }

        VisualFingerprint cached = PRODUCT_FINGERPRINT_CACHE.get(normalizedUrl);
        if (cached != null) {
            return cached;
        }

        BufferedImage img = loadProductImage(normalizedUrl, contextRealPath);
        if (img != null) {
            VisualFingerprint fp = extractFingerprint(img);
            if (fp != null) {
                PRODUCT_FINGERPRINT_CACHE.put(normalizedUrl, fp);
                return fp;
            }
        }
        return null;
    }

    /**
     * Locates product image from disk via multiple fallback search paths.
     */
    private static BufferedImage loadProductImage(String relativePath, String contextRealPath) {
        try {
            // Path option 1: via contextRealPath (deployed Tomcat webapp)
            if (contextRealPath != null && !contextRealPath.isEmpty()) {
                File f = new File(contextRealPath, relativePath);
                if (f.exists() && f.isFile()) {
                    return ImageIO.read(f);
                }
            }

            // Path option 2: via project workspace source directory
            String[] searchRoots = new String[]{
                    "SWP391_G6_FALL26/src/main/webapp",
                    "src/main/webapp",
                    "../SWP391_G6_FALL26/src/main/webapp",
                    "../../SWP391_G6_FALL26/src/main/webapp",
                    System.getProperty("user.dir") + "/SWP391_G6_FALL26/src/main/webapp",
                    System.getProperty("user.dir") + "/src/main/webapp"
            };

            for (String root : searchRoots) {
                File f = new File(root, relativePath);
                if (f.exists() && f.isFile()) {
                    return ImageIO.read(f);
                }
            }

            // Path option 3: direct file path
            File direct = new File(relativePath);
            if (direct.exists() && direct.isFile()) {
                return ImageIO.read(direct);
            }

            // Path option 4: Classpath Resource
            InputStream is = VisualSearchEngine.class.getClassLoader().getResourceAsStream(relativePath);
            if (is != null) {
                try (is) {
                    return ImageIO.read(is);
                }
            }

            // Path option 5: HTTP URL
            if (relativePath.startsWith("http://") || relativePath.startsWith("https://")) {
                return ImageIO.read(new URL(relativePath));
            }
        } catch (Exception e) {
            LOGGER.log(Level.FINE, "Could not load image for path '" + relativePath + "': " + e.getMessage());
        }
        return null;
    }
}
