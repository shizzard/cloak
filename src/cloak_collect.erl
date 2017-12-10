-module(cloak_collect).
-export([collect/1]).
-include("cloak.hrl").



collect(Forms0) ->
    [?es:revert(traverse(fun callback/2, Form)) || Form <- Forms0].



traverse(Fun, Tree0) ->
    Tree1 = case ?es:subtrees(Tree0) of
        [] ->
            Tree0;
        List ->
            ?es:update_tree(
                Tree0,
                [[traverse(Fun, Subtree) || Subtree <- Group] || Group <- List]
            )
    end,
    Fun(?es:type(Tree1), Tree1).



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
    put(state, (get(state))#state{
        callback_validate_exists = is_callback_validate(Form, (get(state))#state.callback_validate_exists),
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



collect_record_field([$_ | _] = FieldStringName, FieldName, _FieldValue) ->
    State = get(state),
    put(state, State#state{
        %% record field name starts with '_', so it is hidden
        hidden_record_fields = [#record_field{
            name = FieldName,
            binary_name = list_to_binary(FieldStringName)
        } | State#state.hidden_record_fields]
    });

collect_record_field(FieldStringName, FieldName, none = _FieldValue) ->
    State = get(state),
    put(state, (get(state))#state{
        %% record field has no initial value, so it is required
        required_record_fields = [#record_field{
            name = FieldName,
            binary_name = list_to_binary(FieldStringName)
        } | State#state.required_record_fields]
    });

collect_record_field(FieldStringName, FieldName, _FieldValue) ->
    State = get(state),
    put(state, (get(state))#state{
        %% record field has initial value, so it is optional
        optional_record_fields = [#record_field{
            name = FieldName,
            binary_name = list_to_binary(FieldStringName)
        } | State#state.optional_record_fields]
    }).



is_callback_validate(Form, Default) ->
    case {?es:atom_value(?es:function_name(Form)), ?es:function_arity(Form)} of
        {?cloak_callback_validate, 2} ->
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