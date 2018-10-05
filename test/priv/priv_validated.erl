-module(priv_validated).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    a,
    a1, % no validator, required
    b = atom,
    b1 = undefined % no validator, optional
}).


on_validate_a(Value) when Value > 100 ->
    {ok, Value};

on_validate_a(_) ->
    error(badarg).


on_validate_b(Value) when Value =/= invalid_atom ->
    {ok, Value};

on_validate_b(_) ->
    error(badarg).
