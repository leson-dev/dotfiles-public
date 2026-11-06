-- Rex config. Reload with: rex config reload
local terminal = "com.superlogical.terminal"

-- Open lazygit in a floating pane over the current window, in the focused
-- terminal's directory. The pane closes when lazygit quits (q).
rex.action{
  name  = "lazygit_float",
  title = "Open lazygit in a floating pane",
  category = "Git",
  run   = function(ctx, args)
    local cwd
    if ctx.block_id then
      local r = rex.block.call(terminal, "pwd", { block_id = ctx.block_id })
      -- pwd is a file://HOST/path URL
      if r and r.pwd then cwd = r.pwd:gsub("^file://[^/]*", "") end
    end
    local _, err = rex.session.new_layer{
      bounds = { 0.05, 0.05, 0.9, 0.9 },
      focus  = true,
      layout = rex.layout.block{
        flavor  = terminal .. ".shell",
        label   = "lazygit",
        options = { command = { "lazygit" }, cwd = cwd },
      },
    }
    if err ~= nil then error(err, 0) end
  end,
}

rex.bind("cmd+g", "lazygit_float")
