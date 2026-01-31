local M = {}

local parsers = require('dolper.parsers')

local function get_visual_selection()
    local s_start = vim.fn.getpos("'<")
    local s_end = vim.fn.getpos("'>")
    local n_lines = math.abs(s_end[2] - s_start[2]) + 1
    local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
    lines[1] = string.sub(lines[1], s_start[3], -1)
    if n_lines == 1 then
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
    else
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
    end
    return table.concat(lines)
end

local function get_word_under_cursor()
    local curr_pos = vim.fn.getpos('.')
    local curr_line = vim.fn.getline('.')
    local line_length = vim.fn.strlen(curr_line)
    local end_pos = {curr_pos[1], curr_pos[2], line_length, curr_pos[4]}

    if line_length == 0 then return "" end

    local lines = vim.fn.getregion(curr_pos, end_pos)
    return table.concat(lines)
end

function M.try_parsing(input)
    local output = {}
    for _, h in ipairs(M['handlers']) do
        local handler_result = h(input)
        if handler_result ~= nil then
            output[#output + 1] = handler_result
        end
    end
    return output
end

function M.setup(opts)
    local hex_handler = parsers.default_hex_handler
    local dec_handler = parsers.default_dec_handler
    local custom_handlers = nil
    if opts ~= nil then
        if opts['hex_handler'] ~= nil then
            hex_handler = opts['hex_handler'][1]
        end
        if opts['dec_handler'] ~= nil then
            dec_handler = opts['dec_handler'][1]
        end
        if opts['custom_handlers'] ~= nil and type(opts['custom_handlers']) == 'table' then
            custom_handlers = opts['custom_handlers']
        end
    end
    M['handlers'] = {}
    if hex_handler ~= nil then M['handlers'][#M['handlers'] + 1] = hex_handler end
    if dec_handler ~= nil then M['handlers'][#M['handlers'] + 1] = dec_handler end
    if custom_handlers ~= nil then
        for i=1,#custom_handlers do
            M['handlers'][#M['handlers']+1] = custom_handlers[i]
        end
    end
end


function M.popup(is_visual)
    -- window already open
    if M['win'] ~= nil then
        if M['autocmd_id'] == nil then
            vim.api.nvim_win_close(0, true)
            M['win'] = nil
            return
        end
        vim.api.nvim_del_autocmd(M['autocmd_id'])
        M['autocmd_id'] = nil
        vim.api.nvim_set_current_win(M['win'])

        vim.api.nvim_create_autocmd({'WinLeave'}, {
                once = true,
                callback = function()
                    vim.api.nvim_win_close(M['win'], true)
                    M['win'] = nil
                    M['autocmd_id'] = nil
                end,
        })
        return
    end

    local message = ""
    if is_visual then
        message = get_visual_selection()
    else
        message = get_word_under_cursor()
    end

    local buf = vim.api.nvim_create_buf(false, true)

    local parsing_output = M.try_parsing(message)
    local width = vim.fn.strlen(message)
    local height = #parsing_output

    if height == 0 then
        parsing_output = {"No info"}
        height = 1
    end

    for i, m in ipairs(parsing_output) do
        if width < vim.fn.strlen(m) then
            width = vim.fn.strlen(m)
        end
        vim.api.nvim_buf_set_lines(buf, i-1, i-1, false, {m})
    end

    -- Create the floating window
    local opts = {
        relative = 'cursor',
        width = width,
        height = height,
        col = 0,
        row = 0,
        anchor = 'SW',
        style = 'minimal',
        border = { '+', '-', '+', '|', '+', '-', '+', '|' },
    }
    M['win'] = vim.api.nvim_open_win(buf, false, opts)

    -- Change highlighting
    vim.api.nvim_set_option_value('filetype', vim.o.filetype, { buf = buf })
    M['autocmd_id'] = vim.api.nvim_create_autocmd({"CursorMoved"}, {
        once = true,
        callback = function()
            vim.api.nvim_win_close(M['win'], true)
            M['autocmd_id'] = nil
            M['win'] = nil
        end,
    })
end

return M
