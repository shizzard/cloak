# Runtime errors

TL;DR: `cloak` will `throw` the standard `badarg` error in every case other than happy-path one.

This means that you should wrap critical sections of your code with `try..catch` to avoid process crash.

## Validation errors

Validation errors will be generated in case of:

* [Required field](field-types.md) was not found in `Module:new/1` argument map;
* Field value [validation](validators.md) failed with any reason;
* Any of `Module:Getter/1`, `Module:Setter/2`, `Module:update/2`, `Module:export/1` functions being called with wrong type of argument, e.g. invalid value passed instead of `Module` internal record (`Module:t()`).
