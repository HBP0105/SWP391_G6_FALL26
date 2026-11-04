package com.swp391.service.external;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;

import java.io.IOException;
import java.io.InputStream;
import java.util.Map;
import javax.naming.InitialContext;
import javax.naming.NamingException;

public class CloudinaryService {

    private static final String PRODUCT_FOLDER = "swp391-fall26/products";

    public String uploadProductImage(InputStream inputStream) throws IOException {
        if (inputStream == null) {
            throw new IllegalArgumentException("Image input stream is required.");
        }

        byte[] imageBytes = inputStream.readAllBytes();
        if (imageBytes.length == 0) {
            throw new IllegalArgumentException("Image file is empty.");
        }

        Cloudinary cloudinary = createCloudinary();

        Map<?, ?> uploadResult = cloudinary.uploader().upload(
                imageBytes,
                ObjectUtils.asMap(
                        "folder", PRODUCT_FOLDER,
                        "resource_type", "image"
                )
        );

        Object secureUrl = uploadResult.get("secure_url");
        if (secureUrl == null || secureUrl.toString().isBlank()) {
            throw new IOException("Cloudinary did not return an image URL.");
        }

        return secureUrl.toString();
    }

    private Cloudinary createCloudinary() {
        String cloudName = getRequiredConfig("CLOUDINARY_CLOUD_NAME");
        String apiKey    = getRequiredConfig("CLOUDINARY_API_KEY");
        String apiSecret = getRequiredConfig("CLOUDINARY_API_SECRET");

        return new Cloudinary(ObjectUtils.asMap(
                "cloud_name", cloudName,
                "api_key",    apiKey,
                "api_secret", apiSecret,
                "secure",     true
        ));
    }

    /**
     * Lookup order:
     *  1. OS environment variable  (setx / export)
     *  2. JVM system property      (-DCLOUDINARY_CLOUD_NAME=... in CATALINA_OPTS)
     *  3. JNDI context entry       (<Environment> in META-INF/context.xml)
     */
    private String getRequiredConfig(String name) {
        // 1. OS env
        String value = System.getenv(name);
        if (value != null && !value.isBlank()) {
            return value.trim();
        }

        // 2. JVM system property
        value = System.getProperty(name);
        if (value != null && !value.isBlank()) {
            return value.trim();
        }

        // 3. JNDI (Tomcat context.xml <Environment>)
        try {
            Object jndiValue = new InitialContext().lookup("java:comp/env/" + name);
            if (jndiValue != null && !jndiValue.toString().isBlank()) {
                return jndiValue.toString().trim();
            }
        } catch (NamingException ignored) {
            // JNDI not available in this runtime
        }

        throw new IllegalStateException(
                name + " is not configured in environment variables, "
                + "JVM system properties, or JNDI (context.xml)."
        );
    }
}

