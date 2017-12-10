-module(priv_typed_basic).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    a :: integer(),
    b = atom :: atom(),
    '_c' = 0 :: integer()
}).
