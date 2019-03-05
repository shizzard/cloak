# Validators

`cloak` provides two ways of data validation: field-level and datastructure-level.

## Field-level validation

By default `cloak` threats all incoming values as valid.

You may declare a function called `on_validate_FIELD_NAME` with the following spec:

```erlang
-spec on_validate_FIELD_NAME(Value :: term()) ->
    MaybeNewValue :: term() | no_return().
```

Another words, your function should be of arity `1`, it should take an argument and validate it. If everything is okay, your function should return the (maybe new) `Value`, and this `Value` will be used as a field value. You also may throw an error.

Lets take a look at [priv_callbacks_on_validate.erl](/test/priv/priv_callbacks_on_validate.erl) test module.

```erlang
-module(priv_callbacks_on_validate).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    a,
    a1, % no validator, required
    b = atom,
    b1 = undefined % no validator, optional
}).


on_validate_a(Value) when Value > 100 ->
    Value;

on_validate_a(_) ->
    error(badarg).


on_validate_b(Value) when Value =/= invalid_atom ->
    Value;

on_validate_b(_) ->
    error(badarg).

```

We have two couples of fields here: two required (`a`, `a1`) and two optional (`b`, `b1`). Fields `a` and `b` have validator functions declared for them (`on_validate_a/1` and `on_validate_b` respectively). Field `a` should be greater then `100`, and field `b` should be any value except `invalid_atom`.

As usual, `cloak` will respect [field type](field-types.md) declaration and will throw an error if you will try to create a structure with missing required fields:

```erlang
1> priv_callbacks_on_validate:new(#{a => 150}).
** exception error: bad argument
     in function  priv_callbacks_on_validate:new_required/3
     in call from priv_callbacks_on_validate:new/1
```

Field `a1` have no validator declared, but it is still required.

You may create a struct with any value of field `a1`, but field `a` is protected with validator function:

```erlang
2> priv_callbacks_on_validate:new(#{a => 15, a1 => {any, term, [i, want]}}).
** exception error: bad argument
     in function  priv_callbacks_on_validate:on_validate_a/1 
     in call from priv_callbacks_on_validate:a/2
     in call from priv_callbacks_on_validate:new_required/3
     in call from priv_callbacks_on_validate:new/1
```

Same thing happens with optional field that is protected with validator function:

```erlang
3> priv_callbacks_on_validate:new(#{a => 150, a1 => {any, term, [i, want]}, b => invalid_atom}).
** exception error: bad argument
     in function  priv_callbacks_on_validate:on_validate_b/1
     in call from priv_callbacks_on_validate:b/2
     in call from priv_callbacks_on_validate:new_optional/3
     in call from priv_callbacks_on_validate:new/1
```

If you will provide valid data for your datastructure, `cloak` will return the struct:

```erlang
4> priv_callbacks_on_validate:new(#{a => 150, a1 => {any, term, [i, want]}, b => some_atom}).
{priv_callbacks_on_validate,150,{any,term,[i,want]},some_atom,undefined}
```

Note, that default values for optional fields are not validated by `cloak` in any case. In the example above field `b` have a validator with the restriction of `invalid_atom` value, but if you will set the default value of field `b` to `invalid_atom`, it will be set successfully (if no field `b` value will exist in `Module:new/1` argument).

You also may want to check [priv_callbacks_on_validate.erl](/test/priv/priv_callbacks_on_validate.erl) modified source code to understand what happens when you're declaring field-level validator:

```erlang
i_on_validate(a1, Var_value_0) ->
    Var_value_0;
i_on_validate(a, Var_value_0) ->
    on_validate_a(Var_value_0);
i_on_validate(b1, Var_value_0) ->
    Var_value_0;
i_on_validate(b, Var_value_0) ->
    on_validate_b(Var_value_0);
i_on_validate(_, _) ->
    error(badarg).
```

On every set operation `cloak` calls [generated internal function](internal-functions.md) `i_on_validate/2`. If `cloak` find user-dedeclared validator in module source code, it modifies the code of `i_on_validate2` function to pass the argument to user-declared validator.

## Datastructure-level validation

By default `cloak` threats your datastructure as valid, but sometimes your datastructure has some multifield constraints that must be met. In this case `Module:on_update/1` callback might be helpful.

```erlang
-spec on_update(Value :: #?MODULE{}) ->
    MaybeNewStruct :: #?MODULE{} | no_return().
```

The same thing as with field-level validation here, except the fact that your callback should accept internal `#?MODULE{}` datastructure and return (probably new) datastructure on success. This means, that this callback is also the place to code [protected and private](field-types.md) fields updates.

Lets take a look at [priv_callbacks_on_update.erl](/test/priv/priv_callbacks_on_update.erl) test module.

```erlang
-module(priv_callbacks_on_update).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {
    a,
    b = atom,
    prot_c = 0,
    priv_d = 0
}).

on_update(#?MODULE{a = A, prot_c = C} = Value) when A > 100 andalso C == 0 ->
    Value;

on_update(_) ->
    error(badarg).
```

On every structure update (including `MODULE:new/1`, `MODULE:update/2` and `Module:Setter/2` calls) this function will be invoked to check resulting datastructure for validity.

```erlang
1> priv_callbacks_on_update:new(#{a => 15}).
** exception error: bad argument
     in function  priv_callbacks_on_update:new/1
```

Despite the fact that field `a` is not protected with validator, you will still get runtime error. Same thing when using `Module:Setter/2` and `Module:update/2`:

```erlang
2> S = priv_callbacks_on_update:new(#{a => 150}).
{priv_callbacks_on_update,150,atom,0,0}
3> priv_callbacks_on_update:a(S, 15).
{priv_callbacks_on_update,15,atom,0,0}
4> priv_callbacks_on_update:update(S, #{a => 15, b => any}).
** exception error: bad argument
     in function  priv_callbacks_on_update:update/2
```

You may also check dumped [priv_callbacks_on_update.erl](/test/priv/priv_callbacks_on_update.erl) source code to understand how this works:

```erlang
i_on_update(#priv_callbacks_on_update{} = Var_record_0) ->
    on_update(Var_record_0);
i_on_update(_) ->
    error(badarg).
```

On every modifying operation `cloak` will invoke `Module:i_on_update/1` [internal function](internal-functions.md). By default this function returns `Argument`, but if it will detect datastructure-level validator, it will pass the argument to detected function.
