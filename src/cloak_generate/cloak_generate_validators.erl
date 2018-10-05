-module(cloak_generate_validators).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    [
        validator__(RecordField) || RecordField
        <- (get(state))#state.required_record_fields
        ++ (get(state))#state.optional_record_fields
    ].


%% Setters


validator__(#record_field{name = Name}) ->
    FunctionName = cloak_generate:validator_function_name(Name),
    ?es:function(?es:atom(FunctionName), validator_clauses__(Name)).


validator_clauses__(Name) ->
    [?es:clause(
        validator_clause_patterns_match__(),
        _Guards = none,
        validator_clause_body_match__(Name)
    )].


validator_clause_patterns_match__() ->
    [cloak_generate:var__(value, 0)].


validator_clause_body_match__(Name) ->
    MaybeUserDefinedValidatorCallback = cloak_generate:generic_user_definable_validator_callback_name(Name),
    case lists:member(
        MaybeUserDefinedValidatorCallback,
        (get(state))#state.user_defined_validator_callbacks
    ) of
        true ->
            [?es:application(?es:atom(MaybeUserDefinedValidatorCallback), [cloak_generate:var__(value, 0)])];
        false ->
            [?es:tuple([?es:atom(ok), cloak_generate:var__(value, 0)])]
    end.
