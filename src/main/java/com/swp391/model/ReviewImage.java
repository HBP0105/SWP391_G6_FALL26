package com.swp391.model;

import java.time.LocalDateTime;

/**
 * Model representing an image attached to a product review.
 */
public class ReviewImage {

    private int imageId;
    private int reviewId;
    private String imageUrl;
    private String publicId;
    private boolean isPrimary;
    private LocalDateTime createdAt;

    public ReviewImage() {
    }

    public ReviewImage(int imageId, int reviewId, String imageUrl, String publicId, boolean isPrimary, LocalDateTime createdAt) {
        this.imageId = imageId;
        this.reviewId = reviewId;
        this.imageUrl = imageUrl;
        this.publicId = publicId;
        this.isPrimary = isPrimary;
        this.createdAt = createdAt;
    }

    public int getImageId() {
        return imageId;
    }

    public void setImageId(int imageId) {
        this.imageId = imageId;
    }

    public int getReviewId() {
        return reviewId;
    }

    public void setReviewId(int reviewId) {
        this.reviewId = reviewId;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getPublicId() {
        return publicId;
    }

    public void setPublicId(String publicId) {
        this.publicId = publicId;
    }

    public boolean isIsPrimary() {
        return isPrimary;
    }

    public void setIsPrimary(boolean isPrimary) {
        this.isPrimary = isPrimary;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}

