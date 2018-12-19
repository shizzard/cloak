# Field types

`cloak` supports four field types: private, protected, optional and required.

Record definition should contain at least one required or optional field, otherwise `cloak` will generate compile-time error.

## Private fields

`cloak` will threat record field as private if it starts with `?cloak_priv_prefix`, which is `priv_` by default. Go to [Compile-time options](compile-time-options.md) page to learn how you can redefine it.

```erlang
record(?MODULE, {
    field,
    priv_field %% this one is private
}).
```

Private fields are not accessible from outside its "parent" module (unless you will hack it with `erlang:element/2` or something similar, of course, or will write and export a special function for this purpose): these fields are ignored in `Module:new/1` function, there will be no getters or setters generated, and these fields will not be exported (unless you change this behavior in your [Exporter](exporters.md) callback declaration).

Private fields are designed to store some internal information for use inside your module only. For example, you may place some information on datastructure creation, maintain it on updates and use it on export.

## Protected fields

`cloak` will threat record field as protected if it starts with `?cloak_prot_prefix`, which is `prot_` by default. Go to [Compile-time options](compile-time-options.md) page to learn how you can redefine it.

```erlang
record(?MODULE, {
    field,
    prot_field %% this one is protected
}).
```

Protected fields are "read-only": these fields will be ignored in `Module:new/1` function and these fields will not be exported; `cloak` will generate getters for these fields, but no setters will be available.

Protected fields are helpful when you need to store some metainformation regarding your datastructure, that is accessible from external code.

## Optional fields

Optional fields are those that have default value declared explicitly. Yes, every erlang record field will have default value `undefined` by design, but if you want `cloak` to threat field as optional, you will need to set explicit default value.

```erlang
record(?MODULE, {
    field,
    another_field = undefined %% still declare default value even if it is `undefined`
    yet_another_field = 0 %% some integer field with `0` default value
}).
```

Optional fields will be covered by all of generated functions. If field key/value will not present in `Module:new/1` argument, default value will be used instead.

## Required fields

Required field is any field that is not covered with previous definitions, e.g. `cloak` will threat record field as required if there is no default value for it and if it is not started with private or protected prefixes.

```
record(?MODULE, {
    field %% required field
}).
```

Required field, like optional one, will be covered by all of generated functions. If field key/value will not present in `Module:new/1` argument, [runtime error](runtime-errors.md) will be generated.
