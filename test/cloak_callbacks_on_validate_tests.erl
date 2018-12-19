-module(cloak_callbacks_on_validate_tests).

-include_lib("eunit/include/eunit.hrl").


can_get_struct_test() ->
    Struct = priv_callbacks_on_validate:new(#{a => 123, a1 => 123}),
    ?assertEqual(123, priv_callbacks_on_validate:a(Struct)),
    ?assertEqual(123, priv_callbacks_on_validate:a1(Struct)),
    ?assertEqual(atom, priv_callbacks_on_validate:b(Struct)),
    ?assertEqual(undefined, priv_callbacks_on_validate:b1(Struct)).

can_get_optional_field_overriden_test() ->
    Struct = priv_callbacks_on_validate:new(#{a => 123, a1 => 123, b => valid_atom}),
    ?assertEqual(123, priv_callbacks_on_validate:a(Struct)),
    ?assertEqual(123, priv_callbacks_on_validate:a1(Struct)),
    ?assertEqual(valid_atom, priv_callbacks_on_validate:b(Struct)),
    ?assertEqual(undefined, priv_callbacks_on_validate:b1(Struct)).

can_set_valid_value_test() ->
    Struct = priv_callbacks_on_validate:new(#{a => 123, a1 => 123, b => valid_atom}),
    Struct1 = priv_callbacks_on_validate:a(321, Struct),
    Struct2 = priv_callbacks_on_validate:b(yet_valid_atom, Struct1),
    ?assertEqual(321, priv_callbacks_on_validate:a(Struct2)),
    ?assertEqual(123, priv_callbacks_on_validate:a1(Struct2)),
    ?assertEqual(yet_valid_atom, priv_callbacks_on_validate:b(Struct2)),
    ?assertEqual(undefined, priv_callbacks_on_validate:b1(Struct2)).

cannot_set_invalid_value_test() ->
    Struct = priv_callbacks_on_validate:new(#{a => 123, a1 => 123, b => valid_atom}),
    ?assertError(badarg, priv_callbacks_on_validate:a(Struct, 99)),
    ?assertError(badarg, priv_callbacks_on_validate:b(Struct, invalid_atom)).

can_get_badarg_on_construction_test() ->
    ?assertError(badarg, priv_callbacks_on_validate:new(#{a => 99, a1 => 123})).

can_get_optional_badarg_on_construction_test() ->
    ?assertError(badarg, priv_callbacks_on_validate:new(#{a => 123, a1 => 123, b => invalid_atom})).
