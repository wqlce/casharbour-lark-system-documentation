# 系统文档归档 Skill

`lark-system-documentation` 用于按“信息技术部流程以及开发文档”飞书知识库的现行标准，编写、拆分、归档并回读验收以下资料：

- 产品文档（PRD）
- 技术文档（技术设计）
- 更新日志
- 问题记录
- 特殊情况记录

它会先读取知识库中的治理规则和通用模板，再判断需求应合一还是拆分为 PRD 与技术设计，最后将文档归档到正确的系统栏目并验证结果。

## 安装

克隆本仓库后，在 Codex 中打开仓库根目录即可。Codex 会从 `.agents/skills` 识别该 Skill；若未立即显示，重新打开任务或重启 Codex。

```bash
git clone https://github.com/wqlce/casharbour-lark-system-documentation.git
cd casharbour-lark-system-documentation
```

## 前置条件

每位使用者都必须：

1. 使用自己的 GitHub 和飞书账号。
2. 安装并授权 `lark-cli`，具备飞书文档和知识库操作能力。
3. 具有“信息技术部流程以及开发文档”知识库目标目录的访问与编辑权限。

请勿共享个人登录态、飞书 token、secret、账号密码或 `~/.codex` 整个目录。

## 使用示例

```text
使用 $lark-system-documentation，
为高校CRM的学生信息修改功能补齐产品文档和技术文档，
按知识库标准归档。
```

```text
使用 $lark-system-documentation，
把这份 AI 需求草案整理成科研营项目的正式文档；
涉及微伴接口和订单同步，请判断是否拆分并归档。
```

## 维护与业务可读性

知识库内的《知识库文档编写与维护规则》、产品模板、技术模板及《更新日志通用模板（业务版）》是当前标准来源。Skill 每次从飞书读取最新规则，不在仓库另存一份模板正文。

- **前轻后重与去技术化**：产品文档与更新日志遵循[业务可读性与去技术化写作规范](.agents/skills/lark-system-documentation/references/plain-language-guide.md)。产品文档顶部仅保留极简 4 行《基本信息》与一句话业务摘要，编号、修订、产品版本、分支、标签及证据日期沉底至文末《归档与追溯信息》；正文禁用代码、Git、SemVer、单测条数、底层模板键名及冗长防御性免责声明。
- **更新日志分环境维护**：按“项目＋环境”持续维护固定时间线，正式服和测试服独立成篇，各自按实际部署日期倒序排列。正式服坚持极简用户视角（每条功能 2~3 句业务人话）；测试服采用“上半块给业务验收看 + 下半块研发备注”上下分层结构。代码分支、提交、构建和恢复步骤统一放关联技术记录或文末维护说明。
- **固定更新入口**：[项目更新文档登记](.agents/skills/lark-system-documentation/references/project-release-pages.md)已保存 12 个项目的正式服、测试服共 24 个固定入口；后续按登记更新原页面。
- **版本与负责人**：版本与分支治理已同步当前的统一自动版本维护规则；文档负责人默认取执行时飞书 CLI 已验证的当前登录用户（`lark-cli auth status --json --verify`）。

- [知识库文档编写与维护规则](https://cas-harbour.feishu.cn/wiki/C1DSwr1VAiXxktku0MRcMRMln6e)
- [产品文档通用模板](https://cas-harbour.feishu.cn/wiki/JOjYwEwXkiLHGJkrvkCcY6Yen6f)
- [更新日志通用模板（业务版）](https://cas-harbour.feishu.cn/wiki/CnIbw6aJiiZFJsk3m0Ccd20RnMh)

## 自动检查更新

Skill 内置了轻量级更新脚本 [`scripts/check_update.sh`](.agents/skills/lark-system-documentation/scripts/check_update.sh)，执行任务前会自动按间隔检查 GitHub `main` 分支是否有新版本：

- **节流与非阻塞**：默认每 24 小时（`86400` 秒）检查一次；离线、超时或本地有未提交改动时自动跳过，不影响正常写文档。
- **双模式兼容**：
  - Git 克隆安装：自动执行 `git pull --ff-only origin main`。
  - 独立复制目录安装（如 `~/.codex/skills/lark-system-documentation`）：比对 `.skill-version` 与远端最新 commit，有更新时自动拉取同步。
- **常用参数与环境变量**：
  - `bash scripts/check_update.sh --force`：忽略 24 小时间隔立即检查并更新。
  - `bash scripts/check_update.sh --check-only`：仅检查是否有更新，不修改文件。
  - `LARK_DOC_SKILL_AUTO_UPDATE=0`：临时或全局关闭自动检查。
  - `LARK_DOC_SKILL_CHECK_INTERVAL=3600`：自定义检查间隔秒数。
