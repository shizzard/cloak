-module(cloak_generate_export).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    [export__()].


%% New


export__() ->
    put(state, (get(state))#state{export = [
        {?cloak_generated_function_export, ?cloak_generated_function_export_arity} | (get(state))#state.export
    ]}),
    [
        ?es:function(?es:atom(?cloak_generated_function_export), export_clauses__())
    ].


export_clauses__() ->
    [
        ?es:clause(export_clause_patterns_match__(), _Guards = none, export_clause_body_match__()),
        ?es:clause(export_clause_patterns_mismatch__(), _Guards = none, export_clause_body_mismatch__())
    ].


export_clause_patterns_match__() ->
    [?es:match_expr(
        ?es:record_expr(?es:atom((get(state))#state.module), []),
        cloak_generate:var__(record, 0)
    )].


export_clause_body_match__() ->
    [?es:map_expr([
        export_clause_body_match_map_field__(RecordField) || RecordField
        <- (get(state))#state.required_record_fields
        ++ (get(state))#state.optional_record_fields
    ])].


export_clause_body_match_map_field__(#record_field{name = Name}) ->
    MaybeUserDefinedExportCallback = cloak_generate:generic_user_definable_export_callback_name(Name),
    case lists:member(
        MaybeUserDefinedExportCallback,
        (get(state))#state.user_defined_export_callbacks
    ) of
        true ->
            ?es:map_field_assoc(
                ?es:atom(Name),
                ?es:application(
                    ?es:atom(MaybeUserDefinedExportCallback),
                    [cloak_generate:var__(record, 0)]
                )
            );
        false ->
            ?es:map_field_assoc(
                ?es:atom(Name),
                ?es:record_access(
                    cloak_generate:var__(record, 0),
                    ?es:atom((get(state))#state.module),
                    ?es:atom(Name)
                )
            )
    end.


export_clause_patterns_mismatch__() ->
    [?es:underscore()].


export_clause_body_mismatch__() ->
    [cloak_generate:error_badarg__()].
