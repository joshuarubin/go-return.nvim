# go-return.nvim

Snippet for writing contextually aware error handling in Go

Uses treesitter to determine the proper return types so that boilerplate error handling is automated.

```go
if err != nil {
    return <zero value>, <zero value>, err
}
```


## Requirements

- Neovim 0.7+
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [LuaSnip](https://github.com/L3MON4D3/LuaSnip)

## Installation

<details>
  <summary>Packer</summary>

```lua
use({
    "joshuarubin/go-return.nvim",
    branch = "main",
    requires = { "nvim-treesitter/nvim-treesitter", "L3MON4D3/LuaSnip" },
    config = function()
        require("go-return").setup({
            name = "ie"
        })
    end,
})
```
</details>

## Setup

The only option is the keyword name of the snippet. By default it is `ie`.
