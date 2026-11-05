# Example workflow: Building a tiny app with the new setup

> **Source:** https://www.devas.life/effective-neovim-setup-for-agentic-coding-towards-2027/  
> **Author:** Takuya Matsuyama  
> **Published:** 04 Nov 2026

To try the setup in a real agentic workflow, I built a keymap cheat sheet website with [Vite+](https://viteplus.dev/) and my agent.

To show how I use this setup day to day, I built a tiny app with it: a one-page cheat sheet of every keymap in this config.

I followed Inkdrop's [note-driven agentic coding](https://docs.inkdrop.app/start-guide/note-driven-agentic-coding) workflow.  
Each task gets one note, which works as a shared place for me and the agent.  
I write the requirements, and the agent fills in the rest of the plan.

## 1. Scaffold the app

I created a [Waku](https://waku.gg/) app in `~/Developments/devaslife/keymap-cheatsheet`:

```sh
npm create waku@latest
```

## 2. Write the requirements in a plan note

I created a new note and applied the built-in **Implementation plan** [note template](https://docs.inkdrop.app/reference/note-templates) with `Cmd+T`.

- The template starts with **Requirements** and **Related notes** sections for me to write.
- The rest is a skeleton for the agent: requirements restatement, current state, decisions, phases, risks, status, and outcome.
- Instructions for the agent live in `> # !Instructions` and `> # !Example` blocks.
  - Inkdrop strips them from the created note, and the agent reads them from the source template.

My requirements were just two lines, plus a link to the spec note:

```markdown
## Requirements

- Build a one-page keymap cheatsheet for my neovim setup
- It renders a simple table for each keymap

## Related notes

- [Set up Neovim](inkdrop://note/…)
```

## 3. Let the agent fill out the plan

I copied the note link and passed it to Claude Code:

```
fill out [Create a keymap cheatsheet for Neovim setup](inkdrop://note/eOuwoieG)
```

Claude Code reads and updates the note through the Inkdrop MCP server, using the `fill-out-template` skill.

Before writing the plan, it read both the spec note and my actual Lua config.

- It listed where every keymap is defined, with `file:line` references.
- It found mismatches between the spec and the config.
  - e.g. the spec had a typo, `:f` instead of `;f`, for finding files.
- It decided to trust the config over the spec.

Then it asked me about the decisions only I could make:

| Decision    | Question                                        | My pick                               |
| ----------- | ----------------------------------------------- | ------------------------------------- |
| Data source | Where does the page get its keymaps?            | A hand-curated, typed TS data file    |
| Coverage    | Spec tables only, or every key the config maps? | Every mapped key                      |
| Starter UI  | Keep the starter header and footer?             | Remove it, so there's one page at `/` |

It recorded my answers in **Decisions Needed** and broke the work into three phases:

1. Keymap data
2. Page and table component
3. Remove starter leftovers

Reviewing a plan is much cheaper than reviewing code, so this is where I spend my attention.

## 4. Implement it

I told Claude Code to work on it, and it implemented all three phases in **1 minute 18 seconds**.  
It checked off each phase in the note's **Status** section as it went.

The cheat sheet has 7 sections and 59 keys, with dark mode.

## 5. Review the code in Neovim

This is where the Git part of my setup comes in:

- `;g`: lazygit, to skim the whole diff
- `<leader>dv`: codediff, to walk through each changed file side by side
- `<leader>gd`: the mini.diff overlay, to see the changes inside a file

After the review, I switched the project to pnpm and committed it.

## 6. Record the outcome

Finally, I pasted a screenshot of the working page into Claude Code.  
It filled out the note's **Outcome** and **Follow-up** sections.

Now the note records what was built and why, including the follow-up to fix the typo in my spec. The finished note: [Create a keymap cheatsheet for Neovim setup](https://community.inkdrop.app/d975606d93c067c5ef8d6adfb5db83b5/eOuwoieG)
