param(
    [string]$Message = ''
)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

$latest = Get-ChildItem -LiteralPath $root -Filter 'C-72自助馆_v*.html' |
    Sort-Object { [version]($_.BaseName -replace '^C-72自助馆_v', '') } -Descending |
    Select-Object -First 1
if (-not $latest) { throw '没找到版本文件：C-72自助馆_vX.Y.html' }

Copy-Item -LiteralPath $latest.FullName -Destination (Join-Path $root 'index.html') -Force
Write-Host "已把 $($latest.Name) 复制成 index.html"

git -C $root add index.html
if (-not $Message) { $Message = "发布 $($latest.BaseName)" }
$staged = git -C $root diff --cached --name-only
if (-not $staged) {
    Write-Host 'index.html 没有变化，不用提交'
} else {
    git -C $root commit -m $Message | Out-Null
    Write-Host "已提交：$Message"
}

git -C $root push
Write-Host '已推送，1-2 分钟后线上更新：https://oraclec72.github.io/c-72/'
