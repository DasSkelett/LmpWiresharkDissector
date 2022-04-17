function array_lshiftrotate_n(buffer, cursor, n)
    -- Rotate-shift the buffer, to adjust for the single-bit values.
    
    local raw_array = buffer:bytes(cursor):raw(0)
    local hex_array
    for index = 0, n-2
    do
        raw_array = array_lshiftrotate(raw_array, false)
    end
    raw_array, hex_array = array_lshiftrotate(raw_array, true)

    -- Skip the first byte, which is garbage left over from the rotation.
    raw_array = raw_array:sub(2)
    hex_array = hex_array:sub(3)
    
    local byte_array = ByteArray.new(hex_array)
    buffer = ByteArray.new(hex_array):tvb("Bit Shifted")
    cursor = 0
    
    return buffer, cursor
end


function array_lshiftrotate(array, with_hex_array)
    -- The bytes are aligned like this: AAA..... BBBAAAAA ...BBBBB
    --                                  567      56701234 56701234
    -- Procedure: Work from right to left
    -- Copy MSB from byte, shift to the left
    -- Write saved MSB into LSB of byte to the right
    --                                  AA...... BBAAAAAA ..BBBBBB
    --                                  A....... BAAAAAAA .BBBBBBB
    --                                  ........ AAAAAAAA BBBBBBBB
    
    local length = string.len(array)
    local hex_table = {}
    local binary_table = {}
    
    for index = length, 1, -1
    do
        -- Copy MSB
        local last_msb = bit.band((string.byte(array, index) or 0), 0x80)
        -- Shift byte to the left
        local shifted = bit.lshift((string.byte(array, index) or 0), 1)
        -- Cleanup: Strip leftmost bit, and blank out new rightmost
        shifted = bit.band(shifted, 0xFE)
        local right_byte = 0x00
        if (index == length)
        then
            binary_table[index] = string.char(shifted)
            if (with_hex_array or false)
            then
                hex_table[index] = string.format("%02x", shifted)
            end
        else
            -- If there's a byte to the right, carry over the last MSB into the LSB of the right byte
            --                                                            First shift the MSB to the LSB
            --                    Fetch the right byte from the table     |                         |
            --           Fill the new LSB in                              |                         |
            --           |       |                                        |                         |
            right_byte = bit.bor((string.byte(binary_table[index+1]) or 0), bit.rshift(last_msb, 7))
            right_byte = bit.band(right_byte, 0xFF)
            
            -- Now fill them into the array
            binary_table[index+1] = string.char(right_byte)
            binary_table[index] = string.char(shifted)
            if (with_hex_array or false)
            then
                hex_table[index+1] = string.format("%02x", right_byte)
                hex_table[index] = string.format("%02x", shifted)
            end
        end
    end
    return table.concat(binary_table), table.concat(hex_table)
end


-- Unused
function array_lshiftrotate_slow(array, with_hex_array)
    -- The bytes are aligned like this: AAA..... BBBAAAAA ...BBBBB
    --                                  567      56701234 56701234
    -- Procedure: Work from right to left
    -- Copy MSB from byte, shift to the left
    -- Write saved MSB into LSB of byte to the right
    --                                  AA...... BBAAAAAA ..BBBBBB
    --                                  A....... BAAAAAAA .BBBBBBB
    --                                  ........ AAAAAAAA BBBBBBBB
    
    local length = string.len(array)
    local hex_array
    with_hex_array = true
    
    if (with_hex_array or false)
    then
        hex_array = array
    end
    
    for index = length, 1, -1
    do
        -- Copy MSB
        local last_msb = bit.band((string.byte(array, index) or 0), 0x80)
        -- Shift byte to the left
        local shifted = bit.lshift((string.byte(array, index) or 0), 1)
        -- Cleanup: Strip leftmost bit, and blank out new rightmost
        shifted = bit.band(shifted, 0xFE)
        local right_byte = 0x00
        if (index < length)
        then
            -- If there's a byte to the right, carry over the last MSB into the LSB of the right byte
            -- First shift the MSB to the LSB
            --             local lsb = bit.rshift(last_msb, 7)
            right_byte = bit.bor((string.byte(array, index+1) or 0), bit.rshift(last_msb, 7))
            right_byte = bit.band(right_byte, 0xFF)
            
            -- Now fill them into the array
            array = array:sub(1, index-1) .. string.char(shifted) .. string.char(right_byte) .. array:sub(index+2)
            if (with_hex_array or false)
            then
                hex_array = hex_array:sub(1, (index-1))
                .. string.format("%02x", shifted)
                .. string.format("%02x", right_byte)
                .. hex_array:sub((index+3))
            end
        else
            array = array:sub(1, index-1) .. string.char(shifted) .. array:sub(index+1)
            if (with_hex_array or false)
            then
                hex_array = hex_array:sub(1, (index-1)) .. string.format("%02x", shifted)
            end
        end
    end
    return array, hex_array
end


-- Unused
function array_lshift(array)
    local length = string.len(array)
    local hex_array = array
    for index = 1, length
    do
        -- Shift byte to the left
        local shifted = bit.lshift((string.byte(array, index) or 0), 1)
        -- Strip leftmost bit, and blank out new rightmost
        shifted = bit.band(shifted, 0xFE)
        if (index < length)
        then
            -- If there's a next byte, carry over the next leftmost bit
            shifted = bit.bor(shifted, bit.rshift(bit.band((string.byte(array, index+1) or 0), 0x80), 7))
        end
        array = array:sub(1, index-1) .. string.char(bit.band(shifted, 0xFF)) .. array:sub(index+1)
        hex_array = hex_array:sub(1, (index-1)*2) .. string.format("%02x", bit.band(shifted, 0xFF)) .. hex_array:sub((index-1)*2+2)
    end
    return array, hex_array
end
