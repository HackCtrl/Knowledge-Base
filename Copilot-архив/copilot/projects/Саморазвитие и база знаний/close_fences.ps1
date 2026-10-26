$ErrorActionPreference='Stop'
$vault='C:\Users\Кирилл\Documents\Obsidian Vault'
$utf8=[System.Text.UTF8Encoding]::new($false)
$closed=0
Get-ChildItem -LiteralPath $vault -Recurse -File -Filter '*.md' | Where-Object {$_.FullName -notlike "$vault\copilot\*"} | ForEach-Object {
  $text=[IO.File]::ReadAllText($_.FullName,$utf8)
  if(([regex]::Matches($text,'(?m)^```')).Count % 2 -ne 0){
    if($text -match '(?m)^## Навигация\s*$'){$new=[regex]::Replace($text,'(?m)^## Навигация\s*$',"```\n\n## Навигация",1)}else{$new=$text.TrimEnd()+"`n``` `n"}
    [IO.File]::WriteAllText($_.FullName,$new,$utf8);$closed++
  }
}
[pscustomobject]@{closed=$closed}|ConvertTo-Json
