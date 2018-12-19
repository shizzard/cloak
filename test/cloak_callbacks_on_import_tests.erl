-module(cloak_callbacks_on_import_tests).

-include_lib("eunit/include/eunit.hrl").


can_get_valid_value_test() ->
    Struct = priv_callbacks_on_import:new(#{a => [123, 321, 117, 4]}),
    ?assertEqual(123, priv_callbacks_on_import:a(Struct)).


can_set_valid_value_test() ->
    Struct = priv_callbacks_on_import:new(#{a => [123, 321, 117, 4]}),
    ?assertEqual(117, priv_callbacks_on_import:a(priv_callbacks_on_import:a(117, Struct))).
