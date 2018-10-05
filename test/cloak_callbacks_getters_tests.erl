-module(cloak_callbacks_getters_tests).

-include_lib("eunit/include/eunit.hrl").


can_get_valid_value_test() ->
    ?assertEqual(100, priv_callbacks_getters:a(priv_callbacks_getters:new(#{a => 123}))),
    ?assertEqual(100, priv_callbacks_getters:a(priv_callbacks_getters:new(#{a => 99}))),
    ?assertEqual(100, priv_callbacks_getters:a(priv_callbacks_getters:new(#{a => 100}))).


can_get_valid_value_after_update_test() ->
    Struct = priv_callbacks_getters:new(#{a => 123}),
    ?assertEqual(100, priv_callbacks_getters:a(priv_callbacks_getters:a(Struct, 99))).
