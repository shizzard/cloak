-module(cloak_generate_i_new_maybe_substructure).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    [i_new_maybe_substructure__()].


%% New


i_new_maybe_substructure__() ->
    [?es:function(?es:atom(?cloak_generated_function_i_new_maybe_substructure), i_new_maybe_substructure_clauses__())].


%% Maybe substructures new


i_new_maybe_substructure_clauses__() ->
    [
        ?es:clause(
            i_new_maybe_substructure_clause_patterns_substructures__(FieldName),
            _Guards = none,
            i_new_maybe_substructure_clause_body_substructures_application__(SubstructureModule)
        ) || {FieldName, SubstructureModule} <- ?get_state()#state.nested_substructures
    ] ++ lists:flatten([
        [
            ?es:clause(
                i_new_maybe_substructure_clause_patterns_substructures_list__(FieldName),
                [?es:application(?es:atom(is_list), [cloak_generate:var__(value, 0)])],
                i_new_maybe_substructure_clause_body_substructures_list_application__(SubstructureModule)
            ),
            ?es:clause(
                i_new_maybe_substructure_clause_patterns_substructures_list_badarg__(FieldName),
                _Guards = none,
                i_new_maybe_substructure_clause_body_substructures_list_badarg__(SubstructureModule)
            )
        ] || {FieldName, SubstructureModule} <- ?get_state()#state.nested_substructures_list
    ]) ++ [
        ?es:clause(
            i_new_maybe_substructure_clause_patterns_substructure_return__(),
            _Guards = none,
            i_new_maybe_substructure_clause_body_substructure_return__()
        )
    ].


i_new_maybe_substructure_clause_patterns_substructures__(FieldName) ->
    [?es:atom(FieldName), cloak_generate:var__(value, 0)].


i_new_maybe_substructure_clause_body_substructures_application__(SubstructureModule) ->
    [?es:application(
        ?es:atom(SubstructureModule),
        ?es:atom(?cloak_generated_function_new),
        [cloak_generate:var__(value, 0)]
    )].


i_new_maybe_substructure_clause_patterns_substructures_list__(FieldName) ->
    [?es:atom(FieldName), cloak_generate:var__(value, 0)].


i_new_maybe_substructure_clause_body_substructures_list_application__(SubstructureModule) ->
    [?es:list_comp(
        ?es:application(
            ?es:atom(SubstructureModule),
            ?es:atom(?cloak_generated_function_new),
            [cloak_generate:var__(element, 0)]
        ),
        [?es:generator(
            cloak_generate:var__(element, 0),
            cloak_generate:var__(value, 0)
        )]
    )].


i_new_maybe_substructure_clause_patterns_substructures_list_badarg__(FieldName) ->
    [?es:atom(FieldName), ?es:underscore()].


i_new_maybe_substructure_clause_body_substructures_list_badarg__(_SubstructureModule) ->
    [cloak_generate:error_badarg__()].


i_new_maybe_substructure_clause_patterns_substructure_return__() ->
    [?es:underscore(), cloak_generate:var__(value, 0)].


i_new_maybe_substructure_clause_body_substructure_return__() ->
    [cloak_generate:var__(value, 0)].
