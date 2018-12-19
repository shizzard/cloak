-module(priv_substructured).
-compile({parse_transform, cloak_transform}).

-cloak_nested({a, priv_substructured_nested_a}).
-cloak_nested_list({b, priv_substructured_nested_b}).
-cloak_nested({opt, priv_substructured_nested_opt}).

-record(?MODULE, {
    a,
    b,
    opt = priv_substructured_nested_opt:new(#{x => 1})
}).
