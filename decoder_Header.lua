local message_types_ms = {
    [0] = "Main"
}
local message_subtypes_ms_main = {
    [0] = "Register Server",
    [1] = "Request Servers",
    [2] = "Reply Servers",
    [1] = "Introduction"
}
local message_types_srv = {
    [0] = "Handshake",
    [1] = "Settings",
    [8] = "Vessel"
}
local message_subtypes_srv_handshake = {
    [0] = "Handshake Request",
    [1] = "Handshake Reply"
}
local message_subtypes_srv_settings = {
    [0] = "Settings Request",
    [1] = "Settings Reply"
}
local message_subtypes_srv_vessel = {
    [0] = "Proto",
    [1] = "Remove",
    [2] = "Position",
    [3] = "Flightstate",
    [5] = "Resource"
}

local pf_msg_type_ms        = ProtoField.uint16("lmp.header.masterserver.msg_type", "Message Type",
                                                nil, message_types_ms)
local pf_msg_subtype_ms     = ProtoField.uint16("lmp.header.masterserver.msg_subtype", "Message Subtype",
                                               nil, message_types_server)
local pf_msg_type_srv       = ProtoField.uint16("lmp.header.server.msg_type", "Message Type",
                                                nil, message_types_srv)
local pf_msg_subtype_srv_handshake  = ProtoField.uint16("lmp.header.server.msg_subtype", "Message Subtype",
                                                        nil, message_subtypes_srv_handshake)
local pf_msg_subtype_srv_settings  = ProtoField.uint16("lmp.header.server.msg_subtype", "Message Subtype",
                                                        nil, message_subtypes_srv_settings)
local pf_msg_subtype_srv_vessel     = ProtoField.uint16("lmp.header.server.msg_subtype", "Message Subtype",
                                                        nil, message_subtypes_srv_vessel)
    

table.insert(_G.lmp_proto_fields, pf_msg_type_ms)
table.insert(_G.lmp_proto_fields, pf_msg_subtype_ms)
table.insert(_G.lmp_proto_fields, pf_msg_type_srv)
table.insert(_G.lmp_proto_fields, pf_msg_subtype_srv_handshake)
table.insert(_G.lmp_proto_fields, pf_msg_subtype_srv_settings)
table.insert(_G.lmp_proto_fields, pf_msg_subtype_srv_vessel)

function decodeLmpHeader(buffer, cursor, lmp_proto, tree, netMsgType)

    -- Common for all LMP messages
    
    local lmp_base_subtree = tree:add(lmp_proto,buffer(cursor),"Luna Multiplayer")
    
    local subtree = lmp_base_subtree:add(lmp_proto,buffer(cursor,4),"Message Base")
    
    -- MessageBase
    -- 2 MessageTypeId
    -- 2 SubType
    -- X PadBits
    
    local msgType = buffer(cursor,2):le_uint()
    local msgSubType = buffer(cursor+2,2):le_uint()
    
    if netMsgType == 0 then
        subtree:add_le(pf_msg_type_ms, buffer(cursor,2))
        
        if msgType == 0 then
            subtree:add_le(pf_msg_subtype_ms, buffer(cursor+2,2))
        end
    else
        subtree:add_le(pf_msg_type_srv, buffer(cursor,2), msgType)
        
        if msgType == 0 then
            subtree:add_le(pf_msg_subtype_srv_handshake, buffer(cursor+2,2))
        elseif msgType == 1 then
            subtree:add_le(pf_msg_subtype_srv_settings, buffer(cursor+2,2))
        elseif msgType == 8 then
            subtree:add_le(pf_msg_subtype_srv_vessel, buffer(cursor+2,2))
        else
            subtree:add_le(buffer(cursor+2,2), "Message Subtype: Unknown (" .. msgSubType .. ")")
        end
    end
    
    cursor = cursor + 4
    
    local subtree = lmp_base_subtree:add(lmp_proto,buffer(cursor,14),"Message Data")
    
    -- MessageData / Main
    -- 8 SentTime
    -- 2 MajorVersion
    -- 2 MinorVersion
    -- 2 BuildVersion
    -- X PadBits
    
    -- SentTime is a long representing the number of 100 nanosecond ticks from 1/1/0001 (= -62135596800 seconds from Unix Epoch )
    -- e.g. 637635209899496155 for Mon Aug 02 2021 17:09:49 GMT+0000
    -- Divide by 10000000 to get to seconds, subtract -62135596800 to normalize to Unix Epoch.
    -- Lua can't go down to milliseconds, unfortunately
    local date = os.date("%Y-%m-%dT%H:%M:%S", (buffer(cursor, 8):le_uint64() / 10000000 - 62135596800):tonumber())
    subtree:add(buffer(cursor,8),"Sent Time: " .. (date or 0))
    cursor = cursor + 8
    subtree:add(buffer(cursor,2),"Major version: " .. buffer(cursor,2):le_uint())
    cursor = cursor + 2
    subtree:add(buffer(cursor,2),"Minor version: " .. buffer(cursor,2):le_uint())
    cursor = cursor + 2
    subtree:add(buffer(cursor,2),"Build version: " .. buffer(cursor,2):le_uint())
    cursor = cursor + 2
    
    return cursor, lmp_base_subtree, msgType, msgSubType
end
