function decodeReplyServers(buffer, cursor, proto, lmp_base_subtree)
    local subtree = lmp_base_subtree:add(proto,buffer(cursor),"ReplyServers")
    
    -- MsReplyServersMsgData / ReplyServers
    
    subtree:add(buffer(cursor,8),"Server ID: " .. buffer(cursor,8):le_uint64())
    cursor = cursor + 8
    
    nextlen = buffer(cursor,1):uint()
    subtree:add(buffer(cursor,1),"Server Version Length: " .. nextlen)
    cursor = cursor + 1
    subtree:add(buffer(cursor,nextlen),"Server Version: " .. buffer(cursor,nextlen):string())
    cursor = cursor + nextlen
    
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
    
    nextlen = buffer(cursor,1):int()
    subtree:add(buffer(cursor,1),"External Endpoint Length: " .. nextlen)
    cursor = cursor + 1
    
    subtree:add(buffer(cursor,nextlen),"External Endpoint Address: " .. tostring(buffer(cursor,nextlen):ipv4()))
    cursor = cursor + nextlen
    
    subtree:add(buffer(cursor,2),"External Endpoint Port: " .. buffer(cursor,2):le_uint())
    cursor = cursor + 2
    
    subtree:add(buffer(cursor,1),"Password: " .. buffer(cursor,1):bitfield(7, 1))
    subtree:add(buffer(cursor,1),"Cheats: " .. buffer(cursor,1):bitfield(6, 1))
    subtree:add(buffer(cursor,1),"Mod Control: " .. buffer(cursor,1):bitfield(5, 1))
    subtree:add(buffer(cursor,1),"Dedicated Server: " .. buffer(cursor,1):bitfield(4, 1))
    subtree:add(buffer(cursor,1),"Rainbow Effect: " .. buffer(cursor,1):bitfield(3, 1))
    
    -- We need to rotate-shift the buffer, to adjust for the single-bit booleans.
    buffer, cursor = array_lshiftrotate_n(buffer, cursor, 8-5)
    
    subtree:add(buffer(cursor,3),"Colors: " .. tostring(buffer(cursor,3)))
    cursor = cursor + 3
    
    subtree:add(buffer(cursor,4),"GameMode: " .. buffer(cursor,4):le_uint())
    cursor = cursor + 4
    
    subtree:add(buffer(cursor,4),"Max Players: " .. buffer(cursor,4):le_uint())
    cursor = cursor + 4
    
    subtree:add(buffer(cursor,4),"Player Count: " .. buffer(cursor,4):le_uint())
    cursor = cursor + 4
    
    nextlen = buffer(cursor,1):le_uint()
    subtree:add(buffer(cursor,1),"Server Name Length: " .. nextlen)
    cursor = cursor + 1
    subtree:add(buffer(cursor,nextlen),"Server Name: " .. buffer(cursor,nextlen):string())
    cursor = cursor + nextlen
    
    nextlen = buffer(cursor,1):le_uint()
    subtree:add(buffer(cursor,1),"Server Description Length: " .. nextlen)
    cursor = cursor + 1
    subtree:add(buffer(cursor,nextlen),"Server Description: " .. buffer(cursor,nextlen):string())
    cursor = cursor + nextlen
    
    nextlen = buffer(cursor,1):le_uint()
    subtree:add(buffer(cursor,1),"Country Length: " .. nextlen)
    cursor = cursor + 1
    subtree:add(buffer(cursor,nextlen),"Country: " .. buffer(cursor,nextlen):string())
    cursor = cursor + nextlen
    
    nextlen = buffer(cursor,1):le_uint()
    subtree:add(buffer(cursor,1),"Website URL Length: " .. nextlen)
    cursor = cursor + 1
    subtree:add(buffer(cursor,nextlen),"Website URL: " .. buffer(cursor,nextlen):string())
    cursor = cursor + nextlen
    
    nextlen = buffer(cursor,1):le_uint()
    subtree:add(buffer(cursor,1),"Website Label Length: " .. nextlen)
    cursor = cursor + 1
    subtree:add(buffer(cursor,nextlen),"Website Label: " .. buffer(cursor,nextlen):string())
    cursor = cursor + nextlen
    
    subtree:add(buffer(cursor,4),"Warp Mode: " .. buffer(cursor,4):le_uint())
    cursor = cursor + 4
    
    subtree:add(buffer(cursor,4),"Terrain Quality: " .. buffer(cursor,4):le_uint())
    cursor = cursor + 4
    
    subtree:add(buffer(cursor,4),"Vessel Update Interval: " .. buffer(cursor,4):le_uint())
    cursor = cursor + 4    
end
