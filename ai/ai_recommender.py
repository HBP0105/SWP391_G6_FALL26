import sys
import io
import pyodbc
import numpy as np
from sentence_transformers import SentenceTransformer

# Đảm bảo console Windows không bị lỗi Unicode charmap cp1252
if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

print("=========================================================")
print("[START] KHOI DONG MODULE AI GOI Y TAI NGHE (512 VECTOR)")
print("=========================================================\n")

# 1. KẾT NỐI VÀO SQL SERVER
conn_str = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost;"
    "DATABASE=HeadphoneSalesDB;"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)

try:
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()
    print("[OK] [1/5] Da ket noi thanh cong toi CSDL HeadphoneSalesDB!")
except Exception as e:
    conn_str_sa = (
        "DRIVER={ODBC Driver 17 for SQL Server};"
        "SERVER=localhost;"
        "DATABASE=HeadphoneSalesDB;"
        "UID=sa;PWD=123456;"
        "TrustServerCertificate=yes;"
    )
    conn = pyodbc.connect(conn_str_sa)
    cursor = conn.cursor()
    print("[OK] [1/5] Da ket noi thanh cong toi CSDL bang tai khoan sa!")

# 2. TẢI MÔ HÌNH AI 512 VECTOR (CLIP-ViT-B-32)
print("[LOAD] [2/5] Dang tai mo hinh AI Embedding (clip-ViT-B-32)...")
model = SentenceTransformer('clip-ViT-B-32')
print("[OK] [2/5] Mo hinh AI 512 chieu da san sang!")

# 3. LẤY SẢN PHẨM TỪ BẢNG PRODUCTS
cursor.execute("""
    SELECT ProductID, ProductName, Description, NoiseCancelling, BatteryLife 
    FROM Products 
    WHERE Status = 'ACTIVE'
""")
products = cursor.fetchall()
print(f"[INFO] [3/5] Da lay thanh cong {len(products)} san pham tu bang Products.")

# 4. TẠO VECTOR 512 CHIỀU CHO TỪNG SẢN PHẨM
print("[PROCESS] [4/5] Dang chuyen doi thong tin tai nghe thanh Vector 512 chieu...")
product_vectors = {}
for p in products:
    anc_text = "Co chong on chu dong ANC." if p.NoiseCancelling == 1 else "Khong chong on."
    desc = p.Description if p.Description else ""
    full_text = f"{p.ProductName}: {desc} {anc_text} Pin {p.BatteryLife} gio."
    
    vec = model.encode(full_text)
    product_vectors[p.ProductID] = vec

print(f"[OK] [4/5] Da ma hoa xong {len(product_vectors)} san pham thanh Vector 512 chieu.")

def cosine_similarity(v1, v2):
    return float(np.dot(v1, v2) / (np.linalg.norm(v1) * np.linalg.norm(v2)))

# 5. TÍNH TOÁN GỢI Ý VÀ LƯU VÀO BẢNG AIRecommendations
print("\n[AI] [5/5] DANG PHAN TICH VA CAP NHAT GOI Y VAO SQL SERVER:")
cursor.execute("""
    SELECT DISTINCT o.CustomerID, c.Email, oi.ProductID, p.ProductName
    FROM Orders o
    JOIN Customers c ON o.CustomerID = c.CustomerID
    JOIN OrderItems oi ON o.OrderID = oi.OrderID
    JOIN Products p ON oi.ProductID = p.ProductID
""")
customer_orders = cursor.fetchall()

inserted_count = 0
for cust in customer_orders:
    cust_id = cust.CustomerID
    email = cust.Email
    bought_pid = cust.ProductID
    bought_pname = cust.ProductName

    bought_vec = product_vectors[bought_pid]
    
    # Tìm sản phẩm tương đồng nhất trong không gian 512 chiều
    scores = []
    for pid, vec in product_vectors.items():
        if pid == bought_pid: continue
        sim = cosine_similarity(bought_vec, vec)
        scores.append((pid, sim))
    
    scores.sort(key=lambda x: x[1], reverse=True)
    best_pid, best_sim = scores[0]

    cursor.execute("SELECT ProductName FROM Products WHERE ProductID = ?", best_pid)
    rec_pname = cursor.fetchone()[0]
    reason = f"Khach hang da mua {bought_pname}. AI 512 vector de xuat {rec_pname} co do tuong dong cao nhat."

    print(f"  -> Khach: {email:<25} | Goi y: {rec_pname:<30} | Do khop: {round(best_sim * 100, 2)}%")

    # Ghi vào bảng AIRecommendations
    cursor.execute("""
        IF NOT EXISTS (SELECT 1 FROM AIRecommendations WHERE CustomerID = ? AND ProductID = ?)
        BEGIN
            INSERT INTO AIRecommendations 
                (CustomerID, SessionID, ProductID, RecommendationType, SimilarityScore, BehaviorScore, FinalScore, Reason, IsClicked, IsPurchased, CreatedAt)
            VALUES 
                (?, 'SESSION-AUTO', ?, 'SIMILAR', ?, ?, ?, ?, 1, 0, GETDATE())
        END
    """, (cust_id, best_pid, cust_id, best_pid, round(best_sim, 5), round(best_sim * 0.9, 5), round(best_sim, 5), reason))
    inserted_count += 1

conn.commit()
conn.close()

print("\n=========================================================")
print(f"[SUCCESS] DA CAP NHAT {inserted_count} GOI Y VAO SQL SERVER!")
print("=========================================================")
