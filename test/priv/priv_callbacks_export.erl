-module(priv_callbacks_export).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    a
}).


on_export_a(#?MODULE{a = Value}) ->
    Value * 2.
