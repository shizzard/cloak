# Internal functions

Internal functions are auto-generated by cloak on compile-time. Normally you will not need it, but it may be useful if you want to implement some specific functionality and you don't want to reimplement already generated code.

You may quickly find these function in [dumped source code](compile-time-options.md) as these functions have `i_...` names.

## `i_new_required/3`

```erlang
-spec i_new_required(
    Map :: map(), 
    InStruct :: #?MODULE{}, 
    RequiredKeys :: [{AtomKey :: atom(), BinaryKey :: binary()}]
) ->
    OutStruct :: #?MODULE{} | no_return().
```

`i_new_required/3` is used in the exported function `new/1` to fill opaque record with `RequiredKeys`. 

If any of `RequiredFields` will not be found in the `Map`, `badarg` error will occur.

## `i_new_optional/3`

```erlang
-spec i_new_optional(
    Map :: map(), 
    InStruct :: #?MODULE{}, 
    OptionalKeys :: [{AtomKey :: atom(), BinaryKey :: binary()}]
) ->
    OutStruct :: #?MODULE{} | no_return().
```

`i_new_optional/3` is used in the exported function `new/1` to fill opaque record with `OptionalKeys`. 

If any of `OptionalFields` will not be found in the `Map`, nothing will happen, particular key will be skipped. 

## `i_new_maybe_substructure/2`

```erlang
-spec i_new_maybe_substructure(
    AtomKey :: atom(), 
    InValue :: term()
) ->
    OutValue :: term().
```

`i_new_maybe_substructure/2` is called within `i_new_required/3` and `i_new_optional/3` functions. As it can be read, this function calls a [subsctructure](substructures.md) constructor for the field `AtomKey` if there is substructure definition for this field, and returns the opaque struct.

Function returns `InValue` as-is if there no substructure definition in the module.

## `i_on_import/2`

```erlang
-spec i_on_import(
    AtomKey :: atom(), 
    InValue :: term()
) ->
    OutValue :: term().
```

`i_on_import/2` is called within `i_new_required/3` and `i_new_optional/3` functions.

It is mapped to `on_import/1` [importer](importers.md) callback it is defined. 

Function returns `InValue` as-is if no `on_import/1` callback is defined. 

## `i_on_validate/2`

```erlang
-spec i_on_validate(
    AtomKey :: atom(), 
    InValue :: term()
) ->
    OutValue :: term().
```

This function is called on every `AtomKey` field modification. 

It is mapped to `on_validate/1` field-level [validation](validators.md) callback it is defined. 

Function returns `InValue` as-is if no `on_validate/1` callback is defined. 

## `i_on_update/1`

```erlang
-spec i_on_update(
    InStruct :: #?MODULE{}
) ->
    OutStruct :: #?MODULE{} | no_return().
```

This function is called on every `Struct` modification. 

It is mapped to `on_update/1` datastructure-level [validation](validators.md) callback it is defined. 

Function returns `InStruct` as-is if no `on_update/1` callback is defined.

If `InStruct` is not a `#?MODULE{}` record, `badarg` error will occur.

## `i_on_set/1`

```erlang
-spec i_on_set(
    AtomKey :: atom(),
    InValue :: term(),
    InStruct :: #?MODULE{}
) -> 
    OutStruct :: #?MODULE{} | no_return().
```

This function is called on every `set/2` call.

It is mapped to a record expression, where `i_on_validate(AtomKey, InValue)` return is set to the `AtomKey` field.

If `InStruct` is not a `#?MODULE{}` record or `AtomKey` is not present in `#?MODULE{}` record, `badarg` error will occur.
