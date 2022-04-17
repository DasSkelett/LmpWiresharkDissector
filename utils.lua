function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    
    return false
end

function decode_variable_leuint(buffer, cursor)
--[[
    Lidgren sometimes encodes its ints with a variable size.
    
    This works by continuously checking the size of the remaining int, and see if it takes more than 7 bits.
      - Yes: Prepend 1-bitinto the most significant bit, signalling the next byte belongs to this int as well
      - No:  Just encode as normal int
    
    The C# implementation for reference:
    
    Copyright (c) 2015 lidgren, MIT
    https://github.com/lidgren/lidgren-network-gen3/blob/master/LICENSE
    
    int num1 = 0;
    int num2 = 0;
    while (true)
    {
        byte num3 = buffer[ptr++];
        num1 |= (num3 & 0x7f) << (num2 & 0x1f);
        num2 += 7;
        if ((num3 & 0x80) == 0)
        {
            group = num1;
            break;
        }
    }
]]
    
    local num1 = 0
    local num2 = 0
    local num3 = 0
    while (true)
    do
        num3 = buffer(cursor, 1):bitfield(0, 8)
        cursor = cursor + 1
        num1 = bit.bor(num1, bit.lshift(bit.band(num3, 0x7f), bit.band(num2, 0x1f)))
        num2 = num2 + 7
        if (bit.band(num3,0x80) == 0)
        then
            return num1, cursor
        end
    end
end

local all_additionals = {}

function set_pinfo_text(pinfo, additional, reset)
    if reset then
        all_additionals[pinfo.number] = {}
    end
    
    if additional then
        if not all_additionals[pinfo.number]
        then
            all_additionals[pinfo.number] = {}
        end
        all_additionals[pinfo.number][#all_additionals[pinfo.number]+1] = additional
    end
    
    if all_additionals[pinfo.number] and #all_additionals[pinfo.number]
    then
        pinfo.cols['info'] = table.concat(all_additionals[pinfo.number], ", ")
    else
        pinfo.cols['info'] = "[LMP]"
    end
end
