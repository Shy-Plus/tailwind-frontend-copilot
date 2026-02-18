## StyleMode
- 模式：Token-first + Semantic Utilities（在不改动设计系统语义的前提下，用 Tailwind 工具类承载现有设计变量）
- 原则：保持设计系统权威（颜色/字号/间距/圆角/阴影/动效均沿用现有 tokens），以最小侵入提升层级、密度、状态与可访问性
- 手段：CSS variables → Tailwind 映射（不改 token 名），组件局部增强（focus/hover/aria/data states）、暗色与对比度修正、布局与节奏微调

## GateB
- 选项（默认 Inherit）：
  - Inherit（默认）：严格继承现有设计系统，仅做视觉与交互细化，不新增品牌/语义层
  - Subtle Elevation：在 Inherit 基础上增加轻量 3D/光影/动效，保持品牌克制
  - Modernize Aggressive：引入更前沿布局与大幅留白/动态主题，可能影响信息密度与对照
  - Accessibility-First：以对比度、焦点可见性与键盘路径为优先，允许轻度偏离现有视觉
  - Theming Expansion：加入多主题（暗黑/高对比/品牌色变体），需要 tokens 覆盖度良好
- 本次默认：Inherit

## ImprovementPlan
- 色彩与对比度
  - 为语义色添加对比安全层：`text-[--fg] bg-[--bg] data-[state=active]:bg-[--bg-active]`
  - 提升交互对比：`hover:bg-[color]/8 active:bg-[color]/12`；暗色分支用 `dark:` 同步
- 焦点与可访问性
  - 统一焦点环：`focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[--primary] focus-visible:ring-offset-2 focus-visible:ring-offset-[--bg]`
  - 键盘可达性：为可交互元素补 `role`/`aria-*`，用 `aria-*:` 变体标态
- 空间与节奏
  - 统一垂直节奏：标题/段落/组件外边距采用 `clamp()` 对齐排版网格，示例：`mt-[clamp(12px,2vh,20px)]`
  - 列表/表格密度档位：`data-density=compact|cozy|comfortable` 分别映射 `gap-1|gap-2|gap-3`
- 组件细化（示例）
  - 按钮：`inline-flex items-center justify-center rounded-[--radius-sm] px-3.5 py-2.5 text-[--btn-fg] bg-[--btn-bg] hover:bg-[--btn-bg-hover] disabled:opacity-50 disabled:pointer-events-none focus-visible:(ring-2 ring-[--primary] ring-offset-2)`
  - 输入：`bg-[--field-bg] border border-[--field-border] focus-within:border-[--primary] focus-within:shadow-[0_0_0_3px_color-mix(in_oklab,theme(colors.primary)_70%,transparent)]`
  - 卡片：`rounded-[--radius-md] shadow-sm hover:shadow-md transition-shadow duration-200`
  - 弹窗：`backdrop:bg-black/50 data-[state=open]:animate-in data-[state=closed]:animate-out`
- 暗色/高对比
  - 采用 `dark:` 与 `@media (prefers-contrast: more)` 双轨；暗色不改变语义，只变换背景/层级与分隔线透明度
- 动效与性能
  - 统一动效 token：`duration-150/200/300`、`ease-[--ease-standard]`；为首屏关键元素加 `will-change` 白名单
  - 为 Reduced Motion：`@media (prefers-reduced-motion: reduce){ * { animation: none; transition: none; } }`
- 布局与容器
  - 采用容器查询优化响应式：`.container @container (min-width:...){ ... }` 配合 `sm|md|lg` 断点，不改变现有断点语义
- 文案与排版
  - 标题/正文/辅助文字绑定语义尺寸：`text-[--fs-title] leading-[--lh-title] tracking-[--trk-title]`，避免直接写死像素
- 数据状态与 Skeleton
  - 统一 loading/empty/error 三态：`data-[status=loading]:opacity-60`、骨架：`animate-pulse bg-[--muted]/50`
- 可落地检查清单
  - 按页面逐块应用：Header/导航/列表页/详情页/表单/弹窗/表格
  - 对每块产出 Before/After 截图与对比度数值（WCAG AA/AAA）

## RiskControl
- Token 偏离风险
  - 约束：仅通过 `var(--token)` 与 Tailwind utilities 组合，禁止引入硬编码品牌色
  - 审核：设计/前端双签 Gate，变更清单记录 token 触达面
- 选择器/特异性冲突
  - 约束：只在 `@layer components` 承载少量模式样式，避免深层后代选择器
  - 工具：开启 `:where()` 降特异性策略，必要时建立“重置 → 基础 → 组件 → 覆盖”层序
- 暗色与高对比不一致
  - 方案：每新增视觉规则必须同时列出 `dark:`/对比媒介分支；可视回归对两模式分别跑
- 体积与构建
  - 约束：优先原子类，谨慎 `@apply`；避免无约束的动态类插值
  - 检查：构建后 CSS 体积阈值报警与按路由切片抽样
- 可视回归与无障碍
  - 工具面：Storybook 交互快照 + 暗色/高对比矩阵；axe/keyboard 路径脚本化
  - 指标面：对比度 ≥ 4.5:1（正文），焦点环≥2px 且与背景有色相差异
- 回滚与灰度
  - 策略：按页面/组件打 `feature flag`，支持快速关闭；变更以“组件组”为单位可回滚
  - 文档：在项目“样式提升”文档中记录每次变更的范围、截图、影响与风险评估