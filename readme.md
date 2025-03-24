Plugins used:

- [indentmini](https://github.com/nvimdev/indentmini.nvim) for indentation guides.
- [mini.completion](https://github.com/echasnovski/mini.completion) for automatic display of
  completion items and signature help.
- [mini.pick](https://github.com/echasnovski/mini.pick) for searching over files +
  [mini.extra](https://github.com/echasnovski/mini.extra) for searching over LSP symbols.

Source code of the plugins is directly included into the config, because I don't want to deal with
plugin managers or git submodules.

Update all plugins:

```sh
curl https://raw.githubusercontent.com/nvimdev/indentmini.nvim/refs/heads/main/lua/indentmini/init.lua -o ./lua/indentmini.lua
curl https://raw.githubusercontent.com/echasnovski/mini.completion/refs/heads/main/lua/mini/completion.lua -o ./lua/mini/completion.lua
curl https://raw.githubusercontent.com/echasnovski/mini.pick/refs/heads/main/lua/mini/pick.lua -o ./lua/mini/pick.lua
curl https://raw.githubusercontent.com/echasnovski/mini.extra/refs/heads/main/lua/mini/extra.lua -o ./lua/mini/extra.lua
```
