Plugins included directly in this repository:

- [indentmini](https://github.com/nvimdev/indentmini.nvim) for indentation guides.
- [mini.completion](https://github.com/echasnovski/mini.completion) for automatic display of
  completion items and signature help.
- [mini.pick](https://github.com/echasnovski/mini.pick) for searching over files +
  [mini.extra](https://github.com/echasnovski/mini.extra) for searching over LSP symbols.

Source code of these plugins is directly included into the config, because I would prefer to deal
with plugin managers or git submodules as little as possible.

Update all plugins:

```sh
curl https://raw.githubusercontent.com/nvimdev/indentmini.nvim/refs/heads/main/lua/indentmini/init.lua -o ./lua/indentmini.lua
curl https://raw.githubusercontent.com/echasnovski/mini.completion/refs/heads/main/lua/mini/completion.lua -o ./lua/mini/completion.lua
curl https://raw.githubusercontent.com/echasnovski/mini.pick/refs/heads/main/lua/mini/pick.lua -o ./lua/mini/pick.lua
curl https://raw.githubusercontent.com/echasnovski/mini.extra/refs/heads/main/lua/mini/extra.lua -o ./lua/mini/extra.lua
```

---

Optional plugins included via submodules:

- [oil.nvim](https://github.com/stevearc/oil.nvim) as a Netrw replacement.
- [nvim-dap](https://github.com/mfussenegger/nvim-dap) for debugging.

Clone the repository with submodules initialized automatically:

```sh
git clone --recursive https://github.com/poppyfanboy/nvim
```

Initialize submodules for an already cloned repository:

```sh
git submodule update --init --recursive
```

Update all submodules:

```sh
git submodule update --recursive --remote
```
