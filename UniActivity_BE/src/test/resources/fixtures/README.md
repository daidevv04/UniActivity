# Fixtures ảnh cho kiểm thử Karate

`evidence.png` — ảnh PNG 1280×720 (14.5 KB) do nhóm tự tạo bằng script, dùng cho:

- `helpers/image.feature` → TC-040 (nộp 1 ảnh), TC-041 (4 ảnh, vượt giới hạn 3)
- `helpers/big-image.feature` → TC-043 (đọc ảnh này rồi phóng lên 6 MB bằng `Arrays.copyOf`
  để vượt `spring.servlet.multipart.max-file-size=5MB`; không commit file 6 MB vào repo)

Muốn dùng ảnh thật khác (ảnh chụp minh chứng thật): ghi đè `evidence.png` này
(giữ nguyên tên), test tự đọc lại, không cần sửa feature.

Đường dẫn được đọc qua classpath nên không phụ thuộc ổ đĩa máy cá nhân:
`read('classpath:fixtures/evidence.png')`.
