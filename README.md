# Cloak: generic datastructures for Erlang and Elixir (WIP)

TL;DR: `cloak` is a parse_transform application, designed to make erlang programmers life a bit easier. It looks for record `?MODULE` definition in your module and generates a bunch of helper functions for you, like getters and setters. You may find Getting Started guide down below or proceed to the [Documentation](docs/index.md) section.

## Motivation

There are lots of moments when erlang developers need to write lots of boilerplate modules. You may remember all of your `gen_server`s, for example, and all of that callback stubs.

I faced the same problem when found myself writing a bunch of PDU (protocol data units) modules used for validation of network data. Most of the time I was copypasting the same code, changing field names, validation functions and parse/export definitions. And the most frustrating moment is that I needed to support all of that boilerplate once it was written.

I thought that it might be a good idea to generate that code instead of writing it by hand: in general you have all of the information needed for that boilerplate in your datastructure definition.

`cloak` may be useful for you if you have a bunch of code that was written to protect your system from malformed data, no matter where it came from.

All code is generated at compile-time, so you can read generated code, write some tests, and be sure that you will get no surprise at runtime.

`cloak` will never change your own code' AST: all it does is gathering information about your module source code and generating the code for you. That is, `cloak` is truly declarative.

## Getting started

Make `cloak` work for you is a simple thing: all you need to do is to create a module with a record definition and a compile directive that will allow `cloak` to do it's work:

```erlang
-module(cloak_example1).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {one, two, three}).

```

That's it! Once you compile the module, you may take a look at module exports:

```
1> cloak_example1:module_info(exports).
[{new,1},
 {update,2},
 {three,1},
 {two,1},
 {one,1},
 {three,2},
 {two,2},
 {one,2},
 {export,1},
 {module_info,0},
 {module_info,1}]
 ```

Lets cover all of these one-by-one.

`Module:new/1` is the most common way to create an opaque struct. It takes a map with `atom()` or `binary()` keys and `term()` values and returns an opaque record structure, which is obviously a `tuple()`:

```erlang
2> cloak_example1:new(#{one => hello, two => code, three => generation}).
{cloak_example1,hello,code,generation}
```

Note, that `cloak` totally ignores keys and values that are not presented in record definition:

```erlang
3> cloak_example1:new(#{one => hello, two => code, three => generation, extra => atom}).
{cloak_example1,hello,code,generation}
```

`Module:update/2` function may be used to update several fields at a time.

```erlang
4> Opaque = cloak_example1:new(#{one => hello, two => code, three => generation}).
{cloak_example1,hello,code,generation}
5> cloak_example1:update(Opaque, #{one => hi, three => gen}).
{cloak_example1,hi,code,gen}
```

`Module:Getter/1` is used to get a field value.

```erlang
6> cloak_example1:two(Opaque).
code
```

`Module:Setter/2` is a way to update one field value at a time.

```erlang
7> cloak_example1:two(Opaque, 'CODE').
{cloak_example1,hello,'CODE',generation}
```

`Module:export/1` returns your data as a map.

```erlang
8> cloak_example1:export(Opaque).
#{one => hello,three => generation,two => code}
```

Last two functions are not related to `cloak` :)

## Go deeper

Of course, this is not a full list of `cloak` features. You may learn how to use another features, like different types of fields, validators, various callbacks and substructure definitions from [Documentation](docs/index.md) section.
