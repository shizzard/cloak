# Compile-time options

## Common basics

The most common way to set some compile-time options for `cloak` is to append an option to `ERL_COMPILER_OPTIONS` environment variable as specified in [`compile` module documentation](http://erlang.org/doc/man/compile.html). You may look at [Makefile](/Makefile) for some examples.

```sh
ERL_COMPILER_OPTIONS='[{d, $ERLANG_MACROS, $VALUE}]'
```

Another way to specify a compile-time option is to set `-D` flag for `erlc` as specified in [compiler documentation](http://erlang.org/doc/man/erlc.html).

```sh
erlc -D$ERLANG_MACROS=$VALUE ...
```

## Dumping source code

Dumping parse-transformed source code may be very helpful if you want to learn how `cloak` actually works or if you found a bug and want to see what went wrong. It also may be helpful if you're using IDE like IntelliJ Idea, that is indexing your source code to provide some code completion and introspection functionality.

By default `cloak` will not dump any source code. If you want `cloak` to do this, you need to set `cloak_dump` macros at compile time. Value of this option is a directory where source code should be dumped to. This directory should exist and be writable.

```sh
ERL_COMPILER_OPTIONS='[{d, cloak_dump, "/tmp/cloak_dump"}]'
```

If you run `make test` in `cloak` root directory, you will be able to inspect the source code of test modules located in [test/priv/](/test/priv) directory. Source code of parse-transformed modules will be dumped to `temp/` directory. For example, very basic test module [priv_basic.erl](/test/priv/priv_basic.erl) is very short:

```erlang
-module(priv_basic).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    a,
    b = atom,
    prot_c = 0,
    priv_d = 0
}).

```

But if you look at parse-transformed source code (`temp/priv_basic.erl`), you will see big differences:

```erlang
-file("/Users/shizz/code/cloak/_build/test/lib/cloak/test/priv/priv_bas"
      "ic.erl",
      1).
-module(priv_basic).
-record(priv_basic,{a,b = atom,prot_c = 0,priv_d = 0}).
-export([export/1,b/2,a/2,prot_c/1,b/1,a/1,update/2,new/1]).
new(#{} = Var_map_0) ->
    case
        validate_struct(new_optional(Var_map_0,
                                     new_required(Var_map_0,
                                                  #priv_basic{},
                                                  [{a,<<97>>}]),
                                     [{b,<<98>>}]))
    of
        {ok,Var_value_1} ->
            Var_value_1;
        {error,Var_reason_0} ->
            _ = {suppressed_logging,
                 "cloak badarg: struct validation failed with reason: ~"
                 "p",
                 [Var_reason_0]},
            error(badarg)
    end;
new(_) ->
    error(badarg).

## ...more lines below...
```

This code is formatted with the [Erlang pretty printer](http://erlang.org/doc/man/erl_pp.html), so it may seem not very neat, but still understandable.

## Logging suppression

By default `cloak` will generate error log lines when data [validation](validators.md) fails. It is done by calling the default erlang `error_logger` module. For example, if you pass a map without [required](field-types.md) field to `Module:new/1`, it will generate the following error:

```erlang
            error_logger:error_msg("cloak badarg: required field '~s' i"
                                   "s not found",
                                   [Var_key_0]),
```

Sometimes working with invalid data may be a very significant part of your application' happy-path. In this case such logs may flood your error log and make it unreadable. You can suppress error logging with `cloak_suppress_logging` option. Value of the option is `boolean()`, e.g. atoms `true` or `false`. That is, `false` is a default value.

```sh
ERL_COMPILER_OPTIONS='[{d, cloak_suppress_logging, true}]'
```

When this option is set to `true`, `error_logger` calls will be replaced by the following lines:

```erlang
            _ = {suppressed_logging,
                 "cloak badarg: required field '~s' is not found",
                 [Var_key_0]},
```

## Field prefixes

You may redefine [private and protected fields](field-types.md) prefixes with setting `cloak_priv_prefix` and `cloak_prot_prefix`. Default values are `priv_` and `prot_` respectively.

```sh
ERL_COMPILER_OPTIONS='[{d, cloak_priv_prefix="hidden_"}, {d, cloak_prot_prefix, "readonly_"}]'
```

All record fields starting with `hidden_` will be threated as private, and ones starting with `readonly` will be threated as protected.
