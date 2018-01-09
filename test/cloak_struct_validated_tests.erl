-module(cloak_struct_validated_tests).

-include_lib("eunit/include/eunit.hrl").


can_get_struct_test() ->
    Basic = priv_struct_validated:new(#{a => 123}),
    ?assertEqual(123, priv_struct_validated:a(Basic)).

can_get_badarg_on_construction_test() ->
    ?assertError(badarg, priv_struct_validated:new(#{a => 99})).
