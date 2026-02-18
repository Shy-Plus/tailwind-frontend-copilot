## Diagnosis
- 版本与栈确认：`tailwindcss@4.1.3` + `@tailwindcss/vite` + `vite@5.4.0`（package.json:8-11），属于 Tailwind v4 + 官方 Vite 插件方案。
- 样式入口：`src/index.css` 仅包含 `@import "tailwindcss";`（src/index.css:1），但在项目中未被任何入口文件引用（未找到对 `index.css` 的 import）。
- 动态 class 用法：`src/App.tsx` 使用模板字符串 `bg-${color}-500`（src/App.tsx:3）。这类“运行时拼接 class 名”的写法在 Tailwind 的扫描/生成阶段不可静态解析，因而不会产出对应的 CSS。
- Vite 配置：`vite.config.ts` 已启用 `@tailwindcss/vite` 插件（vite.config.ts:2-3），符合 v4 推荐接入路径。
- 结论汇总：
  - 问题A（基础样式未加载）：未引入 `src/index.css`，即便静态类也不会生效。
  - 问题B（动态类不生成）：`bg-${color}-500` 这种模板字符串不被 Tailwind 生成器识别，需改为“静态可枚举”或“CSS 变量 + arbitrary value”等模式，或用 safelist 明确列出。

## GateA
- 目标：确保 Tailwind 在构建链路中被执行且产物注入页面。
- 现状评估：
  - 已有：`@tailwindcss/vite` 插件开启，`src/index.css` 正确 `@import "tailwindcss"`（v4 推荐）。
  - 缺失：`src/index.css` 未被入口引入；缺少 `main.tsx/index.html` 常规入口结构。因此 GateA 未通过，页面不会加载 Tailwind 产物。
- 证据命令（已执行）：
  - 列目录与包信息：`ls -la`、`cat package.json`
  - 搜索 Tailwind/CSS 入口引用：`rg -n "index.css|@tailwind|tailwindcss" -S`（仅命中 src/index.css、自身配置与依赖）
  - 读取 Vite 配置：`sed -n '1,200p' vite.config.ts`

## GateC
- 目标：确保待使用的类名能被扫描并生成。
- 现状评估（v4 with @tailwindcss/vite）：
  - 静态类：会被插件正常识别与生成。
  - 模板字符串拼接类（如 `bg-${color}-500`）：无法被静态分析，默认不生成，对应样式缺失。
  - v4 不再强制配置 `content` 路径；但“可静态发现”这一前提仍成立——动态拼接依旧不可用，需改写或 safelist。
- 证据命令（已执行）：
  - 搜索动态拼接：`rg -n "bg-\\$\\{|text-\\$\\{|class(Name)?=.*\\$\\{" -S src`（命中 src/App.tsx:3）

## FixPlan
- 修复优先级（先打通 GateA，再解决动态类）：
  - 引入样式入口（GateA）：在你的应用入口（通常 `src/main.tsx`）里添加 `import "./index.css"`；若缺少标准入口，请按 Vite React 模板补齐 `index.html` + `src/main.tsx` 并在其中引入 `index.css`。
  - 替代动态拼接（GateC）三选一：
    - 显式枚举（推荐，适用于有限集）：用映射替代模板字符串，保证类名在源码中“可见”。示例：
      - `const bgMap = { red: "bg-red-500", blue: "bg-blue-500" } as const;`
      - `className={clsx(bgMap[color] ?? "bg-red-500", "text-white p-4")}`
    - CSS 变量 + arbitrary value（适用于任意颜色值，例如十六进制/RGB/来自后端）：
      - `className="bg-[--bg] text-white p-4"` 并设置 `style={{ '--bg': '#ef4444' }}` 或计算得到的颜色值（TypeScript 可写成 `as React.CSSProperties`）。
      - 注意：此路劲是“值”动态，类名本身保持静态，Tailwind 能生成 `bg-[--bg]` 对应规则。
    - safelist（适用于可列举但分散在运行时的 Token）：新增 `tailwind.config.ts` 并配置
      - `export default { safelist: [{ pattern: /^bg-(red|blue|green)-(100|200|300|400|500)$/ }] }`
      - 根据你的色板/深浅实际扩展。此方式让生成器强制产出匹配类。
- 代码组织建议：
  - 将颜色 Token 的来源（主题/后端字典）收敛为一份白名单，前端以映射形式承载，避免在模板字符串里直接拼接 Tailwind token。

## Validation
- GateA 验证（样式注入）：
  - 引入样式后，运行本地预览：`npx vite`（或 `npm run dev` 若已配置脚本）。
  - 浏览器检查元素应含有 Tailwind 基础样式（如 `p-4` 的 padding 生效、`text-white` 生效）。
- GateC 验证（类生成）：
  - 显式枚举方案：在页面切换 `color` 的不同枚举值，观察背景色是否随之变化；构建后检查产物 CSS 是否包含 `bg-red-500`/`bg-blue-500` 等。
  - CSS 变量方案：将 `style={{ '--bg': '#00ff00' }}`，观察背景是否变为对应颜色；构建后无需存在具体 `bg-xxx-yyy` 类，`bg-[--bg]` 规则应存在。
  - safelist 方案：执行构建（`npx vite build`）后，grep 产物：
    - `rg -n \"\\.bg-red-500|\\.bg-blue-500\" dist -S`
    - 命中则代表 safelist 生效。
- 回归检查：
  - `rg -n \"\\$\\{.*\\}\" src` 确认不再有用于 Tailwind token 的模板字符串拼接（可允许存在但不用于类名）。
  - 变更后再次打开页面，确认动态样式路径按预期工作且无控制台警告。