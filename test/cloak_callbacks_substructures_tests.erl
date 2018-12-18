-module(cloak_callbacks_substructures_tests).

-include_lib("eunit/include/eunit.hrl").


can_get_struct_test() ->
    Struct = priv_callbacks_substructures:new(#{a => #{c => 1}, b => [#{d => 2}]}),
    ?assert(is_tuple(priv_callbacks_substructures:a(Struct))),
    ?assert(is_list(priv_callbacks_substructures:b(Struct))).


can_get_values_on_export_test() ->
    Struct = priv_callbacks_substructures:new(#{a => #{c => 1}, b => [#{d => 2}]}),
    ?assertEqual(
        #{a => #{c => 1}, b => [#{d => 2}], opt => #{x => 1}},
        priv_callbacks_substructures:export(Struct)
    ).


can_get_override_optional_fields_test() ->
    Struct = priv_callbacks_substructures:new(#{a => #{c => 1}, b => [#{d => 2}], opt => #{x => 2}}),
    ?assertEqual(
        #{a => #{c => 1}, b => [#{d => 2}], opt => #{x => 2}},
        priv_callbacks_substructures:export(Struct)
    ).


can_get_update_values_test() ->
    Struct = priv_callbacks_substructures:new(#{a => #{c => 1}, b => [#{d => 2}]}),
    Struct1 = priv_callbacks_substructures:a(
        Struct,
        priv_callbacks_substructures_nested_a:new(#{c => 2})
    ),
    ?assertEqual(
        #{a => #{c => 2}, b => [#{d => 2}], opt => #{x => 1}},
        priv_callbacks_substructures:export(Struct1)
    ).