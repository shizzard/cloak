-module(priv_callbacks_substructures_nested_a).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    c
}).