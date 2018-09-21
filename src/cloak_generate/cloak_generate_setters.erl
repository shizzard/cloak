-module(cloak_generate_setters).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    [
        setter__(RecordField) || RecordField
        <- (get(state))#state.required_record_fields
        ++ (get(state))#state.optional_record_fields
    ].


%% Setters


setter__(#record_field{name = Name}) ->
    put(state, (get(state))#state{export = [{Name, 2} | (get(state))#state.export]}),
    ?es:function(?es:atom(Name), setter_clauses__(Name)).


setter_clauses__(Name) ->
    [
        ?es:clause(setter_clause_patterns_match__(Name), _Guards = none, setter_clause_body_match__(Name)),
        ?es:clause(setter_clause_patterns_mismatch__(Name), _Guards = none, setter_clause_body_mismatch__(Name))
    ].


setter_clause_patterns_match__(_Name) ->
    [
        ?es:match_expr(
            ?es:record_expr(?es:atom((get(state))#state.module), []),
            cloak_generate:var__(record, 0)
        ),
        cloak_generate:var__(value, 0)
    ].


setter_clause_body_match__(Name) ->
    [?es:case_expr(setter_clause_body_match_case_argument__(Name), setter_clause_body_match_case_clauses__(Name))].


setter_clause_patterns_mismatch__(_Name) ->
    [?es:underscore(), ?es:underscore()].


setter_clause_body_mismatch__(_Name) ->
    [cloak_generate:error_badarg__()].


setter_clause_body_match_case_argument__(Name) ->
    ?es:application(?es:atom(?cloak_callback_validate), [
        ?es:atom(Name), cloak_generate:var__(value, 0)
    ]).


setter_clause_body_match_case_clauses__(Name) ->
    [
        ?es:clause(
            setter_clause_body_match_case_clauses_patterns_match_newvalue__(Name),
            _Guards = none,
            setter_clause_body_match_case_clauses_body_match_newvalue__(Name)
        ),
        ?es:clause(
            setter_clause_body_match_case_clauses_patterns_mismatch__(Name),
            _Guards = none,
            setter_clause_body_match_case_clauses_body_mismatch__(Name)
        )
    ].


setter_clause_body_match_case_clauses_patterns_match_newvalue__(_Name) ->
    [?es:tuple([?es:atom(ok), cloak_generate:var__(value, 1)])].


setter_clause_body_match_case_clauses_body_match_newvalue__(Name) ->
    [?es:application(?es:atom(?cloak_callback_updated), [
        ?es:atom(Name),
        ?es:record_expr(
            cloak_generate:var__(record, 0),
            ?es:atom((get(state))#state.module),
            [?es:record_field(?es:atom(Name), cloak_generate:var__(value, 1))]
        )
    ])].


setter_clause_body_match_case_clauses_patterns_mismatch__(_Name) ->
    [?es:tuple([?es:atom(error), cloak_generate:var__(reason, 0)])].


setter_clause_body_match_case_clauses_body_mismatch__(Name) ->
    [
        cloak_generate:error_message__("cloak badarg: field '~s' validation failed with reason: ~p", [?es:atom(Name), cloak_generate:var__(reason, 0)]),
        cloak_generate:error_badarg__()
    ].
