$ErrorActionPreference='Stop'
$vault='C:\Users\Кирилл\Documents\Obsidian Vault'
$utf8=[System.Text.UTF8Encoding]::new($false)

function Move-Safe([string]$from,[string]$to){
  $src=Join-Path $vault $from;$dst=Join-Path $vault $to
  if(Test-Path -LiteralPath $src){
    $dir=Split-Path -Parent $dst;if(-not(Test-Path -LiteralPath $dir)){[IO.Directory]::CreateDirectory($dir)|Out-Null}
    if(Test-Path -LiteralPath $dst){throw "Target exists: $to"}
    Move-Item -LiteralPath $src -Destination $dst
  }
}

# Remove ambiguous basenames by clarifying their role; no content is deleted.
Move-Safe '00 — Навигация\03 — Практика и работа\Проекты.md' '00 — Навигация\03 — Практика и работа\Карта проектов.md'
Move-Safe '90 — Приватное\Работа\Исходные заметки\Работа.md' '90 — Приватное\Работа\Исходные заметки\Рабочие данные и ссылки.md'

$projectMap=Join-Path $vault '00 — Навигация\03 — Практика и работа\Карта проектов.md'
if(Test-Path -LiteralPath $projectMap){
  $t=[IO.File]::ReadAllText($projectMap,$utf8).Replace('# Проекты','# Карта проектов')
  [IO.File]::WriteAllText($projectMap,$t,$utf8)
}

# Put the only root-level pasted image next to its consuming course material.
Move-Safe 'Pasted image 20260905130017.png' '20 — Обучение\Активные курсы\Специалист по кибербезопасности\Модуль 11. Аудит\Изображения\Pasted image 20260905130017.png'

# Update README structure to match the current taxonomy.
$readme=Join-Path $vault 'README.md';$t=[IO.File]::ReadAllText($readme,$utf8)
$old=@'
- `00 — Навигация` — главная страница, карты направлений и содержание курсов;
- `10 — База знаний` — краткие обобщённые заметки по понятиям и технологиям;
- исходные папки курсов — конспекты, задания и лабораторные работы;
- `99 — Шаблоны` — единые шаблоны заметок;
- `АРХИВ...` — завершённые и неактуальные курсы, сохранённые как источники.
'@
$new=@'
- `00 — Навигация` — главная страница, карты направлений, содержание курсов и управление базой;
- `10 — База знаний` — обобщённые заметки по понятиям и технологиям;
- `20 — Обучение` — активные и архивные курсы;
- `30 — Практика и кейсы` — лабораторные, задания и решения;
- `40 — Работа` — публично безопасные профессиональные материалы;
- `50 — Проекты` — проектные карты без конфиденциальных данных;
- `90 — Приватное` — локальные материалы, полностью исключённые из Git;
- `99 — Шаблоны` — единые шаблоны заметок.
'@
$t=$t.Replace($old,$new)
[IO.File]::WriteAllText($readme,$t,$utf8)

# Link the project map explicitly from the project index.
$projects=Join-Path $vault '50 — Проекты\Проекты.md';$t=[IO.File]::ReadAllText($projects,$utf8)
if($t-notmatch '\[\[Карта проектов\]\]'){$t=$t.TrimEnd()+"`n`n## Дополнительная навигация`n`n- [[Карта проектов]]`n"}
[IO.File]::WriteAllText($projects,$t,$utf8)

[pscustomobject]@{finalized=$true}|ConvertTo-Json
