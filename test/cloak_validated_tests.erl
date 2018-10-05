-module(cloak_validated_tests).

-include_lib("eunit/include/eunit.hrl").


can_get_struct_test() ->
    Struct = priv_validated:new(#{a => 123, a1 => 123}),
    ?assertEqual(123, priv_validated:a(Struct)),
    ?assertEqual(123, priv_validated:a1(Struct)),
    ?assertEqual(atom, priv_validated:b(Struct)),
    ?assertEqual(undefined, priv_validated:b1(Struct)).

can_get_optional_field_overriden_test() ->
    Struct = priv_validated:new(#{a => 123, a1 => 123, b => valid_atom}),
    ?assertEqual(123, priv_validated:a(Struct)),
    ?assertEqual(123, priv_validated:a1(Struct)),
    ?assertEqual(valid_atom, priv_validated:b(Struct)),
    ?assertEqual(undefined, priv_validated:b1(Struct)).

can_set_valid_value_test() ->
    Struct = priv_validated:new(#{a => 123, a1 => 123, b => valid_atom}),
    Struct1 = priv_validated:a(Struct, 321),
    Struct2 = priv_validated:b(Struct1, yet_valid_atom),
    ?assertEqual(321, priv_validated:a(Struct2)),
    ?assertEqual(123, priv_validated:a1(Struct2)),
    ?assertEqual(yet_valid_atom, priv_validated:b(Struct2)),
    ?assertEqual(undefined, priv_validated:b1(Struct2)).

cannot_set_invalid_value_test() ->
    Struct = priv_validated:new(#{a => 123, a1 => 123, b => valid_atom}),
    ?assertError(badarg, priv_validated:a(Struct, 99)),
    ?assertError(badarg, priv_validated:b(Struct, invalid_atom)).

can_get_badarg_on_construction_test() ->
    ?assertError(badarg, priv_validated:new(#{a => 99, a1 => 123})).

can_get_optional_badarg_on_construction_test() ->
    ?assertError(badarg, priv_validated:new(#{a => 123, a1 => 123, b => invalid_atom})).
