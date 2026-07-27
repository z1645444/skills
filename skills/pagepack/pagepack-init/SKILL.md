---
name: pagepack-init
description: Create the initial .codebase/ best practice pack for a management web frontend project. Scans the codebase, distills common patterns into reusable code blocks with real-file references, and outputs agent onboarding guidance. Use when the project has no .codebase/ directory yet.
---

# Pagepack Init

为没有 `.codebase/` 的 management web frontend 项目生成初始 best practice pack。

## 前置检查

1. 若项目已存在 `.codebase/`，停止并引导用户改用 `pagepack-refresh`。
2. 确认这是一个前端项目（存在 `package.json`、框架依赖）。不是则说明 Pagepack 不适用并停止。

## 探测

默认并行派出三个 subagent 收集信号；若当前环境不支持 subagent 或多次失败，则退化为按同样分工顺序逐项自行执行。

三路分工，各自返回结构化结论（不写文件）：

1. **页面类型盘点**：读路由配置与 views/pages 目录，归类项目里的页面类型（列表页、表单页、详情页、弹窗 CRUD、Tab 复合页等），每类给出全部实例文件路径、判断哪个实例最典型完整、指出偏离主流写法的遗留实例。产出决定 `practices/pages/` 下的文件清单。
2. **组件封装盘点**：找出项目自封装的通用组件与高频使用的 UI 库组件用法（表格封装、查询表单、弹窗、上传、权限控件等），每项给出使用示例文件与典型调用方式。产出决定 `practices/components/` 下的文件清单。
3. **api 层与文件结构**：请求封装、api 函数定义方式、数据流约定；目录组织、命名约定、新页面/新模块落在哪里。产出对应 `api.md` 与 `structure.md`。

## 提炼与写入

依据探测结论，主流程写出：

```text
.codebase/
  README.md
  .baseline
  practices/
    pages/<type>.md
    components/<name>.md
    api.md
    structure.md
```

practice 文件名用英文 kebab-case，如 `table-list.md`、`search-form.md`。

每条 practice 必须遵循提炼式形态：

- **标题 + 一句话说明**：这个 pattern 是什么、何时用。
- **通用骨架 code block**：阅读该 pattern 的多个真实实例后归纳合成——剔除业务噪音（页面私有的权限判断、特殊逻辑），命名通用化（如 `UserList` → `ExampleList`）。不要从单个文件整段摘录。该 pattern 全项目仅有一个实例时，从该实例提炼，同样去噪音、通用化命名，参考实现只列这一个文件。
- **注意事项**：同一 pattern 存在多种写法时，以出现次数最多者为标准写法，并显式裁决遗留写法：注明其所在文件、说明勿模仿。
- **参考实现**：2–3 个最典型完整的真实文件路径，供对生成结果不满意时回看真实上下文。

`README.md` 是索引：开头一段话告诉 agent "改代码前按下表找到相关 practice 并读取"，随后每条 practice 一行——路径 + 一句话描述。

语言：practice 正文默认中文；项目内既有文档明显为英文时跟随英文。code block、路径、API 与 framework 名称保留原文。

## 仓库化

`.codebase/` 是独立 git repo，不进 main repo 的版本管理（也不是 submodule）：

1. 在 `.codebase/` 内执行 `git init`。
2. 写入 `.baseline`：单行内容，为 main repo 当前 `git rev-parse HEAD` 的 hash，供 `pagepack-refresh` 体检模式做增量界标。main repo 不是 git repo 或取不到 HEAD 时跳过此步并在收尾说明（refresh 体检会按 baseline 缺失处理）。
3. 将 `.codebase/` 追加进 main repo 的 `.gitignore`（已忽略则跳过）。
4. 在 nested repo 内完成首次 commit。

## Agent 接入

生成完成后处理 `AGENTS.md` / `CLAUDE.md`：

- 任一文件已存在：**只输出**下面的引导文字让用户自己粘贴，不直接编辑；用户明确要求时才代为编辑。
- 两个文件都不存在：新建 `AGENTS.md` 写入引导文字，然后 `ln -s AGENTS.md CLAUDE.md`。

引导文字模板（可按项目语言微调）：

```markdown
## Codebase Practices

若项目根存在 `.codebase/`：改代码前先读 `.codebase/README.md`，按索引找到与本次改动相关的 practice 文件并遵循其中写法。practice 中的 code block 是项目标准写法；需要更完整的真实上下文时，参考 practice 末尾列出的参考实现文件。`.codebase/` 不存在时忽略本节。
```

条件式措辞是刻意的：`.codebase/` 被 main repo ignore，队友 clone 后没有这个目录，agent 应静默跳过而不是报错。

## 收尾汇报

汇报：生成了哪些 practice 文件（各一行说明）、发现的遗留写法裁决、接入引导的处理方式、nested repo 与 `.gitignore` 的处理结果。提醒用户：生成内容已作为 nested repo 的首次 commit，直接读文件核对即可；后续 `pagepack-refresh` 的改动用 `git -C .codebase status` 与 `git -C .codebase diff` 审查；想与队友共享可为 `.codebase/` 单独配 remote。
