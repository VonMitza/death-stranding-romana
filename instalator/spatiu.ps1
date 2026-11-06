param([string]$Path,[double]$NeedGB)
$q=(Get-Item -LiteralPath $Path).PSDrive
$f=[math]::Round($q.Free/1GB,1)
Write-Host "Spatiu liber pe disc: $f GB (necesar: $NeedGB GB)"
if($q.Free/1GB -lt $NeedGB){exit 1}
exit 0
