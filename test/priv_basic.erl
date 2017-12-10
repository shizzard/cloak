-module(priv_basic).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    a,
    b = atom,
    '_c' = 0
}).
