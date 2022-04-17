local pf_guid           = ProtoField.guid("lmp.vessel.guid", "GUID")
local pf_game_time      = ProtoField.relative_time("lmp.vessel.game_time", "Game Time")


table.insert(_G.lmp_proto_fields, pf_guid)
table.insert(_G.lmp_proto_fields, pf_game_time)

_G.lmp_prefs['ignore_vessel'] = Pref.bool("Ignore Vessel Messages", false, "Don't decode messages of the Vessel type")

function decodeVesselBase(buffer, cursor, proto, lmp_base_subtree)
    local subtree = lmp_base_subtree:add(proto,buffer(cursor,24),"Vessel Base")

    -- VesselBaseMsgData / Vessel Base

    -- GUID, 16 Bytes
    subtree:add_le(pf_guid, buffer(cursor,16))
    cursor = cursor + 16

    subtree:add_le(pf_game_time, buffer(cursor,8))
    cursor = cursor + 8

    return cursor
end

function decodeVesselProto(buffer, cursor, proto, lmp_base_subtree)
    local subtree = lmp_base_subtree:add(proto,buffer(cursor),"Vessel Proto")
    if proto.prefs.ignore_vessel then return end

    -- VesselProtoMsgData / Vessel Proto

    subtree:add(buffer(cursor,1),"Force Reload: " .. buffer(cursor,1):bitfield(7, 1))

    -- We need to rotate-shift the buffer, to adjust for the single-bit booleans.
    buffer, cursor = array_lshiftrotate_n(buffer, cursor, 8-1)

    local nextlen = buffer(cursor,4):le_uint()
    subtree:add(buffer(cursor,4),"Data Length: " .. nextlen)
    cursor = cursor + 1
    subtree:add(buffer(cursor,nextlen),"Data: " .. tostring(buffer(cursor,nextlen)))
    cursor = cursor + nextlen

    -- Data is compressed
end

function decodeVesselPosition(buffer, cursor, proto, lmp_base_subtree)
    local subtree = lmp_base_subtree:add(proto,buffer(cursor),"Vessel Position")
    if proto.prefs.ignore_vessel then return end

    -- VesselPositionMsgData / Vessel Position

    subtree:add(buffer(cursor,4),"Body Index: " .. buffer(cursor,4):le_uint())
    cursor = cursor + 4

    subtree:add(buffer(cursor,4),"Subspace ID: " .. buffer(cursor,4):le_uint())
    cursor = cursor + 4

    subtree:add(buffer(cursor,4),"Ping Sec: " .. buffer(cursor,4):le_float())
    cursor = cursor + 4

    subtree:add(buffer(cursor,4),"Terrain Heigth: " .. buffer(cursor,4):le_float())
    cursor = cursor + 4

    subtree:add(buffer(cursor,1),"Landed: " .. buffer(cursor,1):bitfield(7, 1))
    subtree:add(buffer(cursor,1),"Splashed: " .. buffer(cursor,1):bitfield(6, 1))
    subtree:add(buffer(cursor,1),"Gravity Hack: " .. buffer(cursor,1):bitfield(5, 1))

    -- We need to rotate-shift the buffer, to adjust for the single-bit booleans.
    buffer, cursor = array_lshiftrotate_n(buffer, cursor, 8-3)

    subtree:add(buffer(cursor,8),"Latitude: " .. buffer(cursor,8):le_float())
    cursor = cursor + 8
    subtree:add(buffer(cursor,8),"Longitude: " .. buffer(cursor,8):le_float())
    cursor = cursor + 8
    subtree:add(buffer(cursor,8),"Altitude : " .. buffer(cursor,8):le_float())
    cursor = cursor + 8

    subtree:add(buffer(cursor,8),"Velocity X: " .. buffer(cursor,8):le_float())
    cursor = cursor + 8
    subtree:add(buffer(cursor,8),"Velocity Y: " .. buffer(cursor,8):le_float())
    cursor = cursor + 8
    subtree:add(buffer(cursor,8),"Velocity Z: " .. buffer(cursor,8):le_float())
    cursor = cursor + 8

    subtree:add(buffer(cursor,8),"Normal X: " .. buffer(cursor,8):le_float())
    cursor = cursor + 8
    subtree:add(buffer(cursor,8),"Normal Y: " .. buffer(cursor,8):le_float())
    cursor = cursor + 8
    subtree:add(buffer(cursor,8),"Normal Z: " .. buffer(cursor,8):le_float())
    cursor = cursor + 8

    subtree:add(buffer(cursor,4),"Surface-relative Rotation X: " .. buffer(cursor,4):le_float())
    cursor = cursor + 4
    subtree:add(buffer(cursor,4),"Surface-relative Rotation Y: " .. buffer(cursor,4):le_float())
    cursor = cursor + 4
    subtree:add(buffer(cursor,4),"Surface-relative Rotation Z: " .. buffer(cursor,4):le_float())
    cursor = cursor + 4
    subtree:add(buffer(cursor,4),"Surface-relative Rotation W: " .. buffer(cursor,4):le_float())
    cursor = cursor + 4

    subtree:add(buffer(cursor,8),"Orbit Inclination: " .. buffer(cursor,8):le_float())
    cursor = cursor + 8
    subtree:add(buffer(cursor,8),"Orbit Eccentricity: " .. buffer(cursor,8):le_float())
    cursor = cursor + 8
    subtree:add(buffer(cursor,8),"Orbit Semi-Major Axis: " .. buffer(cursor,8):le_float())
    cursor = cursor + 8
    subtree:add(buffer(cursor,8),"Orbit Longitude of Ascending Node: " .. buffer(cursor,8):le_float())
    cursor = cursor + 8
    subtree:add(buffer(cursor,8),"Orbit Argument of Periapsis: " .. buffer(cursor,8):le_float())
    cursor = cursor + 8
    subtree:add(buffer(cursor,8),"Orbit Mean Anomaly at Epoch: " .. buffer(cursor,8):le_float())
    cursor = cursor + 8
    subtree:add(buffer(cursor,8),"Orbit Epoch: " .. buffer(cursor,8):le_float())
    cursor = cursor + 8
    subtree:add(buffer(cursor,8),"Orbit Flight Globals Index: " .. buffer(cursor,8):le_float())
    cursor = cursor + 8
end

function decodeVesselResource(buffer, cursor, proto, lmp_base_subtree)
    local subtree = lmp_base_subtree:add(proto,buffer(cursor),"Vessel Resource")
    if proto.prefs.ignore_vessel then return end

    -- VesselResourceMsgData / Vessel Resource

    local count = buffer(cursor,4):le_uint()
    subtree:add(buffer(cursor,4),"Resources Count: " .. count)
    cursor = cursor + 4

    -- repeat for count
    for i = 0,count-1,1
    do
        local resname_length = buffer(cursor+4,1):uint()
        local restree = subtree:add(proto, buffer(cursor, 4+1+resname_length+8+1), "Resource " .. i)

        restree:add(buffer(cursor,4),"Part Flight ID: " .. buffer(cursor, 4):le_uint())
        cursor = cursor + 4

        restree:add(buffer(cursor,1),"Resource Name Length: " .. resname_length)
        cursor = cursor + 1
        restree:add(buffer(cursor,resname_length),"Resource Name: " .. buffer(cursor,resname_length):string())
        cursor = cursor + resname_length

        restree:add(buffer(cursor,8),"Amount: " .. buffer(cursor,8):le_float())
        cursor = cursor + 8

        restree:add(buffer(cursor,1),"Flow State: " .. buffer(cursor,1):bitfield(7, 1))
        cursor = cursor + 1
        -- We need to rotate-shift the buffer, to adjust for the single-bit booleans.
        -- buffer, cursor = array_lshiftrotate_n(buffer, cursor, 8-1)
    end
end
