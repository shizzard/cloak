-module(priv_callbacks_substructures).
-compile({parse_transform, cloak_transform}).

-cloak_nested({a, priv_callbacks_substructures_nested_a}).
-cloak_nested_list({b, priv_callbacks_substructures_nested_b}).
-cloak_nested({opt, priv_callbacks_substructures_nested_opt}).

-record(?MODULE, {
    a,
    b,
    opt = priv_callbacks_substructures_nested_opt:new(#{x => 1})
}).
