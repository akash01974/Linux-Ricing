-- matugen generated Neovim colorscheme
-- Source: Material You (Matugen)

local M = {}

M.normal = {
  bg = "{{ colors.surface_container_lowest.dark.hex }}",
  fg = "{{ colors.on_surface.dark.hex }}",
}

M.cursor = {
  bg = "{{ colors.primary.dark.hex }}",
  fg = "{{ colors.on_primary.dark.hex }}",
}

M.selection = {
  bg = "{{ colors.secondary.dark.hex }}",
  fg = "{{ colors.on_secondary.dark.hex }}",
}

M.comment = {
  fg = "{{ colors.on_surface_variant.dark.hex }}",
}

M.line_numbers = {
  fg = "{{ colors.on_surface_variant.dark.hex }}",
  bg = "{{ colors.surface_container_lowest.dark.hex }}",
}

M.pmenu = {
  bg = "{{ colors.surface_container.dark.hex }}",
  fg = "{{ colors.on_surface.dark.hex }}",
  sel_bg = "{{ colors.primary_container.dark.hex }}",
  sel_fg = "{{ colors.on_primary_container.dark.hex }}",
}

M.keyword = "{{ colors.secondary.dark.hex }}"
M.string = "{{ colors.primary.dark.hex }}"
M.function_name = "{{ colors.tertiary.dark.hex }}"
M.type_name = "{{ colors.secondary.dark.hex }}"
M.constant = "{{ colors.on_primary_fixed_variant.dark.hex }}"
M.number = "{{ colors.tertiary_fixed_dim.dark.hex }}"
M.operator = "{{ colors.on_surface.dark.hex }}"
M.variable = "{{ colors.on_surface.dark.hex }}"
M.parameter = "{{ colors.on_surface_variant.dark.hex }}"
M.preprocessor = "{{ colors.secondary_fixed_dim.dark.hex }}"
M.error = "{{ colors.error.dark.hex }}"
M.warning = "{{ colors.tertiary_fixed_dim.dark.hex }}"
M.info = "{{ colors.primary.dark.hex }}"
M.hint = "{{ colors.secondary.dark.hex }}"
M.todo = "{{ colors.primary_fixed_dim.dark.hex }}"

M.diff = {
  add = "{{ colors.secondary_fixed_dim.dark.hex }}",
  change = "{{ colors.tertiary_fixed_dim.dark.hex }}",
  delete = "{{ colors.error.dark.hex }}",
  text = "{{ colors.primary.dark.hex }}",
}

M.border = "{{ colors.outline_variant.dark.hex }}"
M.visual_bg = "{{ colors.primary_container.dark.hex }}"
M.search_bg = "{{ colors.primary_fixed.dark.hex }}"
M.search_fg = "{{ colors.on_primary_fixed.dark.hex }}"
M.substitute_bg = "{{ colors.tertiary_fixed.dark.hex }}"

M.tab = {
  active_bg = "{{ colors.primary.dark.hex }}",
  active_fg = "{{ colors.on_primary.dark.hex }}",
  inactive_bg = "{{ colors.surface_container.dark.hex }}",
  inactive_fg = "{{ colors.on_surface_variant.dark.hex }}",
}

M.statusline = {
  bg = "{{ colors.surface_container.dark.hex }}",
  fg = "{{ colors.on_surface.dark.hex }}",
  mode_bg = "{{ colors.primary.dark.hex }}",
  mode_fg = "{{ colors.on_primary.dark.hex }}",
}

M.winbar = {
  bg = "{{ colors.surface_container.dark.hex }}",
  fg = "{{ colors.on_surface_variant.dark.hex }}",
}

M.git = {
  added = "{{ colors.secondary_fixed_dim.dark.hex }}",
  changed = "{{ colors.tertiary_fixed_dim.dark.hex }}",
  removed = "{{ colors.error.dark.hex }}",
}

M.lsp = {
  error = "{{ colors.error.dark.hex }}",
  warning = "{{ colors.tertiary_fixed_dim.dark.hex }}",
  info = "{{ colors.primary.dark.hex }}",
  hint = "{{ colors.secondary.dark.hex }}",
  reference_bg = "{{ colors.primary_container.dark.hex }}",
}

M.telescope = {
  bg = "{{ colors.surface_container_lowest.dark.hex }}",
  fg = "{{ colors.on_surface.dark.hex }}",
  sel_bg = "{{ colors.primary_container.dark.hex }}",
  sel_fg = "{{ colors.on_primary_container.dark.hex }}",
  border = "{{ colors.outline_variant.dark.hex }}",
  title = "{{ colors.primary.dark.hex }}",
}

return M
