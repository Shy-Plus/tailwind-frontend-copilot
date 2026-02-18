**Diagnosis**
- 症状：某些“动态 class”（如模板字符串拼接、运行时拼接、条件分支返回的非常量 class）在页面上不生效，元素上能看到 className，但无对应样式。
- 根因范式（常见高命中率）：
  - 内容扫描缺失：`tailwind.config.js` 的 `content` 未覆盖到 `.tsx/.ts`、外部包、动态载入路径，导致构建时未生成对应原子类。
  - 非静态 class：`bg-${color}-500`、`${size && 'p-' + size}` 这类并非“完整字面量”的类名，Tailwind 构建期无法解析，故不会产出 CSS。
  - 运行时合并器副作用：`tailwind-merge/twMerge` 把语义上并非互斥的类合并掉（例如先有 `p-2` 后追加 `p-4` 被吞，或与 `!important`、变体顺序冲突）。
  - 图层/引入顺序：全局样式或第三方样式在 `@tailwind utilities` 之后覆盖了原子类；或缺失 `@tailwind base/components/utilities` 的任一层。
  - 任意值/任意变体用法错误：`bg-[color:var(--x)]`、`data-[state=open]:...`、`group-[.active]:...` 等写法不规范（括号、引号、转义）或版本不支持。
  - 条件渲染分支未被扫描：只在运行时才出现的文本（SSR 分支、惰性组件、动态 import 组件）未在静态源里出现，导致产物缺失。
  - 外部组件库：本地 node_modules 内自研包/本地包的 TSX 中包含原子类，但未纳入 `content`。

**GateA**
- 目标：确认 Tailwind 产物是否正确注入与层级正确。
- 核对点：
  - 页面最终 HTML 的 `<style>`/构建 CSS 中能搜到典型类（如 `p-2`, `bg-red-500`）与变体（`hover:bg-…`、`sm:p-…`）。
  - 全局样式文件里存在完整的 `@tailwind base; @tailwind components; @tailwind utilities;`，且自定义 CSS 应该写在 `@tailwind utilities` 之后才采用更高专一度选择器。
  - 浏览器开发者工具中，对同一元素的 Tailwind 规则没有被后续选择器（特别是第三方样式或全局样式）覆盖。

**GateC**
- 目标：确认“类名可被静态扫描到”与“内容覆盖面完整”。
- 核对点：
  - `content` 包含：`src/**/*.{js,ts,jsx,tsx}`，以及实际放置组件的所有目录（含 `app/`、`pages/`、`components/`、`features/`、`shared/` 等），以及任何本地包（如 `packages/ui/**/*.{ts,tsx}`）。
  - 动态 class 是否可落到“完整字面量字符串”。凡是 `${}`、字符串拼接、数组 map 生成片段，最终都要在源文件中呈现为具体的 `class="..."` 值集合，才能被扫描。
  - 若需要运行时变化的“参数化样式”，是否改为以下可扫描策略之一：类名白名单映射、`safelist`（含正则）、CSS 变量 + 任意值语法、data-attribute 变体。
  - 若使用 `twMerge`/`clsx`，检查合并顺序与覆盖逻辑是否导致关键类被移除。

**FixPlan**
- 修正动态生成为静态可扫描：
  - 用映射代替拼接：例如把 `bg-${color}-500` 改为 `const bgMap = { red: 'bg-red-500', blue: 'bg-blue-500', … }`，再 `className={bgMap[color] ?? 'bg-gray-500'}`。
  - 条件尺寸同理：`p-${size}` 改为 `const pMap = { sm:'p-2', md:'p-4', lg:'p-6' }`。
- 无法穷举时的两条官方友好路径：
  - `safelist`：在 `tailwind.config.js` 中添加精确枚举或正则，如 `safelist: ['bg-red-500','bg-blue-500', …]` 或 `safelist: [{ pattern: /(bg|text|border)-(red|blue|green)-(100|500|700)/ }]`。
  - 任意值 + CSS 变量：把值动态放到 CSS 变量，类名保持静态可扫描，例如：
    - 在元素上设置 `style={{ '--btn-bg': colorHex }}`，类写成 `bg-[var(--btn-bg)]`。
    - 尺寸同理：`style={{ '--pad': '1rem' }}` + `p-[var(--pad)]`。
- 校正 content 覆盖：
  - 补全所有源码/本地包路径与扩展名；确保被懒加载的组件源文件也位于 `content` 扫描范围内。
- 规避合并器副作用：
  - 对关键冲突类禁用 `twMerge` 或调整顺序，确保最终保留的是你期望的类。必要时对互斥组保持单一来源（只从映射返回一个确定值）。
- 变体/任意选择器规范化：
  - 确保 `data-[state=open]:…`、`group-[.active]:…`、`aria-[expanded=true]:…` 等写法语法正确（括号、等号、转义）。
  - 若用 `peer`/`group` 变体，确认对应的触发元素层级与属性存在。
- 层级与覆盖：
  - 保证 `@tailwind utilities` 在自定义组件样式前引入；如需覆盖，使用更高专一度或 `!important`（尽量少用）。

**Validation**
- 元素级验证：
  - 打开开发者工具，选中目标元素，检查“规则面板”是否存在对应 Tailwind 声明；确认没有被后续选择器覆盖。
  - 手动切换触发条件（hover/focus/data-state）观察类是否在 DOM 上切换，且对应规则已存在。
- 产物级验证：
  - 在构建产物/开发模式的注入 CSS 中搜索本次修复涉及的类（如 `bg-blue-500`、`p-6`、`data-[state=open]` 对应规则），确认存在。
  - 对使用 `safelist`/正则的场景，抽样几项边界值（最深/最浅色阶、最小/最大尺寸）确认均被产出。
- 回归与约束：
  - 对所有“可变样式点”统一采用“映射/变量/白名单”三选一策略，并在代码评审中检查是否出现新的字符串拼接。
  - 如使用 `twMerge`，为常见互斥组（空间、颜色、排版）加单元测试或故事用例，验证最终 class 不被误吞。