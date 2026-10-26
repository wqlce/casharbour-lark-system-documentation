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

## 维护

知识库内的《知识库文档编写与维护规则》、产品模板、技术模板及《更新日志通用模板（业务版）》是当前标准来源。Skill每次从飞书读取最新规则，不在仓库另存一份模板正文。

产品文档以“文档信息”标题和二列信息表开头，标题直接说明重点；正文按实际功能、用户任务或流程组织，不硬套固定章节。

更新日志按“项目＋环境”持续维护固定时间线，正式服和测试服独立成篇，各自按实际部署日期倒序排列。每次更新的独立功能从 1 编号，入口、注意事项和限制放在对应功能下面。正式发布与业务验收分别记录，测试部署不能标成正式上线。代码分支、提交、日志和恢复步骤统一放关联技术记录。

[项目更新文档登记](.agents/skills/lark-system-documentation/references/project-release-pages.md)已保存 12 个项目的正式服、测试服共 24 个固定入口；后续按登记更新原页面。当前未纳入的 5 个小项目不自动扩展本批入口。通知从对应条目提炼，实际发送仍需明确授权和受众。

版本与分支治理已同步当前的统一自动版本维护规则；是否部署、是否推送默认分支及是否变更数据或权限，仍取决于具体任务授权。

文档负责人默认取执行时飞书CLI已验证的当前登录用户，通过`lark-cli auth status --json --verify`核实姓名与有效user身份后填写，不留空或写待指定，不照抄他人的登录账号。用户另有明确指定时采用指定人。

- [知识库文档编写与维护规则](https://cas-harbour.feishu.cn/wiki/C1DSwr1VAiXxktku0MRcMRMln6e)
- [更新日志通用模板（业务版）](https://cas-harbour.feishu.cn/wiki/CnIbw6aJiiZFJsk3m0Ccd20RnMh)

已有使用者可在本仓库执行`git pull --ff-only`更新Skill。拉取Skill仅更新写作指引，不部署业务系统、不改变知识库权限。
