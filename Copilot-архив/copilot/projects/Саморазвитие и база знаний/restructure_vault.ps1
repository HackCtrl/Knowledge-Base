$ErrorActionPreference='Stop'
$vault='C:\Users\Кирилл\Documents\Obsidian Vault'
$utf8=[System.Text.UTF8Encoding]::new($false)
$moves=New-Object System.Collections.Generic.List[object]
$updated=0

function Ensure-Dir([string]$relative){$p=Join-Path $vault $relative;if(-not(Test-Path -LiteralPath $p)){[IO.Directory]::CreateDirectory($p)|Out-Null}}
function Move-Safe([string]$from,[string]$to){
  $src=Join-Path $vault $from;$dst=Join-Path $vault $to
  if(-not(Test-Path -LiteralPath $src)){return}
  if(Test-Path -LiteralPath $dst){throw "Target exists: $to"}
  Ensure-Dir (Split-Path -Parent $to)
  Move-Item -LiteralPath $src -Destination $dst
  $script:moves.Add([pscustomobject]@{From=$from;To=$to})
}
function Write-Note([string]$relative,[string]$content){
  $p=Join-Path $vault $relative;Ensure-Dir(Split-Path -Parent $relative);[IO.File]::WriteAllText($p,$content.TrimEnd()+"`n",$utf8)
}

# Stable top-level taxonomy.
@('20 — Обучение\Активные курсы','20 — Обучение\Архив курсов','30 — Практика и кейсы','40 — Работа','50 — Проекты','90 — Приватное\Работа\Секреты','90 — Приватное\Работа\Файлы','00 — Навигация\01 — Карты направлений','00 — Навигация\02 — Курсы','00 — Навигация\03 — Практика и работа','00 — Навигация\04 — Управление базой','10 — База знаний\Информационная безопасность','10 — База знаний\Компьютерные сети')|ForEach-Object{Ensure-Dir $_}

# Active courses and archive.
$courseMoves=[ordered]@{
 '1С программирование для начинающих'='20 — Обучение\Активные курсы\1С программирование для начинающих'
 'Python для кибербезопасности'='20 — Обучение\Активные курсы\Python для кибербезопасности'
 'SQL'='20 — Обучение\Активные курсы\SQL'
 'Компьютерные сети на примерах - Просто о Сложном (по книге)'='20 — Обучение\Активные курсы\Компьютерные сети на примерах - Просто о Сложном (по книге)'
 'Специалист по кибербезопасности'='20 — Обучение\Активные курсы\Специалист по кибербезопасности'
 'Специалист по противодействию кибератакам'='20 — Обучение\Активные курсы\Специалист по противодействию кибератакам'
 'АРХИВ. Пройденный курсы. Не актуальные курсы'='20 — Обучение\Архив курсов\Материалы курсов'
 'Кейсы ИБ, Кибербезопасности'='30 — Практика и кейсы\Кейсы ИБ и кибербезопасности'
}
foreach($m in $courseMoves.GetEnumerator()){Move-Safe $m.Key $m.Value}

# Knowledge notes grouped by subject.
@('Сегментация сети.md','DMZ.md','SIEM.md','Анализ журналов.md')|ForEach-Object{Move-Safe ("10 — База знаний\$_") ("10 — База знаний\Информационная безопасность\$_")}
@('Модель OSI.md','Стек TCP-IP.md')|ForEach-Object{Move-Safe ("10 — База знаний\$_") ("10 — База знаний\Компьютерные сети\$_")}

# Navigation grouped by function.
$areaPages=@('Информационная безопасность.md','Противодействие кибератакам.md','Компьютерные сети.md','SIEM, журналы событий и мониторинг.md','Системное администрирование.md','Python для кибербезопасности.md','SQL и базы данных.md','Программирование в 1С.md')
foreach($n in $areaPages){Move-Safe ("00 — Навигация\$n") ("00 — Навигация\01 — Карты направлений\$n")}
Get-ChildItem -LiteralPath (Join-Path $vault '00 — Навигация') -File -Filter '* — содержание.md' | ForEach-Object {Move-Safe ("00 — Навигация\$($_.Name)") ("00 — Навигация\02 — Курсы\$($_.Name)")}
@('Практические и лабораторные работы.md','Рабочие материалы.md','Проекты.md')|ForEach-Object{Move-Safe ("00 — Навигация\$_") ("00 — Навигация\03 — Практика и работа\$_")}
@('Требует разбора.md','Правила ведения базы.md','Отчёт о реорганизации базы.md')|ForEach-Object{Move-Safe ("00 — Навигация\$_") ("00 — Навигация\04 — Управление базой\$_")}
Move-Safe '00 — Навигация\DTEK Core.md' '50 — Проекты\DTEK Core.md'
Move-Safe '00 — Навигация\CyberWhale.md' '50 — Проекты\CyberWhale.md'

# Private work materials: preserve every file, but keep them outside public Git.
Move-Safe 'Работа' '90 — Приватное\Работа\Исходные заметки'
@('микротик пароли 1.txt','микротик пароли.txt','пароль wifi.txt','пароль тимвьюер.txt')|ForEach-Object{Move-Safe $_ ("90 — Приватное\Работа\Секреты\$_")}
Move-Safe 'настройка нового ЛО.7z' '90 — Приватное\Работа\Файлы\настройка нового ЛО.7z'

# Redact direct credentials from the Markdown note while retaining its useful structure.
$workPrivate=Join-Path $vault '90 — Приватное\Работа\Исходные заметки\Работа.md'
if(Test-Path -LiteralPath $workPrivate){
  $t=[IO.File]::ReadAllText($workPrivate,$utf8)
  $t=[regex]::Replace($t,'(?m)^- \*\*Ключ vpn\*\*\s*-.*$','- **Ключ VPN** — `<REDACTED>`')
  $labels=@('Пароль для удаленного подключения','Название для удаленного подключения','Учетка','Локалка на удаленке админа','Камеры')
  foreach($label in $labels){
    $pattern='(?m)^- \*\*'+[regex]::Escape($label)+'\*\*\s*-.*$'
    $replacement='- **'+$label+'** — `<REDACTED>`'
    $t=[regex]::Replace($t,$pattern,$replacement)
  }
  $t=[regex]::Replace($t,'(?m)^- \[(?:10\.|172\.(?:1[6-9]|2\d|3[01])\.|192\.168\.)[^\r\n]+$','- `<REDACTED>`')
  if($t -notmatch '^---\r?\n'){
    $header=@'
---
type: work-reference
status: active
visibility: private
tags: [work/private]
aliases: []
---

# Рабочие данные и ссылки

> [!warning] Приватный материал
> Файл исключён из Git. Не переносить его содержимое в публичные заметки.

'@
    $t=$header+$t
  }
  [IO.File]::WriteAllText($workPrivate,$t,$utf8)
}

# Update path-qualified links and plain path references after moving directories.
$prefixMap=[ordered]@{}
foreach($m in $courseMoves.GetEnumerator()){$prefixMap[($m.Key -replace '\\','/')]=$m.Value -replace '\\','/'}
$allMd=Get-ChildItem -LiteralPath $vault -Recurse -File -Filter '*.md' | Where-Object {$_.FullName -notlike "$vault\copilot\*"}
foreach($f in $allMd){
  $t=[IO.File]::ReadAllText($f.FullName,$utf8);$new=$t
  foreach($m in $prefixMap.GetEnumerator()){$new=$new.Replace($m.Key+'/',$m.Value+'/').Replace($m.Key+'\',$m.Value+'\')}
  if($new-ne$t){[IO.File]::WriteAllText($f.FullName,$new,$utf8);$updated++}
}

# Category indexes.
Write-Note '10 — База знаний\База знаний.md' @'
---
type: area-index
status: active
tags: [navigation/knowledge]
aliases: []
---

# База знаний

Обобщённые профессиональные заметки раскрывают понятия независимо от конкретного курса и ссылаются на первичные конспекты.

## Информационная безопасность

- [[Сегментация сети]]
- [[DMZ]]
- [[SIEM]]
- [[Анализ журналов]]

## Компьютерные сети

- [[Модель OSI]]
- [[Стек TCP-IP]]

## Карты направлений

- [[Информационная безопасность]]
- [[Противодействие кибератакам]]
- [[Компьютерные сети]]
- [[SIEM, журналы событий и мониторинг]]
- [[Системное администрирование]]
- [[Python для кибербезопасности]]
- [[SQL и базы данных]]
- [[Программирование в 1С]]

Новые обобщения создаются, когда тема встречается в нескольких источниках или регулярно применяется на практике.
'@

Write-Note '20 — Обучение\Обучение.md' @'
---
type: area-index
status: active
tags: [navigation/learning]
aliases: []
---

# Обучение

## Активные курсы

- [[Специалист по кибербезопасности — содержание]]
- [[Специалист по противодействию кибератакам — содержание]]
- [[Компьютерные сети на примерах — содержание]]
- [[Python для кибербезопасности — содержание]]
- [[SQL — содержание]]
- [[1С для начинающих — содержание]]

## Практика

- [[Кейсы SkillFactory — содержание]]
- [[Практические и лабораторные работы]]

## Архив

- [[Архив курсов — содержание]]

Курсовые конспекты сохраняют структуру источника. Итоговые понятия и технологии выносятся в [[База знаний|обобщённую базу знаний]].
'@

Write-Note '30 — Практика и кейсы\Практика и кейсы.md' @'
---
type: area-index
status: active
tags: [navigation/practice]
aliases: []
---

# Практика и кейсы

- [[Практические и лабораторные работы]]
- [[Кейсы SkillFactory — содержание]]
- [[Решение — разведка организации]]
- [[Решение — сетевая сегментация]]

## Стандарт результата

Цель → исходные условия → ход выполнения → результат → проверка → собственный вывод.

Практические заметки связываются с соответствующим курсом и профессиональной картой направления.
'@

Write-Note '40 — Работа\Работа.md' @'
---
type: area-index
area: work
status: active
visibility: public-safe
tags: [navigation/work]
aliases: []
---

# Работа

Публично безопасная точка входа для профессиональных материалов и технической поддержки.

## Направления

- типовые обращения и диагностика;
- проверенные инструкции;
- рабочие сценарии 1С;
- системное и сетевое администрирование;
- выводы по инцидентам без персональных и внутренних данных.

## Связанные разделы

- [[Рабочие материалы]]
- [[Системное администрирование]]
- [[Проекты]]

> [!warning] Приватные материалы
> Учётные данные, внутренние адреса, закрытые ссылки и рабочие файлы хранятся в `90 — Приватное`, исключённом из Git. Они не переносятся в публичные конспекты.
'@

Write-Note '50 — Проекты\Проекты.md' @'
---
type: area-index
area: projects
status: active
visibility: private
tags: [navigation/projects]
aliases: []
---

# Проекты

- [[DTEK Core]]
- [[CyberWhale]]
- [[Практика и кейсы|Учебные проекты и кейсы]]

Для каждого проекта используются разделы: обзор, архитектура, документация, решения, задачи, журнал изменений и итоги. Конфиденциальные материалы остаются в приватной области.
'@

Write-Note '90 — Приватное\README.md' @'
# Приватная область

Этот каталог исключён из Git и предназначен для локальных рабочих материалов, которые нельзя публиковать.

- Не добавлять содержимое каталога в публичную навигацию или README репозитория.
- Не копировать секреты в учебные заметки.
- При переносе полезной информации обезличивать адреса, учётные данные и внутренние ссылки.
- Реальные секреты хранить в специализированном менеджере паролей; этот каталог считать временным локальным хранилищем.
'@

# Rewrite Home around the new stable hierarchy.
Write-Note '00 — Навигация\Главная.md' @'
---
type: home
status: active
tags: [navigation/home]
aliases: [Стартовая страница]
---

# База знаний IT-специалиста и специалиста по информационной безопасности

Система объединяет профессиональные знания, обучение, практику, работу и проекты. Курсовые материалы сохраняют контекст источника, а [[База знаний]] связывает повторяющиеся понятия и технологии.

## Основные разделы

- [[База знаний]] — обобщённые понятия и технологии;
- [[Обучение]] — активные и архивные курсы;
- [[Практика и кейсы]] — лабораторные, задания и решения;
- [[Работа]] — публично безопасные профессиональные материалы;
- [[Проекты]] — DTEK Core, CyberWhale и учебные проекты.

## Профессиональные направления

- [[Информационная безопасность]]
- [[Противодействие кибератакам]]
- [[Компьютерные сети]]
- [[SIEM, журналы событий и мониторинг]]
- [[Системное администрирование]]
- [[Python для кибербезопасности]]
- [[SQL и базы данных]]
- [[Программирование в 1С]]

## Быстрый доступ

- [[Карта базы знаний]]
- [[Практические и лабораторные работы]]
- [[Архив курсов — содержание]]
- [[Требует разбора]]
- [[Правила ведения базы]]
- [[Учебная заметка|Шаблон учебной заметки]]

## Требует внимания

- [[Требует разбора|Очередь неразобранных и незавершённых материалов]]
- заполнение страниц проектов фактическими безопасными сведениями;
- перенос повторяющихся понятий из курсов в обобщённые заметки по мере изучения.

## Правила

1. Не хранить секреты и персональные данные в публичной части.
2. Не копировать целые конспекты в обобщённые заметки.
3. Связывать курс, тему, практику и профессиональное применение.
4. Новые учебные заметки оформлять по [[Учебная заметка|шаблону]].
5. Спорные и незавершённые материалы направлять в [[Требует разбора]].
'@

# Update work/navigation MOC after private split.
$workMoc=Join-Path $vault '00 — Навигация\03 — Практика и работа\Рабочие материалы.md'
if(Test-Path -LiteralPath $workMoc){
  $t=[IO.File]::ReadAllText($workMoc,$utf8)
  if($t-notmatch '\[\[Работа\]\]'){$t=$t.TrimEnd()+"`n`n## Точка входа`n`n- [[Работа]]`n"}
  $t=$t.Replace('status: planned','status: active')
  [IO.File]::WriteAllText($workMoc,$t,$utf8)
}

# README links after navigation-page moves.
$readme=Join-Path $vault 'README.md'
if(Test-Path -LiteralPath $readme){
  $t=[IO.File]::ReadAllText($readme,$utf8)
  $t=$t.Replace('00%20%E2%80%94%20Навигация/Информационная%20безопасность.md','00%20%E2%80%94%20Навигация/01%20%E2%80%94%20Карты%20направлений/Информационная%20безопасность.md')
  $t=$t.Replace('00%20%E2%80%94%20Навигация/Компьютерные%20сети.md','00%20%E2%80%94%20Навигация/01%20%E2%80%94%20Карты%20направлений/Компьютерные%20сети.md')
  $t=$t.Replace('00%20%E2%80%94%20Навигация/Практические%20и%20лабораторные%20работы.md','00%20%E2%80%94%20Навигация/03%20%E2%80%94%20Практика%20и%20работа/Практические%20и%20лабораторные%20работы.md')
  [IO.File]::WriteAllText($readme,$t,$utf8)
}

# Git exclusions for the private area and local secret formats.
$gitignore=Join-Path $vault '.gitignore';$gi=if(Test-Path -LiteralPath $gitignore){[IO.File]::ReadAllText($gitignore,$utf8)}else{''}
@('/90 — Приватное/','*.7z','*парол*.txt','*password*.txt') | ForEach-Object { if(($gi -split "\r?\n") -notcontains $_){$gi=$gi.TrimEnd()+"`n$_`n"} }
[IO.File]::WriteAllText($gitignore,$gi,$utf8)

[pscustomobject]@{Moved=$moves.Count;UpdatedPathReferences=$updated;Moves=$moves}|ConvertTo-Json -Depth 4
