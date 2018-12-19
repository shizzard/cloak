-module(priv_substructured_nested_b).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    d
}).