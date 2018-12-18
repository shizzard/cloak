-module(cloak_generate_update).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    [update__()].


%% Update


update__() ->
    put(state, (get(state))#state{export = [
        {?cloak_generated_function_update, ?cloak_generated_function_update_arity} | (get(state))#state.export
    ]}),
    [
        ?es:function(?es:atom(?cloak_generated_function_update), update_clauses__())
    ].


update_clauses__() ->
    [
        ?es:clause(update_clause_patterns_match__(), _Guards = none, update_clause_body_match__()),
        ?es:clause(update_clause_patterns_mismatch__(), _Guards = none, update_clause_body_mismatch__())
    ].


update_clause_patterns_match__() ->
    [
        ?es:match_expr(
            ?es:record_expr(?es:atom((get(state))#state.module), []),
            cloak_generate:var__(record, 0)
        ),
        ?es:match_expr(?es:map_expr([]), cloak_generate:var__(map, 0))
    ].


update_clause_body_match__() ->
    [?es:case_expr(update_clause_body_match_case_argument__(), update_clause_body_match_case_clauses__())].


update_clause_body_match_case_argument__() ->
    ?es:application(?es:atom(?cloak_callback_validate_struct), [
        ?es:application(?es:atom(?cloak_generated_function_new_optional), [
            cloak_generate:var__(map, 0),
            cloak_generate:var__(record, 0),
            ?es:list([
                ?es:tuple([
                    ?es:atom(Field#record_field.name),
                    ?es:abstract(Field#record_field.binary_name)
                ]) || Field <- (get(state))#state.required_record_fields ++ (get(state))#state.optional_record_fields
            ])
        ])
    ]).

update_clause_body_match_case_clauses__() ->
    [
        ?es:clause(
            update_clause_body_match_case_clauses_patterns_match_ok__(),
            _Guards = none,
            update_clause_body_match_case_clauses_body_match_ok__()
        ),
        ?es:clause(
            update_clause_body_match_case_clauses_patterns_error__(),
            _Guards = none,
            update_clause_body_match_case_clauses_body_error__()
        )
    ].


update_clause_body_match_case_clauses_patterns_match_ok__() ->
    [?es:tuple([?es:atom(ok), cloak_generate:var__(value, 1)])].


update_clause_body_match_case_clauses_body_match_ok__() ->
    [cloak_generate:var__(value, 1)].


update_clause_body_match_case_clauses_patterns_error__() ->
    [?es:tuple([?es:atom(error), cloak_generate:var__(reason, 0)])].


update_clause_body_match_case_clauses_body_error__() ->
    [
        cloak_generate:error_message__("cloak badarg: struct validation failed with reason: ~p", [cloak_generate:var__(reason, 0)]),
        cloak_generate:error_badarg__()
    ].


update_clause_patterns_mismatch__() ->
    [?es:underscore(), ?es:underscore()].


update_clause_body_mismatch__() ->
    [cloak_generate:error_badarg__()].
