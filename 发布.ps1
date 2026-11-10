param(
    [string]$Message = '',
    [string]$Token = $env:GH_TOKEN
)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

$latest = Get-ChildItem -LiteralPath $root -Filter 'C-72自助馆_v*.html' |
    Sort-Object { [version]($_.BaseName -replace '^C-72自助馆_v', '') } -Descending |
    Select-Object -First 1
if (-not $latest) { throw '没找到版本文件：C-72自助馆_vX.Y.html' }

# 页面里有几百张内嵌图，单文件 40MB+ 时 Pages 部署会超时（实测 48MB 必挂、23MB 正常）。
# 所以线上入口统一走压缩版：图片按显示尺寸 2 倍转 WebP。源版本文件保持原画质不动。
python (Join-Path $root '压缩上线.py') $latest.FullName (Join-Path $root 'index.html')
if ($LASTEXITCODE -ne 0) { throw '压缩失败：检查 python 和 Pillow 是否可用' }

git -C $root add index.html
if (-not $Message) { $Message = "发布 $($latest.BaseName)" }
$staged = git -C $root diff --cached --name-only
if (-not $staged) {
    Write-Host 'index.html 没有变化，不用提交'
} else {
    git -C $root commit -m $Message | Out-Null
    Write-Host "已提交：$Message"
}

if ($Token) {
    # 这个 token 只在本次请求头里用，不落盘
    $b = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("x-access-token:$Token"))
    git -C $root -c "http.extraHeader=Authorization: Basic $b" push
} else {
    git -C $root push
}
Write-Host '已推送，约 3 分钟后线上更新：https://oraclec72.github.io/c-72/'
