local pf_warp_mode          = ProtoField.uint32("lmp.settings.reply.warp_mode", "Warp Mode", nil,
                                                { [0] = "None", [1] = "Subspace" })
local pf_game_mode          = ProtoField.uint32("lmp.settings.reply.game_mode", "Game Mode", nil,
                                                { [0] = "Sandbox", [1] = "Science", [2] = "Career" })
local pf_terrain_quality    = ProtoField.uint32("lmp.settings.reply.terrain_quality", "Terrain Quality", nil,
                                                { [0] = "Low", [1] = "Default", [2] = "High", [3] = "Ignore" })
local pf_allow_cheats       = ProtoField.bool("lmp.settings.reply.allow_cheats", "Allow Cheats", 3, nil, 0x01)
local pf_allow_sack_kerbals = ProtoField.bool("lmp.settings.reply.allow_cheats", "Allow Sack Kerbals", 3, nil, 0x02)
local pf_allow_admin        = ProtoField.bool("lmp.settings.reply.allow_cheats", "Allow Admin", 3, nil, 0x04)
local pf_max_asteroids      = ProtoField.uint32("lmp.settings.reply.max_asteroids", "Max Number of Asteroids")
local pf_max_comets         = ProtoField.uint32("lmp.settings.reply.max_comets", "Max Number of Comets")
local pf_console_id_l       = ProtoField.uint8("lmp.settings.reply.console_identifier_l", "Console Identifier Length")
local pf_console_id         = ProtoField.string("lmp.settings.reply.console_identifier", "Console Identifier")
local pf_game_difficulty    = ProtoField.uint32("lmp.settings.reply.game_difficulty", "Game Difficulty", nil, 
                                                { [0] = "Easy", [1] = "Normal", [2] = "Moderate", [3] = "Hard", 
                                                  [4] = "Custom" })
table.insert(_G.lmp_proto_fields, pf_warp_mode)
table.insert(_G.lmp_proto_fields, pf_game_mode)
table.insert(_G.lmp_proto_fields, pf_terrain_quality)
table.insert(_G.lmp_proto_fields, pf_allow_cheats)
table.insert(_G.lmp_proto_fields, pf_allow_sack_kerbals)
table.insert(_G.lmp_proto_fields, pf_allow_admin)
table.insert(_G.lmp_proto_fields, pf_max_asteroids)
table.insert(_G.lmp_proto_fields, pf_max_comets)
table.insert(_G.lmp_proto_fields, pf_console_id_l)
table.insert(_G.lmp_proto_fields, pf_console_id)
table.insert(_G.lmp_proto_fields, pf_game_difficulty)

function decodeSettingsReply(buffer, cursor, proto, lmp_base_subtree)
    local subtree = lmp_base_subtree:add(proto,buffer(cursor),"Settings Reply")
    
    -- SettingsReplyMsgData / Settings Reply
    
    subtree:add_le(pf_warp_mode, buffer(cursor,4))
    cursor = cursor + 4
    subtree:add_le(pf_game_mode, buffer(cursor,4))
    cursor = cursor + 4
    subtree:add_le(pf_terrain_quality, buffer(cursor,4))
    cursor = cursor + 4
    
    subtree:add(pf_allow_cheats, buffer(cursor,1))
    subtree:add(pf_allow_sack_kerbals, buffer(cursor,1))
    subtree:add(pf_allow_admin, buffer(cursor,1))
    
    -- We need to rotate-shift the buffer, to adjust for the single-bit booleans.
    buffer, cursor = array_lshiftrotate_n(buffer, cursor, 8-3)
    
    subtree:add_le(pf_max_asteroids, buffer(cursor,4))
    cursor = cursor + 4
    subtree:add_le(pf_max_comets, buffer(cursor,4))
    cursor = cursor + 4
    
    nextlen = buffer(cursor,1):uint()
    subtree:add_le(pf_console_id_l, buffer(cursor,1))
    cursor = cursor + 1
    subtree:add(pf_console_id, buffer(cursor,nextlen))
    cursor = cursor + nextlen
    
    subtree:add_le(pf_game_difficulty, buffer(cursor,4))
    cursor = cursor + 4
    
    -- TODO ...

end
