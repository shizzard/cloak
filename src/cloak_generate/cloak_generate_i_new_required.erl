-module(cloak_generate_i_new_required).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    [i_new_required__()].


%% i_new_required


i_new_required__() ->
    [?es:function(?es:atom(?cloak_generated_function_i_new_required), i_new_required_clauses__())].


i_new_required_clauses__() ->
    [
        ?es:clause(i_new_required_clause_patterns_return__(), _Guards = none, i_new_required_clause_body_return__()),
        ?es:clause(i_new_required_clause_patterns_iterate__(), _Guards = none, i_new_required_clause_body_iterate__())
    ].


i_new_required_clause_patterns_return__() ->
    [?es:underscore(), cloak_generate:var__(record, 0), ?es:list([])].


i_new_required_clause_body_return__() ->
    [cloak_generate:var__(record, 0)].


i_new_required_clause_patterns_iterate__() ->
    [cloak_generate:var__(map, 0), cloak_generate:var__(record, 0), ?es:list(
        [?es:tuple([
            cloak_generate:var__(key, 0), cloak_generate:var__(binkey, 0)
        ])], cloak_generate:var__(keys, 0)
    )].


i_new_required_clause_body_iterate__() ->
    [?es:case_expr(i_new_required_clause_body_iterate_case_argument__(), i_new_required_clause_body_iterate_case_clauses__())].


i_new_required_clause_body_iterate_case_argument__() ->
    ?es:tuple([
        ?es:application(
            ?es:module_qualifier(?es:atom(maps), ?es:atom(is_key)),
            [cloak_generate:var__(key, 0), cloak_generate:var__(map, 0)]
        ),
        ?es:application(
            ?es:module_qualifier(?es:atom(maps), ?es:atom(is_key)),
            [cloak_generate:var__(binkey, 0), cloak_generate:var__(map, 0)]
        )
    ]).


i_new_required_clause_body_iterate_case_clauses__() ->
    [
        ?es:clause(
            i_new_required_clause_body_iterate_case_clause_patterns_keytrue__(),
            _Guards = none,
            i_new_required_clause_body_iterate_case_clause_body_keytrue__()
        ),
        ?es:clause(
            i_new_required_clause_body_iterate_case_clause_patterns_binkeytrue__(),
            _Guards = none,
            i_new_required_clause_body_iterate_case_clause_body_binkeytrue__()
        ),
        ?es:clause(
            i_new_required_clause_body_iterate_case_clause_patterns_false__(),
            _Guards = none,
            i_new_required_clause_body_iterate_case_clause_body_false__()
        )
    ].


i_new_required_clause_body_iterate_case_clause_patterns_keytrue__() ->
    [?es:tuple([?es:atom(true), ?es:underscore()])].


i_new_required_clause_body_iterate_case_clause_body_keytrue__() ->
    MapsGetKeyApplication = ?es:application(
        ?es:module_qualifier(?es:atom(maps), ?es:atom(get)),
        [cloak_generate:var__(key, 0), cloak_generate:var__(map, 0)]
    ),
    IImportApplication = ?es:application(
        ?es:atom(?cloak_generated_function_i_on_import),
        [cloak_generate:var__(key, 0), MapsGetKeyApplication]
    ),
    INewMaybeSubstructureApplication = ?es:application(
        ?es:atom(?cloak_generated_function_i_new_maybe_substructure),
        [cloak_generate:var__(key, 0), IImportApplication]
    ),
    ISetApplication = ?es:application(
        ?es:atom(?cloak_generated_function_i_set),
        [
            cloak_generate:var__(key, 0),
            INewMaybeSubstructureApplication,
            cloak_generate:var__(record, 0)
        ]
    ),
    [?es:application(
        ?es:atom(?cloak_generated_function_i_new_required),
        [cloak_generate:var__(map, 0), ISetApplication, cloak_generate:var__(keys, 0)]
    )].


i_new_required_clause_body_iterate_case_clause_patterns_binkeytrue__() ->
    [?es:tuple([?es:underscore(), ?es:atom(true)])].


i_new_required_clause_body_iterate_case_clause_body_binkeytrue__() ->
    MapsGetKeyApplication = ?es:application(
        ?es:module_qualifier(?es:atom(maps), ?es:atom(get)),
        [cloak_generate:var__(binkey, 0), cloak_generate:var__(map, 0)]
    ),
    IImportApplication = ?es:application(
        ?es:atom(?cloak_generated_function_i_on_import),
        [cloak_generate:var__(key, 0), MapsGetKeyApplication]
    ),
    INewMaybeSubstructureApplication = ?es:application(
        ?es:atom(?cloak_generated_function_i_new_maybe_substructure),
        [cloak_generate:var__(key, 0), IImportApplication]
    ),
    ISetApplication = ?es:application(
        ?es:atom(?cloak_generated_function_i_set),
        [
            cloak_generate:var__(key, 0),
            INewMaybeSubstructureApplication,
            cloak_generate:var__(record, 0)
        ]
    ),
    [?es:application(
        ?es:atom(?cloak_generated_function_i_new_required),
        [cloak_generate:var__(map, 0), ISetApplication, cloak_generate:var__(keys, 0)]
    )].


i_new_required_clause_body_iterate_case_clause_patterns_false__() ->
    [?es:tuple([?es:underscore(), ?es:underscore()])].


i_new_required_clause_body_iterate_case_clause_body_false__() ->
    [
        cloak_generate:error_message__("cloak badarg: required field '~s' is not found", [cloak_generate:var__(key, 0)]),
        cloak_generate:error_badarg__()
    ].
