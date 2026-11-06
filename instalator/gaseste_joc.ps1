param([string]$Out,[string]$Start)
$rel='data\59b95a781c9170b0d13773766e27ad90.bin'
$name='DEATH STRANDING DIRECTORS CUT'
$c=New-Object System.Collections.ArrayList
if($Start){[void]$c.Add($Start)
  try{[void]$c.Add((Split-Path $Start -Parent))}catch{}}
$roots=New-Object System.Collections.ArrayList
foreach($k in 'HKCU:\Software\Valve\Steam','HKLM:\SOFTWARE\WOW6432Node\Valve\Steam','HKLM:\SOFTWARE\Valve\Steam'){
  try{$p=Get-ItemProperty $k -ErrorAction Stop
    if($p.SteamPath){[void]$roots.Add(($p.SteamPath -replace '/','\'))}
    if($p.InstallPath){[void]$roots.Add($p.InstallPath)}}catch{}
}
foreach($r in @($roots)){
  $v=Join-Path $r 'steamapps\libraryfolders.vdf'
  if(Test-Path -LiteralPath $v){
    foreach($m in [regex]::Matches((Get-Content -LiteralPath $v -Raw),'"path"\s+"([^"]+)"')){
      [void]$roots.Add(($m.Groups[1].Value -replace '\\\\','\'))
    }
  }
}
foreach($r in $roots){[void]$c.Add((Join-Path $r "steamapps\common\$name"))}
foreach($d in (Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue)){
  [void]$c.Add((Join-Path $d.Root "SteamLibrary\steamapps\common\$name"))
  [void]$c.Add((Join-Path $d.Root "Steam\steamapps\common\$name"))
}
foreach($g in $c){
  if($g -and (Test-Path -LiteralPath (Join-Path $g $rel))){
    [IO.File]::WriteAllText($Out,$g,[Text.Encoding]::Default);exit 0
  }
}
exit 1
