package com.swp391.util;

import org.junit.jupiter.api.Test;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;

import static org.junit.jupiter.api.Assertions.*;

public class VisualSearchEngineTest {

    @Test
    public void testVisualMatchingAccuracy() throws Exception {
        // Uploaded image from the user
        File uploadFile = new File("C:/Users/Admin/.gemini/antigravity/brain/d87e3c4b-9e9e-4f8e-a2c6-1fa4f24c3f85/.user_uploaded/media_1794380579833_bb3a55e5.png");
        // Store product images
        File prod02File = new File("SWP391_G6_FALL26/src/main/webapp/assets/img/product02.png");
        File prod01File = new File("SWP391_G6_FALL26/src/main/webapp/assets/img/product01.png");

        assertTrue(uploadFile.exists(), "Upload file must exist");
        assertTrue(prod02File.exists(), "product02.png must exist");
        assertTrue(prod01File.exists(), "product01.png must exist");

        BufferedImage imgUpload = ImageIO.read(uploadFile);
        BufferedImage imgProd02 = ImageIO.read(prod02File);
        BufferedImage imgProd01 = ImageIO.read(prod01File);

        VisualSearchEngine.VisualFingerprint fpUpload = VisualSearchEngine.extractFingerprint(imgUpload);
        VisualSearchEngine.VisualFingerprint fpProd02 = VisualSearchEngine.extractFingerprint(imgProd02);
        VisualSearchEngine.VisualFingerprint fpProd01 = VisualSearchEngine.extractFingerprint(imgProd01);

        double simWithTargetProd02 = VisualSearchEngine.compareFingerprints(fpUpload, fpProd02);
        double simWithLaptopProd01 = VisualSearchEngine.compareFingerprints(fpUpload, fpProd01);

        System.out.println("=== VISUAL ENGINE SIMILARITY TEST ===");
        System.out.println("Similarity with Product 02 (Target Headphone): " + (simWithTargetProd02 * 100) + "%");
        System.out.println("Similarity with Product 01 (Laptop): " + (simWithLaptopProd01 * 100) + "%");

        // The target headphone MUST have significantly higher match score (> 95%)
        assertTrue(simWithTargetProd02 >= 0.95, "Product 02 must have >= 95% match, got: " + simWithTargetProd02);
        assertTrue(simWithTargetProd02 > simWithLaptopProd01 + 0.30, "Target headphone must strongly beat laptop");
    }
}

