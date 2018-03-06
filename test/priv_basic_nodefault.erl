-module(priv_basic_nodefault).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    a,
    b = atom,
    prot_c,
    priv_d
}).
