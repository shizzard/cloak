-module(priv_callbacks_substructures_nested_b).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    d
}).