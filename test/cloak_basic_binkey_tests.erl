-module(cloak_basic_binkey_tests).

-include_lib("eunit/include/eunit.hrl").


can_get_struct_test() ->
    Struct = priv_basic:new(#{<<"a">> => atom}),
    ?assertEqual(atom, priv_basic:a(Struct)).

can_get_badarg_on_required_field_missing_test() ->
    ?assertError(badarg, priv_basic:new(#{})).

can_get_optional_field_overriden_test() ->
    Struct = priv_basic:new(#{<<"a">> => atom, <<"b">> => 123}),
    ?assertEqual(atom, priv_basic:a(Struct)),
    ?assertEqual(123, priv_basic:b(Struct)).

can_set_value_test() ->
    Struct = priv_basic:new(#{<<"a">> => atom, <<"b">> => 123}),
    Struct1 = priv_basic:a(another, Struct),
    Struct2 = priv_basic:b(321, Struct1),
    ?assertEqual(another, priv_basic:a(Struct2)),
    ?assertEqual(321, priv_basic:b(Struct2)).
