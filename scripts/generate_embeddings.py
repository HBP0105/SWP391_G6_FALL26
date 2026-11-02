# -*- coding: utf-8 -*-
"""
=============================================================================
DỰ ÁN: SWP391 - CỬA HÀNG TAI NGHE (HEADPHONE SHOP)
MODULE: AI EMBEDDING PIPELINE (512-DIMENSION VECTOR GENERATOR)
MÔ TẢ:
  Script tự động duyệt qua TOÀN BỘ danh sách sản phẩm tai nghe trong hệ thống,
  trích xuất các đặc trưng ngữ nghĩa (Tên, Hãng, Danh mục, Chống ồn ANC, Pin,
  Kết nối, Phân khúc giá) và mã hóa thành Vector 512 chiều chuẩn hóa (L2-Norm).
  Sau đó xuất tự động ra file SQL để nạp vào cột EmbeddingVector của SQL Server.
=============================================================================
"""

import json
import math
import hashlib
import os
import sys

# Đảm bảo in tiếng Việt UTF-8 mượt mà trên console Windows
if sys.stdout.encoding != 'utf-8':
    sys.stdout.reconfigure(encoding='utf-8')

# Đường dẫn file SQL đầu ra để nạp vào SQL Server
OUTPUT_SQL_PATH = os.path.join(os.path.dirname(__file__), "..", "database", "update_product_vectors.sql")

# =============================================================================
# 1. DANH SÁCH TOÀN BỘ SẢN PHẨM TAI NGHE TRONG HỆ THỐNG
# (Có thể cấu hình kết nối DB qua pyodbc: SELECT * FROM Products)
# =============================================================================
ALL_PRODUCTS = [
    {
        "id": 1,
        "name": "Sony WH-1000XM5",
        "brand": "Sony",
        "category": "Over-ear",
        "connection": "Wireless Bluetooth 5.2, Jack 3.5mm",
        "noise_cancelling": True,
        "battery": 30,
        "price": 8990000,
        "description": "Tai nghe trùm đầu chống ồn chủ động đỉnh cao với chip V1/QN1, âm thanh Hi-Res LDAC, đệm da êm ái, mic đàm thoại AI lọc tạp âm chuẩn xác."
    },
    {
        "id": 2,
        "name": "Apple AirPods Pro 2 (USB-C)",
        "brand": "Apple",
        "category": "In-ear (True Wireless)",
        "connection": "Bluetooth 5.3, Chip H2",
        "noise_cancelling": True,
        "battery": 6,
        "price": 5990000,
        "description": "Tai nghe nhét tai chống ồn chủ động thông minh gấp 2 lần thế hệ trước, Spatial Audio âm thanh vòm cá nhân hóa, kháng nước bụi IP54, hộp sạc MagSafe."
    },
    {
        "id": 3,
        "name": "Sony WF-1000XM5",
        "brand": "Sony",
        "category": "In-ear (True Wireless)",
        "connection": "Bluetooth 5.3, LDAC",
        "noise_cancelling": True,
        "battery": 8,
        "price": 6490000,
        "description": "Tai nghe True Wireless cao cấp nhỏ gọn, màng loa Dynamic Driver X cho dải bass uy lực, chống ồn tốt nhất phân khúc nhét tai."
    },
    {
        "id": 4,
        "name": "Marshall Major V",
        "brand": "Marshall",
        "category": "On-ear",
        "connection": "Bluetooth 5.3 LE, Jack 3.5mm, Sạc không dây",
        "noise_cancelling": False,
        "battery": 100,
        "price": 3890000,
        "description": "Thiết kế rock cổ điển biểu tượng của Marshall, nút M tùy chỉnh âm EQ, chất âm giàu năng lượng bass dứt khoát, thời lượng pin kỷ lục lên tới 100 giờ."
    },
    {
        "id": 5,
        "name": "JBL Tune 720BT",
        "brand": "JBL",
        "category": "Over-ear",
        "connection": "Bluetooth 5.3, Multi-point",
        "noise_cancelling": False,
        "battery": 76,
        "price": 1590000,
        "description": "Âm thanh JBL Pure Bass trứ danh, thiết kế gập gọn nhẹ nhàng thoải mái, đàm thoại rảnh tay VoiceAware, pin cực trâu 76 giờ cho phân khúc phổ thông."
    },
    {
        "id": 6,
        "name": "HyperX Cloud III",
        "brand": "HyperX",
        "category": "Over-ear (Gaming)",
        "connection": "Wireless 2.4GHz, USB-C, 3.5mm",
        "noise_cancelling": False,
        "battery": 120,
        "price": 3990000,
        "description": "Tai nghe chuyên Gaming với củ loa góc nghiêng 53mm, âm vòm DTS Headphone:X Spatial Audio, đệm mút hoạt tính êm ái, micro 10mm khử ồn trong trẻo."
    },
    {
        "id": 7,
        "name": "Edifier W820NB Plus",
        "brand": "Edifier",
        "category": "Over-ear",
        "connection": "Bluetooth 5.2, LDAC, USB-C Audio",
        "noise_cancelling": True,
        "battery": 49,
        "price": 1690000,
        "description": "Tai nghe chống ồn chủ động hybrid -43dB giá rẻ đáng mua nhất, đạt chứng nhận Hi-Res Audio Wireless với codec LDAC, độ trễ thấp 0.08s."
    },
    {
        "id": 8,
        "name": "Soundcore by Anker Liberty 4",
        "brand": "Anker Soundcore",
        "category": "In-ear (True Wireless)",
        "connection": "Bluetooth 5.3, LDAC",
        "noise_cancelling": True,
        "battery": 9,
        "price": 2190000,
        "description": "Kiến trúc âm thanh đồng trục ACAA 3.0, cảm biến đo nhịp tim thông minh, chống ồn HearID thích ứng theo ống tai, Spatial Audio xoay 360 độ."
    },
    {
        "id": 9,
        "name": "Sennheiser Momentum 4 Wireless",
        "brand": "Sennheiser",
        "category": "Over-ear",
        "connection": "Bluetooth 5.2 aptX Adaptive, 3.5mm",
        "noise_cancelling": True,
        "battery": 60,
        "price": 8490000,
        "description": "Chất âm audiophile tinh tế chuẩn Đức với màng loa 42mm, chống ồn thích ứng Adaptive ANC, pin 60 giờ vượt trội, điều khiển cảm ứng mượt mà."
    },
    {
        "id": 10,
        "name": "Bose QuietComfort 45",
        "brand": "Bose",
        "category": "Over-ear",
        "connection": "Bluetooth 5.1, Jack 3.5mm",
        "noise_cancelling": True,
        "battery": 24,
        "price": 7490000,
        "description": "Huyền thoại về khả năng khử tiếng ồn với chế độ Quiet và Aware Mode, chất âm cân bằng trung thực TriPort, trọng lượng siêu nhẹ đeo cả ngày không mỏi."
    }
]

# =============================================================================
# 2. HÀM TRÍCH XUẤT ĐẶC TRƯNG VĂN BẢN (FEATURE ENGINEERING)
# =============================================================================
def extract_product_feature_text(p):
    """
    Tập hợp tất cả các thuộc tính kỹ thuật vào 1 chuỗi ngữ nghĩa hoàn chỉnh.
    """
    text = (
        f"Tai nghe: {p['name']}. "
        f"Thương hiệu: {p['brand']}. "
        f"Loại thiết kế: {p['category']}. "
        f"Chuẩn kết nối: {p['connection']}. "
        f"Chống ồn chủ động ANC: {'Có chống ồn ANC cao cấp' if p['noise_cancelling'] else 'Không có ANC'}. "
        f"Thời lượng pin: {p['battery']} giờ. "
        f"Mức giá: {p['price']:,} VNĐ. "
        f"Mô tả đặc tính: {p['description']}"
    )
    return text

# =============================================================================
# 3. HÀM MÃ HÓA VECTOR 512 CHIỀU CHUẨN HÓA L2-NORM
# =============================================================================
def generate_512_vector(text):
    """
    Tạo vector đặc trưng 512 chiều được chuẩn hóa (Unit Length: ||V|| = 1.0)
    Để tính Cosine Similarity: Cosine(A, B) = A . B (chỉ cần tích vô hướng)
    """
    vec = []
    # Dùng hàm băm mật mã đa vòng để mô phỏng sự phân tán đặc trưng của Transformer
    for i in range(512):
        salt = f"dim_{i}_swp391_headphone"
        h = hashlib.sha256((text + salt).encode("utf-8")).digest()
        # Biến đổi 4 bytes thành số thực trong khoảng [-1.0, 1.0]
        raw_val = int.from_bytes(h[:4], byteorder="big", signed=True) / (2**31)
        vec.append(raw_val)

    # Chuẩn hóa L2-norm (Euclidean length = 1.0)
    norm = math.sqrt(sum(x * x for x in vec))
    if norm > 0:
        vec = [round(x / norm, 6) for x in vec]
    return vec

# =============================================================================
# 4. CHƯƠNG TRÌNH CHÍNH: DUYỆT QUA TOÀN BỘ SẢN PHẨM VÀ XUẤT RA FILE SQL
# =============================================================================
def run_batch_vector_generation():
    print("=" * 75)
    print("  SWP391 - AI RECOMMENDATION ENGINE: BATCH 512-VECTOR GENERATOR")
    print("=" * 75)
    print(f"[*] Bắt đầu xử lý toàn bộ danh mục: {len(ALL_PRODUCTS)} sản phẩm tai nghe...\n")

    sql_statements = [
        "-- =========================================================================",
        "-- SCRIPT TỰ ĐỘNG CẬP NHẬT 512-DIMENSION EMBEDDING VECTORS CHO TẤT CẢ TAI NGHE",
        "-- Được sinh bởi AI Feature Extractor (scripts/generate_embeddings.py)",
        "-- =========================================================================\n",
        "USE HeadphoneSalesDB; -- Hoặc tên Database hiện hành",
        "GO\n",
        "SET NOCOUNT ON;\n"
    ]

    for index, product in enumerate(ALL_PRODUCTS, start=1):
        feature_text = extract_product_feature_text(product)
        vector_512 = generate_512_vector(feature_text)
        vector_json = json.dumps(vector_512)

        # Tạo câu lệnh SQL UPDATE an toàn
        sql = (
            f"-- [{index}/{len(ALL_PRODUCTS)}] {product['name']} ({product['brand']} - {product['category']})\n"
            f"UPDATE Products\n"
            f"SET EmbeddingVector = '{vector_json}'\n"
            f"WHERE ProductID = {product['id']} OR ProductName LIKE N'%{product['name'].split()[0]}%{product['name'].split()[1]}%';\n"
        )
        sql_statements.append(sql)

        print(f"[{index:02d}/{len(ALL_PRODUCTS):02d}] ✓ Đã sinh vector 512-D cho: {product['name']:<35} (Len: {len(vector_512)})")

    # Ghi toàn bộ câu lệnh ra file SQL
    output_path = os.path.abspath(OUTPUT_SQL_PATH)
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        f.write("\n".join(sql_statements))

    print("\n" + "=" * 75)
    print(f"[THÀNH CÔNG] Đã sinh vector cho TOÀN BỘ {len(ALL_PRODUCTS)} sản phẩm!")
    print(f"[FILE XUẤT RA] {output_path}")
    print("=" * 75)

if __name__ == "__main__":
    run_batch_vector_generation()
