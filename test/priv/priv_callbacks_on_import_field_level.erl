-module(priv_callbacks_on_import_field_level).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    a,
    b = atom
}).


on_import_a([Integer | _Tail]) when is_integer(Integer) ->
    Integer;

on_import_a(_) ->
    error(badarg).