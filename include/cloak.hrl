-define(es, erl_syntax).

%% Attributes
-define(cloak_attribute_nested, cloak_nested).
-define(cloak_attribute_nested_list, cloak_nested_list).

%% Generated functions

-define(cloak_generated_function_new, new).
-define(cloak_generated_function_set, set).
-define(cloak_generated_function_get, get).
-define(cloak_generated_function_update, update).
-define(cloak_generated_function_export, export).

%% Generated functions - internal
-define(cloak_generated_function_i_new_required, i_new_required).
-define(cloak_generated_function_i_new_optional, i_new_optional).
-define(cloak_generated_function_i_new_maybe_substructure, i_new_maybe_substructure).
-define(cloak_generated_function_i_set, i_set).
-define(cloak_generated_function_i_get, i_get).
-define(cloak_generated_function_i_on_import, i_on_import).
-define(cloak_generated_function_i_on_update, i_on_update).
-define(cloak_generated_function_i_on_validate, i_on_validate).

%% Generated functions arities (for exportable ones)
-define(cloak_generated_function_new_arity, 1).
-define(cloak_generated_function_getter_arity, 1).
-define(cloak_generated_function_setter_arity, 2).
-define(cloak_generated_function_update_arity, 2).
-define(cloak_generated_function_export_arity, 1).

%% User-definable callbacks
-define(user_definable_update_callback, on_update).
-define(
user_definable_import_callback_name(FieldName),
    list_to_atom(lists:flatten(io_lib:format("on_import_~s", [FieldName])))
).
-define(
    user_definable_validator_callback_name(FieldName),
    list_to_atom(lists:flatten(io_lib:format("on_validate_~s", [FieldName])))
).
-define(
    user_definable_export_callback_name(FieldName),
    list_to_atom(lists:flatten(io_lib:format("on_export_~s", [FieldName])))
).

%% Datatypes
-define(cloak_struct_type, t).

%% Errors
-define(cloak_ct_error_no_basic_fields, cloak_ct_error_no_basic_fields).
-define(cloak_ct_error_no_record_definition, cloak_ct_error_no_record_definition).

%% Internal compile-time records
-record(record_field, {
    name :: atom(),
    binary_name :: binary()
}).
-record(state, {
    module :: atom(),
    record_definition_exists = false :: boolean(),
    required_record_fields = [] :: [#record_field{}],
    optional_record_fields = [] :: [#record_field{}],
    protected_record_fields = [] :: [#record_field{}],
    private_record_fields = [] :: [#record_field{}],
    nested_substructures = [] :: [{atom(), atom()}],
    nested_substructures_list = [] :: [{atom(), atom()}],
    user_definable_on_update_callback_exists = false :: boolean(),
    user_definable_validator_callbacks = [] :: [atom()],
    user_definable_export_callbacks = [] :: [atom()],
    user_definable_import_callbacks = [] :: [atom()],
    user_defined_getter_callbacks = [] :: [atom()],
    user_defined_setter_callbacks = [] :: [atom()],
    user_defined_import_callbacks = [] :: [atom()],
    user_defined_validator_callbacks = [] :: [atom()],
    user_defined_export_callbacks = [] :: [atom()],
    export = [] :: list()
}).

%% Some internal macros
-define(get_state(), (get(state))).
-define(put_state(NewState), put(state, NewState)).

