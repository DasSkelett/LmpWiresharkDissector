local net_message_types = {
    [0] = "Unconnected",
    [1] = "UserUnreliable",
    [2] = "UserSequenced1",
    [34] = "UserReliableUnordered",
    [35] = "UserReliableSequenced1",
    [67] = "UserReliableOrdered1",
    [68] = "UserReliableOrdered2",
    [75] = "UserReliableOrdered9",
    [99] = "Unused1",
    [128] = "LibraryError",
    [129] = "Ping",
    [130] = "Pong",
    [131] = "Connect",
    [132] = "ConnectResponse",
    [133] = "ConnectionEstablished",
    [134] = "Acknowledge",
    [135] = "Disconnect",
    [136] = "Discovery",
    [137] = "DiscoveryResponse",
    [138] = "NatPunchMessage",
    [139] = "NatIntroduction",
    [142] = "NatIntroductionConfirmRequest",
    [143] = "NatIntroductionConfirmed",
    [140] = "ExpandMTURequest",
    [141] = "ExpandMTUSuccess"
}

local pf_net_msg_type       = ProtoField.uint8("lmp.header.net_msg_type", "Net Message Type", nil, net_message_types)
local pf_fragment           = ProtoField.bool("lmp.header.fragment", "Fragment?", 1, nil, 0x01)
local pf_sequence           = ProtoField.uint16("lmp.header.sequence", "Sequence Number", base.DEC, nil, 0xFFFE)
local pf_payload_length     = ProtoField.uint16("lmp.header.payload_length", "Payload Length", base.UNIT_STRING,
                                                { " bits" })
-- Technically variable sized, so could be anything from uint8 to uint64.
local pf_frag_gid           = ProtoField.uint64("lmp.header.fragment_gid", "Fragment Group ID",
                                                base.DEC, nil, 0xEFEFEFEFEFEFEFEF)
local pf_frag_total_bits    = ProtoField.uint64("lmp.header.fragment_total_bits", "Fragment Total Bits",
                                                base.DEC, nil, 0xEFEFEFEFEFEFEFEF)
local pf_frag_chunk_size    = ProtoField.uint64("lmp.header.fragment_chunk_size", "Fragment Chunk Size",
                                                base.DEC, nil, 0xEFEFEFEFEFEFEFEF)
local pf_frag_chunk_no      = ProtoField.uint64("lmp.header.fragment_chunk_number", "Fragment Chunk Number",
                                                base.DEC, nil, 0xEFEFEFEFEFEFEFEF)
local pf_frag_hash          = ProtoField.uint64("lmp.header.fragment_hash", "Fragment Hash (Group ID * Src Port)")
table.insert(_G.lmp_proto_fields, pf_net_msg_type)
table.insert(_G.lmp_proto_fields, pf_fragment)
table.insert(_G.lmp_proto_fields, pf_sequence)
table.insert(_G.lmp_proto_fields, pf_payload_length)
table.insert(_G.lmp_proto_fields, pf_frag_gid)
table.insert(_G.lmp_proto_fields, pf_frag_total_bits)
table.insert(_G.lmp_proto_fields, pf_frag_chunk_size)
table.insert(_G.lmp_proto_fields, pf_frag_chunk_no)
table.insert(_G.lmp_proto_fields, pf_frag_hash)

-- For defragmentation
local fragments = { }

-- Returns a (potentially re-assembled) buffer, cursor, Lidgren message type ID
-- If buffer is nil, consider the decoding as completed, can happen if we need more fragments
-- or it is a Lidgren library message
function decodeLidgrenHeader(buffer, lmp_proto, pinfo, tree)
    local cursor = 0

    local lg_header_subtree = tree:add(lmp_proto,buffer(0,5),"Lidgren Header")

    -- Lidgren header
    --  8 bits - NetMessageType
    --  1 bit  - Fragment?
    -- 15 bits - Sequence number
    -- 16 bits - Payload length in bits

    local lidgren_message_type_id = buffer(0, 1):le_uint()
    lg_header_subtree:add_le(pf_net_msg_type, buffer(0, 1))

    -- It would be really cool if we could read those values back from Wireshark, but this is not possible within
    -- the dissector that creates them.
    local fragmented = buffer(1,1):bitfield(7, 1)
    lg_header_subtree:add_le(pf_fragment, buffer(1, 1))

    local seq_number_1 = buffer(1,1):bitfield(0, 7)
    local seq_number_2 = buffer(2,1):bitfield(0, 8)
    -- The first 7 bits are the least significant that need to be appended to the second 8 bits
    -- Thus, shift the second number by 8 bits
    local seq_number = bit.lshift(seq_number_2, 8) + seq_number_1
    lg_header_subtree:add_le(pf_sequence, buffer(1, 2))

    local payload_length = math.ceil(buffer(3, 2):le_uint() / 8)
    lg_header_subtree:add_le(pf_payload_length, buffer(3, 2))

    local pinfo_text = ((net_message_types[lidgren_message_type_id] or "["..tostring(lidgren_message_type_id).."]")
                        .. ", Len=" .. buffer:len() .. " PayLen=" .. payload_length)

    set_pinfo_text(pinfo, pinfo_text, true)

    cursor = 5


    if (fragmented == 1)
    then
        -- This is a fragment
        -- Example pcap: FullSession.pcapng packet id 47 and up
        -- Reassembling code is based on https://osqa-ask.wireshark.org/questions/55621/lua-udp-reassembly/

        local pre_frag_cursor = cursor
        local new_cursor

        -- Variable-sized ints need to be decoded manually
        local frag_gid
        frag_gid, new_cursor = decode_variable_leuint(buffer, cursor)
        lg_header_subtree:add_le(pf_frag_gid, buffer(cursor, new_cursor-cursor), UInt64.new(frag_gid))
        cursor = new_cursor

        local frag_tbits
        frag_tbits, new_cursor = decode_variable_leuint(buffer, cursor)
        lg_header_subtree:add_le(pf_frag_total_bits, buffer(cursor, new_cursor-cursor), UInt64.new(frag_tbits))
        cursor = new_cursor

        local frag_chsize
        frag_chsize, new_cursor = decode_variable_leuint(buffer, cursor)
        lg_header_subtree:add_le(pf_frag_chunk_size, buffer(cursor, new_cursor-cursor), UInt64.new(frag_chsize))
        cursor = new_cursor

        local frag_chnum
        frag_chnum, new_cursor = decode_variable_leuint(buffer, cursor)
        lg_header_subtree:add_le(pf_frag_chunk_no, buffer(cursor, new_cursor-cursor), UInt64.new(frag_chnum))
        cursor = new_cursor

        tree:add(lmp_proto,buffer(cursor), "Fragment")

        -- Client and server can use the same frag_gids for different conversations!
        -- Let's "hash" frag_gid with the source port.
        local frag_hash = frag_gid * tonumber(pinfo.src_port)

        local frag_hash_item = lg_header_subtree:add_le(pf_frag_hash, UInt64.new(frag_hash))
        frag_hash_item:set_generated()

        if (fragments[frag_hash] == nil) then
            fragments[frag_hash] = {}
        end

        local already_assembled = fragments[frag_hash][-1] ~= nil
        if already_assembled then
            -- New re-assembled Tvb
            buffer = ByteArray.tvb(fragments[frag_hash][-1], "Reassembled")
            cursor = 0
        else
            if (fragments[frag_hash][frag_chnum] == nil) then
                fragments[frag_hash][frag_chnum] = {}
            end
            -- Save the message into the global fragment table
            fragments[frag_hash][frag_chnum] = buffer(cursor):bytes()
        end

        -- If the fragment doesn't fill the chunk size, it's probably the last one
        local last_fragment = payload_length - 1 - pre_frag_cursor < frag_chsize

        -- If we're looking at the last packet and we haven't assembled it before, reassemble it.
        if (not already_assembled and last_fragment)
        then

            local completeMessage = ByteArray.new()
            local index = 0
            local assembled = false
            while (index < 128) -- maximum 128 fragments
            do
                if fragments[frag_hash][index] ~= nil then
                    completeMessage = completeMessage .. fragments[frag_hash][index]
                else
                    print ("Missing fragment: " .. index .. " for group: " .. frag_gid .. " hash: " .. frag_hash)
                    break
                end
                if (index == frag_chnum)
                then
                    -- Final fragment, we're done
                    assembled = true
                    break
                end
                index = index + 1
            end
            if (not assembled)
            then
                -- Missing fragment or >maximum fragments
                return nil
            end

            -- Save reassembled packet in table, purge partial fragments
            fragments[frag_hash] = {}
            fragments[frag_hash][-1] = completeMessage
            fragments[frag_hash][-2] = pinfo.number

            -- New re-assembled Tvb
            buffer = ByteArray.tvb(completeMessage, "Reassembled")
            cursor = 0
        elseif (already_assembled and not last_fragment)
        then
            -- The packet number isn't set in first pass, but later ones
            set_pinfo_text(pinfo, "Reassembled in " .. fragments[frag_hash][-2])
            return
        end
    end

    if (has_value({128,129,130,131,132,133,134,135,136,137,138,139,142,143,140,141} , lidgren_message_type_id))
    then
        -- Library message
        tree:add(lmp_proto,buffer(cursor), "Lidgren Data")
        return nil
    end

    return buffer, cursor, lidgren_message_type_id
end
