# Exporters

As opposed of [importers.md](importers.md), exporter functions may be used to pack your data according to your needs.

Exporter function is called right before packing your datastructure back into the `map()`.

You may declare a function `on_export_FIELD_NAME` with the following spec:

```erlang
-spec on_export_FIELD_NAME(InValue :: term()) ->
    OutValue :: term() | no_return().
``` 

You may find a simple example of such a function in [priv_callbacks_on_export.erl](/test/priv/priv_callbacks_on_export.erl):

```erlang
on_export_a(Value) ->
    Value * 2.
```

As you may notice, this function doubles the `a` field value before packing it into the map.

You may refer to the modified source code to understand what happens when you declare the exporter:

```erlang
export(#priv_callbacks_on_export{} = Var_record_0) ->
    #{a => i_on_export(a, Var_record_0#priv_callbacks_on_export.a)};
export(_) ->
    error(badarg).
    
## ...

i_on_export(a, Var_value_0) ->
    on_export_a(Var_value_0);
i_on_export(_, Var_value_0) ->
    Var_value_0.
```