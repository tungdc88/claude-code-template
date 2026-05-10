# Personal Rules — áp dụng tất cả projects

- Luôn trả lời bằng **tiếng Việt**, kể cả khi câu hỏi bằng tiếng Anh.
- Type hints trên tất cả function signatures. Không dùng `print()` trong production code.
- Catch specific exceptions, không bare `except:`.
- Chỉ thay đổi những gì được yêu cầu. Không refactor xung quanh, không cleanup unrelated.
- Trước khi code: nêu assumption, surface trade-off, đề xuất đơn giản hơn nếu có. Nếu task có nhiều cách hiểu → trình bày các option, không tự chọn ngầm.
- Trước khi code: định nghĩa success criteria có thể verify (test pass / output cụ thể / metric đạt ngưỡng). Tránh "make it work" mơ hồ. Loop code → verify → fix cho đến khi criteria pass.
- Simplicity test: nếu viết 200 dòng mà có thể 50 dòng → viết lại. Không thêm abstraction cho code dùng 1 lần. Không thêm config/flexibility chưa được yêu cầu. Không error handling cho scenario bất khả thi.
- Cuối session: chạy tests → commit → cập nhật progress docs → báo user task tiếp theo.

---

## Hướng dẫn chọn model (đề xuất ở đầu session mới)

**Behavior:** Khi user mô tả task ở turn đầu session, đánh giá độ phức tạp và đề xuất model phù hợp **bằng 1 câu duy nhất** nếu model hiện tại chưa tối ưu. User chuyển bằng `/model <alias>`. Nếu user đã chỉ định rõ model → không đề xuất đổi. Không lặp lại đề xuất trong cùng session.

### Decision matrix

| Loại task | Model đề xuất | Alias | Lý do |
|-----------|---------------|-------|-------|
| Refactor đa file liên kết chặt, kiến trúc hệ thống, debug bug khó, agentic loop dài (>30 phút), reasoning nhiều ràng buộc cùng lúc | **Opus 4.7** | `opus` | Step-change agentic coding, default effort `xhigh`, mạnh nhất hiện tại |
| Cần plan kiến trúc trước rồi mới code | **Opusplan** | `opusplan` | Plan mode = Opus, execute = Sonnet → tiết kiệm token mà vẫn có reasoning sâu khi cần |
| Daily coding, code review, viết tests, sửa bug rõ ràng, phân tích data, tool use thông thường | **Sonnet 4.6** *(default)* | `sonnet` | Đạt 95–99% Opus ở coding, rẻ ~5×, đủ cho 90% task |
| Q&A đơn giản, tóm tắt, format/lint, classify, sub-agent, latency-sensitive, high-volume | **Haiku 4.5** | `haiku` | ~2–3s cho 500 từ (vs Sonnet ~4–5s), rẻ nhất, đủ thông minh cho task đơn giản |
| Codebase >200K tokens (đọc nhiều file lớn cùng lúc, session dài) | thêm hậu tố `[1m]` | `opus[1m]` / `sonnet[1m]` | Mở rộng context lên 1M tokens (Max/Team/Enterprise: Opus 1M included) |

### Quy tắc đề xuất

- **Default = Sonnet 4.6** (Pro/Team Standard/Enterprise/API) hoặc **Opus 4.7** (Max/Team Premium). Nếu Pro/API và task phức tạp → đề xuất `/model opus`.
- **Nâng lên Opus** khi task cần: reasoning sâu nhiều bước, refactor liên kết phức tạp, debug bug khó tái hiện, hoặc agentic loop dài. Opus 4.7 default `xhigh` effort — không cần chỉnh.
- **Hạ xuống Haiku** khi task: đơn giản lặp lại, cần phản hồi nhanh, hoặc dùng làm sub-agent router phân loại request.
- **`opusplan`** là lựa chọn an toàn cho task R&D / quant / kiến trúc hệ thống: dùng Opus reasoning ở plan mode rồi tự chuyển Sonnet để execute → cân bằng chất lượng/chi phí.
- **Effort level** (`/effort low|medium|high|xhigh|max`): chỉ chỉnh khi muốn override. Mặc định Opus 4.7 = `xhigh`, Sonnet 4.6 = `high`. `max` chỉ dùng cho task siêu khó (dễ overthink, không nên default).
- Format đề xuất ngắn gọn ví dụ: *"Task này dạng refactor đa file → cân nhắc `/model opus` để có reasoning sâu hơn."*
