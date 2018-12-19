-module(cloak_callbacks_on_export_tests).

-include_lib("eunit/include/eunit.hrl").


can_get_valid_value_test() ->
    Struct = priv_callbacks_on_export:new(#{a => 123}),
    ?assertEqual(123, priv_callbacks_on_export:a(Struct)).


can_get_valid_value_on_export_test() ->
    Struct = priv_callbacks_on_export:new(#{a => 123}),
    ?assertEqual(#{a => 246}, priv_callbacks_on_export:export(Struct)).
