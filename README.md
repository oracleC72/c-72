# C-72 自助馆

一个单文件的游戏自助馆页面（93 款，图标 / 海报 / 竖卡全部 base64 内嵌在 HTML 里，不依赖外部图床）。

## 线上地址

- 站点：https://oraclec72.github.io/c-72/
- 仓库：https://github.com/oraclec72/c-72 （分支 `main`，GitHub Pages 从根目录发布）

## 这个文件夹里都是什么

| 路径 | 作用 | 进仓库 |
|---|---|---|
| `index.html` | **线上版**，Pages 唯一入口。内容是版本文件压缩后的结果，别手改 | ✅ |
| `..\本机版本\C-72自助馆_vX.Y.html` | 本地版本文件（当前 `v3.83`（线上 V1.1 就是这一版）），改版改这个，原画质 | ❌ |
| `压缩上线.py` | 把版本文件压成 `index.html`（图片转 WebP，见下） | ✅ |
| `发布.ps1` | 一条命令：选最新版本 → 压缩 → 提交 → 推送 | ✅ |
| `首次上线.ps1` | 建库 + 推送 + 开 Pages，只在第一次用 | ✅ |
| `..\archive\旧版本存档\` | 历史版本归档（`v3.47` 起，含更早的中间版） | ❌ |
| `原图_20261110/` | 原始素材与裁切后的横图 / 竖卡 / 图标 | ❌ |
| `预览/`、`交接文档.md`、`问题修改.txt` 等 | 本地工作资料 | ❌ |

## 改一版 + 发布

1. 在 `..\本机版本\C-72自助馆_v3.83.html` 上改出下一版（新版本号，别覆盖旧文件）。
2. 把上一版挪进 `..\archive\旧版本存档\`，本机版本目录只留最新一版。
3. 发布：

```powershell
.\发布.ps1 -Token ghp_xxxx          # 会自动压缩、提交、推送
.\发布.ps1 -Token ghp_xxxx -Message "修 les 标签"
```

4. 等约 3 分钟，https://oraclec72.github.io/c-72/ 自动更新（仓库 Actions 页能看进度）。

本地看效果：双击 `index.html`（压缩版）或 `..\本机版本\C-72自助馆_v3.83.html`（原画质）都能开，不用起服务器。

## 为什么线上是压缩版

原件 48.7 MB，GitHub Pages 的部署步骤有 10 分钟硬超时：48 MB 的站点每次都卡在 `Deploy to GitHub Pages`，然后 `Timeout reached` / `Deployment cancelled`，站点一直 404（实测 20 MB、23 MB 都能 1–3 分钟上线）。

所以 `压缩上线.py` 把页面里 314 张内嵌 base64 图按「页面实际显示尺寸的 2 倍」重采样、转 WebP q86：48.7 MB → 23.3 MB，版式、反光、字号、排版逻辑全不碰。原画质一直留在 `..\本机版本\` 的最新版本文件和原图库里，随时能回退或换更大的压缩参数。

## 仓库体积

压缩后每次提交约 23.3 MB。推十几次后接近 1 GB 软上限时，可以把历史压成一条（丢旧提交记录，站点内容不受影响）：

```powershell
git checkout --orphan fresh
git add index.html README.md .nojekyll .gitattributes 发布.ps1 首次上线.ps1 压缩上线.py
git commit -m "重建历史：只保留当前站点"
git branch -D main
git branch -m main
git push -f origin main
```

## 首次部署备忘

- 仓库 `oraclec72/c-72`，公开（Pages 免费版需要公开仓库）。
- Settings → Pages：Source = `Deploy from a branch`，Branch = `main` / `/ (root)`。
- 根目录 `.nojekyll` 别删，免得 Jekyll 去啃这个单文件。
- 首次上线：`.\首次上线.ps1 -Token ghp_xxxx`。跑完记得把 token 在 GitHub 上 revoke。

## 两个必须记住的坑

**代理**：这台机器直连 github.com:443 是通的不了（`git push` 报 `Failed to connect ... port 443`），但系统里挂着 `127.0.0.1:10090` 的本地代理。仓库里已写死 `git config http.proxy http://127.0.0.1:10090`，换机器要重新配一次。

**认证**：`git push` 只认 Basic，不认 Bearer——`Authorization: Bearer <token>` 会被 GitHub 回 `remote: invalid credentials`。正确写法由 `发布.ps1` 代劳：

```powershell
$b = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("x-access-token:$Token"))
git -c "http.extraHeader=Authorization: Basic $b" push
```

另外 token 勾 `repo` 就够；要往仓库里加 `.github/workflows/` 下的东西，还得额外勾 `workflow`。
