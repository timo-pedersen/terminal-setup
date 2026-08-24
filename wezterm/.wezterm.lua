local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

local ucrt64 = {
  'cmd.exe',
  '/c',
  'C:\\msys64\\msys2_shell.cmd -here -defterm -no-start -ucrt64',
}

local mingw64 = {
  'cmd.exe',
  '/c',
  'C:\\msys64\\msys2_shell.cmd -here -defterm -no-start -mingw64',
}

-- Cursor
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_ease_in = 'Ease'
config.scrollback_lines = 3000

-- Looks
config.initial_cols = 155
config.initial_rows = 33
config.color_scheme = 'Geohot'
config.font_size = 10
config.line_height = 1.0
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'

-- Behavior
config.window_close_confirmation = 'NeverPrompt'
-- config.default_prog = ucrt64
config.default_prog = mingw64
-- config.default_prog = {
--   'C:\\msys64\\usr\\bin\\env.exe', 'MSYS=disable_pcon', 'MSYSTEM=MINGW64',
--   'CHERE_INVOKING=1', 'C:\\msys64\\usr\\bin\\bash.exe', '--login', '-1'
-- }
config.default_cwd = 'C:/git'

-- Tab bar
config.use_fancy_tab_bar = true

config.colors = {
  tab_bar = {
    inactive_tab_edge = '#BBBBBB',
    background = '#0b0022',
  },
}

config.window_frame = {
  font = wezterm.font {
    family = 'Roboto',
    weight = 'Bold',
  },
  font_size = 9.0,
  active_titlebar_bg = '#333355',
  inactive_titlebar_bg = '#333355',
}

wezterm.on('update-right-status', function(window, pane)
  local date = wezterm.strftime '%a %Y-%m-%d %H:%M:%S'

  window:set_right_status(wezterm.format {
    { Foreground = { AnsiColor = 'Yellow' } },
    { Background = { Color = '#333355' } },
    { Text = ' ' .. date .. ' ' },
  })
end)

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local zoomed = ''
  if tab.active_pane.is_zoomed then
    zoomed = '[Z] '
  end

  local title = tab.active_pane.title
  local cwd = tab.active_pane.current_working_dir

  if cwd then
    local path = cwd.file_path

    -- Normalize Windows separators, remove trailing slash,
    -- then take only the final directory component.
    path = path:gsub('\\', '/'):gsub('/+$', '')
    title = path:match('([^/]+)$') or path
  end

  return zoomed .. title
end)

wezterm.on('window-config-reloaded', function(window, pane)
  window:toast_notification(
    'wezterm',
    'Configuration reloaded.',
    nil,
    4000
  )
end)

-- Mouse
config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = act.PasteFrom 'Clipboard',
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'Clipboard',
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'CTRL|SHIFT',
    action = act.SendString 'explorer .\n',
  },
}

-- Launcher
config.launch_menu = {
  {
    label = 'UCRT64',
    args = ucrt64,
  },
  {
    label = 'Git Bash',
    args = { 'C:/Program Files/Git/bin/bash.exe', '-i', '-l' },
  },
  {
    label = 'CMD',
    args = { 'cmd.exe' },
  },
  {
    label = 'PowerShell',
    args = { 'powershell.exe' },
  },
}


table.insert(config.launch_menu, {
  label = 'MINGW64 XXXXXXXXX',
  args = {
    'C:\\msys64\\usr\\bin\\env.exe',
    'MSYSTEM=MINGW64',
    'CHERE_INVOKING=1',
    'C:\\msys64\\usr\\bin\\bash.exe', '--login', '-i',
  },
})

table.insert(config.launch_menu, {
  label = 'UCRT64 XXXXXX',
  args = {
    'C:\\msys64\\usr\\bin\\env.exe',
    'MSYSTEM=UCRT64',
    'CHERE_INVOKING=1',
    'C:\\msys64\\usr\\bin\\bash.exe', '--login', '-i',
  },
})

-- Leader
config.leader = {
  key = 'a',
  mods = 'CTRL',
  timeout_milliseconds = 1000,
}

local test_text = string.rep('abcdefghij ', 50)

config.keys = {
  {
    key = 'F11',
    mods = 'NONE',
    action = wezterm.action_callback(function(window, pane)
      pane:send_text(test_text)
    end),
  },
  {
    key = 'F12',
    mods = 'NONE',
    action = wezterm.action_callback(function(window, pane)
      pane:send_paste(test_text)
    end),
  },
  -- Ctrl-A Ctrl-A sends an actual Ctrl-A.
  {
    key = 'a',
    mods = 'LEADER|CTRL',
    action = act.SendKey { key = 'a', mods = 'CTRL' },
  },

  -- Splits
  {
    key = 'h',
    mods = 'LEADER',
    action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'v',
    mods = 'LEADER',
    action = act.SplitVertical { domain = 'CurrentPaneDomain' },
  },

  -- Explorer
  {
    key = 'e',
    mods = 'LEADER',
    action = act.SendString 'explorer .\n',
  },

  -- Move current tab
  {
    key = '0',
    mods = 'LEADER',
    action = wezterm.action_callback(function(window, pane)
      local tabs = window:mux_window():tabs()
      window:perform_action(act.MoveTab(#tabs - 1), pane)
    end),
  },
  {
    key = '1',
    mods = 'LEADER',
    action = act.MoveTab(0),
  },
  {
    key = '2',
    mods = 'LEADER',
    action = act.MoveTab(1),
  },
  {
    key = '3',
    mods = 'LEADER',
    action = act.MoveTab(2),
  },
  {
    key = '4',
    mods = 'LEADER',
    action = act.MoveTab(3),
  },
  {
    key = '5',
    mods = 'LEADER',
    action = act.MoveTab(4),
  },
}

return config
