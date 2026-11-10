# Git 与部署

仓库：`Asura1211/id-tag`，公开。线上：https://nfc.hitlcj.top/。向 main 推送会自动发布，其他分支不会。拥有 main 写权限的人可以触发生产发布；授权协作者前请考虑这一点。仓库中的案例证书和示例信息只用于演示。

让 AI 执行的示例：

> 请先阅读 AGENTS.md 和 docs/deployment.md，检查现有改动，完成我指定的修改并验证；然后提交并推送到 main，等待自动部署结束，核对线上版本。不要包含与本次任务无关的改动。

## 本地和 Git

安装 Git、Python 3、Node.js 和浏览器。使用具备仓库权限的 GitHub 账号克隆仓库，在项目目录运行 `python3 -m http.server 8766 --bind 127.0.0.1`。检查 `git status`，运行 AGENTS.md 的检查，再提交并推送。只提交本次任务的文件，不要覆盖其他人的未提交改动；推送前确认用户已授权生产发布。GitHub Actions 的 Check and deploy ID-Tag 工作流可查看结果。

## 自动发布原理

GitHub Actions 在 main 推送时检查文件，用独立密钥连接服务器的 `idtag-deploy` 受限账号，请求发布本次完整 commit。服务器校验目标是当前 main、取得全局发布锁、拉取仓库并创建只读静态版本，保留旧版，切换站点后验证；失败时恢复上一个版本。服务器发布脚本为 root 管理的 `/usr/local/sbin/idtag-release`，不是直接执行仓库里的任意脚本。版本写入 `/version.json`，可与 Actions 的 commit 对照。PWA 缓存版本由发布脚本根据 commit 注入，无需手工修改。

站点域名 `nfc.hitlcj.top`；Nginx 站点配置 `/etc/nginx/sites-available/nfc.hitlcj.top`，站点的 Nginx 配置对脚本和样式启用 gzip 压缩；静态入口 `/var/www/idtag-live`，版本目录 `/var/www/idtag-releases`。证书续期的 webroot 仍为 `/var/www/idtag-pwa`，不可随意删除。部署依赖服务器出站 GitHub SSH、GitHub 只读 deploy key、Actions secret `IDTAG_DEPLOY_KEY` 和仓库变量 `IDTAG_HOST_KEY`。绝不将密钥写入仓库。服务器执行入口及权限必须由服务器管理员维护。

## 核对和失败处理

检查 GitHub Actions 日志是否成功，读取 https://nfc.hitlcj.top/version.json 对照本次完整 commit，访问首页、sw.js 并验证关键页面。首次上线后的已安装旧版本，需要在线重新打开并点击“立即更新”。确认其他服务状态无异常。工作流、版本不匹配或健康检查失败时停止并报告；不要通过重复触发掩盖失败。回滚须由服务器管理员选择 `/var/www/idtag-releases` 中先前版本，确认后原子切换 `/var/www/idtag-live` 并验证；此操作不修改 Git 历史，后续 main 更新会再次触发部署。
