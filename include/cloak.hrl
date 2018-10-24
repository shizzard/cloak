-define(es, erl_syntax).

-define(cloak_generated_function_new, new).
-define(cloak_generated_function_new_arity, 1).
-define(cloak_generated_function_update, update).
-define(cloak_generated_function_update_arity, 2).
-define(cloak_generated_function_export, export).
-define(cloak_generated_function_export_arity, 1).

-define(cloak_generated_function_getter_arity, 1).
-define(cloak_generated_function_setter_arity, 2).
-define(cloak_generated_function_validator_arity, 1).

-define(cloak_callback_validate_struct, validate_struct).
-define(cloak_callback_validate, validate).
-define(cloak_callback_updated, updated).
-define(cloak_struct_type, t).

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
    callback_validate_struct_exists = false :: boolean(),
    callback_updated_exists = false :: boolean(),
    user_definable_getter_callbacks = [] :: [atom()],
    user_definable_setter_callbacks = [] :: [atom()],
    user_definable_validator_callbacks = [] :: [atom()],
    user_definable_export_callbacks = [] :: [atom()],
    user_defined_getter_callbacks = [] :: [atom()],
    user_defined_setter_callbacks = [] :: [atom()],
    user_defined_validator_callbacks = [] :: [atom()],
    user_defined_export_callbacks = [] :: [atom()],
    export = [] :: list()
}).


