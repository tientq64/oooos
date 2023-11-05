# CHANGELOG

## [0.3.0] - 05/11/2023

- Viết lại hàm `Both::import`, thay vì dùng `eval` thực thi JS và dùng thẻ `style` thêm CSS như trước, bây giờ sẽ thêm thẻ `script` và `link` với URL.
- Thêm các component: `Checkbox`, `Radio`.
- Thêm các app: `CodeEditor`, `ImageViewer`, `OpenWith`, `Popup`.
- App `Terminal`: Thêm lệnh `help` cơ bản (đang làm); đổi icon của app.
- App `Test`: Viết thêm nhiều test.
- App `FileManager`: Thêm "Mở bằng" vào contextmenu với các ứng dụng có thể mở.
- Thêm các trường `useContentSize`, `isModal`, `hidden`, `openEntsSameTask` trong khai báo app.
- App `OS`: Đổi icon từ `kiwi-bird` thành `egg-fried`. Xóa thuộc tính `exts`, `exts` mục đích là để quản lý phần mở rộng tập tin nhưng bây giờ sử dụng thuộc tính `supportedExts` của app là đủ. Thêm quản lý trạng thái pin.
- Component `Both` thêm các hàm: `indent`, `escapeHtml`, `uniqueArr`, `uniqueNewArr`, `castObj`, `castNewObj`, `formatTooltip`, `wait`, `waitVar`.
- Thêm tooltip. Điều này cũng thêm event `mouseover` vào global event.
- Component `Menu`: Thêm thuộc tính `value` (controlled), xác định item nào được active. Điều này cũng thêm thuộc tính `value` vào item. Cũng thêm thuộc tính `enabled` (ngược lại của `disabled`) vào item.
- Sửa component `Menubar` và code liên quan vì nhầm thuộc tính `subitems` của item thành `items`.
- Lỗi thỉnh thoảng desktop có chạy nhưng không tải được và treo, chỉ khi mở một task mới bất kỳ thì nó mới tải và hoạt động như bình thường. Xem thuộc tính `srcdoc` của iframe thì thấy html chỉ hiện đến đoạn thẻ `meta charset`. Hiện chưa thể biết nguyên nhân tại sao và cách khắc phục.
- Component `Task`: Thêm thuộc tính `env`. Dự định để bỏ các thuộc tính có dấu $ ở cuối, thay vào đó dựa vào `env` để update các thuộc tính tương ứng. Cũng thêm thuộc tính `parentTask` để biết task nào là task cha của task này, thông thường là task khởi chạy nhưng có thể gán cho một task khác khi run. Thuộc tính `noHeader` bây giờ sẽ không tính toán dựa vào thuộc tính `fullscreen` nữa, mà dùng hàm `getNoHeader` thay thế. Cũng thêm các thuộc tính và hàm khác nữa.
- Thêm loại app `core`, loại app này sẽ chạy ngay trong main, không phải trong iframe. Điều này giúp app tải và chạy nhanh hơn đáng kể. Và vì chạy trong main nên app có thể truy cập vào toàn bộ hđh.
- Khắc phục một vài text hiển thị không sắc nét, bằng cách thêm CSS background.
- Cải thiện fullscreen animation, thay easing bằng các biến Stylus.
- Cải thiện dark mode.

## [0.2.0] - 22/10/2023

- Thêm component `Menubar`, `Textarea`.
- Viết thêm hoàn thiện dần phương thức `Task::openEnt`.
- Thêm tính năng ghim app vào taskbar, danh sách task trong taskbar cũng được viết lại cho phù hợp.
- Thêm tính năng đổi vị trí cho taskbar, hiện tại chỉ có `bottom` và `top`.
- Thêm `skipTaskbar`, `supportedExts` trong khai báo app.
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
- Thêm trường `focusable` trong khai báo app.
- Khai báo app của `OS` lấy thông tin từ `package.json`, gần tương tự như `app.yml`. Cũng thêm các trường `version`, `author`, `description`, `license` vào khai báo app nữa.
- Thêm các phương thức `OS::emits`, `Task::emit` giúp việc gửi sự kiện đến phía `Frme` ngắn gọn hơn.
- Thêm phương thức `Task::getVapps` để lấy thông tin cơ bản của `OS::apps`
- Đã có thể tập trung vào các cửa sổ khi bấm vào, hoặc khi bấm vào nút trong taskbar. Thứ tự hiển thị của các cửa sổ được quản lý bằng style `z-index`.
- `Both::createPopper` đổi strategy từ mặc định (`absolute`) sang `fixed`. Điều này để popper có thể hiển thị ngay cả khi nó nằm trong element có style là `overflow: hidden`. Nhưng qua test thử thì thấy nó vẫn bị ẩn, có thể thử lại sau.

## [0.1.4] - 19/10/2023

- Thêm các phương thức `Task::requestTaskPerm` và `Task::setDesktopBgImagePath`.
- Thay đổi ảnh nền mặc định từ `ufo.jpg` sang `gradient.jpg`.
- Các tin nhắn loại `tf` và `ta` bây giờ khi gửi sẽ trả về Promise, đợi phía nhận phản hồi, nhưng không phải phản hồi trả về dữ liệu, mà chỉ là để bên gửi biết là bên nhận đã nhận được.
- Thêm trường `admin` trong khai báo app.
- Bỏ trường `appDataPath` trong khai báo app, chỉ dùng trường `path`.
- Thêm thuộc tính `size` cho component `Icon`.
