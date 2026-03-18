将 air normals 和 ground normals 的以下这种形式：

- id: item_0213bd1615
    displayName: ジャンプ小パンチ
    children:
    - id: item_e0c2f756f3
      displayName: 垂直ジャンプ小パンチ
      detail:
        displayName: ハンドスタンプ
    - id: item_25ab24896c
      displayName: 斜めジャンプ小パンチ
      detail:
        displayName: ハンドスタンプ

改成：

- id: item_0213bd1615
    displayName: ジャンプ小パンチ
    variants:
    - id: item_e0c2f756f3
      displayName: 垂直
      detail:
        displayName: ハンドスタンプ
    - id: item_25ab24896c
      displayName: 斜め
      detail:
        displayName: ハンドスタンプ

相应的 MoveEntry 里面新增一个属性 var variants: [MoveVariant]
新增 MoveVariant 结构体

UI 方面，点击 带有 variants 的 entry 后会显示一个新的页面，这个页面的顶部有 segmented control，比如 ｜ 垂直 ｜ 斜め ｜，技能的详情就直接显示在下面了，用户点击 segmented control，详情就相应变化