-module(cloak_generate_i_on_validate).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    [
        i_validate__(
            ?get_state()#state.required_record_fields
            ++ ?get_state()#state.optional_record_fields
            ++ ?get_state()#state.protected_record_fields
            ++ ?get_state()#state.private_record_fields
        )
    ].


%% Validators (?MODULE:validate/2)


i_validate__(RecordFields) ->
    ?es:function(?es:atom(?cloak_generated_function_i_on_validate), i_validate_clauses__(RecordFields)).


i_validate_clauses__(RecordsFields) ->
    i_validate_clauses__(RecordsFields, []).


i_validate_clauses__([], Acc) ->
    lists:reverse([?es:clause(
        i_validate_clause_patterns_mismatch__(),
        _Guards = none,
        i_validate_clause_body_mismatch__()
    ) | Acc]);

i_validate_clauses__([#record_field{name = Name} | RecordFields], Acc) ->
    MaybeUserDefinedValidatorCallback = ?user_definable_validator_callback_name(Name),
    case lists:member(
        MaybeUserDefinedValidatorCallback,
        ?get_state()#state.user_defined_validator_callbacks
    ) of
        true ->
            i_validate_clauses__(RecordFields, [?es:clause(
                i_validate_clause_patterns_match__(Name),
                _Guards = none,
                i_validate_clause_body_match__(Name)
            ) | Acc]);
        false ->
            i_validate_clauses__(RecordFields, Acc)
    end.


i_validate_clause_patterns_match__(Name) ->
    [
        ?es:atom(Name),
        cloak_generate:var__(value, 0)
    ].


i_validate_clause_body_match__(Name) ->
    MaybeUserDefinedValidatorCallback = ?user_definable_validator_callback_name(Name),
    [?es:application(?es:atom(MaybeUserDefinedValidatorCallback), [cloak_generate:var__(value, 0)])].



i_validate_clause_patterns_mismatch__() ->
    [?es:underscore(), cloak_generate:var__(value, 0)].


i_validate_clause_body_mismatch__() ->
    [cloak_generate:var__(value, 0)].