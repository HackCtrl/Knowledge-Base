$ErrorActionPreference='Stop'
$vault='C:\Users\Кирилл\Documents\Obsidian Vault'
$utf8=[System.Text.UTF8Encoding]::new($false)
$roots=[ordered]@{'SQL'='sql';'Python для кибербезопасности'='python';'1С программирование для начинающих'='bsl'}
$changed=0
foreach($entry in $roots.GetEnumerator()){
  $lang=$entry.Value
  Get-ChildItem -LiteralPath (Join-Path $vault $entry.Key) -Recurse -File -Filter '*.md' | ForEach-Object {
    $text=[IO.File]::ReadAllText($_.FullName,$utf8)
    $lines=New-Object System.Collections.Generic.List[string]
    foreach($l in ($text -split "`r?`n",-1)){$lines.Add($l)}
    $nav=$lines.IndexOf('## Навигация')
    if($nav -lt 0){return}
    # Remove fence artifacts after the navigation heading and links.
    for($i=$lines.Count-1;$i -gt $nav;$i--){if($lines[$i] -match '^```(?:sql|python|bsl)?\s*$'){$lines.RemoveAt($i)}}
    # Remove every trailing blank/fence run before navigation, then restore one closure if needed.
    $nav=$lines.IndexOf('## Навигация')
    $i=$nav-1
    while($i -ge 0 -and ($lines[$i] -match '^\s*$' -or $lines[$i] -match '^```(?:sql|python|bsl)?\s*$')){$lines.RemoveAt($i);$nav--;$i--}
    $inside=$false
    for($i=0;$i -lt $nav;$i++){
      if($lines[$i] -match '^```(?:sql|python|bsl)?\s*$'){
        $lines[$i]=if($inside){'```'}else{'```' + $lang};$inside=-not $inside
      }
    }
    if($inside){$lines.Insert($nav,'```');$nav++}
    $lines.Insert($nav,'')
    $new=($lines -join "`n").TrimEnd()+"`n"
    if($new -ne $text){[IO.File]::WriteAllText($_.FullName,$new,$utf8);$changed++}
  }
}
[pscustomobject]@{cleaned=$changed}|ConvertTo-Json
