# dolper.nvim

Neovim plugin for displaying additional information by parsing data under cursor.

By default it is able to parse numbers in hexadecimal/decimal format under cursor and show them:
* in other format (decimal/hexadecimal)
* with reversed endianess
* as array of uint8

## Screenshots
<img width="612" height="116" alt="image" src="https://github.com/user-attachments/assets/aa64fdd3-adbe-4134-a4ad-9e34bda99385" />
<img width="486" height="93" alt="image" src="https://github.com/user-attachments/assets/2e10d901-9360-40a9-9db5-8d71ecb6e75b" />

## Configuration
### Basic configuration
```lua
require('dolper').setup()

local opts = { noremap = true }
mapk = vim.api.nvim_set_keymap

mapk('n', '<leader>h', ":lua require('dolper').popup(false)<CR>", opts)
mapk('v', '<leader>h', "<ESC>:lua require('dolper').popup(true)<CR>", opts)
```
### Adding custom handlers
```lua
require('dolper').setup({
    custom_handlers = {
        function(input)
            return string.format("%s has length %d", input, vim.fn.strlen(input))
        end
    },

})
```
<img width="550" height="96" alt="image" src="https://github.com/user-attachments/assets/f128696c-6167-4b3b-a5b0-60c9190755bf" />

### Disabling default handlers
```lua
require('dolper').setup({
    hex_handler = { nil },
    dec_handler = { nil },
})
```
