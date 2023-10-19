# CHANGELOG

## [0.1.4] - 19/10/2023

- Thêm các phương thức `requestTaskPerm` và `setDesktopBgImagePath`.
- Thay đổi ảnh nền mặc định từ `ufo.jpg` sang `gradient.jpg`.
- Các tin nhắn loại `tf` và `ta` bây giờ khi gửi sẽ trả về Promise, đợi phía nhận phản hồi, nhưng không phải phản hồi trả về dữ liệu, mà chỉ là để bên gửi biết là bên nhận đã nhận được.
- Thêm trường `admin` trong khai báo `app.yml`.
- Bỏ trường `appDataPath` trong khai báo `app.yml`, chỉ dùng trường `path`.
- Thêm thuộc tính `size` cho component `Icon`.
