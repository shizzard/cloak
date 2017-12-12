-module(priv_validated).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    a,
    b = atom,
    prot_c = 0,
    priv_d = 0
}).

cloak_validate(a, Value) when Value > 100 ->
    {ok, Value};

cloak_validate(b, Value) when Value =/= invalid_atom ->
    {ok, Value};

cloak_validate(_, _) ->
    {error, invalid}.
