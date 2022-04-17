--[[

    A Wireshark Lua Dissector for Luna Multiplayer [WIP]

    Copyright (c) DasSkelett (https://github.com/DasSkelett)

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    --------------------------------------------------------------------

    Usage:
    - tshark -X lua_script:LmpWiresharkDissector.lua -O lunamultiplayer -V -r lmp-server-msg.pcapng
    - wireshark -X lua_script:LmpWiresharkDissector.lua lmp-server-msg.pcapng

    Links:
    - https://www.wireshark.org/docs/wsdg_html_chunked/wsluarm_modules.html
    - https://gitlab.com/wireshark/wireshark/-/wikis/Lua/Dissectors
    - https://github.com/LunaMultiplayer/LunaMultiplayer

    --------------------------------------------------------------------

    Workflow to add new decoders:

    1) Edit decoder_header.lua:
        1) Insert message type into message_types_srv
        2) Create new message_subtypes_srv_* table with the subtypes
        3) Create new pf_msg_subtype_srv_* ProtoField pointing to that table
        4) Insert ProtoField into _G.lmp_proto_fields
        5) Call subtree:add_le() with new ProtoField in the if-elseif structure
    2) Create new decoder_*.lua file for this message type
        1) 'require' it in LmpWiresharkDissector
        2) Declare ProtoFields at the top of the file
        3) Insert ProtoFields into the global table
        4) Write the decode* functions
        5) Call decode* functions in the LmpWiresharkDissector.lua if-elseif

]]


-- Imports
require 'utils'
require 'shifting'

-- Table of ProtoFields, needs to be declared before importing decoders

_G.lmp_proto_fields = {}
_G.lmp_prefs        = {}

---- Decoders for message types

require 'decoder_Lidgren'
require 'decoder_Header'

-- Master Server

require 'decoder_ReplyServers'
require 'decoder_RegisterServer'
require 'decoder_Introduction'

-- Server

require 'decoder_Handshake'
require 'decoder_Vessel'
require 'decoder_Settings'

-- Our protocol
local lmp_proto = nil
lmp_proto = Proto("lunamultiplayer","Luna Multiplayer (LMP)")

-- create a function to dissect it
function lmp_proto.dissector(buffer,pinfo,tree)
    pinfo.cols.protocol = "LMP"

    local cursor
    local lidgren_message_type_id
    -- This not only decodes the header, but also reassembles the packet if necessary.
    -- Returns nil if something failed or packet is only fragment
    buffer, cursor, lidgren_message_type_id = decodeLidgrenHeader(buffer, lmp_proto, pinfo, tree)

    if buffer == nil then
        return
    end

    local lmp_base_subtree, msgType, msgSubType
    cursor, lmp_base_subtree, msgType, msgSubType = decodeLmpHeader(buffer, cursor, lmp_proto, tree,
                                                                    lidgren_message_type_id)

    if (lidgren_message_type_id == 0)
    then
        -- Unconnected message: Client<->MasterServer or Server<->MasterServer
        if (msgType == 0)
        then
            if (msgSubType == 0)
            then
                decodeRegisterServer(buffer, cursor, lmp_proto, lmp_base_subtree)
                -- 1 is RequestServers, which has no fields to decode
            elseif (msgSubType == 2)
            then
                decodeReplyServers(buffer, cursor, lmp_proto, lmp_base_subtree)
            elseif (msgSubType == 3)
            then
                decodeIntroduction(buffer, cursor, lmp_proto, lmp_base_subtree)
            end
        end
    else
        -- Client<->Server
        if (msgType == 0)
        then
            -- Handshake
            if (msgSubType == 0)
            then
                -- Handshake Request
                decodeHandshakeRequest(buffer, cursor, lmp_proto, lmp_base_subtree)
            elseif (msgSubType == 1)
            then
                -- Handshake Reply
                decodeHandshakeReply(buffer, cursor, lmp_proto, lmp_base_subtree)
            end
        elseif (msgType == 1)
        then
            -- Settings

            if (msgSubType == 0)
            then
                -- Request
            elseif (msgSubType == 1)
            then
                -- Reply
                decodeSettingsReply(buffer, cursor, lmp_proto, lmp_base_subtree)
            end
        elseif (msgType == 8)
        then
            -- Vessel

            cursor = decodeVesselBase(buffer, cursor, lmp_proto, lmp_base_subtree)

            if (msgSubType == 0)
            then
                -- Proto
                decodeVesselProto(buffer, cursor, lmp_proto, lmp_base_subtree)
            elseif (msgSubType == 1)
            then
                -- Remove
                --decodeHandshakeReply(buffer, cursor, lmp_proto, lmp_base_subtree)
            elseif (msgSubType == 2)
            then
                -- Position
                decodeVesselPosition(buffer, cursor, lmp_proto, lmp_base_subtree)
            elseif (msgSubType == 3)
            then
                -- Flightstate
                --decodeHandshakeReply(buffer, cursor, lmp_proto, lmp_base_subtree)
            elseif (msgSubType == 5)
            then
                -- Resource
                decodeVesselResource(buffer, cursor, lmp_proto, lmp_base_subtree)
            end
        end
    end
end


function register_proto_fields(lmp_proto)
    lmp_proto.fields = _G.lmp_proto_fields
end

function register_prefs(lmp_proto)
--     lmp_proto.prefs[name] = pref
    for k, v in pairs(_G.lmp_prefs) do
        lmp_proto.prefs[k] = v
    end
end

-- Register ProtoFields and Prefs
register_proto_fields(lmp_proto)
register_prefs(lmp_proto)

-- load the udp.port table
local udp_table = DissectorTable.get("udp.port")
-- register our protocol to handle udp port 8700 and 8750
udp_table:add(8700,lmp_proto)
udp_table:add(8750,lmp_proto)
udp_table:add(8800,lmp_proto)
