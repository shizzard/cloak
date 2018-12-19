-module(cloak_generate_i_on_import).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    [
        i_import__(
            ?get_state()#state.required_record_fields
            ++ ?get_state()#state.optional_record_fields
                ++ ?get_state()#state.protected_record_fields
                ++ ?get_state()#state.private_record_fields
        )
    ].


%% Validators (?MODULE:validate/2)


i_import__(RecordFields) ->
    ?es:function(?es:atom(?cloak_generated_function_i_on_import), i_import_clauses__(RecordFields)).


i_import_clauses__(RecordsFields) ->
    i_import_clauses__(RecordsFields, []).


i_import_clauses__([], Acc) ->
    lists:reverse([?es:clause(
        i_import_clause_patterns_mismatch__(),
        _Guards = none,
        i_import_clause_body_mismatch__()
    ) | Acc]);

i_import_clauses__([#record_field{name = Name} | RecordFields], Acc) ->
    i_import_clauses__(RecordFields, [?es:clause(
        i_import_clause_patterns_match__(Name),
        _Guards = none,
        i_import_clause_body_match__(Name)
    ) | Acc]).


i_import_clause_patterns_match__(Name) ->
    [
        ?es:atom(Name),
        cloak_generate:var__(value, 0)
    ].


i_import_clause_body_match__(Name) ->
    MaybeUserDefinedImportCallback = ?user_definable_import_callback_name(Name),
    case lists:member(
        MaybeUserDefinedImportCallback,
        ?get_state()#state.user_defined_import_callbacks
    ) of
        true ->
            [?es:application(?es:atom(MaybeUserDefinedImportCallback), [cloak_generate:var__(value, 0)])];
        false ->
            [cloak_generate:var__(value, 0)]
    end.



i_import_clause_patterns_mismatch__() ->
    [?es:underscore(), ?es:underscore()].


i_import_clause_body_mismatch__() ->
    [cloak_generate:error_badarg__()].