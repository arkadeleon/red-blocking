# RedBlocking 角色 YAML 结构化 Schema

## Status

- Phase: 2
- Status: finalized on 2026-03-13
- Source baseline:
  - `docs/CHARACTER_YAML_PHASE0_BASELINE.md`
  - `docs/character_yaml_legacy_browser_snapshots/`

这份文档是结构化角色 YAML 的唯一 schema 规范。后续 Phase 3 的 Swift 运行时模型、Phase 4 的迁移脚本、Phase 5 之后的解码与投影，都以这里的字段名、层级和约束为准。

## Scope

- 适用范围：`RedBlocking/Resources/CharacterData/*.yml` 的 19 个角色资料文件
- 不适用范围：`Characters.yml`
- 第一优先级：迁移后浏览层级、标题、副标题、动作入口与当前版本完全一致

## Root Shape

每个角色文件根节点固定为 3 个字段：

- `character`
- `introduction`
- `moveGroups`

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
  - id: ground_normals
    displayTitle: "【地上通常技】"
    entries: []
  - id: normal_throws
    displayTitle: "【通常投げ】"
    entries: []
  - id: lever_input_moves
    displayTitle: "【レバー入れ技】"
    entries: []
  - id: common_moves
    displayTitle: "【特殊入力技】"
    entries: []
  - id: special_moves
    displayTitle: "【必殺技】"
    entries: []
  - id: super_arts
    displayTitle: "【スーパーアーツ】"
    entries: []
```

## Fixed Group IDs

`moveGroups` 的数量固定为 7，顺序也固定为下表：

| id | displayTitle |
| --- | --- |
| `air_normals` | `【空中通常技】` |
| `ground_normals` | `【地上通常技】` |
| `normal_throws` | `【通常投げ】` |
| `lever_input_moves` | `【レバー入れ技】` |
| `common_moves` | `【特殊入力技】` |
| `special_moves` | `【必殺技】` |
| `super_arts` | `【スーパーアーツ】` |

约束：

- `introduction` 不进入 `moveGroups`
- 根层只能出现这 7 个 group id
- 更深层如果再次出现 `【空中通常技】` 这类标题，不提升为 `MoveGroup`，而是普通 `MoveEntry`

## Canonical Runtime Targets

Phase 3 的 Swift 模型按下列目标命名：

- `CharacterProfile`
- `CharacterIntroduction`
- `MoveGroup`
- `MoveGroupID`
- `MoveEntry`
- `MoveDetail`
- `MoveMedia`
- `MoveLabeledValue`
- `MoveNoteGroup`

其中 `MoveLabeledValue` 和 `MoveNoteGroup` 是 `MoveDetail` 的辅助类型，不单独占根层节点。

## YAML Types

### CharacterProfile

```yaml
character:
  id: alex
  displayName: Alex
introduction: ...
moveGroups: ...
```

字段：

- `character.id`: 机器 id，小写 snake_case，跨迁移稳定
- `character.displayName`: 角色展示名，保持与当前角色列表一致
- `introduction`: `CharacterIntroduction`
- `moveGroups`: `[MoveGroup]`

### CharacterIntroduction

```yaml
introduction:
  displayTitle: "【パワーエイジ】"
  body: |-
    ...
```

字段：

- `displayTitle`: 顶层第一段 `SectionTitle`
- `body`: 顶层介绍正文，保留原换行

约束：

- 介绍区只出现一次
- `body` 不能为空

### MoveGroup

```yaml
- id: special_moves
  displayTitle: "【必殺技】"
  entries:
    - ...
```

字段：

- `id`: 固定 5 选 1
- `displayTitle`: 原 section 标题
- `entries`: `[MoveEntry]`

### MoveEntry

`MoveEntry` 是唯一递归节点。所有中间层、分支层、复合说明层都由它表达。

```yaml
- id: jumping_jab
  displayName: ジャンプ小パンチ
  children:
    - id: neutral_jumping_jab
      displayName: 垂直ジャンプ小パンチ
      detail:
        displayName: ハンドスタンプ
```

字段：

- `id`: 当前节点稳定 id
- `displayName`: 当前层展示标题
- `children`: `[MoveEntry]`
- `detail`: `MoveDetail`

约束：

- `children` 和 `detail` 二选一，禁止同时存在
- 非叶子节点必须使用 `children`
- 叶子节点必须使用 `detail`
- 所有旧 YAML 中的 `Next -> Sections`，统一投影为 `children`
- 旧结构里的 `補足 > 通常`、`1回目`、`打撃部分`、`幻影陣中の各技の数値` 这类自定义层级，都继续保留为 `MoveEntry`

### MoveDetail

`MoveDetail` 只表达最终详情页数据，不承载继续导航的子层级。

```yaml
detail:
  displayName: ハンドスタンプ
  startup: "4"
  active: "12"
  damage: "40"
  stun: "9"
  stunReduction: "3"
  meterGain:
    - id: whiff
      label: 空振り
      value: "0"
    - id: guard
      label: ガード
      value: "1"
    - id: hit
      label: ヒット
      value: "2"
    - id: blocking
      label: BL
      value: "4"
  noteGroups:
    - id: notes
      displayTitle: 補足
      entries:
        - 攻撃判定発生が早く、持続が長い上に小攻撃にしてはスタン値が高い
  media:
    kind: motion_player
    displayLabel: モーション
    skillName: Jumping Jab
    characterCode: "01"
    skillCode: "008"
```

标准字段：

- `displayName`
- `command`
- `superCancel`
- `guard`
- `blocking`
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

字段说明：

- 所有数值字段仍使用字符串保存，不在 schema 阶段引入数值化解析
- `displayName` 对应旧结构中的 `技名`
- `superCancel` 对应 `SC`
- `guard` 对应 `ガード`
- `blocking` 对应 `BL`
- `startup` 对应 `発生`
- `active` 对应 `持続`
- `recovery` 对应 `硬直`
- `damage` 对应 `攻撃力`
- `chipDamage` 对应 `ケズリ`，如果未来出现 `削りダメージ` 也并入此字段
- `stun` 对应 `スタン値`
- `stunReduction` 对应 `削減値`

约束：

- `MoveDetail` 不再嵌套 `children`
- `displayName` 不允许为空；若旧数据没有 `技名`，则沿用叶子节点的 `MoveEntry.displayName`
- `meterGain`、`frameAdvantage`、`stats`、`noteGroups` 都保序
- `media` 最多 1 个；旧结构里只有一个 `Presented` 入口

### MoveLabeledValue

```yaml
- id: standing_hit
  label: 立ヒット
  value: ダウン
```

字段：

- `id`: 机器 id
- `label`: 原始展示标签
- `value`: 原始值

用途：

- `meterGain`
- `frameAdvantage`
- `stats`

约束：

- 必须保留原顺序
- `label` 必须保留原文
- `id` 允许来自规范化后的标题，不要求全局唯一，只要求同一数组内唯一

### MoveNoteGroup

```yaml
- id: notes
  displayTitle: 補足
  entries:
    - 出が意外に速く判定は横&下方向に強い
    - 空対空やコンボの追撃、遠めからの飛び込みに使用
```

字段：

- `id`: 说明分组 id
- `displayTitle`: 展示标题
- `entries`: `[String]`

约束：

- `entries` 保留原 row 顺序
- 单个 entry 可为多行字符串
- `通常 / EX / 共通 / 小 / 中 / 大 / 追加入力` 这类说明子组，不进入 `stats`，而是作为独立 `MoveNoteGroup`

### MoveMedia

```yaml
media:
  kind: motion_player
  displayLabel: モーション
  skillName: Jumping Jab
  characterCode: "01"
  skillCode: "008"
```

字段：

- `kind`: 固定为 `motion_player`
- `displayLabel`: 当前入口展示标题，默认使用 `モーション`
- `skillName`: 当前动作展示名
- `characterCode`
- `skillCode`

约束：

- 不再保存 UIKit 细节字段 `ViewController`
- 旧结构中 `Presented.ViewController` 必须为 `FramesPlayerViewController`，否则迁移失败

## Field Boundary Rules

### 1. 哪些内容进入标准字段

只有下列旧 row title 进入 `MoveDetail` 标准字段：

| Legacy title | Structured field |
| --- | --- |
| `技名` | `displayName` |
| `コマンド` | `command` |
| `SC` | `superCancel` |
| `ガード` | `guard` |
| `BL` | `blocking` |
| `発生` | `startup` |
| `持続` | `active` |
| `硬直` | `recovery` |
| `攻撃力` | `damage` |
| `ケズリ` | `chipDamage` |
| `スタン値` | `stun` |
| `削減値` | `stunReduction` |

### 2. 哪些内容进入专用统计块

下列 section title 进入专用字段，而不是 `stats`：

- `ゲージ増加量` -> `meterGain`
- `ヒット&ガード硬直時間差` -> `frameAdvantage`

扩展规则：

- `1回目ゲージ増加量`
- `追加入力ゲージ増加量`
- `ヒット&ガード硬直時間差(中P)`
- `ヒット&ガード硬直時間差(立大P)`

这类“带后缀说明”的 section 不直接塞进 `MoveDetail.frameAdvantage` 或 `MoveDetail.meterGain`。它们先保留为中间 `MoveEntry`，其叶子 `detail` 里再出现对应专用字段。这样才能保持现有导航层级和页面标题完全不变。

### 3. 哪些内容进入 noteGroups

下列内容进入 `noteGroups`：

- `補足`
- `通常`
- `EX`
- `共通`
- `小`
- `中`
- `大`
- `追加入力`
- `追加入力「小」`
- `追加入力「中」`
- `追加入力「大」`
- `追加入力「無し」`

规则：

- `補足` 本身是 note group
- `補足` 下面再分 `通常 / EX` 时，每个子 section 各自生成一个 `MoveNoteGroup`
- `補足` 直接挂文本 row 时，生成单个 `MoveNoteGroup(id: notes, displayTitle: 補足, entries: ...)`

### 4. 哪些内容进入 stats

无法归入标准字段、专用统计块、说明块或媒体入口的叶子级键值项，统一进入 `stats`，例如：

- `投げ間合い`
- `SA発生`
- `効果`
- `ガード、BL時`

规则：

- `stats` 只承接叶子详情页中的键值行
- 如果旧结构仍有后续 `Next`，它就不是 `stats`，而是新的 `MoveEntry`

### 5. 哪些内容必须保留为 MoveEntry

以下形态一律保留为 `MoveEntry.children`，不允许扁平化进 `MoveDetail`：

- 深层导航链
- `1回目 / 2回目 / 3回目`
- `打撃部分 / バックドロップ / パワーボム`
- `幻影陣中の各技の数値`
- 角色对位分支，如 `ダッドリー / ユン / ヤン / Q`
- 复合段位分支，如 `上段(1・2段目)`、`下段(3段目)`
- 顶层分类复用，如深层的 `【空中通常技】`

原因：

- 这些节点在当前 UI 中就是可导航页面，不是详情页字段
- 一旦扁平化，legacy 快照中的 `navigation_depth` 和 `navigation_title` 会发生变化

## Coverage Decisions For Known Complex Cases

### Alex

覆盖点：

- 常规叶子详情
- `補足 > 通常 / EX`
- 必杀技带媒体入口

结论：

- `フラッシュチョップ > 補足 > 通常 / EX` 保留为 `MoveEntry.children`
- `Flash Chop (EX)` 只进入 `media`

### Dudley

覆盖点：

- 深度 3 导航链
- `通常 / EX` 说明块
- 多段组件节点

结论：

- `ダッキング系 > ダッキング > ダッキング【小】` 保持 3 层
- `ロケットアッパー > 1回目 / 2回目 / 3回目` 全部是 `MoveEntry`

### Yun

覆盖点：

- 深层复用顶层分类标题
- `幻影陣中の性能`
- `通常 / EX` 说明块

结论：

- `幻影陣(げんえいじん) > 幻影陣中の各技の数値 > 【空中通常技】` 中的 `【空中通常技】` 不是 `MoveGroup`
- `幻影陣中の性能` 是普通 `MoveEntry`
- 只有真正叶子页中的键值与说明，才进入 `MoveDetail`

## Failure Rules

迁移和解码阶段遇到以下情况必须失败：

- 根层缺少 `character`、`introduction` 或 `moveGroups`
- `moveGroups` 的 id 数量或顺序不正确
- 同一 `MoveEntry` 同时出现 `children` 和 `detail`
- 旧结构出现未知顶层 section
- 无法判断当前节点是导航层还是叶子详情层
- 旧 `Presented.ViewController` 不是 `FramesPlayerViewController`
- 叶子详情出现无法归类且也无法安全落入 `stats` 的结构冲突

## Verification Checklist

Phase 2 完成标准按以下项目核对：

- Alex、Dudley、Yun 的复杂样例都能用本 schema 解释，且不需要额外补字段
- `MoveDetail` 的标准字段边界已经固定，不再讨论 `BL` / `block` / `blocking` 之类命名分歧
- 所有已知复杂 section 都已有明确归属：`MoveEntry`、`noteGroups`、`stats` 或 `media`
- Phase 3 可直接按本文的 `Canonical Runtime Targets` 建模
