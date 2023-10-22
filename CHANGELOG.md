# CHANGELOG

## [0.2.0] - 22/10/2023

- Thêm component `Menubar`, `Textarea`.
- Viết thêm hoàn thiện dần phương thức `Task::openEnt`.
- Thêm tính năng ghim app vào taskbar, danh sách task trong taskbar cũng được viết lại cho phù hợp.
- Thêm tính năng đổi vị trí cho taskbar, hiện tại chỉ có `bottom` và `top`.
- Thêm `skipTaskbar`, `supportedExts` trong khai báo `app.yml`.
- Các phương thức gọi hàm dạng `Both::safe*` sẽ phân làm 2 loại async và sync.
- Các tin nhắn loại `tf` và `ta` bây giờ sẽ đợi hàm bên frme trả về dữ liệu, listener bên frme cũng được sửa lại để có thể trả về dữ liệu. Một trường hợp cụ thể là đóng task, sau đó task sẽ gửi tin nhắn `ta` yêu cầu đóng đến bên frme, bên frme trả về giá trị xác nhận đóng hay không. Ví dụ ứng dụng soạn thảo văn bản khi chưa lưu mà bị đóng, sẽ hiện lên cảnh báo xác nhận.
- Đổi `OS::emits` và `Task::emit` thành `Task::permEmitAll` và `Task:permEmit`, để gửi sự kiện thay đổi thuộc tính đến frme.
- Thêm `Task::emitAll` và `Task::emit` để gửi sự kiện tùy ý đến frme.
- Thêm hàm `Task::onmousedown`.
- Thêm CSS `.Task-titleText` trong `main.styl`.
- `build.ls` dùng thư viện `fs`, không dùng `fs-extra` nữa, vì code hơi thừa.

## [0.1.5] - 21/10/2023

- Cửa sổ đã có thể resize.
- Đổi tên và thêm ảnh nền.
- Thêm `exts` trong `OS` quản lý các phần mở rộng của tập tin.
- Thêm trường `focusable` trong khai báo `app.yml`.
- Khai báo app của `OS` lấy thông tin từ `package.json`, gần tương tự như `app.yml`. Cũng thêm các trường `version`, `author`, `description`, `license` vào khai báo `app.yml` nữa.
- Thêm các phương thức `OS::emits`, `Task::emit` giúp việc gửi sự kiện đến phía `Frme` ngắn gọn hơn.
- Thêm phương thức `Task::getVapps` để lấy thông tin cơ bản của `OS::apps`
- Đã có thể tập trung vào các cửa sổ khi bấm vào, hoặc khi bấm vào nút trong taskbar. Thứ tự hiển thị của các cửa sổ được quản lý bằng style `z-index`.
- `Both::createPopper` đổi strategy từ mặc định (`absolute`) sang `fixed`. Điều này để popper có thể hiển thị ngay cả khi nó nằm trong element có style là `overflow: hidden`. Nhưng qua test thử thì thấy nó vẫn bị ẩn, có thể thử lại sau.

## [0.1.4] - 19/10/2023

- Thêm các phương thức `Task::requestTaskPerm` và `Task::setDesktopBgImagePath`.
- Thay đổi ảnh nền mặc định từ `ufo.jpg` sang `gradient.jpg`.
- Các tin nhắn loại `tf` và `ta` bây giờ khi gửi sẽ trả về Promise, đợi phía nhận phản hồi, nhưng không phải phản hồi trả về dữ liệu, mà chỉ là để bên gửi biết là bên nhận đã nhận được.
- Thêm trường `admin` trong khai báo `app.yml`.
- Bỏ trường `appDataPath` trong khai báo `app.yml`, chỉ dùng trường `path`.
- Thêm thuộc tính `size` cho component `Icon`.
