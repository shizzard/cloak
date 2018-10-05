-module(priv_callbacks_getters).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    a
}).


on_get_a(_Record) ->
    100.
