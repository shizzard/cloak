-module(priv_callbacks_on_update).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    a,
    b = atom,
    prot_c = 0,
    priv_d = 0
}).

on_update(#?MODULE{a = A, prot_c = C} = Value) when A > 100 andalso C == 0 ->
    Value;

on_update(_) ->
    error(badarg).
