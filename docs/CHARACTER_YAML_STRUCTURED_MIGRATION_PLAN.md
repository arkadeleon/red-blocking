# RedBlocking 角色 YAML 结构化迁移计划

## 背景

当前各角色 YAML 文件采用的是面向 UI 的 `Section / Row / Next` 树结构。它能驱动当前界面，但数据语义偏弱，字段命名和层级组织更像“页面怎么展示”，而不是“角色资料和招式数据是什么”。

本次迁移的目标是把 19 个角色 YAML 改造成结构化领域数据，同时保证现有 SwiftUI 界面的展示结果与当前版本保持一致。角色列表入口文件 `Characters.yml` 不在本次改动范围内，继续沿用现有格式和读取方式。

## 目标

- 仅迁移 `RedBlocking/Resources/CharacterData` 下的 19 个角色 YAML。
- `Characters.yml` 保持原样，不修改 schema，不修改内容。
- 角色浏览界面、详情界面、动作入口和 motion player 跳转结果与当前版本一致。
- 新 YAML 使用结构化领域模型，避免继续依赖 `Section / Row / Next` 的 UI 树表达。
- 提供可重复执行的迁移和校验工具，避免一次性手工转换。

## 新数据结构

### 根节点

每个角色文件保留现有文件名，根节点统一为：

- `character`
- `introduction`
- `moveGroups`

示意结构：

```yaml
character:
  id: alex
  displayName: Alex

introduction:
  displayTitle: "【パワーエイジ】"
  body: |-
    世界の強豪たちと闘い、格闘の怖さと奥深さを知ったアレックス。
    ...

moveGroups:
  - id: air_normals
    displayTitle: "【空中通常技】"
    entries: []
```

### moveGroups

`moveGroups` 固定为 5 类，使用英文机器键和展示标题并存：

- `air_normals`
- `ground_normals`
- `command_normals`
- `special_moves`
- `super_arts`

顶层第一段介绍文案不放入 `moveGroups`，单独放到 `introduction`。

### MoveEntry

`MoveEntry` 是递归节点，用来表达当前 YAML 中所有中间层和叶子层。

建议字段：

- `id`
- `displayName`
- `children`
- `detail`

约束如下：

- 中间层节点使用 `children`
- 叶子节点使用 `detail`
- 同一个节点不同时承担多个语义层级

示意结构：

```yaml
- id: jumping_jab
  displayName: ジャンプ小パンチ
  children:
    - id: jumping_jab_neutral
      displayName: 垂直ジャンプ小パンチ
      detail:
        displayName: ハンドスタンプ
```

### MoveDetail

`MoveDetail` 用于表达叶子详情页面的数据。标准字段优先，少量不规则字段通过弹性结构承接。

建议字段：

- `displayName`
- `command`
- `superCancel`
- `guard`
- `block`
- `startup`
- `active`
- `recovery`
- `damage`
- `chipDamage`
- `stun`
- `stunReduction`
- `meterGain`
- `frameAdvantage`
- `stats`
- `noteGroups`
- `media`

其中：

- `meterGain` 对应 `ゲージ増加量`
- `frameAdvantage` 对应 `ヒット&ガード硬直時間差`
- `stats` 用于承接无法归入标准字段的少量键值项，并保留原顺序
- `noteGroups` 用于承接 `補足`，包括 `通常 / EX` 这类说明分组
- `media` 用于承接当前 `Presented` 里的动作播放器信息

示意结构：

```yaml
detail:
  displayName: ハンドスタンプ
  startup: "4"
  active: "12"
  damage: "40"
  stun: "9"
  stunReduction: "3"
  meterGain:
    whiff: "0"
    guard: "1"
    hit: "2"
    block: "4"
  noteGroups:
    - id: notes
      displayTitle: 補足
      lines:
        - 攻撃判定発生が早く、持続が長い上に小攻撃にしてはスタン値が高い
  media:
    skillName: Jumping Jab
    characterCode: "01"
    skillCode: "008"
```

## 运行时改造方向

### 保持不变的部分

- `Characters.yml` 继续由现有角色列表数据模型读取。
- 角色顺序、角色资源名、角色图片名、背景图名全部保持现状。
- `FrameData` 资源结构不改。
- 现有 UI 外观不做重设计。

### 需要调整的部分

- `MoveRepository` 改为解码结构化角色 profile，而不是 `[CharacterMove.Section]`。
- `AppNavigationModel` 改为持有结构化节点引用，而不是直接缓存 `Section / Row` 树。
- `MoveBrowserModel` 直接从结构化模型生成浏览页和详情页所需的展示模型。
- motion player 入口继续由 `media` 驱动，保持当前跳转行为。

### 长期接口方向

本次迁移完成后，不再把旧的 `CharacterMove.Section` 视为长期运行时接口。UI 直接消费新的领域模型及其投影出的展示模型。

## 固定映射规则

### 顶层映射

- 第 1 段 `SectionTitle` 和故事文本映射到 `introduction`
- `【空中通常技】` -> `air_normals`
- `【地上通常技】` -> `ground_normals`
- `【特殊入力技】` -> `command_normals`
- `【必殺技】` -> `special_moves`
- `【スーパーアーツ】` -> `super_arts`

### 中间层映射

- 所有 `Next` 中间层统一转换成 `children`
- 所有展示标题保留原文，不做文案改写

### 叶子详情映射

- 常规键值行优先映射到标准字段
- 无法归类的键值行映射到 `stats`
- `ゲージ増加量` 映射到 `meterGain`
- `ヒット&ガード硬直時間差` 映射到 `frameAdvantage`
- `補足` 映射到 `noteGroups`
- `Presented.ViewController == FramesPlayerViewController` 映射到 `media`

### 严格失败原则

以下情况一律视为迁移失败，必须先补规则再继续：

- 未知顶层 section
- 未知叶子区块
- 同一节点出现冲突字段
- 无法稳定判断是中间层还是叶子层
- 无法还原为与当前界面一致的浏览层级

## 批量迁移与校验

在 `scripts` 目录下补充两类工具：

### 1. legacy 快照导出脚本

用途：

- 读取旧角色 YAML
- 导出每个角色完整浏览树的基线快照
- 作为迁移后 parity 校验依据

快照至少包含：

- section 标题
- row 标题
- row 副标题
- row 类型
- 递归层级
- 动作入口信息

### 2. 新 schema 迁移脚本

用途：

- 批量读取旧角色 YAML
- 按固定映射规则输出新结构化 YAML
- 生成稳定 `id`
- 对未知结构立即报错退出

## 验收标准

- 19 个角色 YAML 全部完成结构化迁移。
- `Characters.yml` 保持原样且仍能正常驱动角色列表。
- 所有新角色 YAML 均可成功解码为结构化模型。
- 新模型生成的浏览层级、标题、副标题、顺序、动作入口与 legacy 快照逐角色一致。
- 所有 motion player 入口仍能打开正确资源。
- 迁移脚本和校验脚本可重复运行。

## 默认假设

- 角色 YAML 文件名保持不变。
- 角色顺序和角色入口继续由 `Characters.yml` 决定。
- 新 schema 使用英文机器键，同时保留全部展示文案字段。
- 本次不处理国际化，不重写原文案。
- 本次不改 `Characters.yml`，不改 `FrameData`，不重设计 UI。
