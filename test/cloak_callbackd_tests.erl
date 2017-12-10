-module(cloak_callbackd_tests).

-include_lib("eunit/include/eunit.hrl").


can_get_valid_value_test() ->
    Basic0 = priv_callbackd:new(#{a => 123, b => atom}),
    %% quite hacky
    Basic1 = priv_callbackd:a(Basic0, 123),
    Basic2 = priv_callbackd:a(Basic1, 123),
    Basic3 = priv_callbackd:a(Basic2, 123),
    ?assertEqual({priv_callbackd, 123, atom, 3}, Basic3),
    Basic4 = priv_callbackd:b(Basic3, atom),
    ?assertEqual({priv_callbackd, 123, atom, 2}, Basic4).
