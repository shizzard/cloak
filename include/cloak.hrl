-define(es, erl_syntax).

-define(cloak_callback_validate, cloak_validate).
-define(cloak_callback_updated, cloak_updated).

-record(record_field, {
    name :: atom(),
    binary_name :: binary()
}).
-record(state, {
    module :: atom(),
    required_record_fields = [] :: [#record_field{}],
    optional_record_fields = [] :: [#record_field{}],
    protected_record_fields = [] :: [#record_field{}],
    private_record_fields = [] :: [#record_field{}],
    callback_validate_exists = false :: boolean(),
    callback_updated_exists = false :: boolean(),
    export = [] :: list()
}).


