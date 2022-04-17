-- https://hg.prosody.im/trunk/rev/48f7cda4174d
return {
    band   = function (a, b) return a & b end;
    bor    = function (a, b) return a | b end;
    lshift = function (a, b) return a << b end;
    rshift = function (a, b) return a << b end;
}
