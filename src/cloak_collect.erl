-module(cloak_collect).
-export([collect/1]).
-include("cloak.hrl").

-ifndef(cloak_priv_prefix).
-define(cloak_priv_prefix, "priv_").
-endif.
-ifndef(cloak_prot_prefix).
-define(cloak_prot_prefix, "prot_").
-endif.



collect(Forms0) ->
    [?es:revert(cloak_traverse:traverse(fun callback/2, Form)) || Form <- Forms0].



callback(attribute, Form) ->
    case {?es:atom_value(?es:attribute_name(Form)), ?es:attribute_arguments(Form)} of
        {module, Args} ->
            ?put_state(?get_state()#state{
                module = ?es:atom_value(hd(Args))
            });
        {?cloak_attribute_nested, [Tuple]} ->
            [Field, SubstructureModule] = ?es:tuple_elements(Tuple),
            cloak_generate:set_nested_substructure_module(?es:atom_value(Field), ?es:atom_value(SubstructureModule));
        {?cloak_attribute_nested_list, [Tuple]} ->
            [Field, SubstructureModule] = ?es:tuple_elements(Tuple),
            cloak_generate:set_nested_substructure_list_module(?es:atom_value(Field), ?es:atom_value(SubstructureModule));
        {record, Args} ->
            case ?es:atom_value(hd(Args)) == ?get_state()#state.module of
                true ->
                    ?put_state(?get_state()#state{record_definition_exists = true}),
                    [
                        collect_record_field(?es:type(FieldForm), FieldForm)
                        || FieldForm <- ?es:tuple_elements(hd(tl(?es:attribute_arguments(Form))))
                    ];
                false ->
                    ok
            end;
        _ ->
            ok
    end,
    Form;

callback(function, Form) ->
    maybe_detect_user_definable_callback(Form),
    Form;

callback(_Type, Form) ->
    Form.



collect_record_field(record_field, Form) ->
    collect_record_field(
        ?es:atom_name(?es:record_field_name(Form)),
        ?es:atom_value(?es:record_field_name(Form)),
        ?es:record_field_value(Form),
        _Type = none
    );

collect_record_field(typed_record_field, Form) ->
    collect_record_field(
        ?es:atom_name(?es:record_field_name(?es:typed_record_field_body(Form))),
        ?es:atom_value(?es:record_field_name(?es:typed_record_field_body(Form))),
        ?es:record_field_value(?es:typed_record_field_body(Form)),
        ?es:typed_record_field_type(Form)
    ).



collect_record_field(FieldStringName, FieldName, FieldValue, Type) ->
    case {
        FieldValue,
        lists:prefix(?cloak_priv_prefix, FieldStringName),
        lists:prefix(?cloak_prot_prefix, FieldStringName)
    } of
        {_, true, _} ->
            ?put_state(?get_state()#state{
                %% private field prefix
                private_record_fields = [#record_field{
                    name = FieldName,
                    binary_name = list_to_binary(FieldStringName),
                    type = Type
                } | ?get_state()#state.private_record_fields]
            });
        {_, _, true} ->
            ?put_state(?get_state()#state{
                %% protected field prefix
                protected_record_fields = [#record_field{
                    name = FieldName,
                    binary_name = list_to_binary(FieldStringName),
                    type = Type
                } | ?get_state()#state.protected_record_fields]
            });
        {none, _, _} ->
            ?put_state(?get_state()#state{
                %% record field has no initial value, so it is required
                required_record_fields = [#record_field{
                    name = FieldName,
                    binary_name = list_to_binary(FieldStringName),
                    type = Type
                } | ?get_state()#state.required_record_fields],
                user_definable_on_import_callbacks = [
                    ?user_definable_import_callback_name(FieldName)
                    | ?get_state()#state.user_definable_on_import_callbacks
                ],
                user_definable_on_validate_callbacks = [
                    ?user_definable_validator_callback_name(FieldName)
                    | ?get_state()#state.user_definable_on_validate_callbacks
                ],
                user_definable_on_export_callbacks = [
                    ?user_definable_export_callback_name(FieldName)
                    | ?get_state()#state.user_definable_on_export_callbacks
                ]
            });
        {_, _, _} ->
            ?put_state(?get_state()#state{
                %% no field prefix
                optional_record_fields = [#record_field{
                    name = FieldName,
                    binary_name = list_to_binary(FieldStringName),
                    type = Type
                } | ?get_state()#state.optional_record_fields],
                user_definable_on_import_callbacks = [
                    ?user_definable_import_callback_name(FieldName)
                    | ?get_state()#state.user_definable_on_import_callbacks
                ],
                user_definable_on_validate_callbacks = [
                    ?user_definable_validator_callback_name(FieldName)
                    | ?get_state()#state.user_definable_on_validate_callbacks
                ],
                user_definable_on_export_callbacks = [
                    ?user_definable_export_callback_name(FieldName)
                    | ?get_state()#state.user_definable_on_export_callbacks
                ]
            })
    end.



maybe_detect_user_definable_callback(Form) ->
    FunctionName = ?es:atom_value(?es:function_name(Form)),
    %% Weird construction here
    case {
        lists:member(FunctionName, ?get_state()#state.user_definable_on_import_callbacks),
        lists:member(FunctionName, ?get_state()#state.user_definable_on_validate_callbacks),
        lists:member(FunctionName, ?get_state()#state.user_definable_on_export_callbacks),
        ?user_definable_on_import_callback == FunctionName,
        ?user_definable_on_update_callback == FunctionName,
        ?user_definable_on_export_callback == FunctionName
    } of
        {true, _, _, _, _, _} ->
            ?put_state(?get_state()#state{
                user_defined_on_import_callbacks = [FunctionName | ?get_state()#state.user_defined_on_import_callbacks]
            });
        {_, true, _, _, _, _} ->
            ?put_state(?get_state()#state{
                user_defined_on_validate_callbacks = [FunctionName | ?get_state()#state.user_defined_on_validate_callbacks]
            });
        {_, _, true, _, _, _} ->
            ?put_state(?get_state()#state{
                user_defined_on_export_callbacks = [FunctionName | ?get_state()#state.user_defined_on_export_callbacks]
            });
        {_, _, _, true, _, _} ->
            ?put_state(?get_state()#state{
                user_defined_on_import_callback_exists = true
            });
        {_, _, _, _, true, _} ->
            ?put_state(?get_state()#state{
                user_defined_on_update_callback_exists = true
            });
        {_, _, _, _, _, true} ->
            ?put_state(?get_state()#state{
                user_defined_on_export_callback_exists = true
            });
        {_, _, _, _, _, _} ->
            ok
    end.
