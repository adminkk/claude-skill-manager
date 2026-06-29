# Claude Skill Manager

一个用于更新 Claude 项目技能与 OpenSpec 配置的 PowerShell 脚本工具。

`update-skill.ps1` 会在当前目录下准备 `.claude/skills`，下载并更新 Superpowers skills，同时检查 OpenSpec CLI 和当前项目的 OpenSpec 配置。

## 功能

- 下载 `obra/superpowers` 仓库中的 skills，并复制到当前项目的 `.claude/skills`。
- 自动创建缺失的 `.claude/skills` 目录。
- 检查本机是否安装 `npm`。
- 如果可用，通过 `npm install -g @fission-ai/openspec@latest` 更新 OpenSpec CLI。
- 如果当前目录已经是 OpenSpec 项目，执行 `openspec update`。
- 如果当前目录不是 OpenSpec 项目，执行 `openspec init` 初始化。
- 输出成功、跳过和失败数量汇总。

## 环境要求

- Windows PowerShell。
- 可访问 GitHub 或脚本内置的 GitHub ZIP 代理地址。
- `npm` 可选；没有安装时会跳过 OpenSpec CLI 更新。
- 如需初始化或更新 OpenSpec 项目，需要 `openspec` 命令可用。

## 使用方式

在需要更新 Claude skills 的项目根目录运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\update-skill.ps1
```

脚本会以当前工作目录作为目标项目目录，而不是以脚本所在目录作为目标目录。因此，请先切换到你希望更新的项目根目录。

```powershell
cd D:\path\to\your-project
powershell -ExecutionPolicy Bypass -File D:\path\to\claude-skill-manager\update-skill.ps1
```

## 运行测试

当前仓库包含一个静态测试，用于检查脚本是否包含 OpenSpec 初始化逻辑：

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\update-skill.static-tests.ps1
```

测试通过时会输出：

```text
update-skill static tests passed.
```

## 脚本流程

1. 创建当前目录下的 `.claude\skills`。
2. 创建临时目录。
3. 从 GitHub 或代理地址下载 Superpowers ZIP。
4. 解压并复制 `skills` 内容到 `.claude\skills`。
5. 检查并更新 OpenSpec CLI。
6. 根据当前项目状态执行 `openspec update` 或 `openspec init`。
7. 清理临时目录。
8. 输出执行结果汇总。

## 注意事项

- 脚本会写入当前目录下的 `.claude\skills`。
- 脚本可能会在当前目录初始化 OpenSpec 项目。
- 脚本会尝试全局安装或更新 `@fission-ai/openspec`。
- 如果网络不可用或 GitHub 代理不可用，Superpowers 更新会失败。
- 如果当前 PowerShell 执行策略限制脚本运行，可使用上面的 `-ExecutionPolicy Bypass` 示例。

## 项目结构

```text
.
├── update-skill.ps1
└── tests
    └── update-skill.static-tests.ps1
```

## 许可证

当前仓库未包含 LICENSE 文件。使用或分发前请先补充许可证信息。
