-module(priv_callbackd).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    a,
    b = atom,
    prot_op_count = 0,
    priv_c = 0
}).

cloak_updated(a, Record) ->
    Record#?MODULE{prot_op_count = Record#?MODULE.prot_op_count + 1};

cloak_updated(b, Record) ->
    Record#?MODULE{prot_op_count = Record#?MODULE.prot_op_count + 1};

cloak_updated(_, Record) ->
    Record.
