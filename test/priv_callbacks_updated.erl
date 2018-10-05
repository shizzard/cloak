-module(priv_callbacks_updated).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    a,
    b = atom,
    prot_op_count = 0,
    priv_c = 0
}).

updated(a, Record) ->
    Record#?MODULE{prot_op_count = Record#?MODULE.prot_op_count + 1};

updated(b, Record) ->
    Record#?MODULE{prot_op_count = Record#?MODULE.prot_op_count + 1};

updated(_, Record) ->
    Record.
