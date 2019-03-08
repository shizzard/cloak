# Importers

Defining importer functions is a way to import some fancy packed data into your datastructure.

Please, refer to [Exporters](exporters.md) documentation to find a way to pack your data back.

## Field-level importers

Techically speaking, field-level importers are called only within `new/1` function right before the [substructures](substructures.md) initialization if any.

You may declare a function called `on_import_FIELD_NAME` with the following spec:

```erlang
-spec on_import_FIELD_NAME(InValue :: term()) ->
    OutValue :: term() | no_return().
```

For example, if the original map contains a structured binary value under the `binary` field, the following function will automatically transform it to map:

```erlang
on_import_binary(<<Length:16, Value:Length/binary>>) ->
    #{
        length => Length,
        value => Value 
    };
on_import_binary(_) ->
    error(badarg).
```

You may refer to the [`priv_callbacks_on_import.erl`](/test/priv/priv_callbacks_on_import.erl) modified source code to understand what happens when you declare the importer:

```erlang
i_on_import(a, Var_value_0) ->
    on_import_a(Var_value_0);
i_on_import(_, Var_value_0) ->
    Var_value_0.
```

## Datastructure-level importers


