-module(priv_callbacks_setters).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    a,
    prot_a
}).


on_set_a(Record, Value) ->
    Record#?MODULE{a = Value, prot_a = Value}.
