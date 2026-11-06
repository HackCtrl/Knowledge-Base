<%*
const title = (await tp.system.prompt("Проверяемый сценарий", "Ручная проверка"))?.trim() || "Ручная проверка";
const safeTitle = title.replace(/[\\/:]/g, "-");
await tp.file.rename(`QA — ${safeTitle}`);
-%>
---
тип: ручной qa
статус: подготовлен
исполнитель: владелец
создано: <% tp.date.now("YYYY-MM-DD") %>
обновлено: <% tp.date.now("YYYY-MM-DD") %>
теги:
  - dtek
  - qa
---

# <% title %>

## Окружение

- Дата:
- Браузер или устройство:
- Тестовая роль:
- Тестовая организация:

## Предусловия

## Шаги

1. <% tp.file.cursor() %>

## Ожидается

## Получено

## Результат

- [ ] PASS
- [ ] FAIL
- [ ] BLOCKED

## Доказательство

## Замечание для Codex
