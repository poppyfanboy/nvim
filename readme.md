Plugins used:

- [indentmini](https://github.com/nvimdev/indentmini.nvim) for indentation guides.
- [mini.completion](https://github.com/echasnovski/mini.completion) for automatic display of
  completion items and signature help.
- [mini.pick](https://github.com/echasnovski/mini.pick) for searching over files +
  [mini.extra](https://github.com/echasnovski/mini.extra) for searching over LSP symbols.
- [onehalf](https://github.com/sonph/onehalf) colorscheme.

Source code of the plugins is directly included into the config, because I don't want to deal with
plugin managers or git submodules.

Update all plugins:

```sh
curl https://raw.githubusercontent.com/nvimdev/indentmini.nvim/refs/heads/main/lua/indentmini/init.lua -o ./lua/indentmini.lua
curl https://raw.githubusercontent.com/echasnovski/mini.completion/refs/heads/main/lua/mini/completion.lua -o ./lua/mini/completion.lua
curl https://raw.githubusercontent.com/echasnovski/mini.pick/refs/heads/main/lua/mini/pick.lua -o ./lua/mini/pick.lua
curl https://raw.githubusercontent.com/echasnovski/mini.extra/refs/heads/main/lua/mini/extra.lua -o ./lua/mini/extra.lua
```

---

UPD: Ok, I give up, I hate Netrw and I also need support for debug adapters. So, I've added
[oil.nvim](https://github.com/stevearc/oil.nvim) and
[nvim-dap](https://github.com/mfussenegger/nvim-dap) as git submodules. They are optional and the
core `init.lua` config is still usable on its own though.

Clone the repository with submodules:

```sh
git clone --recursive https://github.com/poppyfanboy/nvim
```

Initialize submodules for an already cloned repository:

```sh
git submodule update --init --recursive
```

Update all submodules:

```sh
git submodule foreach git pull
```
