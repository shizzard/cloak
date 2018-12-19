-module(cloak_generate_setters).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    [
        setter__(RecordField) || RecordField
        <- ?get_state()#state.required_record_fields
        ++ ?get_state()#state.optional_record_fields
    ].


%% Setters (?MODULE:set_{FIELD}/2)


setter__(#record_field{name = Name}) ->
    ?put_state(?get_state()#state{export = [
        {Name, ?cloak_generated_function_setter_arity} | ?get_state()#state.export
    ]}),
    ?es:function(?es:atom(Name), setter_clauses__(Name)).


setter_clauses__(Name) ->
    [
        ?es:clause(
            setter_clause_patterns_match__(Name),
            _Guards = none,
            setter_clause_body_match__(Name)
        ),
        ?es:clause(
            setter_clause_patterns_mismatch__(Name),
            _Guards = none,
            setter_clause_body_mismatch__(Name)
        )
    ].


setter_clause_patterns_match__(_Name) ->
    [
        cloak_generate:var__(value, 0),
        ?es:match_expr(
            ?es:record_expr(?es:atom(?get_state()#state.module), []),
            cloak_generate:var__(record, 0)
        )
    ].


setter_clause_body_match__(Name) ->
    [?es:application(?es:atom(?cloak_generated_function_i_on_update), [
        ?es:application(?es:atom(?cloak_generated_function_i_set), [
            ?es:atom(Name),
            cloak_generate:var__(value, 0),
            cloak_generate:var__(record, 0)
        ])
    ])].


setter_clause_patterns_mismatch__(_Name) ->
    [?es:underscore(), ?es:underscore()].


setter_clause_body_mismatch__(_Name) ->
    [cloak_generate:error_badarg__()].
