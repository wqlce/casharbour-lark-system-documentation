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
git clone https://github.com/wqlce/lark-system-documentation.git
cd lark-system-documentation
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

知识库内的《知识库文档编写与维护规则》、产品模板与技术模板是当前标准来源。更新这些规则后，Skill 会在下次运行时读取最新版本，无需同步复制模板正文。
