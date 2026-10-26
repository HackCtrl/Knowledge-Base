$ErrorActionPreference='Stop'
$OutputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new()
$vault='C:\Users\Кирилл\Documents\Obsidian Vault'
$utf8=[System.Text.UTF8Encoding]::new($false)
$md=@(Get-ChildItem -LiteralPath $vault -Recurse -File -Filter '*.md' | Where-Object {$_.FullName -notlike "$vault\copilot\*"})
$allFiles=@(Get-ChildItem -LiteralPath $vault -Recurse -File | Where-Object {$_.FullName -notmatch '\\.git\\|\\copilot\\'})
$byBase=@{};foreach($f in $md){$k=$f.BaseName.ToLowerInvariant();if(-not$byBase.ContainsKey($k)){$byBase[$k]=0};$byBase[$k]++}
$fileByName=@{};foreach($f in $allFiles){$fileByName[$f.Name.ToLowerInvariant()]=$true}
$broken=New-Object System.Collections.Generic.List[string]
$missing=New-Object System.Collections.Generic.List[string]
$linkCount=0;$embedCount=0;$oddFences=0
foreach($f in $md){
  $t=[IO.File]::ReadAllText($f.FullName,$utf8)
  if(([regex]::Matches($t,'(?m)^```')).Count % 2 -ne 0){$oddFences++}
  foreach($m in [regex]::Matches($t,'(?<!!)\[\[([^\]|]+)(?:\|[^\]]+)?\]\]')){
    $target=($m.Groups[1].Value -split '#')[0].Trim();if(-not$target -or $target-eq'...'){continue};$linkCount++
    $rel=($target -replace '/','\');$candidate=Join-Path $vault ($rel+'.md');$base=[IO.Path]::GetFileNameWithoutExtension($target).ToLowerInvariant()
    if(-not(Test-Path -LiteralPath $candidate) -and -not$byBase.ContainsKey($base)){$broken.Add($f.FullName.Substring($vault.Length+1)+'|'+$target)}
  }
  foreach($m in [regex]::Matches($t,'!\[\[([^\]|#]+)')){
    $target=$m.Groups[1].Value.Trim();$embedCount++;$name=[IO.Path]::GetFileName($target).ToLowerInvariant();$base=[IO.Path]::GetFileNameWithoutExtension($target).ToLowerInvariant()
    if(-not$fileByName.ContainsKey($name) -and -not$byBase.ContainsKey($base)){$missing.Add($f.FullName.Substring($vault.Length+1)+'|'+$target)}
  }
}
$readme=[IO.File]::ReadAllText((Join-Path $vault 'README.md'),$utf8);$readmeLinks=@([regex]::Matches($readme,'\]\(([^)]+)\)'));$readmeBroken=0
foreach($m in $readmeLinks){$target=$m.Groups[1].Value;if($target -match '^https?://'){continue};$p=Join-Path $vault ([uri]::UnescapeDataString(($target -split '#')[0]));if(-not(Test-Path -LiteralPath $p)){$readmeBroken++}}
$privateNote=Join-Path $vault '90 — Приватное\Работа\Исходные заметки\Рабочие данные и ссылки.md';$privateRedacted=$false
if(Test-Path -LiteralPath $privateNote){
  $t=[IO.File]::ReadAllText($privateNote,$utf8);$privateRedacted=$true
  $labels=@('Ключ VPN','Пароль для удаленного подключения','Название для удаленного подключения','Учетка','Локалка на удаленке админа','Камеры')
  foreach($label in $labels){$m=[regex]::Match($t,'(?m)^- \*\*'+[regex]::Escape($label)+'\*\*[^\r\n]*$');if(-not$m.Success -or -not$m.Value.Contains('<REDACTED>')){$privateRedacted=$false}}
}
$ignored=(git -C $vault check-ignore '90 — Приватное/Работа/Исходные заметки/Рабочие данные и ссылки.md' 2>$null) -ne $null
$status=@(git -C $vault -c core.quotepath=false status --porcelain --untracked-files=all)
$secretStatus=@($status | Where-Object {$_ -match '90 — Приватное|микротик пароли|пароль wifi|пароль тимвьюер|настройка нового ЛО'}).Count
$oldRoots=@('1С программирование для начинающих','Python для кибербезопасности','SQL','АРХИВ. Пройденный курсы. Не актуальные курсы','Кейсы ИБ, Кибербезопасности','Компьютерные сети на примерах - Просто о Сложном (по книге)','Работа','Специалист по кибербезопасности','Специалист по противодействию кибератакам')
$remainingOld=@($oldRoots|Where-Object{Test-Path -LiteralPath (Join-Path $vault $_)})
$navDup=@(Get-ChildItem -LiteralPath (Join-Path $vault '00 — Навигация') -Recurse -File -Filter '*.md'|Group-Object BaseName|Where-Object{$_.Count-gt1})
$result=[ordered]@{MarkdownFiles=$md.Count;TotalFilesExcludingGitAndCopilot=$allFiles.Count;WikilinksChecked=$linkCount;BrokenWikilinks=$broken.Count;EmbedsChecked=$embedCount;MissingEmbeds=$missing.Count;OddCodeFences=$oddFences;ReadmeLocalLinks=$readmeLinks.Count;ReadmeBrokenLinks=$readmeBroken;PrivateNoteRedacted=$privateRedacted;PrivateAreaIgnoredByGit=$ignored;SensitivePathsVisibleInGitStatus=$secretStatus;OldTopLevelRootsRemaining=$remainingOld.Count;DuplicateNamesInsideNavigation=$navDup.Count}
$result|ConvertTo-Json
if($broken.Count){'BROKEN';$broken|Sort-Object -Unique}
if($missing.Count){'MISSING';$missing|Sort-Object -Unique}
if($remainingOld.Count){'OLD_ROOTS';$remainingOld}
