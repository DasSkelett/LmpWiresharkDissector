bit = require 'x_bit53'

require 'shifting'

local test_string = "iaushefmoaije,pf<svefk boirh<g o efp<awdi+<äawð…^¨»efi, weßu0r 93uw98rz3n9a0pr<kdf -öypskd fae4f39"
    .. "fea#yepk mfpsjye faeo apowfu3ßm 03r9ua<öoj fr-öp<um wdüi>Ad ,öwuopd m<awdu9 n08zw3789r2z p190ß^u 0uz z8 p efio "
    .. "ifuahfwop3i4h fröawopfk äyspeokf· þojefpojaw fäüpai3pofji apwäüe fimawöelkf äypseiom fawuf oeijf mopijupoejf jp"
    .. "fea#yepk mfpsjye faeo apowfu3ßm 03r9ua<öoj fr-öp<um wdüi>Ad ,öwuopd m<awdu9 n08zw3789r2z p190ß^u 0uz z8 p efio "
    .. "ifuahfwop3i4h fröawopfk äyspeokf· þojefpojaw fäüpai3pofji apwäüe fimawöelkf äypseiom fawuf oeijf mopijupoejf jp"
    .. "fea#yepk mfpsjye faeo apowfu3ßm 03r9ua<öoj fr-öp<um wdüi>Ad ,öwuopd m<awdu9 n08zw3789r2z p190ß^u 0uz z8 p efio "
    .. "ifuahfwop3i4h fröawopfk äyspeokf· þojefpojaw fäüpai3pofji apwäüe fimawöelkf äypseiom fawuf oeijf mopijupoejf jp"
    .. "fea#yepk mfpsjye faeo apowfu3ßm 03r9ua<öoj fr-öp<um wdüi>Ad ,öwuopd m<awdu9 n08zw3789r2z p190ß^u 0uz z8 p efio "
    .. "ifuahfwop3i4h fröawopfk äyspeokf· þojefpojaw fäüpai3pofji apwäüe fimawöelkf äypseiom fawuf oeijf mopijupoejf jp"
    .. "fea#yepk mfpsjye faeo apowfu3ßm 03r9ua<öoj fr-öp<um wdüi>Ad ,öwuopd m<awdu9 n08zw3789r2z p190ß^u 0uz z8 p efio "
    .. "ifuahfwop3i4h fröawopfk äyspeokf· þojefpojaw fäüpai3pofji apwäüe fimawöelkf äypseiom fawuf oeijf mopijupoejf jp"
    .. "fea#yepk mfpsjye faeo apowfu3ßm 03r9ua<öoj fr-öp<um wdüi>Ad ,öwuopd m<awdu9 n08zw3789r2z p190ß^u 0uz z8 p efio "
    .. "ifuahfwop3i4h fröawopfk äyspeokf· þojefpojaw fäüpai3pofji apwäüe fimawöelkf äypseiom fawuf oeijf mopijupoejf jp"
    .. "fea#yepk mfpsjye faeo apowfu3ßm 03r9ua<öoj fr-öp<um wdüi>Ad ,öwuopd m<awdu9 n08zw3789r2z p190ß^u 0uz z8 p efio "
    .. "ifuahfwop3i4h fröawopfk äyspeokf· þojefpojaw fäüpai3pofji apwäüe fimawöelkf äypseiom fawuf oeijf mopijupoejf jp"
    .. "fea#yepk mfpsjye faeo apowfu3ßm 03r9ua<öoj fr-öp<um wdüi>Ad ,öwuopd m<awdu9 n08zw3789r2z p190ß^u 0uz z8 p efio "
    .. "ifuahfwop3i4h fröawopfk äyspeokf· þojefpojaw fäüpai3pofji apwäüe fimawöelkf äypseiom fawuf oeijf mopijupoejf jp"
    .. "fea#yepk mfpsjye faeo apowfu3ßm 03r9ua<öoj fr-öp<um wdüi>Ad ,öwuopd m<awdu9 n08zw3789r2z p190ß^u 0uz z8 p efio "
    .. "ifuahfwop3i4h fröawopfk äyspeokf· þojefpojaw fäüpai3pofji apwäüe fimawöelkf äypseiom fawuf oeijf mopijupoejf jp"
    .. "fea#yepk mfpsjye faeo apowfu3ßm 03r9ua<öoj fr-öp<um wdüi>Ad ,öwuopd m<awdu9 n08zw3789r2z p190ß^u 0uz z8 p efio "
    .. "ifuahfwop3i4h fröawopfk äyspeokf· þojefpojaw fäüpai3pofji apwäüe fimawöelkf äypseiom fawuf oeijf mopijupoejf jp"
    .. "fea#yepk mfpsjye faeo apowfu3ßm 03r9ua<öoj fr-öp<um wdüi>Ad ,öwuopd m<awdu9 n08zw3789r2z p190ß^u 0uz z8 p efio "
    .. "ifuahfwop3i4h fröawopfk äyspeokf· þojefpojaw fäüpai3pofji apwäüe fimawöelkf äypseiom fawuf oeijf mopijupoejf jp"
    .. "fea#yepk mfpsjye faeo apowfu3ßm 03r9ua<öoj fr-öp<um wdüi>Ad ,öwuopd m<awdu9 n08zw3789r2z p190ß^u 0uz z8 p efio "
    .. "ifuahfwop3i4h fröawopfk äyspeokf· þojefpojaw fäüpai3pofji apwäüe fimawöelkf äypseiom fawuf oeijf mopijupoejf jp"
    .. "fea#yepk mfpsjye faeo apowfu3ßm 03r9ua<öoj fr-öp<um wdüi>Ad ,öwuopd m<awdu9 n08zw3789r2z p190ß^u 0uz z8 p efio "
    .. "ifuahfwop3i4h fröawopfk äyspeokf· þojefpojaw fäüpai3pofji apwäüe fimawöelkf äypseiom fawuf oeijf mopijupoejf jp"
    .. "fea#yepk mfpsjye faeo apowfu3ßm 03r9ua<öoj fr-öp<um wdüi>Ad ,öwuopd m<awdu9 n08zw3789r2z p190ß^u 0uz z8 p efio "
    .. "ifuahfwop3i4h fröawopfk äyspeokf· þojefpojaw fäüpai3pofji apwäüe fimawöelkf äypseiom fawuf oeijf mopijupoejf jp"
    .. "fea#yepk mfpsjye faeo apowfu3ßm 03r9ua<öoj fr-öp<um wdüi>Ad ,öwuopd m<awdu9 n08zw3789r2z p190ß^u 0uz z8 p efio "
    .. "ifuahfwop3i4h fröawopfk äyspeokf· þojefpojaw fäüpai3pofji apwäüe fimawöelkf äypseiom fawuf oeijf mopijupoejf jp"
    .. "fea#yepk mfpsjye faeo apowfu3ßm 03r9ua<öoj fr-öp<um wdüi>Ad ,öwuopd m<awdu9 n08zw3789r2z p190ß^u 0uz z8 p efio "
    .. "ifuahfwop3i4h fröawopfk äyspeokf· þojefpojaw fäüpai3pofji apwäüe fimawöelkf äypseiom fawuf oeijf mopijupoejf jp"
    

-- test_string, hex_string = array_lshiftrotate(test_string, false)
-- test_string, hex_string = array_lshiftrotate(test_string, false)
-- test_string, hex_string = array_lshiftrotate(test_string, false)
-- test_string, hex_string = array_lshiftrotate(test_string, false)
-- test_string, hex_string = array_lshiftrotate(test_string, false)
-- test_string, hex_string = array_lshiftrotate(test_string, false)
-- test_string, hex_string = array_lshiftrotate(test_string, true)
-- a, b = test_string, hex_string

test_string, hex_string = array_lshiftrotate_perf(test_string, false)
test_string, hex_string = array_lshiftrotate_perf(test_string, false)
test_string, hex_string = array_lshiftrotate_perf(test_string, false)
test_string, hex_string = array_lshiftrotate_perf(test_string, false)
test_string, hex_string = array_lshiftrotate_perf(test_string, false)
test_string, hex_string = array_lshiftrotate_perf(test_string, false)
test_string, hex_string = array_lshiftrotate_perf(test_string, true)
-- c, d = test_string, hex_string
-- 
-- print(b, d)
-- print(a == c)
