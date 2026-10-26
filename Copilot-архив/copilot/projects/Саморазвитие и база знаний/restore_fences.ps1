$ErrorActionPreference='Stop'
$vault='C:\Users\Кирилл\Documents\Obsidian Vault'
$utf8=[System.Text.UTF8Encoding]::new($false)
$roots=[ordered]@{'SQL'='sql';'Python для кибербезопасности'='python';'1С программирование для начинающих'='bsl'}
$changedFiles=0
foreach($entry in $roots.GetEnumerator()){
  $lang=$entry.Value
  Get-ChildItem -LiteralPath (Join-Path $vault $entry.Key) -Recurse -File -Filter '*.md' | ForEach-Object {
    $text=[IO.File]::ReadAllText($_.FullName,$utf8)
    $lines=$text -split "`r?`n",-1
    $out=New-Object System.Collections.Generic.List[string]
    $inside=$false;$changed=$false
    foreach($line in $lines){
      $isNormalFence=$line -match '^```(?:sql|python|bsl)?\s*$'
      $isPsArtifact=$line -match 'System\.Collections\.DictionaryEntry\.Value'
      $isLiteralNavArtifact=$line -match '^`\\n\\n## Навигация\s*$'
      $isSingleTickArtifact=$line -match '^`\s*$'
      if($isNormalFence -or $isPsArtifact -or $isLiteralNavArtifact -or $isSingleTickArtifact){
        if($isLiteralNavArtifact){
          if($inside){$out.Add('```');$inside=$false}else{$out.Add('```' + $lang);$inside=$true;$out.Add('```');$inside=$false}
          $out.Add('');$out.Add('## Навигация');$changed=$true;continue
        }
        if($inside){$desired='```';$inside=$false}else{$desired='```' + $lang;$inside=$true}
        $out.Add($desired)
        if($line -ne $desired){$changed=$true}
      } else {$out.Add($line)}
    }
    if($inside){
      $navIndex=$out.IndexOf('## Навигация')
      if($navIndex -ge 0){$out.Insert($navIndex,'');$out.Insert($navIndex,'```')}else{$out.Add('```')}
      $changed=$true
    }
    if($changed){[IO.File]::WriteAllText($_.FullName,($out -join "`n"),$utf8);$changedFiles++}
  }
}
[pscustomobject]@{restoredFiles=$changedFiles}|ConvertTo-Json
