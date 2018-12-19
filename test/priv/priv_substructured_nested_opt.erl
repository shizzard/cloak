-module(priv_substructured_nested_opt).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    x
}).