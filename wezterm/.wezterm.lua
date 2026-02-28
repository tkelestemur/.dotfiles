-- Pull in the wezterm API
local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.max_fps = 120
config.audible_bell = "Disabled"
config.font_size = 16.0
config.window_background_opacity = 0.8

return config
