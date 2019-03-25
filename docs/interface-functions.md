# Interface functions

Interface functions are those functions that `cloak` will generate and export from your module.

This section is mostly the [Getting Started](/README.md) guide from the main README file, but contains more details and links to the related documentation.

## `new/1`

`Module:new/1` is the most common way to create an opaque struct. It takes a map with `atom()` or `binary()` keys and `term()` values and returns an opaque record structure, which is obviously a `tuple()`:

Note, that `new/1` totally ignores keys and values that are not presented in record definition, as well as your [private and protected](field-types.md) fields.

If you will declare [datastructure-level importer](importers.md) for your datastructure, `new/1` will accept an argument of any type, not only maps. However, unsure you will return a map from your datastructure-level importer so that `cloak` will be able to perform ordinary initialization steps.

This function also triggers all of [validators](validators.md) declared, both field-level and datastructure-level, in this order.

## `update/2`

`Module:update/2` function may be used to update several fields at a time. It basically acts in the same way as `new/1`, but threats all fields as optional. 

While it will also ignore all unknown keys, as well as your [private and protected](field-types.md) fields, it performs per-field merging.

This function will also trigger all [importers](importers.md) and all [validators](validators.md) declared.

## `Getter/1`

`cloak` will generate `Module:Getter/1` function for every [required, optional and protected](field-types.md) field declared.

It is pretty straight-forward and simple returns `?#MODULE{}` record field value. 

## `Setter/2`

`cloak` will generate `Module:Getter/1` function for every [required and optional](field-types.md) field declared.

```erlang
7> cloak_example1:two(Opaque, 'CODE').
{cloak_example1,hello,'CODE',generation}
```

## `export/1`

`Module:export/1` returns your data as a map.
 