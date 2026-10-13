# MODULE AI GỢI Ý TAI NGHE (512-DIMENSIONAL VECTOR EMBEDDING)

Phân hệ tích hợp Trí tuệ Nhân tạo hỗ trợ gợi ý sản phẩm bán kèm (Cross-sell/Upsell) cho dự án Web Bán Tai Nghe.

---

## 1. Kiến Trúc & Công Nghệ Sử Dụng
- **Mô hình AI:** `CLIP-ViT-B-32` (Pre-trained Contrastive Language-Image Pretraining của OpenAI).
- **Kích thước biểu diễn (Vector Dimension):** Đúng **512 chiều** (512-dimensional semantic vector).
- **Thuật toán so sánh:** **Cosine Similarity** đo góc giữa 2 vector trong không gian đặc trưng đa chiều.
- **Cơ sở dữ liệu:** Microsoft SQL Server (`HeadphoneSalesDB`), bảng lưu trữ kết quả: `AIRecommendations`.

---

## 2. Các Bước Kích Hoạt Module AI

### Bước 1: Đảm bảo CSDL đã hoạt động
Khởi động SQL Server và đảm bảo database `HeadphoneSalesDB` đã được nạp dữ liệu.

### Bước 2: Cài đặt thư viện Python (Chỉ làm lần đầu)
Mở terminal/cmd tại thư mục này và gõ:
```bash
pip install -r requirements.txt
```

### Bước 3: Chạy phân tích và nạp gợi ý vào SQL Server
```bash
python ai_recommender.py
```

---

## 3. Kết Quả Tích Hợp Vào Web (Java Web)
- Dữ liệu sau khi phân tích được lưu tự động vào bảng `AIRecommendations`.
- **Màn hình Order Detail (`views/staff/order-detail.jsp`):** Hiển thị khối gợi ý thông minh kèm ảnh, % độ khớp tương đồng và lý do AI đề xuất.
- **Màn hình AI Performance Report (`views/admin/ai-performance-report.jsp`):** Hiển thị các chỉ số đo lường hiệu suất AI (Độ tương đồng trung bình, CTR, tỷ lệ chuyển đổi đơn hàng).
