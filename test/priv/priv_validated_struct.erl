-module(priv_validated_struct).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    a,
    b = atom,
    prot_c = 0,
    priv_d = 0
}).

validate_struct(#?MODULE{a = A, prot_c = C} = Value) when A > 100 andalso C == 0 ->
    {ok, Value};

validate_struct(_) ->
    {error, invalid}.
