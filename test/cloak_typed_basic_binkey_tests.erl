-module(cloak_typed_basic_binkey_tests).

-include_lib("eunit/include/eunit.hrl").


can_get_struct_test() ->
    Basic = priv_typed_basic:new(#{<<"a">> => atom}),
    ?assertEqual(atom, priv_typed_basic:a(Basic)).

can_get_badarg_on_required_field_missing_test() ->
    ?assertError(badarg, priv_typed_basic:new(#{})).

can_get_optional_field_overriden_test() ->
    Basic = priv_typed_basic:new(#{<<"a">> => atom, <<"b">> => 123}),
    ?assertEqual(atom, priv_typed_basic:a(Basic)),
    ?assertEqual(123, priv_typed_basic:b(Basic)).

can_set_value_test() ->
    Basic = priv_typed_basic:new(#{<<"a">> => atom, <<"b">> => 123}),
    Basic1 = priv_typed_basic:a(Basic, another),
    Basic2 = priv_typed_basic:b(Basic1, 321),
    ?assertEqual(another, priv_typed_basic:a(Basic2)),
    ?assertEqual(321, priv_typed_basic:b(Basic2)).
