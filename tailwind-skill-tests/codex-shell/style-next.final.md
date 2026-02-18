## Baseline
- 框架/版本：Next.js 15.1.0、React 18.3.1、Tailwind CSS 4.1.3（@tailwindcss/postcss 集成）。证据：package.json:1, package.json:6-9
- PostCSS 接入：仅启用 '@tailwindcss/postcss' 插件。证据：postcss.config.mjs:1-5
- Tailwind v4 用法：CSS 入口通过 `@import "tailwindcss";`，并使用 `@theme` 定义令牌（颜色/字体）。证据：app/globals.css:1, app/globals.css:3-6
- 令牌现状：已定义 `--color-brand-500: #0a7ea4;` 与 `--font-display`，页面使用 `bg-brand-500` 与 `text-white`。证据：app/globals.css:4, app/page.tsx:2
- 对比度校验：#0a7ea4 与白色对比度≈4.63，满足 WCAG AA 正文阈值≥4.5（本次会话内计算）。
- 结构最小：`app/` 下仅有 `globals.css` 与 `page.tsx`，无 `tailwind.config.*`（符合 v4 无配置默认），`styles/` 为空。证据：ls 与 rg 输出
- 潜在风险：缺少 `app/layout.tsx` 可能导致全局样式未注入及构建失败（Next App Router 必备）。当前仅做风格/性能方案，不改文件。

## GateB
- 建议风格模式：Incremental Evolution（渐进演进）
- 选择理由：已有品牌主色与最小令牌，不宜做全面视觉重置；在保持现有色彩与结构前提下补齐令牌与版式可快速提升质感、风险最低。
- 变更边界：仅增量补齐主题令牌与可访问性状态样式；不更改信息架构、不更换品牌方向、不引入破坏性全局重置。
- 非目标：不做重品牌、不调整组件 API、不引入大型 UI 套件。

## StyleStrategy
- 主题令牌（不破坏现有）：
  - 字体映射：在 `@theme` 中将 `--font-sans` 指向 `--font-display`，确保 `font-sans` 即用即得（保留系统与中文回退）。参考：app/globals.css:3-6
  - 品牌色阶：在现有 `--color-brand-500` 基础上补 `--color-brand-600/700` 以用于 hover/focus 阶段，保持统一视觉层级。
  - 中性色：按需补一档 `--color-gray-900` 与 `--color-gray-500` 以便文本/分隔线统一。
- 版式系统：
  - 标题：大标题使用 `text-balance tracking-tight leading-tight`，正文使用 `leading-relaxed text-pretty` 提升可读性。
  - 容器：采用 `.container mx-auto px-6 md:px-8` 的页面包裹策略，保证边距与网格节律统一。
- 交互与可访问性：
  - 焦点环：统一 `focus-visible:outline-none focus-visible:ring-2 ring-brand-500/40`，可读且不刺眼。
  - 悬停/按压：`motion-safe:transition-colors`，并提供 `hover:bg-brand-600 active:bg-brand-700` 渐进层级。
  - 降噪动效：`motion-reduce:transition-none`，尊重用户“减少动效”设置。
- 组件边界与语义：
  - 保持实用类组合，不进行运行时拼接；对重复组合以原子为主，必要时引入极少量 `@utility` 自定义工具类。

## PerformancePlan
- 内容扫描收敛：
  - 在全局 CSS 顶部声明 `@source "app/**/*.{ts,tsx}";` 以缩小扫描面，降低开发时编译与热更开销（Tailwind v4 推荐做法）。
- 动态类消除与审计：
  - 审核运行时拼接类名，使用映射表 + `clsx/cva` 保持类名静态化；当前检索仅发现静态类。证据：app/page.tsx:2
  - 命令（审计示例）：`rg -n \"class(Name)?=\\\"[^\"]*\\$\\{\" app`（应无结果）；`rg -n \"bg-\\$|text-\\$|p-\\$|m-\\$\" app`
- 构建与体积验证（建议在本仓库执行）：
  - 生产构建：`npm i && npx next build`（需先补 `app/layout.tsx` 才可通过；此处仅给出验证路径）
  - CSS 体积：`du -h .next/static/css || true`、`wc -c .next/static/css/*.css || true`
  - 变更前后对比：`git diff --stat && git diff | rg \"@theme|@source|ring-brand|brand-6|brand-7\"`
- RSC 与客户端边界：
  - 页面/组件默认 Server 组件；仅在确需交互时标注 `\"use client\"`，避免不必要的客户端包体与水合。
- 资源与字体：
  - 继续采用系统字体栈（当前 `--font-display` 已含中文与无衬线回退），避免网络字体阻塞；若后续引入 `next/font`，需度量 LCP/FOUT。

## Acceptance
- 风格验收：
  - 主色层级统一，hover/focus/active 显示一致；正文/标题排版符合上文版式策略；对比度≥AA（正文≥4.5，按钮文本≥4.5）。
- 性能验收：
  - Tailwind 扫描面已限制在 `app/**/*.{ts,tsx}`；无运行时类名拼接；生产构建 CSS 无异常膨胀（仅包含使用到的工具类）。
- 构建与回归：
  - `next build` 成功（补齐必要 `app/layout.tsx` 后验证）；关键页面视觉无回归；交互状态在键鼠与触屏下一致。
- 可观测性与回滚：
  - 通过 `git` 粒度小的提交记录变更；出现回归可一键回滚到变更前状态。
- 后续动作（需您确认 Gate B 后执行）：
  - 按上述 StyleStrategy 补齐极少量 `@theme` 令牌与焦点环策略；声明 `@source`；提交 PR 并给出前后截图与构建体积对比报告。