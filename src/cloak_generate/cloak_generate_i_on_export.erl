-module(cloak_generate_i_on_export).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    [
        i_on_export_datastructure_level__()
    ] ++ case ?get_state()#state.cloak_i_on_export_function_to_be_generated of
        true ->
            [i_on_export_field_level__(
                ?get_state()#state.required_record_fields
                ++ ?get_state()#state.optional_record_fields
            )];
        false ->
            []
    end.


i_on_export_datastructure_level__() ->
    ?es:function(
        ?es:atom(?cloak_generated_function_i_on_export),
        i_on_export_datastructure_level_clauses__()
    ).


i_on_export_datastructure_level_clauses__() ->
    [
        ?es:clause(
            i_on_export_datastructure_level_clause_patterns_match__(),
            _Guards = none,
            i_on_export_datastructure_level_clause_body_match__()
        ),
        ?es:clause(
            i_on_export_datastructure_level_clause_patterns_mismatch__(),
            _Guards = none,
            i_on_export_datastructure_level_clause_body_mismatch__()
        )
    ].


i_on_export_datastructure_level_clause_patterns_match__() ->
    [?es:match_expr(?es:map_expr([]), cloak_generate:var__(map, 0))].


i_on_export_datastructure_level_clause_body_match__() ->
    case ?get_state()#state.user_defined_on_export_callback_exists of
        true ->
            [?es:application(
                ?es:atom(?user_definable_on_export_callback),
                [cloak_generate:var__(map, 0)]
            )];
        false ->
            [cloak_generate:var__(map, 0)]
    end.


i_on_export_datastructure_level_clause_patterns_mismatch__() ->
    [?es:underscore()].


i_on_export_datastructure_level_clause_body_mismatch__() ->
    [cloak_generate:error_badarg__()].


i_on_export_field_level__(RecordFields) ->
    ?es:function(?es:atom(?cloak_generated_function_i_on_export), i_on_export_field_level_clauses__(RecordFields)).


i_on_export_field_level_clauses__(RecordsFields) ->
    i_on_export_field_level_clauses__(RecordsFields, []).


i_on_export_field_level_clauses__([], Acc) ->
    lists:reverse([?es:clause(
        i_on_export_field_level_clause_patterns_mismatch__(),
        _Guards = none,
        i_on_export_field_level_clause_body_mismatch__()
    ) | Acc]);

i_on_export_field_level_clauses__([#record_field{name = Name} | RecordFields], Acc) ->
    MaybeUserDefinedImportCallback = ?user_definable_export_callback_name(Name),
    case lists:member(
        MaybeUserDefinedImportCallback,
        ?get_state()#state.user_defined_on_export_callbacks
    ) of
        true ->
            i_on_export_field_level_clauses__(RecordFields, [?es:clause(
                i_on_export_field_level_clause_patterns_match__(Name),
                _Guards = none,
                i_on_export_field_level_clause_body_match__(Name)
            ) | Acc]);
        false ->
            i_on_export_field_level_clauses__(RecordFields, Acc)
    end.


i_on_export_field_level_clause_patterns_match__(Name) ->
    [
        ?es:atom(Name),
        cloak_generate:var__(value, 0)
    ].


i_on_export_field_level_clause_body_match__(Name) ->
    MaybeUserDefinedImportCallback = ?user_definable_export_callback_name(Name),
    [?es:application(?es:atom(MaybeUserDefinedImportCallback), [cloak_generate:var__(value, 0)])].


i_on_export_field_level_clause_patterns_mismatch__() ->
    [?es:underscore(), cloak_generate:var__(value, 0)].


i_on_export_field_level_clause_body_mismatch__() ->
    [cloak_generate:var__(value, 0)].