-module(cloak_basic_typed_tests).

-include_lib("eunit/include/eunit.hrl").


can_get_constructor_defined_test() ->
    ?assertEqual(true, lists:member({new, 1}, priv_basic_typed:module_info(exports))).

can_get_all_accessors_defined_test() ->
    ?assertEqual(true, lists:all(fun(Export) ->
        lists:member(Export, priv_basic_typed:module_info(exports))
    end, [{a, 1}, {a, 2}, {b, 1}, {b, 2}])).

cannot_get_private_accessors_defined_test() ->
    ?assertEqual(true, lists:all(fun(Export) ->
        not lists:member(Export, priv_basic_typed:module_info(exports))
    end, [{'_c', 1}, {'_c', 2}])).

can_get_struct_test() ->
    Struct = priv_basic_typed:new(#{a => atom}),
    ?assertEqual(atom, priv_basic_typed:a(Struct)).

can_get_badarg_on_required_field_missing_test() ->
    ?assertError(badarg, priv_basic_typed:new(#{})).

can_get_optional_field_overriden_test() ->
    Struct = priv_basic_typed:new(#{a => atom, b => 123}),
    ?assertEqual(atom, priv_basic_typed:a(Struct)),
    ?assertEqual(123, priv_basic_typed:b(Struct)).

can_set_value_test() ->
    Struct = priv_basic_typed:new(#{a => atom, b => 123}),
    Struct1 = priv_basic_typed:a(Struct, another),
    Struct2 = priv_basic_typed:b(Struct1, 321),
    ?assertEqual(another, priv_basic_typed:a(Struct2)),
    ?assertEqual(321, priv_basic_typed:b(Struct2)).
