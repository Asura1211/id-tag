# ID-Tag 开发约定

这是仅供演示的静态 PWA，不接真实 NFC、账号、后端或持久化。演示数据会在刷新后重置。保持现有功能，不要在未经要求时重写页面、删除原型素材或引入框架。原型中的账号、手机号为演示数据；案例证书为原始案例文件，不应当作虚构数据或随意公开传播。

先阅读 README.md 和 docs/deployment.md。修改前检查 git status，保护用户现有改动。按变更验证导航、相关业务流程及离线缓存；修改 PWA 更新机制必须检查首次访问、等待、更新、离线和恢复联网。执行 `node --check js/app.js && node --check js/update.js && node --check sw.js && python3 tests/check_static.py`。

不要提交密钥、令牌、真实个人信息或配置文件。仅在用户明确要求时提交或推送；向 main 推送会自动发布至生产环境，推送前说明这一事实并遵从用户明确指令。部署完成后核对 GitHub Actions 结果、线上 version.json 与目标 commit、页面及缓存脚本；失败时报告，不要擅自回滚其他服务。
