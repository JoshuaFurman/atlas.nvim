# atlas.nvim

A lightweight Neovim plugin that displays a navigable Table of Contents for Markdown files in a floating window.

## Features

- 📝 **Auto-generated TOC**: Parses Markdown headers (`#`, `##`, etc.) automatically.
- 🪟 **Floating Window**: Displays the TOC in a centered floating window with rounded borders.
- 🚀 **Fast Navigation**: Jump instantly to any header.
- 🧠 **Smart Parsing**: Ignores comments inside code blocks.
- 🎨 **NVChad Friendly**: Uses standard highlights and borders to match your theme.
- 🔧 **Zero Dependencies**: Uses only Neovim built-in APIs.

## Installation

Install with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "JoshuaFurman/atlas.nvim",
  cmd = { "Atlas" },
  config = function()
    require("atlas").setup({})
  end,
}
```

If you are developing this locally, you can point to the local directory:

```lua
{
  dir = "/path/to/atlas",
  cmd = { "Atlas" },
  config = function()
    require("atlas").setup()
  end,
}
```

## Usage

1. Open a Markdown file.
2. Run the command:
   ```vim
   :Atlas
   ```
3. A floating window will appear with the Table of Contents.
   - **`j` / `k`**: Navigate up and down.
   - **`<Enter>`**: Jump to the selected header.
   - **`q` / `<Esc>`**: Close the window.

## Configuration

The `setup` function accepts a table of options. Defaults are shown below:

```lua
require("atlas").setup({
  -- Ensure the command only runs on supported filetypes
  check_filetype = true,
})
```
