param(
    [string]$Token = $env:GH_TOKEN
)
$ErrorActionPreference = 'Stop'
$owner = 'oracleC72'
$repo  = 'c-72'
$api   = 'https://api.github.com'
$root  = $PSScriptRoot

if (-not $Token) { throw '缺 token：.\首次上线.ps1 -Token ghp_xxx（或先设 $env:GH_TOKEN）' }
$h = @{
    Authorization = "Bearer $Token"
    Accept        = 'application/vnd.github+json'
    'User-Agent'  = 'c72-publish'
}

# 1) 建仓库（已存在就跳过）
try {
    $body = @{ name = $repo; private = $false; description = 'C-72 自助馆 · 93 款游戏自助馆单页'; auto_init = $false } | ConvertTo-Json
    Invoke-RestMethod -Method Post -Uri "$api/user/repos" -Headers $h -Body $body -ContentType 'application/json' | Out-Null
    Write-Host "仓库已建：$owner/$repo"
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 422 -or $code -eq 409) { Write-Host '仓库已存在，跳过建库' } else { throw }
}

# 2) 推送（token 只走这一次请求头，不写进 git 配置）
$env:GIT_TERMINAL_PROMPT = '0'
$remote = "https://github.com/$owner/$repo.git"
git -C $root remote remove origin 2>$null
git -C $root remote add origin $remote
git -C $root -c "http.extraHeader=Authorization: Bearer $Token" push -u origin main
if ($LASTEXITCODE -ne 0) { throw '推送失败，检查 token 是否有 repo 权限' }

# 3) 打开 Pages（已开就跳过）
try {
    $pb = @{ source = @{ branch = 'main'; path = '/' } } | ConvertTo-Json
    Invoke-RestMethod -Method Post -Uri "$api/repos/$owner/$repo/pages" -Headers $h -Body $pb -ContentType 'application/json' | Out-Null
    Write-Host 'Pages 已开启（main / 根目录）'
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 409) { Write-Host 'Pages 本来就开着，跳过' } else { Write-Warning "Pages 接口返回 $code，去 Settings → Pages 手动选 main / root 即可" }
}

# 4) 等站点真的能打开
$url = "https://$($owner.ToLower()).github.io/$repo/"
for ($i = 1; $i -le 18; $i++) {
    Start-Sleep -Seconds 10
    try {
        $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 20
        if ($r.StatusCode -eq 200) { Write-Host "线上已就绪（第 $($i*10) 秒）：$url"; break }
    } catch {
        Write-Host "第 $($i*10) 秒还没起来，继续等…"
    }
}
Write-Host "站点：$url"
Write-Host '确认能打开后，去 GitHub → Settings → Developer settings 把这个 token 删掉。'
