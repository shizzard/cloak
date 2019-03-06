-module(cloak_generate_export).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    [export__()].


%% New


export__() ->
    ?put_state(?get_state()#state{export = [
        {?cloak_generated_function_export, ?cloak_generated_function_export_arity} | ?get_state()#state.export
    ]}),
    [
        ?es:function(?es:atom(?cloak_generated_function_export), export_clauses__())
    ].


export_clauses__() ->
    FieldsCount = length(?get_state()#state.required_record_fields) + length(?get_state()#state.required_record_fields),
    [
        ?es:clause(export_clause_patterns_match__(FieldsCount), _Guards = none, export_clause_body_match__()),
        ?es:clause(export_clause_patterns_mismatch__(), _Guards = none, export_clause_body_mismatch__())
    ].


export_clause_patterns_match__(0) ->
    [?es:record_expr(?es:atom(?get_state()#state.module), [])];

export_clause_patterns_match__(_) ->
    [?es:match_expr(
        ?es:record_expr(?es:atom(?get_state()#state.module), []),
        cloak_generate:var__(record, 0)
    )].


export_clause_body_match__() ->
    [?es:map_expr([
        export_clause_body_match_map_field__(
            RecordField#record_field.name,
            cloak_generate:get_nested_substructure_module(RecordField#record_field.name),
            cloak_generate:get_nested_substructure_list_module(RecordField#record_field.name),
            lists:member(
                ?user_definable_export_callback_name(RecordField#record_field.name),
                ?get_state()#state.user_defined_export_callbacks
            )
        ) || RecordField
        <- ?get_state()#state.required_record_fields
        ++ ?get_state()#state.optional_record_fields
    ])].


export_clause_body_match_map_field__(Name, _, _, true) ->
    %% User-defined callback specified
    ?es:map_field_assoc(
        ?es:atom(Name),
        ?es:application(?es:atom(?cloak_generated_function_i_on_export), [
            ?es:atom(Name),
            ?es:record_access(
                cloak_generate:var__(record, 0),
                ?es:atom(?get_state()#state.module),
                ?es:atom(Name)
            )
        ])
    );

export_clause_body_match_map_field__(Name, undefined, undefined, _) ->
    %% No user-defined callback, no substructures specified
    ?es:map_field_assoc(
        ?es:atom(Name),
        ?es:application(?es:atom(?cloak_generated_function_i_on_export), [
            ?es:atom(Name),
            ?es:record_access(
                cloak_generate:var__(record, 0),
                ?es:atom(?get_state()#state.module),
                ?es:atom(Name)
            )
        ])
    );

export_clause_body_match_map_field__(Name, UserDefinedSubstructureModule, undefined, _) ->
    %% Field is a substructure
    ?es:map_field_assoc(
        ?es:atom(Name),
        ?es:application(
            ?es:atom(UserDefinedSubstructureModule),
            ?es:atom(?cloak_generated_function_export),
            [?es:record_access(
                cloak_generate:var__(record, 0),
                ?es:atom(?get_state()#state.module),
                ?es:atom(Name)
            )]
        )
    );

export_clause_body_match_map_field__(Name, undefined, UserDefinedSubstructureListModule, _) ->
    %% Field is a list of substructures
    ?es:map_field_assoc(
        ?es:atom(Name),
        ?es:list_comp(
            ?es:application(
                ?es:atom(UserDefinedSubstructureListModule),
                ?es:atom(?cloak_generated_function_export),
                [cloak_generate:var__(element, 0)]
            ),
            [?es:generator(
                cloak_generate:var__(element, 0),
                ?es:record_access(
                    cloak_generate:var__(record, 0),
                    ?es:atom(?get_state()#state.module),
                    ?es:atom(Name)
                )
            )]
        )
    ).


export_clause_patterns_mismatch__() ->
    [?es:underscore()].


export_clause_body_mismatch__() ->
    [cloak_generate:error_badarg__()].
