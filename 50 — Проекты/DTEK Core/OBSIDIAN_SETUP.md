---
title: Obsidian Setup
type: setup-guide
status: active
updated: 2026-10-26
tags:
  - dtek
  - obsidian
---

# Настройка Obsidian

## Открыть Проект

1. Откройте существующий Vault `/Users/a000/Documents/Courses`.
2. В разделе `50 — Проекты` откройте [[50 — Проекты/DTEK Core|DTEK Core]].
3. Перейдите в [[50 — Проекты/DTEK Core/00_START_HERE|DTEK Project Control Center]].
4. Закрепите стартовую страницу через `Pin`.

Код остаётся в `/Users/a000/Documents/DTEK Core`. Каталог `Репозиторий`
содержит только локальные символические ссылки на актуальные `docs/`, `tasks/`
и основные документы. Он не создаёт вторую копию проектной документации.

## Рекомендуемые Community Plugins

Установите через `Settings -> Community plugins -> Browse`:

1. **Kanban** — доски из файлов `50 — Проекты/DTEK Core/boards/`.
2. **Dataview** — автоматические выборки по metadata.
3. **Tasks** — сроки, фильтры и task queries.
4. **Obsidian Git** — опционально; используйте только если понимаете текущий Git workflow.

Начните с Kanban. Все файлы остаются читаемыми и без плагинов.

## Безопасные Настройки Git

- Vault и DTEK Core являются разными Git-репозиториями.
- Не выполняйте автоматический commit/push одновременно с работающим Codex.
- Перед ручным изменением убедитесь, что предыдущая задача завершена.
- Не используйте force push или reset.
- Не коммитьте secrets, `.env.local` и личные вложения.
- Локальные layout/workspace настройки Obsidian можно оставить вне Git.
- Изменения Vault коммитьте отдельно только после разрешения существующих
  конфликтов в его Git-истории.

## Вложения

Для будущих схем и изображений создавайте вложения только в согласованной папке
и не сохраняйте туда клиентские evidence, credentials или персональные данные.
Mermaid-схемы предпочтительны: они текстовые, редактируются и версионируются.

## Работа С Досками

После установки Kanban откройте:

- [[50 — Проекты/DTEK Core/boards/DEVELOPMENT_BOARD|Development Board]];
- [[50 — Проекты/DTEK Core/boards/IDEAS_AND_RESEARCH|Ideas & Research]];
- [[50 — Проекты/DTEK Core/boards/BUGS_AND_QA|Bugs & QA]];
- [[50 — Проекты/DTEK Core/boards/RISKS_AND_BLOCKERS|Risks & Blockers]];
- [[50 — Проекты/DTEK Core/boards/DESIGN_BOARD|Design Board]].

Карточки можно переносить мышью. Не переносите задачу в `Done`, пока нет
фактических проверок, commit и push.
