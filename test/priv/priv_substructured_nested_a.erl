-module(priv_substructured_nested_a).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    c
}).