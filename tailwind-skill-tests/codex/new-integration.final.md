## Stack
- Next.js（App Router，Turbopack/Webpack）：推荐用 PostCSS 方式安装 v4（`tailwindcss` + `@tailwindcss/postcss`），零配置起步，在全局样式中仅 `@import "tailwindcss"` 即可。([en.nextjs.im](https://en.nextjs.im/docs/app/guides/tailwind-css?utm_source=openai))
- Vite + React：推荐启用官方 Vite 插件 `@tailwindcss/vite`，在 `vite.config.ts` 中 `plugins: [tailwindcss()]`，性能更优于仅 PostCSS。([tailwindcss.com](https://tailwindcss.com/blog/tailwindcss-v4?utm_source=openai))
- Vue/Nuxt/Svelte（Vite 系）：同样优先 `@tailwindcss/vite`；若遇到生态插件冲突，可退回 PostCSS 方案。([tailwindcss.com](https://tailwindcss.com/blog/tailwindcss-v4?utm_source=openai))
- v4 配置理念：CSS-first，不再需要 `tailwind.config.js`（默认即可用）；在样式表中 `@import "tailwindcss"`，用 `@theme`/`@utility` 做定制。([tailwindcss.com](https://tailwindcss.com/blog/tailwindcss-v4?utm_source=openai))
- Source 扫描：v4 自动检测模板文件；需额外扫描或精确控制时，用 `@source` 与 `source()`（如 `@import "tailwindcss" source("../src");`）。([tailwindcss.com](https://tailwindcss.com/docs/detecting-classes-in-source-files?utm_source=openai))

## GateA
- 选型落锤：Next（PostCSS）或 Vite（Vite 插件），并确认包管理器与 Node 版本范围。
- CSS 入口与引入：明确全局样式文件路径与在根布局/入口处的 `import` 位置。
- Token 策略：是否采用 CSS-first `@theme` 统一变量（色板、字号、断点）。
- Source 策略：默认自动检测或需在样式中追加 `@source`/`source()` 以覆盖 monorepo/外部包。
- 约束清单：是否保留 Preflight、是否需要暗色模式与断点语义。

## GateB
- 视觉模式：继承现有系统 / 渐进演进 / 全量重置（三选一）。
- 字体与字号：系统字体或品牌字体加载策略（FOIT/FOUT 取舍）。
- 色彩与语义：品牌主色、语义色与明暗态配比；是否启用 OKLCH 变量。
- 间距与栅格：默认步进（如 4/8 pt）与容器宽度。
- 组件边界：哪些用原子类直写，哪些抽象为复合组件或 `@utility`。

## GateC
- 构建验证：本地 Dev 热更与 Prod 构建均产出正确 CSS（Next `next build`/Vite `vite build`）。
- Source 覆盖：示例页包含常见变体（hover/focus/lg 等），动态类（如 `grid-cols-[auto,1fr]`）可正确生成。
- 兼容范围：目标浏览器与可接受的自动前缀；关键页面 CLS/LCP 不因样式加载退化。
- 回归面：已有页面视觉无意外漂移；样式产物体积与生成时长在阈值内。
- 文档与交付：更新接入与维护文档（架构、方法、巡检清单）。

## MinimalSteps
- Next.js（PostCSS，官方推荐）
  - 初始化与安装：`npx create-next-app@latest myapp --ts --eslint && cd myapp && npm i -D tailwindcss @tailwindcss/postcss postcss`（v4 零配置起步）。([en.nextjs.im](https://en.nextjs.im/docs/app/guides/tailwind-css?utm_source=openai))
  - 配置 PostCSS：创建 `postcss.config.mjs`，内容仅 `{ plugins: { '@tailwindcss/postcss': {} } }`。([en.nextjs.im](https://en.nextjs.im/docs/app/guides/tailwind-css?utm_source=openai))
  - 引入样式：在全局 CSS（如 `src/app/globals.css`）添加一行：`@import "tailwindcss";`；在根布局 `layout.tsx` 引入该 CSS。([tailwindcss.com](https://tailwindcss.com/blog/tailwindcss-v4?utm_source=openai))
  - 验证：`npm run dev`，页面放入 `<div className="p-6 rounded-lg bg-emerald-500/10 text-emerald-600">OK</div>` 检查是否生效。
- Vite + React（首选 Vite 插件）
  - 初始化与安装：`npm create vite@latest myapp -- --template react-ts && cd myapp && npm i -D tailwindcss @tailwindcss/vite`
  - 启用插件：`vite.config.ts` 中 `import tailwindcss from "@tailwindcss/vite"; export default defineConfig({ plugins: [react(), tailwindcss()] })`。([tailwindcss.com](https://tailwindcss.com/blog/tailwindcss-v4?utm_source=openai))
  - 引入样式：`src/index.css` 写入 `@import "tailwindcss";`，并在 `main.tsx` 里 `import "./index.css"`。
  - 验证：`npm run dev`，页面加入测试块验证变体与任意值。
  - 兼容提示：若你在 `vite.config.ts` 设置了 `css.transformer: 'lightningcss'`，遇到 `@apply` 或控制台告警，请先移除此项以规避已知不兼容历史。([github.com](https://github.com/tailwindlabs/tailwindcss/issues/14205?utm_source=openai))
- 通用可选项
  - 若不走 Vite/框架插件，也可用 PostCSS 方式：安装 `tailwindcss @tailwindcss/postcss postcss` 并在 `postcss.config.*` 中启用，样式中仅 `@import "tailwindcss"`。([tailwindcss.com](https://tailwindcss.com/blog/tailwindcss-v4?utm_source=openai))
  - 需扫描外部包或限定扫描范围时，在样式中追加 `@source` / 使用 `source()` 控制基路径与 safelist。([tailwindcss.com](https://tailwindcss.com/docs/detecting-classes-in-source-files?utm_source=openai))

## Rollback
- 移除 v4（Next/PostCSS 路径）：`npm rm tailwindcss @tailwindcss/postcss postcss`，删去 CSS 中 `@import "tailwindcss"` 与 PostCSS 配置项，恢复页面到原生/其他样式方案。
- 移除 v4（Vite 插件路径）：`npm rm tailwindcss @tailwindcss/vite`，从 `vite.config.ts` 移除 `tailwindcss()`，并删去 CSS 中的 `@import "tailwindcss"`。
- 快速回退到 v3（如需验证对比）：
  - Next/Vite 通用：`npm i -D tailwindcss@3 postcss autoprefixer && npx tailwindcss init -p`，CSS 改为 `@tailwind base; @tailwind components; @tailwind utilities;`，`tailwind.config.js` 中补全 `content`。([v3.tailwindcss.com](https://v3.tailwindcss.com/docs/guides/nextjs?utm_source=openai))
- 风险声明：回退会使依赖 v4 的 `@theme`/`@utility` 与自动 Source 策略失效，需同步调整样式与构建设定。