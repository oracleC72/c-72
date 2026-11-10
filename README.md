# C-72 自助馆

一个单文件的游戏自助馆页面（93 款，图标 / 海报 / 竖卡全部 base64 内嵌在 HTML 里，不依赖外部图床）。

## 线上地址

- 站点：https://oraclec72.github.io/c-72/
- 仓库：https://github.com/oraclec72/c-72 （分支 `main`，GitHub Pages 从根目录发布）

## 这个文件夹里都是什么

| 路径 | 作用 | 进仓库 |
|---|---|---|
| `index.html` | **线上版**，GitHub Pages 唯一入口，内容 = 当前版本文件的完整副本 | ✅ |
| `C-72自助馆_vX.Y.html` | 本地版本文件（当前是 `v3.15`），改版时改这个 | ❌ |
| `旧版本/` | 历史版本归档（`v0.9` → `v3.14`，含早前 deepseek 备份与过程文档） | ❌ |
| `原图_20261110/` | 原始素材与裁切后的横图 / 竖卡 / 图标 | ❌ |
| `预览/`、`交接文档.md`、`问题修改.txt` 等 | 本地工作资料 | ❌ |

`index.html` 一旦和版本文件不一致，线上就是旧内容——所以别手改 `index.html`，用下面的发布脚本。

## 改一版的流程

1. 在 `C-72自助馆_v3.15.html` 上改出 `C-72自助馆_v3.16.html`（新版本号，别覆盖旧文件）。
2. 把上一版挪进 `旧版本/`（保持根目录只有最新一版）。
3. 在本文件夹执行：

```powershell
.\发布.ps1                  # 自动把最新版本复制成 index.html、提交、推送
.\发布.ps1 -Message "修 les 标签"   # 想自己写提交说明时
```

4. 等 1–2 分钟，GitHub Pages 构建完就会更新（仓库页 Actions 标签能看到进度）。

本地想先看效果：直接双击 `index.html` 或 `C-72自助馆_v3.15.html` 都一样能开，不用起服务器。

## 体积说明

单文件约 50 MB。每发布一次，git 历史就多 50 MB；发布十几次后仓库会接近 1 GB 的软上限。到那时可以把历史压成一条（会丢掉旧提交记录，站点内容不受影响）：

```powershell
git checkout --orphan fresh
git add index.html README.md .nojekyll .gitattributes
git commit -m "重建历史：只保留当前站点"
git branch -D main
git branch -m main
git push -f origin main
```

## 首次部署备忘

- 仓库 `oraclec72/c-72`，公开（Pages 免费版需要公开仓库）。
- Settings → Pages：Source = `Deploy from a branch`，Branch = `main` / `/ (root)`。
- 根目录的 `.nojekyll` 别删，否则 Jekyll 会去处理这个 50 MB 的文件。

首次上线（只需跑一次）：本地仓库已经 init + commit 好了，`origin` 也指向 `oraclec72/c-72`，只差权限。拿到 classic PAT（勾 `repo`）后：

```powershell
.\首次上线.ps1 -Token ghp_xxxx           # 建库 + 推送 + 开 Pages + 等站点能打开
```

跑完记得回 GitHub 把那个 token revoke 掉。
