function toBytes(num)
    -- returns a table of bits, most significant first.
    local t = {} -- will contain the bits
    local r = 0
    while num > 0 do
        table.insert(t,math.fmod(num, 256))
        num = math.floor((num - t[#t]) / 256)
    end
    for b = 1,#t do
        t[b] = (t[b] << b-1) + r     -- Shift left digit-1 places
        r = t[b] >> 7                -- Shift right by 7 bits (want to keep 7) to get remainder
        t[b] = (t[b] & 127) + 128    -- 0 the 8th bit, and set to 1  ( or it buy 128? )
    end
    if r > 0 then                    -- if there is a remining remainder, add 128 to it - larger numbers might need to revisit this.
        table.insert(t,r+128)
    end
    if #t == 0 then                  -- if no values where inserted (a zero was given), encode it by adding 128
        t[1] = 128
    end

    for _,i in ipairs( t ) do
        print( string.format( "%s %d %s %x", _, i, string.char(i), i ) )
    end

    return t
end


--[[
To avoid 0 values,

Enocde to 7 bits, with the 8th bit always being 1
(0000 0000  becomes 1000 0000)
Carry the 8th bit to the next byte

fromBytes( string.char( 0x81 )..string.char( 0xd3 )..string.char( 0xb4 )..string.char( 0x88 ) )

]]
function fromBytes( bytes )
    local num = 0
    local multiplier = 1

    for i = #bytes,1,-1 do
        local byte = string.byte( bytes, i )
        print( string.format( "%d %x %d %d", i, byte, byte, #bytes-i))
        local value = byte % 128           -- remove encoding bit
        value = value >> (#bytes-i)
        print( value )
        -- 'steal' (#bytes-i+1) bytes from left byte
        stealByte = string.byte( bytes, i-1)
        print( stealByte, ( ( 2 ^ ( #bytes-i+1 ) ) - 1 ) )
        if stealByte then
            stealByte = stealByte & ( ( 2 ^ ( #bytes-i+1 ) ) - 1 )
            print( stealByte )
        end

        num = num + value * multiplier
        if byte >= 128 then
            multiplier = multiplier * 256
        else
            break
        end
    end

    return num
end

function d( str )
    outTable = {}
    k = 1
    for v in string.gmatch(str, "([^|]+)") do
        outTable[k] = v
        if k == 4 then
            outTable[k] = fromBytes(outTable[k])
        end
        if k >= 5 then
            outTable[k] = string.format( "%s%s", fromBytes(outTable[k], "") )
        end
        print( k, outTable[k] )
        k = k + 1
    end
end

