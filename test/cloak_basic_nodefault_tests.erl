-module(cloak_basic_nodefault_tests).

-include_lib("eunit/include/eunit.hrl").


can_get_struct_test() ->
    Basic = priv_basic_nodefault:new(#{a => atom}),
    ?assertEqual(atom, priv_basic_nodefault:a(Basic)).

can_get_prot_field_undefined_test() ->
    Basic = priv_basic_nodefault:new(#{a => atom}),
    ?assertEqual(undefined, priv_basic_nodefault:prot_c(Basic)).
