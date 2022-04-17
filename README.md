# LMP Wireshark Dissector

## Usage

```sh
wireshark -X lua_script:LmpWiresharkDissector.lua
```

## Manual server list request

```sh
# Sends a server list request, static date
echo -ne "0000009000000001009bee15b40520da0800001c000000" | xxd -ps -r | cat > /dev/udp/116.203.125.175/8700


# The following gets the hex representation of the current ticks (=one ten millionth of a second) since 0001-01-01
printf %016x `echo $((($(date --utc +%s) - $(date +%s --utc --date "0001-01-01")) * 10000000))`
# Converts big-endian hex to little-endian hex (https://km.kkrach.de/p_bash_conversion/)
be2le() {
	[ -z "$1" -o "$1" = "-h" ] && echo "be2le: Converts zero-padded big-endian hex numbers to little-endian" && return 0
	echo "$1" | grep -o .. | tac | echo "$(tr -d '\n')"
}

# Combined
echo -ne "000000900000000100$(be2le $(printf %016x $(echo $((($(date --utc +%s) - $(date +%s --utc --date "0001-01-01")) * 10000000)))))00001c000000" | xxd -ps -r | cat> /dev/udp/127.0.0.1/8700
# or 00001d000000 for 0.29.0
```

## Manual ping

        Type     Frag Seq              PayLen            Payload
        ........ .    ....... ........ ........ ........ ------
    Bin 10000001 0    0000000 00000000 00000000 00000000
    Hex 8   1    0       0    0   0    0   0    0   0

    echo -ne "\x81\x00\x00\x00\x00" >/dev/udp/116.203.125.175/8700
