-module(cloak_generate_i_set).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    [i_set__(
        ?get_state()#state.required_record_fields
        ++ ?get_state()#state.optional_record_fields
        ++ ?get_state()#state.protected_record_fields
        ++ ?get_state()#state.private_record_fields
    )].


%% Update

i_set__(RecordFields) ->
    ?es:function(?es:atom(?cloak_generated_function_i_set), i_set_clauses__(RecordFields)).


i_set_clauses__(RecordsFields) ->
    i_set_clauses__(RecordsFields, []).


i_set_clauses__([], Acc) ->
    lists:reverse([?es:clause(
        i_set_clause_patterns_mismatch__(),
        _Guards = none,
        i_set_clause_body_mismatch__()
    ) | Acc]);

i_set_clauses__([#record_field{name = Name} | RecordFields], Acc) ->
    i_set_clauses__(RecordFields, [?es:clause(
        i_set_clause_patterns_match__(Name),
        _Guards = none,
        i_set_clause_body_match__(Name)
    ) | Acc]).


i_set_clause_patterns_match__(Name) ->
    [
        ?es:atom(Name),
        cloak_generate:var__(value, 0),
        ?es:match_expr(
            ?es:record_expr(?es:atom(?get_state()#state.module), []),
            cloak_generate:var__(record, 0)
        )
    ].


i_set_clause_body_match__(Name) ->
    [?es:record_expr(
        cloak_generate:var__(record, 0),
        ?es:atom(?get_state()#state.module),
        [?es:record_field(
            ?es:atom(Name),
            ?es:application(?es:atom(?cloak_generated_function_i_on_validate), [
                ?es:atom(Name),
                cloak_generate:var__(value, 0)
            ])
        )]
    )].


i_set_clause_patterns_mismatch__() ->
    [?es:underscore(), ?es:underscore(), ?es:underscore()].


i_set_clause_body_mismatch__() ->
    [cloak_generate:error_badarg__()].
