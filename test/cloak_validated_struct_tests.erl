-module(cloak_validated_struct_tests).

-include_lib("eunit/include/eunit.hrl").


can_get_struct_test() ->
    Struct = priv_validated_struct:new(#{a => 123}),
    ?assertEqual(123, priv_validated_struct:a(Struct)).

can_get_badarg_on_construction_test() ->
    ?assertError(badarg, priv_validated_struct:new(#{a => 99})).
