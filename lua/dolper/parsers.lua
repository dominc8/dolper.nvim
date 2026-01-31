local parsers = {}

local function parse_hex(input)
    local reversed_endianess_input = ""
    local n = vim.fn.strlen(input)
    local arr_u8_s = "as_u8[]="
    local prefix_s = "{"
    local i = 1
    if n % 2 == 1 then
        reversed_endianess_input = "0" .. string.sub(input, 1, 1)
        arr_u8_s = arr_u8_s .. prefix_s .. tonumber(string.sub(input, 1, 1), 16)
        prefix_s = ", "
        i = 2
    end
    while i < n do
        reversed_endianess_input = string.sub(input, i, i+1) .. reversed_endianess_input
        arr_u8_s = arr_u8_s .. prefix_s .. tonumber(string.sub(input, i, i+1), 16)
        prefix_s = ", "
        i = i + 2
    end
    local output = input .. " parsed as hex={" .. tonumber(input, 16) .. "(" .. tonumber(reversed_endianess_input, 16) .. ")," .. arr_u8_s .. "}}"
    return output
end

function parsers.default_hex_handler(input)
    local i, j = string.find(input, "%x+")
    if i ~= nil and j ~= nil then
        local s = string.sub(input, i, j)
        return parse_hex(s)
    end
    return nil
end

local function parse_dec(input)
    local x_reversed_endianess = 0
    local x_orig = tonumber(input)
    local x = tonumber(input)
    local arr_u8_s = "as_u8[]="
    local prefix_s = "{"

    while x > 0 do
        local b = x % 256
        x_reversed_endianess = x_reversed_endianess * 256 + b
        x = math.floor(x / 256)
        arr_u8_s = arr_u8_s .. prefix_s .. b
        prefix_s = ", "
    end
    local output = input .. " parsed as dec={" .. string.format("0x%X", x_orig) .. "(" .. x_reversed_endianess .. ")," .. arr_u8_s .. "}}"
    return output
end

function parsers.default_dec_handler(input)
    local i, j = string.find(input, "%d+")
    if i ~= nil and j ~= nil then
        local s = string.sub(input, i, j)
        return parse_dec(s)
    end
    return nil
end

return parsers
