![nvim screenshot](./images/screenshot-neovim.png)

# Takuya's dotfiles

**Warning**: Don’t blindly use my settings unless you know what that entails. Use at your own risk!

### Looking for an AI-native tech notes app?

Check out my app called [Inkdrop](https://www.inkdrop.app/)

[![Inkdrop](./images/screenshot-inkdrop.jpg)](https://www.inkdrop.app/)

## Contents

Managed with [chezmoi](https://www.chezmoi.io/).

- Neovim config
- tmux config
- Ghostty config
- git and lazygit config
- fish config
- Homebrew package list

## Neovim setup

### Requirements

- Neovim >= **0.12** (plugins are managed with the built-in `vim.pack`)
- Git
- [lazygit](https://github.com/jesseduffield/lazygit) **_(optional)_**
- [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter) and a **C** compiler for `nvim-treesitter`
- for the [snacks.nvim](https://github.com/folke/snacks.nvim) picker:
  - **live grep**: [ripgrep](https://github.com/BurntSushi/ripgrep)
  - **find files**: [fd](https://github.com/sharkdp/fd)
- a terminal that supports true color and _undercurl_, such as [Ghostty](https://ghostty.org/)
- [Solarized Osaka](https://github.com/craftzdog/solarized-osaka.nvim)

## Terminal setup

- [Ghostty](https://ghostty.org/) - Terminal emulator
- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer

### Fonts

Installed as Homebrew casks from the `Brewfile`:

- [PlemolJP](https://github.com/yuru7/PlemolJP) (`PlemolJP Console NF`) - A mix of IBM Plex Mono and IBM Plex Sans JP
- [BlexMono Nerd Font](https://github.com/ryanoasis/nerd-fonts)

## Shell setup (macOS)

- [Fish shell](https://fishshell.com/)
- [Fisher](https://github.com/jorgebucaran/fisher) - Plugin manager
- [Tide](https://github.com/IlanCosman/tide) - Shell theme
- [z for fish](https://github.com/jethrokuan/z) - Directory jumping
- [Eza](https://github.com/eza-community/eza) - `ls` replacement
- [ghq](https://github.com/x-motemen/ghq) - Local Git repository organizer
- [fzf](https://github.com/PatrickF1/fzf.fish) - Interactive filtering

## How to use

Watch my video tutorials:

1. [My Neovim setup](https://www.youtube.com/watch?v=fFHlfbKVi30)
   - [Article version](https://www.devas.life/effective-neovim-setup-for-web-development-towards-2024/)
1. [My dev workflow using tmux and vim](https://www.youtube.com/watch?v=sSOfr2MtRU8&list=PLxQA0uNgQDCICMRwlOzWAZBPL05XBC_br&index=10)
1. [A productive command-line Git workflow for indie app developers](https://www.youtube.com/watch?v=qKpY7t5m35k&list=PLxQA0uNgQDCICMRwlOzWAZBPL05XBC_br&index=4)
   - [Blogpost](https://dev.to/craftzdog/a-productive-command-line-git-workflow-for-indie-app-developers-k7d)
1. [My Fish shell workflow for coding](https://www.youtube.com/watch?v=KKxhf50FIPI)

## About me

- [@inkdrop_app on X](https://twitter.com/inkdrop_app)
- [Newsletters](https://www.devas.life/)
- [My product: Inkdrop - Markdown note-taking app](https://www.inkdrop.app/)
