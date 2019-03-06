-module(priv_callbacks_on_export).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    a
}).


on_export_a(Value) ->
    Value * 2.
