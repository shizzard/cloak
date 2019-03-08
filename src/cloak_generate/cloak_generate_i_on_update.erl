-module(cloak_generate_i_on_update).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    [i_on_update__()].


i_on_update__() ->
    [?es:function(?es:atom(?cloak_generated_function_i_on_update), i_on_update_clauses__())].


i_on_update_clauses__() ->
    [
        ?es:clause(i_on_update_clause_patterns_match__(), _Guards = none, i_on_update_clause_body_match__()),
        ?es:clause(i_on_update_clause_patterns_mismatch__(), _Guards = none, i_on_update_clause_body_mismatch__())
    ].


i_on_update_clause_patterns_match__() ->
    [
        ?es:match_expr(
            ?es:record_expr(?es:atom(?get_state()#state.module), []),
            cloak_generate:var__(record, 0)
        )
    ].


i_on_update_clause_body_match__() ->
    case ?get_state()#state.user_defined_on_update_callback_exists of
        true ->
            [?es:application(
                ?es:atom(?user_definable_on_update_callback),
                [cloak_generate:var__(record, 0)]
            )];
        false ->
            [cloak_generate:var__(record, 0)]
    end.


i_on_update_clause_patterns_mismatch__() ->
    [?es:underscore()].


i_on_update_clause_body_mismatch__() ->
    [cloak_generate:error_badarg__()].
