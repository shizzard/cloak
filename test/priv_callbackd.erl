-module(priv_callbackd).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    a,
    b = atom,
    '_c' = 0
}).

cloak_updated(a, Record) ->
    Record#?MODULE{'_c' = Record#?MODULE.'_c' + 1};

cloak_updated(b, Record) ->
    Record#?MODULE{'_c' = Record#?MODULE.'_c' - 1};

cloak_updated(_, Record) ->
    Record.
