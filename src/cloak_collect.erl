-module(cloak_collect).
-export([collect/1]).
-include("cloak.hrl").


-ifdef(cloak_priv_prefix).
    priv_prefix() -> ?cloak_priv_prefix.
-else.
    priv_prefix() -> "priv_".
-endif.

-ifdef(cloak_prot_prefix).
    prot_prefix() -> ?cloak_prot_prefix.
-else.
    prot_prefix() -> "prot_".
-endif.



collect(Forms0) ->
    [?es:revert(cloak_traverse:traverse(fun callback/2, Form)) || Form <- Forms0].



callback(attribute, Form) ->
    case ?es:atom_value(?es:attribute_name(Form)) of
        module ->
            put(state, (get(state))#state{
                module = ?es:atom_value(hd(?es:attribute_arguments(Form)))
            });
        record ->
            (?es:atom_value(hd(?es:attribute_arguments(Form))) == (get(state))#state.module)
                andalso [
                    collect_record_field(?es:type(FieldForm), FieldForm)
                    || FieldForm <- ?es:tuple_elements(hd(tl(?es:attribute_arguments(Form))))
                ];
        _ ->
            ok
    end,
    Form;

callback(function, Form) ->
    maybe_detect_user_definable_callback(Form),
    put(state, (get(state))#state{
        callback_validate_struct_exists = is_callback_validate_struct(Form, (get(state))#state.callback_validate_struct_exists),
        callback_updated_exists = is_callback_updated(Form, (get(state))#state.callback_updated_exists)
    }),
    Form;

callback(_Type, Form) ->
    Form.



collect_record_field(record_field, Form) ->
    collect_record_field(
        ?es:atom_name(?es:record_field_name(Form)),
        ?es:atom_value(?es:record_field_name(Form)),
        ?es:record_field_value(Form)
    );

collect_record_field(typed_record_field, Form) ->
    collect_record_field(
        ?es:atom_name(?es:record_field_name(?es:typed_record_field_body(Form))),
        ?es:atom_value(?es:record_field_name(?es:typed_record_field_body(Form))),
        ?es:record_field_value(?es:typed_record_field_body(Form))
    ).



collect_record_field(FieldStringName, FieldName, FieldValue) ->
    case {
        FieldValue,
        lists:prefix(priv_prefix(), FieldStringName),
        lists:prefix(prot_prefix(), FieldStringName)
    } of
        {_, true, _} ->
            put(state, (get(state))#state{
                %% private field prefix
                private_record_fields = [#record_field{
                    name = FieldName,
                    binary_name = list_to_binary(FieldStringName)
                } | (get(state))#state.private_record_fields]
            });
        {_, _, true} ->
            put(state, (get(state))#state{
                %% protected field prefix
                protected_record_fields = [#record_field{
                    name = FieldName,
                    binary_name = list_to_binary(FieldStringName)
                } | (get(state))#state.protected_record_fields],
                user_definable_getter_callbacks = [
                    cloak_generate:generic_user_definable_getter_callback_name(FieldName)
                    | (get(state))#state.user_definable_getter_callbacks
                ]
            });
        {none, _, _} ->
            put(state, (get(state))#state{
                %% record field has no initial value, so it is required
                required_record_fields = [#record_field{
                    name = FieldName,
                    binary_name = list_to_binary(FieldStringName)
                } | (get(state))#state.required_record_fields],
                user_definable_getter_callbacks = [
                    cloak_generate:generic_user_definable_getter_callback_name(FieldName)
                    | (get(state))#state.user_definable_getter_callbacks
                ],
                user_definable_setter_callbacks = [
                    cloak_generate:generic_user_definable_setter_callback_name(FieldName)
                    | (get(state))#state.user_definable_setter_callbacks
                ],
                user_definable_validator_callbacks = [
                    cloak_generate:generic_user_definable_validator_callback_name(FieldName)
                    | (get(state))#state.user_definable_validator_callbacks
                ],
                user_definable_export_callbacks = [
                    cloak_generate:generic_user_definable_export_callback_name(FieldName)
                    | (get(state))#state.user_definable_export_callbacks
                ]
            });
        {_, _, _} ->
            put(state, (get(state))#state{
                %% no field prefix
                optional_record_fields = [#record_field{
                    name = FieldName,
                    binary_name = list_to_binary(FieldStringName)
                } | (get(state))#state.optional_record_fields],
                user_definable_getter_callbacks = [
                    cloak_generate:generic_user_definable_getter_callback_name(FieldName)
                    | (get(state))#state.user_definable_getter_callbacks
                ],
                user_definable_setter_callbacks = [
                    cloak_generate:generic_user_definable_setter_callback_name(FieldName)
                    | (get(state))#state.user_definable_setter_callbacks
                ],
                user_definable_validator_callbacks = [
                    cloak_generate:generic_user_definable_validator_callback_name(FieldName)
                    | (get(state))#state.user_definable_validator_callbacks
                ],
                user_definable_export_callbacks = [
                    cloak_generate:generic_user_definable_export_callback_name(FieldName)
                    | (get(state))#state.user_definable_export_callbacks
                ]
            })
    end.



maybe_detect_user_definable_callback(Form) ->
    FunctionName = ?es:atom_value(?es:function_name(Form)),
    case {
        lists:member(FunctionName, (get(state))#state.user_definable_getter_callbacks),
        lists:member(FunctionName, (get(state))#state.user_definable_setter_callbacks),
        lists:member(FunctionName, (get(state))#state.user_definable_validator_callbacks),
        lists:member(FunctionName, (get(state))#state.user_definable_export_callbacks)
    } of
        {true, _, _, _} ->
            put(state, (get(state))#state{
                user_defined_getter_callbacks = [FunctionName | (get(state))#state.user_defined_getter_callbacks]
            });
        {_, true, _, _} ->
            put(state, (get(state))#state{
                user_defined_setter_callbacks = [FunctionName | (get(state))#state.user_defined_setter_callbacks]
            });
        {_, _, true, _} ->
            put(state, (get(state))#state{
                user_defined_validator_callbacks = [FunctionName | (get(state))#state.user_defined_validator_callbacks]
            });
        {_, _, _, true} ->
            put(state, (get(state))#state{
                user_defined_export_callbacks = [FunctionName | (get(state))#state.user_defined_export_callbacks]
            });
        {_, _, _, _} ->
            ok
    end.



is_callback_validate_struct(Form, Default) ->
    case {?es:atom_value(?es:function_name(Form)), ?es:function_arity(Form)} of
        {?cloak_callback_validate_struct, 1} ->
            true;
        {_, _} ->
            Default
    end.



is_callback_updated(Form, Default) ->
    case {?es:atom_value(?es:function_name(Form)), ?es:function_arity(Form)} of
        {?cloak_callback_updated, 2} ->
            true;
        {_, _} ->
            Default
    end.
