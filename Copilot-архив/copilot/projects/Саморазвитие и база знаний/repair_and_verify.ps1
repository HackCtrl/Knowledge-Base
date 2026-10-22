$ErrorActionPreference='Stop'
$vault='C:\Users\Кирилл\Documents\Obsidian Vault'
$utf8=[System.Text.UTF8Encoding]::new($false)
$roots=[ordered]@{'SQL'='sql';'Python для кибербезопасности'='python';'1С программирование для начинающих'='bsl'}
$repaired=0
foreach($entry in $roots.GetEnumerator()){
  Get-ChildItem -LiteralPath (Join-Path $vault $entry.Key) -Recurse -File -Filter '*.md'|ForEach-Object{
    $text=[IO.File]::ReadAllText($_.FullName,$utf8)
    $lines=$text -split "`r?`n",-1
    $inside=$false;$changed=$false
    for($i=0;$i -lt $lines.Count;$i++){
      if($lines[$i] -match '^```(?:sql|python|bsl)?\s*$'){
        $desired=if($inside){'```'}else{"```$($entry.Value)"}
        if($lines[$i] -ne $desired){$lines[$i]=$desired;$changed=$true}
        $inside=-not $inside
      }
    }
    if($changed){[IO.File]::WriteAllText($_.FullName,($lines -join "`n"),$utf8);$script:repaired++}
  }
}
[pscustomobject]@{repairedFiles=$script:repaired}|ConvertTo-Json

# Close pre-existing unpaired fences before the navigation footer.
$closed=0
foreach($entry in $roots.GetEnumerator()){
  Get-ChildItem -LiteralPath (Join-Path $vault $entry.Key) -Recurse -File -Filter '*.md'|ForEach-Object{
    $text=[IO.File]::ReadAllText($_.FullName,$utf8)
    $count=([regex]::Matches($text,'(?m)^```')).Count
    if($count % 2 -ne 0){
      if($text -match '(?m)^## Навигация\s*$'){$new=[regex]::Replace($text,'(?m)^## Навигация\s*$',"```\n\n## Навигация",1)}else{$new=$text.TrimEnd()+"`n``` `n"}
      [IO.File]::WriteAllText($_.FullName,$new,$utf8);$closed++
    }
  }
}

# Make the three review-queue links path-explicit to avoid basename ambiguity.
$reviewPath=Join-Path $vault '00 — Навигация\Требует разбора.md'
$review=[IO.File]::ReadAllText($reviewPath,$utf8)
$review=$review.Replace('[[1.1. Знакомство]]','[[1С программирование для начинающих/1. Введение/1.1. Знакомство|1.1. Знакомство]]')
$review=$review.Replace('[[1. Приветственный урок]]','[[SQL/1. Приветственный урок|1. Приветственный урок]]')
$review=$review.Replace('[[1.4. SysMon, Auditd, Osquery. Установка и настройка]]','[[Специалист по противодействию кибератакам/1. Уровень 1. Инфраструктура/1.4. SysMon, Auditd, Osquery. Установка и настройка|1.4. SysMon, Auditd, Osquery. Установка и настройка]]')
[IO.File]::WriteAllText($reviewPath,$review,$utf8)

# Keep local Copilot service data out of the public repository.
$gitignorePath=Join-Path $vault '.gitignore';$gi=[IO.File]::ReadAllText($gitignorePath,$utf8)
if(($gi -split "\r?\n") -notcontains '/copilot/'){$gi=$gi.TrimEnd()+"`n/copilot/`n";[IO.File]::WriteAllText($gitignorePath,$gi,$utf8)}

Write-Output ([pscustomobject]@{closedUnpairedFences=$closed;reviewLinksCorrected=3}|ConvertTo-Json)
