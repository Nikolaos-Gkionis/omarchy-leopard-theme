-- Applied with the theme. Omarchy loads this after its own defaults.
-- Your looknfeel.lua is loaded later, so a rounding line there would win.
local active_border_color = "#e8b423"
local inactive_border_color = "rgba(595959aa)"

hl.config({
  general = {
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  decoration = {
    -- Corner radius in pixels. 0 is square. 8 is a small, clear curve.
    rounding = 8,
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },
})
