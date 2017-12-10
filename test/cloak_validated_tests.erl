-module(cloak_validated_tests).

-include_lib("eunit/include/eunit.hrl").


can_get_struct_test() ->
    Basic = priv_validated:new(#{a => 123}),
    ?assertEqual(123, priv_validated:a(Basic)).

can_get_optional_field_overriden_test() ->
    Basic = priv_validated:new(#{a => 123, b => valid_atom}),
    ?assertEqual(123, priv_validated:a(Basic)),
    ?assertEqual(valid_atom, priv_validated:b(Basic)).

can_set_valid_value_test() ->
    Basic = priv_validated:new(#{a => 123, b => valid_atom}),
    Basic1 = priv_validated:a(Basic, 321),
    Basic2 = priv_validated:b(Basic1, yet_valid_atom),
    ?assertEqual(321, priv_validated:a(Basic2)),
    ?assertEqual(yet_valid_atom, priv_validated:b(Basic2)).

can_get_badarg_on_construction_test() ->
    ?assertError(badarg, priv_validated:new(#{a => 99})).

can_get_optional_badarg_on_construction_test() ->
    ?assertError(badarg, priv_validated:new(#{a => 123, b => invalid_atom})).
