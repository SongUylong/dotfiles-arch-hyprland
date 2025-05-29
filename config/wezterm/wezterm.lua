local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.enable_wayland = false
config.font_size = 20
config.color_scheme = "Catppuccin Macchiato"
config.enable_tab_bar = true
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.5
config.font = wezterm.font("JetBrains Mono", { weight = "Regular", stretch = "Normal", style = "Normal" })
config.window_close_confirmation = "AlwaysPrompt"
config.scrollback_lines = 3000
config.inactive_pane_hsb = {
	saturation = 0.24,
	brightness = 0.5,
}

-- Plugin: bar.wezterm

local moon = "🌙"
local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
bar.apply_to_config(config, {
	position = "top",
	max_width = 22,
	padding = { left = 1, right = 1 },
	modules = {
		leader = {
			enabled = true,
			icon = moon,
			color = 4,
		},
		tab = {
			enabled = true,
			icon = wezterm.nerdfonts.oct_file_directory,
			color = 2,
		},
		clock = {
			enabled = true,
			icon = wezterm.nerdfonts.fa_clock,
			format = "%I:%M",
		},
		workspace = {
			enabled = true,
			color = 6,
		},
		zoom = {
			enabled = true,
			icon = wezterm.nerdfonts.md_fullscreen,
			color = 4,
		},
		pane = {
			enabled = false,
			icon = wezterm.nerdfonts.cod_multiple_windows,
			color = 7,
		},
		username = {
			enabled = false,
			icon = wezterm.nerdfonts.fa_user,
			color = 6,
		},
		hostname = {
			enabled = false,
			icon = wezterm.nerdfonts.cod_server,
			color = 8,
		},
		cwd = {
			enabled = true,
			icon = wezterm.nerdfonts.oct_file_directory,
			color = 7,
		},
	},
})

config.disable_default_mouse_bindings = true

config.colors = {
	foreground = "#CBE0F0",
	background = "#011423",
	cursor_bg = "#47FF9C",
	cursor_border = "#47FF9C",
	cursor_fg = "#011423",
	selection_bg = "#033259",
	selection_fg = "#CBE0F0",
	ansi = {
		"#214969",
		"#E52E2E",
		"#44FFB1",
		"#FFE073",
		"#0FC5ED",
		"#a277ff",
		"#24EAF7",
		"#24EAF7",
	},
	brights = {
		"#214969",
		"#E52E2E",
		"#44FFB1",
		"#FFE073",
		"#A277FF",
		"#a277ff",
		"#24EAF7",
		"#24EAF7",
	},
}

local act = wezterm.action
config.leader = { key = "w", mods = "SUPER", timeout_milliseconds = math.maxinteger }

config.keys = {
	{ key = "c", mods = "LEADER", action = act.ActivateCopyMode },
	--Pane Split
	{ key = "v", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "h", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	--Panes Move
	{ key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },
	--Panes Zoom
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	--Panes Close
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "X", mods = "LEADER", action = act.EmitEvent("close-all-other-panes") },
	--Panes Rotate
	{ key = "r", mods = "LEADER", action = act.RotatePanes("Clockwise") },
	--Panes Resize
	{ key = "s", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
	-- Workspace
	{ key = "w", mods = "LEADER", action = act.ActivateKeyTable({ name = "workspace" }) },
	-- Tabs
	{ key = "t", mods = "LEADER", action = act.ActivateKeyTable({ name = "tab" }) },
	{
		key = "p",
		mods = "LEADER",
		action = wezterm.action_callback(function(window, pane)
			local selection = window:get_selection_text_for_pane(pane)

			-- If we have a selected text and it matches a URL pattern, open it
			if selection and selection ~= "" then
				local url_pattern = "https?://%S+"
				if selection:match(url_pattern) then
					wezterm.log_info("Opening: " .. selection)
					wezterm.open_with(selection) -- Opens the URL in the default browser
				else
					wezterm.log_info("No URL selected!")
				end
			end
		end),
	},
}
config.mouse_bindings = {
	-- Ctrl-click will open the link under the mouse cursor
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}

config.key_tables = {
	tab = {
		{ key = "o", action = act.SpawnTab("CurrentPaneDomain") },
		--Tab Navigation
		{ key = "[", action = act.ActivateTabRelative(-1) },
		{ key = "]", action = act.ActivateTabRelative(1) },
		-- Key table for moving tabs around
		{ key = "m", action = act.ActivateKeyTable({ name = "move_tab", one_shot = false }) },
		-- Tab Close
		{ key = "x", action = act.CloseCurrentTab({ confirm = true }) },
		{ key = "X", action = act.EmitEvent("close-all-other-tabs") },
	},
	move_tab = {
		{ key = "h", action = act.MoveTabRelative(-1) },
		{ key = "j", action = act.MoveTabRelative(-1) },
		{ key = "k", action = act.MoveTabRelative(1) },
		{ key = "l", action = act.MoveTabRelative(1) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
	resize_pane = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 5 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 5 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 5 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 5 }) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
	workspace = {
		{ key = "f", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
		{
			key = "n",
			action = act.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { AnsiColor = "Fuchsia" } },
					{ Text = "Enter name for new workspace" },
				}),
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						window:perform_action(
							act.SwitchToWorkspace({
								name = line,
							}),
							pane
						)
					end
				end),
			}),
		},
		{ key = "l", action = act.SwitchWorkspaceRelative(1) },
		{ key = "h", action = act.SwitchWorkspaceRelative(-1) },
	},
}
--utils of panes
wezterm.on("close-all-other-panes", function(window, pane)
	local tab = pane:tab()
	local panes = tab:panes()

	for _, p in ipairs(panes) do
		if p:pane_id() ~= pane:pane_id() then
			p:activate()
			window:perform_action(act.CloseCurrentPane({ confirm = false }), p)
		end
	end
end)
for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "ALT",
		action = act.ActivateTab(i - 1),
	})
end
--utils of tabs
wezterm.on("close-all-other-tabs", function(window, pane)
	local tab = window:active_tab()
	local mux_window = window:mux_window()
	local tabs = mux_window:tabs()

	for _, t in ipairs(tabs) do
		if t:tab_id() ~= tab:tab_id() then
			t:activate()
			window:perform_action(wezterm.action.CloseCurrentTab({ confirm = false }), pane)
		end
	end
end)
return config
