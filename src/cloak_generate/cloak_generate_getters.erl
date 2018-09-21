-module(cloak_generate_getters).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    [
        getter__(RecordField) || RecordField
        <- (get(state))#state.required_record_fields
        ++ (get(state))#state.optional_record_fields
        ++ (get(state))#state.protected_record_fields
    ].


%% Getters


getter__(#record_field{name = Name}) ->
    put(state, (get(state))#state{export = [{Name, 1} | (get(state))#state.export]}),
    ?es:function(?es:atom(Name), getter_clauses__(Name)).


getter_clauses__(Name) ->
    [
        ?es:clause(getter_clause_patterns_match__(Name), _Guards = none, getter_clause_body_match__(Name)),
        ?es:clause(getter_clause_patterns_mismatch__(Name), _Guards = none, getter_clause_body_mismatch__(Name))
    ].


getter_clause_patterns_match__(Name) ->
    [?es:record_expr(
        ?es:atom((get(state))#state.module),
        [?es:record_field(?es:atom(Name), cloak_generate:var__(Name, 0))]
    )].


getter_clause_body_match__(Name) ->
    [cloak_generate:var__(Name, 0)].


getter_clause_patterns_mismatch__(_Name) ->
    [?es:underscore()].


getter_clause_body_mismatch__(_Name) ->
    [cloak_generate:error_badarg__()].
