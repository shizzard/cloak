-module(cloak_callbacks_setters_tests).

-include_lib("eunit/include/eunit.hrl").


can_get_valid_value_test() ->
    Struct = priv_callbacks_setters:new(#{a => 123}),
    ?assertEqual(123, priv_callbacks_setters:a(Struct)),
    ?assertEqual(123, priv_callbacks_setters:prot_a(Struct)).


can_get_valid_value_after_update_test() ->
    Struct = priv_callbacks_setters:new(#{a => 123}),
    Struct1 = priv_callbacks_setters:a(Struct, 99),
    ?assertEqual(99, priv_callbacks_setters:a(Struct1)),
    ?assertEqual(99, priv_callbacks_setters:prot_a(Struct1)).
