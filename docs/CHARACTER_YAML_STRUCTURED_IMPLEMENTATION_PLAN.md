# RedBlocking 角色 YAML 结构化迁移实施计划

## Summary

这份文档基于 [`CHARACTER_YAML_STRUCTURED_MIGRATION_PLAN.md`](./CHARACTER_YAML_STRUCTURED_MIGRATION_PLAN.md) 拆分具体实施阶段，目标是把角色 YAML 结构化迁移拆成尽量小、可独立验证的 Phase。

每个 Phase 都应满足以下要求：

- 改动范围单一，不同时处理多个高风险问题。
- 每个 Phase 结束后工程都可以成功 build。
- 每个 Phase 都有明确的完成标准和验证方式。
- `Characters.yml` 不在本计划改动范围内。
- 迁移过程中始终以“界面展示结果与当前版本一致”为最高约束。

## 执行原则

### 先基线，后迁移

在动角色 YAML 之前，先把当前浏览树行为固化成可对照的基线，避免后续只能依赖人工肉眼回归。

### 先模型，后 UI

先定新 schema、迁移规则和运行时模型，再切换导航和界面，避免 UI 反向绑死数据结构。

### 严格失败，不做静默兼容

遇到未覆盖的旧结构时，优先补映射规则和测试，不允许为了“先跑起来”而跳过数据。

### 小步提交

建议每个 Phase 单独一个 commit。如果某个 Phase 仍偏大，应继续向下拆分，不要与相邻 Phase 合并。

## Phase 0: Baseline Freeze

### Goal

记录迁移前角色 YAML 的真实结构和界面行为基线。

### Tasks

- 统计 19 个角色 YAML 的顶层 section 标题。
- 识别深层嵌套和特殊形态，尤其是多级分支、`通常/EX` 说明块、不规则字段组合。
- 明确当前 SwiftUI 浏览页依赖的用户可见结果：
  - section 标题
  - row 标题
  - row 副标题
  - 行类型
  - 导航层级
  - 动作入口

### Done When

- 已确认 19 个角色的顶层结构规律。
- 已整理需要兼容的特殊嵌套模式。
- 已形成后续 parity 校验所需字段清单。

### Verification

- 能输出每个角色的顶层 `SectionTitle` 列表。
- 能列出至少一份包含特殊嵌套模式的样例清单。

## Phase 1: Export Legacy Browser Snapshots

### Goal

建立“展示结果一致”的自动化对照基线。

### Tasks

- 在 `scripts` 下新增 legacy 浏览树快照导出脚本。
- 脚本读取旧角色 YAML，输出每个角色的递归浏览树 JSON。
- 快照包含：
  - section 标题
  - row 标题
  - row 副标题
  - row 类型
  - 子节点
  - 动作入口信息
- 将生成的快照提交到仓库，作为后续回归基线。

### Done When

- 19 个角色都已生成快照文件。
- 快照格式可稳定复用。

### Verification

- 每个角色都有对应快照。
- 抽查多个角色时，快照层级与原 YAML 导航层级一致。

## Phase 2: Finalize Structured Schema

### Goal

固化新的角色 YAML schema，确保能覆盖全部已知结构。

### Tasks

- 定义角色文件根节点：
  - `character`
  - `introduction`
  - `moveGroups`
- 定义 `MoveGroup`、`MoveEntry`、`MoveDetail`、`MoveMedia` 的字段和约束。
- 固定 5 个 group id：
  - `air_normals`
  - `ground_normals`
  - `command_normals`
  - `special_moves`
  - `super_arts`
- 明确标准字段、弹性字段、说明字段和媒体字段的边界。

### Done When

- 新 schema 已书面定稿。
- 运行时 Swift 模型有明确映射目标。

### Verification

- schema 可以覆盖 Alex、Dudley、Yun 这类不同复杂度角色。
- 不存在未决字段命名或层级归属问题。

## Phase 3: Add Structured Runtime Models

### Goal

在代码中引入新 schema 对应的 Swift 领域模型。

### Tasks

- 新增结构化模型：
  - `CharacterProfile`
  - `MoveGroup`
  - `MoveEntry`
  - `MoveDetail`
  - `MoveMedia`
- 明确可选字段、递归关系和媒体入口结构。
- 保持 `CharacterRepository` 和 `Character` 不变，继续服务 `Characters.yml`。

### Done When

- 新模型可编译。
- 新模型能表达全部已知结构。

### Verification

- 工程 build 成功。
- 至少能用伪造样例解码复杂分支结构。

## Phase 4: Add Migration Script

### Goal

实现从旧角色 YAML 到新 schema 的批量转换。

### Tasks

- 在 `scripts` 下新增角色 YAML 迁移脚本。
- 固定顶层 section 到 `introduction` 和 `moveGroups` 的映射。
- 固定叶子详情页区块到 `detail` 字段的映射。
- 生成稳定 id。
- 对未知结构直接失败退出。

### Done When

- 脚本可以一次性处理全部 19 个角色。
- 所有已知结构都有明确落点。

### Verification

- 脚本运行后能产出完整的新 YAML。
- 人为注入未知结构时脚本会失败。

## Phase 5: Add Structured Decode Path

### Goal

让运行时可以解码新的角色 profile，但先不切换 UI。

### Tasks

- 调整 `MoveRepository`，新增结构化角色 YAML 的解码路径。
- 保留 `CharacterRepository` 读取 `Characters.yml` 的现状。
- 为结构化解码失败添加错误处理。

### Done When

- 应用能根据 `selection.moveResourceName` 读取结构化角色 YAML。
- 不需要依赖旧 `[CharacterMove.Section]` 解码路径来拿到角色资料。

### Verification

- 19 个角色的新 YAML 全部可解码。
- 角色切换后能成功加载对应 profile。

## Phase 6: Add Browser Projection Models

### Goal

从结构化模型生成浏览页和详情页所需的展示模型。

### Tasks

- 新增浏览投影模型，承接当前 UI 所需的 section 和 row 信息。
- 将 `MoveGroup` 投影为根页面分类列表。
- 将 `MoveEntry.children` 投影为中间层导航页面。
- 将 `MoveDetail` 投影为详情页字段区、说明区和动作入口。
- 明确保序规则，确保输出顺序与旧界面一致。

### Done When

- 新投影模型可以完整表达全部页面层级。
- 不再需要旧的 `Section / Row / Next` 来描述浏览结果。

### Verification

- 结构化投影结果与 legacy 快照逐角色深度一致。

## Phase 7: Switch Navigation to Structured Nodes

### Goal

把导航状态切换到结构化节点，而不是旧 UI 树节点。

### Tasks

- 调整 `AppNavigationModel`，持有当前 `CharacterProfile`。
- 根页面导航进入 `MoveGroup`。
- 中间页面导航进入 `MoveEntry.children`。
- 叶子页面展示 `MoveDetail`。
- `media` 继续驱动 motion player 跳转。

### Done When

- 浏览链路已不依赖旧 `CharacterMove.Section`。
- 角色切换和返回行为保持正常。

### Verification

- 角色浏览、层级跳转、返回导航、motion player 跳转全部可用。

## Phase 8: Switch Move Browser UI

### Goal

让当前 SwiftUI 浏览界面正式消费新的浏览投影模型。

### Tasks

- 调整 `MoveBrowserModel` 数据来源。
- 保留现有 `MoveBrowserView` 及相关 row view 的视觉表现和交互习惯。
- 对空态、错误态和无内容状态做回归。

### Done When

- 用户看到的浏览界面已完全由结构化模型驱动。
- UI 展示结果与当前版本一致。

### Verification

- 逐角色自动 parity 校验通过。
- 人工抽查多个角色，确认标题、副标题、层级和动作入口无回归。

## Phase 9: Replace Character YAML Files

### Goal

用新 schema 正式替换仓库中的 19 个角色 YAML。

### Tasks

- 先保留 legacy 快照基线。
- 使用迁移脚本生成新 YAML。
- 用生成结果覆盖原角色 YAML 文件，文件名保持不变。
- 再次核对 `Characters.yml` 无需修改即可定位这些文件。

### Done When

- 仓库中的 19 个角色 YAML 都已切为新 schema。
- 运行时读取的是新结构化文件。

### Verification

- 角色列表仍然正常工作。
- 所有角色都能进入浏览页并正常跳转。

## Phase 10: Add Automated Tests

### Goal

给迁移结果建立长期回归保护。

### Tasks

- 新增 test target。
- 添加新角色 YAML 解码测试。
- 添加结构化投影与 legacy 快照的 parity 测试。
- 添加动作入口一致性测试。
- 添加未知结构失败测试。

### Done When

- 自动测试覆盖 19 个角色。
- 关键 parity 行为进入 CI 或本地常规回归流程。

### Verification

- 全部测试通过。
- 修改任意角色 YAML 结构后，测试能有效发现回归。

## Phase 11: Cleanup and Final Regression

### Goal

清理旧角色浏览树解码路径，完成迁移收尾。

### Tasks

- 删除不再需要的旧 `CharacterMove.Section` 角色浏览解码路径。
- 清理旧适配逻辑和无用模型。
- 更新相关文档，记录最终运行方式和回归资产。

### Done When

- 运行时已不依赖旧角色 YAML 结构。
- 仓库保留迁移脚本和 legacy 快照作为长期资产。

### Verification

- 工程可 build。
- 角色浏览和 motion player 全量回归通过。

## 推荐执行顺序

建议严格按以下顺序推进，不要跳 Phase：

1. Phase 0
2. Phase 1
3. Phase 2
4. Phase 3
5. Phase 4
6. Phase 5
7. Phase 6
8. Phase 7
9. Phase 8
10. Phase 9
11. Phase 10
12. Phase 11

## 不在本计划范围

- 不修改 `Characters.yml`
- 不修改 `FrameData` 资源结构
- 不重设计 UI 外观
- 不做文案重写
- 不做国际化扩展
