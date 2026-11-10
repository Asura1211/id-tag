---
name: id-tag-deploy
description: 开发、验证和部署 Asura1211/id-tag 船舶缆绳管理 PWA。用于该项目的修改、推送或线上发布；不用于其他项目。
---

# ID-Tag 开发与发布

仓库 https://github.com/Asura1211/id-tag ，生产站点 https://nfc.hitlcj.top/ 。向 main 推送即触发生产自动部署。用户一句话要求开发并部署时，完成修改和验证后直接提交并推送 main，无需重复确认；仅要求开发时不要自行发布。

1. 在现有项目目录工作；若没有，克隆仓库。阅读 `AGENTS.md`、`README.md`、`docs/deployment.md`，检查 `git status`，保留已有工作。按需求修改，保持原有业务功能。
2. 按项目约定运行语法及静态检查，以及与改动直接相关的验证。不要提交密钥或无关变更。确认目标为 `Asura1211/id-tag` 的 main；先同步远程并妥善处理并发更新，不强推、不覆盖他人工作。
3. 如果用户要求推送或部署，提交本次变更并推送 main。新电脑须安装 Git、Node.js、Python 3 和 GitHub CLI，且用有该仓库写权限的账号登录 GitHub，或配置可写的 Git SSH 凭据；公开仓库可供读取，但不自动授予写权限。缺少凭据时说明如何登录，不收集密码和令牌。无需服务器 SSH 权限或复制部署密钥到本机。
4. 查看 GitHub Actions 的 `Check and deploy ID-Tag` 执行结果，并核对 `https://nfc.hitlcj.top/version.json` 的 commit 与本次提交一致，以及首页和 sw.js 可访问。部署失败或版本不一致时报告，不擅自绕过自动发布或回滚。旧客户端需点击“立即更新”以加载新版本。

跨电脑安装：克隆仓库后，将 `.agents/skills/id-tag-deploy` 复制到目标电脑 `~/.codex/skills/id-tag-deploy` 并按客户端要求重新加载技能；其他 Agent 按其技能目录约定安装。之后可说：“使用 id-tag-deploy，完成……并部署到线上。”
