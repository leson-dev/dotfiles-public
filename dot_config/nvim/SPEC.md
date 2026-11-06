# Setup Neovim

## The workflow

- Read the spec and implement only the step I name. Add nothing beyond it.
- Check your work lightly:
  - Neovim starts without errors: `nvim --headless +qa`
  - New keymaps exist: `:verbose map <key>`
- Don't build test projects or drive the UI. I check the behavior myself after the restart.

## 0. Prerequisites

### 0.1 Neovim

- [Neovim](https://neovim.io/doc/install/) **0.12** or newer.
  - The config relies on built-ins that landed in 0.12: `vim.pack`, `vim.lsp.enable`, and the ui2 message UI.

### 0.2 CLI tools

| Tool                           | Why                                                    |
| ------------------------------ | ------------------------------------------------------ |
| `git`                          | `vim.pack` clones plugins with it                      |
| `tree-sitter` CLI + C compiler | _nvim-treesitter_'s main branch builds parsers locally |
| `curl` and `tar`               | Parser and _blink.cmp_ binary downloads                |
| Node.js + npm                  | _Mason_ installs most language servers through npm     |
| `ripgrep` and `fd`             | Back the text search and the file finder               |
| `lazygit` and `git-delta`      | The git UI and its diff renderer                       |

### 0.3 Font

- A Nerd Font. I use [PlemolJP](https://github.com/yuru7/PlemolJP) Console NF.
  - Icons appear in the tabline, statusline, completion menu, and file explorer, so a plain font shows boxes.

### 0.4 Git

- The config folder is a git repository.
- `.gitignore` lists `nvim-pack-lock.json`.

## 1. Foundation

### 1.1 Layout

- `~/.config/nvim`: the config root folder
  - `init.lua`: enables `vim.loader` for faster startup, then requires these files directly, in order:
    1. `craftzdog.utils`, assigned to the global `Craftzdog`
    2. `craftzdog.config.options`, `.keymaps`, `.autocmds`, `.commands`, `.workarounds`
    3. `craftzdog.plugins`
  - `lua/craftzdog/`: my config lives here
    - `utils/`: shared helpers
      - `init.lua`: returns a table of helper modules, empty for now.
        - Later steps add modules like `utils/editor.lua`, exposed as `editor`.
    - `config/`: plain Neovim settings, one file per name above
    - `plugins/`
      - `init.lua`: installs every plugin in one `vim.pack.add` call, then requires each group file
      - Each plugin group gets its own file next to it (e.g. `ui.lua`), which configures its plugins with `require("<plugin>").setup({ ... })`.
      - `keymaps.lua`: every keymap that uses a plugin, required last so all plugins are set up first. Group files hold no keymaps.
- Lua files are indented with tabs, formatted by stylua with its defaults.

### 1.2 Leader and basics

- Leader and local leader are **Space**.
- Mouse is **off**. Keyboard-only.
- Clipboard is `unnamedplus`, so yank and paste go through the system clipboard.
- Indent is **2 spaces**:
  - `tabstop`, `shiftwidth`, and `softtabstop` are all **2**
  - `expandtab` and `smartindent` are **on**
- `-` counts as part of a word, so `foo-bar` is one word.
  - Fits CSS classes and kebab-case names.

### 1.3 Look of the buffer

- **Hybrid** line numbers: `number` + `relativenumber` **on**, so the cursor line shows its real number.
- `cursorline` **on**. No wrap, `scrolloff` **10**, `sidescrolloff` **8**.
- `signcolumn` **always on**.
  - Text doesn't jump when git or diagnostic marks appear.
- `cmdheight` **0** and one global statusline (`laststatus` **3**).
  - Maximizes vertical space.
- **Rounded** borders on every float (`winborder`).
- Popup menu: at most **10** rows, slightly see-through (`pumheight` **10**, `pumblend` **10**).
- Matching brackets flash briefly (`showmatch` **on**, `matchtime` **2**).
- `title` **on**, so the terminal tab shows the file name.
- Diagonal `╱` fill in empty diff areas.

### 1.4 Search, files, undo

- `ignorecase` + `smartcase` **on**: case-insensitive until a capital letter is typed.
- `path` adds `**`, so `:find` searches subfolders.
- `:` completion:
  - `wildmode` is `longest:full,full`
  - `wildignore` skips `*/node_modules/*`, `*.o`, `*.obj`, `*.pyc`, `*.class`, `*.jar`
- `swapfile` and `writebackup` **off**.
- Persistent undo (`undofile` **on**) lives in `~/.cache/nvim/undodir`.
  - Undo survives closing the file. Swap files only get in the way.
- Snappier timing: `updatetime` **300**, `timeoutlen` **500**, `ttimeoutlen` **0**.
  - Faster CursorHold events, and key sequences resolve without lag.

Try it:

- `/craftzdog` in `init.lua`, then `/Craftzdog`
- `:find opt<Tab>`
- Edit `init.lua`, `:wq`, reopen it, then `u`

### 1.5 Splits and folds

- New splits open **below** and to the **right**.
- Folds come from **Treesitter**, with `foldlevel` **99**.
  - Everything starts unfolded, and folds can still be closed by syntax.

Try it:

- `:split`, `:vsplit`
- `:e $VIMRUNTIME/lua/vim/keymap.lua`, then `zc` / `zo` inside a function
- `zM` / `zR`

### 1.6 Messages

Neovim 0.12's experimental **ui2** handles messages. It's turned on at the end of `config/options.lua`.

- Short messages: corner popup up to **30%** of the screen tall, gone after **5 seconds**.
- Long output (errors, `:ls`, `:verbose`, shell commands, progress): a scrollable pager up to **half** the screen.
- Search count, search pattern, completion, `:` completion list, and confirm prompts stay in the command line.
- Output of a command I type goes to the command line too, whatever its kind.
  - It expands over the bottom of the screen until the next key.
  - `Enter` moves it into the pager.

[tiny-cmdline.nvim](https://github.com/rachartier/tiny-cmdline.nvim) shows the `:` command line as a floating box, centered left to right, **20%** from the top. It's set up in `plugins/ui.lua`.

- With `cmdheight` 0, the command line needs somewhere to appear, and near the top is where the eyes already are.

Try it:

- `:echo "hi"`
- `:lua print("hi")`
- `:foo`
- `:!ls`
- `:verbose set ts?`

### 1.7 Autocmds

- Yanked text flashes briefly.
- Only the active window shows the cursorline.

### 1.8 Core keymaps

| Keys                                  | Action                                                                | Notes                                                                              |
| ------------------------------------- | --------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| `x`                                   | Deletes without copying                                               |                                                                                    |
| `<leader>d`, `<leader>c`, `<leader>p` | Delete, change, and paste without touching the yank register          | The yanked text stays safe while editing around it.                                |
| `dw`                                  | Deletes the word backwards without copying                            |                                                                                    |
| `+` / `-`                             | Increment and decrement numbers                                       |                                                                                    |
| `<C-a>`                               | Selects all                                                           |                                                                                    |
| `te`                                  | Opens a new tab                                                       |                                                                                    |
| `ss` / `sv`                           | Split                                                                 | Short, home-row window control.                                                    |
| `sh` `sj` `sk` `sl`                   | Move between windows                                                  | Short, home-row window control.                                                    |
| `<C-m>`                               | Jumps forward in the jump list                                        | Alias for `<C-i>`, which Tab-less terminals send as Tab.                           |
| `<leader>o` / `<leader>O`             | Open a line below or above without continuing a comment (`o<Esc>^Da`) |                                                                                    |

### 1.9 Close hidden buffers

- `<leader>bd` closes every hidden buffer, except unsaved ones.

## 2. Look & feel

### 2.1 Colorscheme

- [solarized-osaka](https://github.com/craftzdog/solarized-osaka.nvim), `vivid` style, **transparent** background.
  - The terminal's blur shows through, and the palette matches the Ghostty theme.

### 2.2 Icons

- [mini.icons](https://github.com/nvim-mini/mini.icons), also mocking [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons).
  - One icon source for every plugin.

### 2.3 Tabline

A custom tabline in `utils/tabline.lua`, with no plugin.

- Shown only when there are **2** or more tabs.
- Each tab shows the active window's file name with its icon, padded with **3** spaces, between slanted separators.
  - Both edges slant outward going down, so each tab is a trapezoid, wider at the bottom.
- Colors from the _solarized-osaka_ palette:
  - Active tab: bold **base4** text on **yellow**
  - Inactive tab: **base0** on **base02**
  - The icon takes the tab's text color.
  - The separators take the tab's color on a transparent background, and so does the empty area after the last tab.
- Names longer than **20** characters are cut to **17** plus `…`.
- Unsaved tabs show `[+]` before the icon.
- Terminals show `[Terminal]` and empty buffers `[No Name]`, with no icon.

### 2.4 Statusline

[lualine](https://github.com/nvim-lualine/lualine.nvim), one global bar, theme `auto`.

| Section | Content                                                                       |
| ------- | ----------------------------------------------------------------------------- |
| a       | Mode                                                                          |
| b       | Git branch                                                                    |
| c       | Project root name (only when it differs from cwd), filetype icon, pretty path |
| x       | Macro recording register, diagnostics, git diff counts                        |
| y       | Progress                                                                      |
| z       | line:column                                                                   |

- The project root is found by searching upward for `.git`, `lua`, `package.json`, `Makefile`, `Cargo.toml`, `go.mod`, or `pyproject.toml`.
- Refreshes on cursor move and macro start/stop.
  - The recording indicator replaces the hidden command line.

### 2.5 Window labels

- [incline.nvim](https://github.com/b0o/incline.nvim) shows a filename tag with an icon in the top-right corner of each window, plus `[+]` when unsaved.
  - With a single global statusline, each split still needs to say which file it holds.
- The tag hides when the cursor reaches its line.

### 2.6 Snacks

[snacks.nvim](https://github.com/folke/snacks.nvim) provides the notifier, indent guides, statuscolumn, and word highlighting.  
Later steps turn on more of it, like the picker and the lazygit integration.

- **Words**: the word under the cursor is highlighted everywhere. `]]` / `[[` jump between occurrences.
  - It needs a language server, so it works after step 5.1.
- **Smooth scroll** is **off**.
  - Scrolling should feel instant.

## 3. Navigating

### 3.1 Picker

The _snacks.nvim_ picker.

| Keys | Action                             | Notes                                                                  |
| ---- | ---------------------------------- | ---------------------------------------------------------------------- |
| `;f` | Finds files, including hidden ones | Dotfiles like `.github/` and `.env.example` are part of real projects. |
| `;r` | Live-greps, including hidden files |                                                                        |
| `;;` | Reopens the last picker            |                                                                        |
| `\\` | Lists open buffers                 | Jumps to a window that already shows the buffer.                       |
| `;e` | Lists diagnostics                  |                                                                        |
| `;n` | Shows notification history         |                                                                        |
| `;h` | Lists git hunks                    |                                                                        |

### 3.2 File explorer

[oil.nvim](https://github.com/stevearc/oil.nvim) replaces netrw and shows hidden files.

- The directory is a buffer, so renaming, moving, and deleting files is plain text editing followed by `:w`.
- Columns: icon, permissions, size, modified time.
- Renaming a file asks the LSP to update imports and saves those edits automatically.
- In the tabline (2.3), an oil tab shows its directory (`~/foo`) with no icon.
  - Paths longer than **20** characters are cut from the left to `…` plus the last **17**.

| Keys | Action                                            | Notes                                               |
| ---- | ------------------------------------------------- | --------------------------------------------------- |
| `sf` | Opens oil as a centered float with a live preview | At most **200** columns wide, with rounded corners. |
| `h`  | Goes to the parent directory                      |                                                     |
| `q`  | Closes oil                                        |                                                     |

## 4. Syntax

### 4.1 Treesitter

[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter), main branch.

- Ensures 38 parsers:
  - astro, bash, c, cmake, cpp, css, diff, fish, gitignore, go, graphql, html, http, java, javascript, jsdoc, json, lua, luadoc, luap, markdown, markdown_inline, php, printf, python, query, regex, rust, scss, sql, svelte, toml, tsx, typescript, vim, vimdoc, xml, yaml
- A FileType autocmd starts highlighting and Treesitter indent whenever a parser exists.
- `:TSUpdate` runs on the `PackChanged` event.
  - Parsers stay in sync with the plugin version.

### 4.2 Small highlights

- [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) highlights `TODO`, `FIXME`, and the like, with defaults.
- [nvim-highlight-colors](https://github.com/brenoprata10/nvim-highlight-colors) paints hex, rgb, hsl, ANSI, and CSS variable colors as backgrounds. Tailwind is off.
  - Neovim's LSP document colors are turned off, so colors aren't painted twice.

## 5. Code smarts

### 5.1 Language servers

[Mason](https://github.com/mason-org/mason.nvim) + [mason-tool-installer](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim) install on start, and never auto-update:

- Servers: lua-language-server, vtsls, eslint-lsp, oxlint, tailwindcss-language-server, css-lsp, rust-analyzer, intelephense
- Formatters: prettier, prettierd, oxfmt, stylua, shfmt

[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) supplies defaults.

- Servers are turned on with `vim.lsp.enable`: eslint, oxlint, lua_ls, cssls, vtsls, tailwindcss, rust_analyzer, intelephense.
- Every server gets file-rename support (`didRename` / `willRename`).

### 5.2 Diagnostics look

- Underlined, not updated while typing, sorted by severity.
- Inline text: `● message`, with the source only when there are several.
- Gutter icons come from the shared icon set.

For example, typing `const x: number = 'a'` in a TSX file:

- The error is underlined, with `● Type 'string' is not assignable…` inline and an icon in the gutter.
- The line also has a "never read" hint, but the gutter shows the error icon, since they are sorted by severity.
- oxlint flags the unused `x` too, so each message shows its source (`ts`, `oxc`).

### 5.3 Per-server settings

Per-server settings live in `after/lsp/<name>.lua`.  
Neovim 0.12 merges these automatically, so there's no setup boilerplate.

- **vtsls**:
  - Uses the workspace TypeScript and updates imports on file move.
  - Server-side fuzzy matching and function-call completion.
  - Inlay hints are short: no variable types, **30** characters max.
- **lua_ls**: knows the Neovim runtime, shows param-type hints, silences a few noisy checks.
- **cssls**: ignores empty rules.
- **oxlint**: starts with `oxlint --lsp`.
- **intelephense**: PHP; attaches to `php` buffers rooted at `composer.json`, and indexes the workspace in the background.

### 5.4 Completion

[blink.cmp](https://github.com/saghen/blink.cmp), version `^1`, `enter` preset: Enter accepts.

- Every language server from 5.1 also gets _blink.cmp_'s completion capabilities.
- Auto-brackets after functions. Docs pop up after **200 ms**.
- Menu items are colorized by Treesitter, with kind icons from the shared icon set.
- Ghost text is **off**.

- In the command line, the menu opens by itself for `:` commands only, with nothing preselected.

### 5.5 Pairs

- [mini.pairs](https://github.com/nvim-mini/mini.pairs) with defaults, in insert and command mode.

### 5.6 Formatting

[conform.nvim](https://github.com/stevearc/conform.nvim) formats with a **500 ms** timeout, falling back to the LSP. Format on save is **off** by default (`vim.g.autoformat = false`).

| Filetypes                                                          | Formatter                                              |
| ------------------------------------------------------------------ | ------------------------------------------------------ |
| js, ts, jsx, tsx, json, css, scss, less, html, markdown, mdx, yaml | oxfmt, then prettierd, then prettier (first available) |
| lua                                                                | stylua                                                 |
| sh                                                                 | shfmt                                                  |
| fish                                                               | fish_indent                                            |

- oxfmt runs only when the project has an oxfmt config, like `.oxfmtrc.json` or a Vite+ `vite.config.ts`.
  - Projects using prettier keep their own formatter.
- `:ToggleFormatter` turns format-on-save on or back off for the current buffer, with a notification.
  - The command lives in `config/commands.lua`.

### 5.7 LSP keymaps

| Keys                    | Action                                                                             | Notes                                          |
| ----------------------- | ---------------------------------------------------------------------------------- | ---------------------------------------------- |
| `gd`                    | Goes to the definition                                                             | Through the picker, like `gD`, `gy`, and `gr`. |
| `gD`                    | Goes to the declaration                                                            |                                                |
| `gy`                    | Goes to the type definition                                                        |                                                |
| `gr`                    | Lists references                                                                   |                                                |
| `gI`                    | Goes to the source definition in TypeScript, the implementation in other languages | Skips the `.d.ts` to reach the real code.      |
| `;c`                    | Lists incoming calls                                                               |                                                |
| `K`                     | Shows hover docs                                                                   |                                                |
| `gK` / `<C-k>` (insert) | Show signature help                                                                |                                                |
| `<C-j>`                 | Jumps to the next diagnostic with a float                                          |                                                |
| `<leader>ca`            | Shows code actions                                                                 |                                                |
| `<leader>cr`            | Renames the symbol                                                                 |                                                |
| `<leader>cR`            | Renames the file with import updates                                               |                                                |
| `<leader>f`             | Formats now                                                                        |                                                |
| `<leader>cl`            | Shows LSP info                                                                     |                                                |

## 6. Git

Since I mostly review code written by my agent now, this is the part of the setup I use the most.

### 6.1 Signs and blame

[gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) with defaults.

| Keys         | Action                                                                   | Notes                                                          |
| ------------ | ------------------------------------------------------------------------ | -------------------------------------------------------------- |
| `<leader>gb` | Blames the line                                                          |                                                                |
| `<leader>gB` | Blames the buffer                                                        |                                                                |
| `<leader>go` | Opens the file as of the commit that last touched the line, in a new tab | Shows the context of an old change without leaving the editor. |
| `<leader>gs` | Stages the buffer, or unstages it if nothing is left to stage            |                                                                |
| `<leader>gh` | Stages or unstages the hunk                                              |                                                                |

### 6.2 Diff overlay

[mini.diff](https://github.com/nvim-mini/mini.diff) from my fork ([`craftzdog/mini.diff`](https://github.com/craftzdog/mini.diff/tree/feat/grouping), branch `feat/grouping`).

- The fork groups changes into whole hunks, the way `git diff` shows them.

| Keys         | Action              |
| ------------ | ------------------- |
| `<leader>gd` | Toggles the overlay |
| `]c` / `[c`  | Jump between hunks  |

### 6.3 Diff view

[codediff.nvim](https://github.com/esmuellert/codediff.nvim) for side-by-side diffs and history.  
I use it when my agent makes a lot of changes in the codebase.

- Explorer: **tree** view, **50** columns wide, opens files as the cursor moves, shows +/- line stats.
- Compact mode: only changes plus **8** context lines, with folds synced across panes.

| Keys         | Action                           |
| ------------ | -------------------------------- |
| `<leader>dv` | Toggles the diff view            |
| `<leader>dh` | Shows the current file's history |
| `<leader>dH` | Shows the repo history           |

### 6.4 Lazygit

`;g` opens [lazygit](https://github.com/jesseduffield/lazygit) in a float through _snacks.nvim_, with the theme synced and the active border in the WarningMsg color.

Pressing `e` on a file closes lazygit and opens the file in the window it was launched from, through `$NVIM` and `nvim --server --remote`.

- `;g` remembers the current window.
- `e` quits lazygit, focuses that window with `--remote-send`, then opens the file, so the cursor ends up in the file.
- Not a new tab and not a nested Neovim. Outside Neovim, it just runs `nvim <file>`.
- The edit command is written in fish syntax.

Lazygit's own config lives in `~/.config/lazygit/config.yml`, outside the Neovim config. _snacks.nvim_ loads it together with the synced theme. It holds:

- Diffs render with `delta --dark --paging=never --syntax-theme="Solarized (dark)"`.
- Mouse events are off and auto-fetch is off.
- `C` in the files panel commits with commitizen (`git cz`).

### 6.5 Links

- [gitlinker.nvim](https://github.com/linrongbin16/gitlinker.nvim): `:GitLink` copies a GitHub URL for the current line, or the selected range.

## 7. Agentic coding

These are small helpers for passing context from Neovim to an agent.

### 7.1 Copy paths for agents

| Keys         | Action                                                         | Notes                                       |
| ------------ | -------------------------------------------------------------- | ------------------------------------------- |
| `<leader>yf` | Copies the current file's path relative to cwd with `#L<line>` | e.g. `lua/craftzdog/config/options.lua#L12` |
| `<leader>yp` | Copies the absolute path the same way                          |                                             |

- Both show the copied text in a notification.
  - Pasting the path into an agent's prompt points it at the exact line.

### 7.2 Helper keymaps

| Keys                  | Action                                                                                    | Notes                                                                                                    |
| --------------------- | ----------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| `<leader>cc` (visual) | Copies the selection as a Markdown code block with `filename="…"` and `line=…` attributes | The same format Inkdrop uses for code-block attributes. Short language names (`tsx`, `jsx`, `ts`, `js`). |
| `<leader>j`           | Opens the project's `package.json` in a centered **80%** float. `q` or `Esc` closes it.   |                                                                                                          |
