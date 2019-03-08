-module(cloak_callbacks_on_import_datastructure_level_tests).

-include_lib("eunit/include/eunit.hrl").


can_get_valid_structure_test() ->
    Struct = priv_callbacks_on_import_datastructure_level:new(<<10:16, "0123456789">>),
    ?assertEqual(10, priv_callbacks_on_import_datastructure_level:length(Struct)),
    ?assertEqual(<<"0123456789">>, priv_callbacks_on_import_datastructure_level:data(Struct)).


can_get_badarg_on_invalid_structure_test() ->
    ?assertError(badarg, priv_callbacks_on_import_datastructure_level:new(<<3:16, "0123">>)).
