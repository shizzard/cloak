-module(cloak_callbackd_tests).

-include_lib("eunit/include/eunit.hrl").


can_get_valid_value_test() ->
    Basic0 = priv_callbackd:new(#{a => 123, b => atom}),
    Basic1 = priv_callbackd:a(Basic0, 123),
    Basic2 = priv_callbackd:a(Basic1, 123),
    Basic3 = priv_callbackd:a(Basic2, 123),
    ?assertEqual(5, priv_callbackd:prot_op_count(Basic3)),
    Basic4 = priv_callbackd:b(Basic3, atom),
    ?assertEqual(6, priv_callbackd:prot_op_count(Basic4)),
    %% quite hacky
    ?assertEqual({priv_callbackd, 123, atom, 6, 0}, Basic4).
