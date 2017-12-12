-module(priv_typed_basic).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    a :: integer(),
    b = atom :: atom(),
    prot_c = 0 :: integer(),
    priv_d = 0 :: integer()
}).
