-module(cloak_callbacks_on_update_tests).

-include_lib("eunit/include/eunit.hrl").


can_get_struct_test() ->
    Struct = priv_callbacks_on_update:new(#{a => 123}),
    ?assertEqual(123, priv_callbacks_on_update:a(Struct)).

can_get_badarg_on_construction_test() ->
    ?assertError(badarg, priv_callbacks_on_update:new(#{a => 99})).

can_get_badarg_on_update_test() ->
    Struct = priv_callbacks_on_update:new(#{a => 123}),
    ?assertError(badarg, priv_callbacks_on_update:update(Struct, #{a => 99})).

can_get_badarg_on_set_test() ->
    Struct = priv_callbacks_on_update:new(#{a => 123}),
    ?assertError(badarg, priv_callbacks_on_update:a(Struct, 99)).
