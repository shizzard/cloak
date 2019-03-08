-module(priv_callbacks_on_import_datastructure_level).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    length,
    data
}).


on_import(<<Length:16, Data:Length/binary>>) ->
    #{
        length => Length,
        data => Data
    };

on_import(_Any) ->
    error(badarg).