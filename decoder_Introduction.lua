function decodeIntroduction(buffer, cursor, proto, lmp_base_subtree)
    local subtree = lmp_base_subtree:add(proto,buffer(cursor),"Introduction")

    -- MsIntroductionMsgData / Introduction

    subtree:add(buffer(cursor,8),"Server ID: " .. buffer(cursor,8):le_uint64())
    cursor = cursor + 8

    nextlen = buffer(cursor,1):int()
    subtree:add(buffer(cursor,1),"Internal Endpoint Length: " .. nextlen)
    cursor = cursor + 1

    subtree:add(buffer(cursor,nextlen),"Internal Endpoint Address: " .. tostring(buffer(cursor,nextlen):ipv4()))
    cursor = cursor + nextlen

    subtree:add(buffer(cursor,2),"Internal Endpoint Port: " .. buffer(cursor,2):le_uint())
    cursor = cursor + 2

    nextlen = buffer(cursor,1):int()
    cursor = cursor + 1
    subtree:add(buffer(cursor,1),"Internal IPv6 Endpoint Length: " .. nextlen)

    subtree:add(buffer(cursor,nextlen),"Internal IPv6 Endpoint Address: " .. tostring(buffer(cursor,nextlen):ipv6()))
    cursor = cursor + nextlen

    subtree:add(buffer(cursor,2),"Internal IPv6 Endpoint Port: " .. buffer(cursor,2):le_uint())
    cursor = cursor + 2

    nextlen = buffer(cursor,1):le_uint()
    subtree:add(buffer(cursor,1),"Token Length: " .. nextlen)
    cursor = cursor + 1
    subtree:add(buffer(cursor,nextlen),"Token: " .. buffer(cursor,nextlen):string())
    cursor = cursor + nextlen
end
