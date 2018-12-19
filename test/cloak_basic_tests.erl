-module(cloak_basic_tests).

-include_lib("eunit/include/eunit.hrl").


can_get_constructor_defined_test() ->
    ?assertEqual(true, lists:member({new, 1}, priv_basic:module_info(exports))).

can_get_all_accessors_defined_test() ->
    ?assertEqual(true, lists:all(fun(Export) ->
        lists:member(Export, priv_basic:module_info(exports))
    end, [{a, 1}, {a, 2}, {b, 1}, {b, 2}, {prot_c, 1}])).

cannot_get_private_accessors_defined_test() ->
    ?assertEqual(true, lists:all(fun(Export) ->
        not lists:member(Export, priv_basic:module_info(exports))
    end, [{priv_d, 1}, {priv_d, 2}, {prot_c, 2}])).

can_get_struct_test() ->
    Struct = priv_basic:new(#{a => atom}),
    ?assertEqual(atom, priv_basic:a(Struct)).

can_get_badarg_on_required_field_missing_test() ->
    ?assertError(badarg, priv_basic:new(#{})).

can_get_optional_field_overriden_test() ->
    Struct = priv_basic:new(#{a => atom, b => 123}),
    ?assertEqual(atom, priv_basic:a(Struct)),
    ?assertEqual(123, priv_basic:b(Struct)).

can_set_value_test() ->
    Struct = priv_basic:new(#{a => atom, b => 123}),
    Struct1 = priv_basic:a(another, Struct),
    Struct2 = priv_basic:b(321, Struct1),
    ?assertEqual(another, priv_basic:a(Struct2)),
    ?assertEqual(321, priv_basic:b(Struct2)).

can_update_multiple_fields_test() ->
    Struct = priv_basic:new(#{a => atom, b => 123}),
    Struct1 = priv_basic:update(#{a => another, b => 321}, Struct),
    ?assertEqual(another, priv_basic:a(Struct1)),
    ?assertEqual(321, priv_basic:b(Struct1)).

can_update_export_test() ->
    Struct = priv_basic:new(#{a => atom, b => 123}),
    Struct1 = priv_basic:update(#{a => another, b => 321}, Struct),
    ?assertEqual(#{a => another, b => 321}, priv_basic:export(Struct1)).
