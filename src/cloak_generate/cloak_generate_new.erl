-module(cloak_generate_new).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    [new__()].


%% New


new__() ->
    put(state, (get(state))#state{export = [
        {?cloak_generated_function_new, ?cloak_generated_function_new_arity} | (get(state))#state.export
    ]}),
    [
        ?es:function(?es:atom(?cloak_generated_function_new), new_clauses__()),
        ?es:function(?es:atom(?cloak_generated_function_new_required), new_required_clauses__()),
        ?es:function(?es:atom(?cloak_generated_function_new_optional), new_optional_clauses__()),
        ?es:function(?es:atom(?cloak_generated_function_new_maybe_substructure), new_maybe_substructure_clauses__())
    ].


new_clauses__() ->
    [
        ?es:clause(new_clause_patterns_match__(), _Guards = none, new_clause_body_match__()),
        ?es:clause(new_clause_patterns_mismatch__(), _Guards = none, new_clause_body_mismatch__())
    ].


new_clause_patterns_match__() ->
    [?es:match_expr(?es:map_expr([]), cloak_generate:var__(map, 0))].


new_clause_body_match__() ->
    [?es:case_expr(new_clause_body_match_case_argument__(), new_clause_body_match_case_clauses__())].


new_clause_body_match_case_argument__() ->
    ?es:application(?es:atom(?cloak_callback_validate_struct), [
        ?es:application(?es:atom(?cloak_generated_function_new_optional), [
            cloak_generate:var__(map, 0),
            ?es:application(?es:atom(?cloak_generated_function_new_required), [
                cloak_generate:var__(map, 0),
                ?es:record_expr(?es:atom((get(state))#state.module), []),
                ?es:list([
                    ?es:tuple([
                        ?es:atom(RequiredField#record_field.name),
                        ?es:abstract(RequiredField#record_field.binary_name)
                    ]) || RequiredField <- (get(state))#state.required_record_fields
                ])
            ]),
            ?es:list([
                ?es:tuple([
                    ?es:atom(OptionalField#record_field.name),
                    ?es:abstract(OptionalField#record_field.binary_name)
                ]) || OptionalField <- (get(state))#state.optional_record_fields
            ])
        ])
    ]).

new_clause_body_match_case_clauses__() ->
    [
        ?es:clause(
            new_clause_body_match_case_clauses_patterns_match_ok__(),
            _Guards = none,
            new_clause_body_match_case_clauses_body_match_ok__()
        ),
        ?es:clause(
            new_clause_body_match_case_clauses_patterns_error__(),
            _Guards = none,
            new_clause_body_match_case_clauses_body_error__()
        )
    ].


new_clause_body_match_case_clauses_patterns_match_ok__() ->
    [?es:tuple([?es:atom(ok), cloak_generate:var__(value, 1)])].


new_clause_body_match_case_clauses_body_match_ok__() ->
    [cloak_generate:var__(value, 1)].


new_clause_body_match_case_clauses_patterns_error__() ->
    [?es:tuple([?es:atom(error), cloak_generate:var__(reason, 0)])].


new_clause_body_match_case_clauses_body_error__() ->
    [
        cloak_generate:error_message__("cloak badarg: struct validation failed with reason: ~p", [cloak_generate:var__(reason, 0)]),
        cloak_generate:error_badarg__()
    ].


new_clause_patterns_mismatch__() ->
    [?es:underscore()].


new_clause_body_mismatch__() ->
    [cloak_generate:error_badarg__()].


%% Required new


new_required_clauses__() ->
    [
        ?es:clause(new_required_clause_patterns_return__(), _Guards = none, new_required_clause_body_return__()),
        ?es:clause(new_required_clause_patterns_iterate__(), _Guards = none, new_required_clause_body_iterate__())
    ].


new_required_clause_patterns_return__() ->
    [?es:underscore(), cloak_generate:var__(record, 0), ?es:list([])].


new_required_clause_body_return__() ->
    [cloak_generate:var__(record, 0)].


new_required_clause_patterns_iterate__() ->
    [cloak_generate:var__(map, 0), cloak_generate:var__(record, 0), ?es:list(
        [?es:tuple([
            cloak_generate:var__(key, 0), cloak_generate:var__(binkey, 0)
        ])], cloak_generate:var__(keys, 0)
    )].


new_required_clause_body_iterate__() ->
    [?es:case_expr(new_required_clause_body_iterate_case_argument__(), new_required_clause_body_iterate_case_clauses__())].


new_required_clause_body_iterate_case_argument__() ->
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


new_required_clause_body_iterate_case_clauses__() ->
    [
        ?es:clause(
            new_required_clause_body_iterate_case_clause_patterns_keytrue__(),
            _Guards = none,
            new_required_clause_body_iterate_case_clause_body_keytrue__()
        ),
        ?es:clause(
            new_required_clause_body_iterate_case_clause_patterns_binkeytrue__(),
            _Guards = none,
            new_required_clause_body_iterate_case_clause_body_binkeytrue__()
        ),
        ?es:clause(
            new_required_clause_body_iterate_case_clause_patterns_false__(),
            _Guards = none,
            new_required_clause_body_iterate_case_clause_body_false__()
        )
    ].


new_required_clause_body_iterate_case_clause_patterns_keytrue__() ->
    [?es:tuple([?es:atom(true), ?es:underscore()])].


new_required_clause_body_iterate_case_clause_body_keytrue__() ->
    MapsGetKeyApplication = ?es:application(
        ?es:module_qualifier(?es:atom(maps), ?es:atom(get)),
        [cloak_generate:var__(key, 0), cloak_generate:var__(map, 0)]
    ),
    MaybeSubstructureApplication = ?es:application(
        ?es:atom(?cloak_generated_function_new_maybe_substructure),
        [cloak_generate:var__(key, 0), MapsGetKeyApplication]
    ),
    SetterApplication = ?es:application(
        ?es:module_qualifier(?es:atom((get(state))#state.module), cloak_generate:var__(key, 0)),
        [
            cloak_generate:var__(record, 0),
            MaybeSubstructureApplication
        ]
    ),
    [?es:application(
        ?es:atom(?cloak_generated_function_new_required),
        [cloak_generate:var__(map, 0), SetterApplication, cloak_generate:var__(keys, 0)]
    )].


new_required_clause_body_iterate_case_clause_patterns_binkeytrue__() ->
    [?es:tuple([?es:underscore(), ?es:atom(true)])].


new_required_clause_body_iterate_case_clause_body_binkeytrue__() ->
    MapsGetKeyApplication = ?es:application(
        ?es:module_qualifier(?es:atom(maps), ?es:atom(get)),
        [cloak_generate:var__(binkey, 0), cloak_generate:var__(map, 0)]
    ),
    MaybeSubstructureApplication = ?es:application(
        ?es:atom(?cloak_generated_function_new_maybe_substructure),
        [cloak_generate:var__(key, 0), MapsGetKeyApplication]
    ),
    SetterApplication = ?es:application(
        ?es:module_qualifier(?es:atom((get(state))#state.module), cloak_generate:var__(key, 0)),
        [
            cloak_generate:var__(record, 0),
            MaybeSubstructureApplication
        ]
    ),
    [?es:application(
        ?es:atom(?cloak_generated_function_new_required),
        [cloak_generate:var__(map, 0), SetterApplication, cloak_generate:var__(keys, 0)]
    )].


new_required_clause_body_iterate_case_clause_patterns_false__() ->
    [?es:tuple([?es:underscore(), ?es:underscore()])].


new_required_clause_body_iterate_case_clause_body_false__() ->
    [
        cloak_generate:error_message__("cloak badarg: required field '~s' is not found", [cloak_generate:var__(key, 0)]),
        cloak_generate:error_badarg__()
    ].


%% Optional new


new_optional_clauses__() ->
    [
        ?es:clause(new_optional_clause_patterns_return__(), _Guards = none, new_optional_clause_body_return__()),
        ?es:clause(new_optional_clause_patterns_iterate__(), _Guards = none, new_optional_clause_body_iterate__())
    ].


new_optional_clause_patterns_return__() ->
    [?es:underscore(), cloak_generate:var__(record, 0), ?es:list([])].


new_optional_clause_body_return__() ->
    [cloak_generate:var__(record, 0)].


new_optional_clause_patterns_iterate__() ->
    [cloak_generate:var__(map, 0), cloak_generate:var__(record, 0), ?es:list(
        [?es:tuple([
            cloak_generate:var__(key, 0), cloak_generate:var__(binkey, 0)
        ])], cloak_generate:var__(keys, 0)
    )].


new_optional_clause_body_iterate__() ->
    [?es:case_expr(new_optional_clause_body_iterate_case_argument__(), new_optional_clause_body_iterate_case_clauses__())].


new_optional_clause_body_iterate_case_argument__() ->
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


new_optional_clause_body_iterate_case_clauses__() ->
    [
        ?es:clause(
            new_optional_clause_body_iterate_case_clause_patterns_keytrue__(),
            _Guards = none,
            new_optional_clause_body_iterate_case_clause_body_keytrue__()
        ),
        ?es:clause(
            new_optional_clause_body_iterate_case_clause_patterns_binkeytrue__(),
            _Guards = none,
            new_optional_clause_body_iterate_case_clause_body_binkeytrue__()
        ),
        ?es:clause(
            new_optional_clause_body_iterate_case_clause_patterns_false__(),
            _Guards = none,
            new_optional_clause_body_iterate_case_clause_body_false__()
        )
    ].


new_optional_clause_body_iterate_case_clause_patterns_keytrue__() ->
    [?es:tuple([?es:atom(true), ?es:underscore()])].


new_optional_clause_body_iterate_case_clause_body_keytrue__() ->
    MapsGetKeyApplication = ?es:application(
        ?es:module_qualifier(?es:atom(maps), ?es:atom(get)),
        [cloak_generate:var__(key, 0), cloak_generate:var__(map, 0)]
    ),
    MaybeSubstructureApplication = ?es:application(
        ?es:atom(?cloak_generated_function_new_maybe_substructure),
        [cloak_generate:var__(key, 0), MapsGetKeyApplication]
    ),
    SetterApplication = ?es:application(
        ?es:module_qualifier(?es:atom((get(state))#state.module), cloak_generate:var__(key, 0)),
        [
            cloak_generate:var__(record, 0),
            MaybeSubstructureApplication
        ]
    ),
    [?es:application(
        ?es:atom(?cloak_generated_function_new_optional),
        [cloak_generate:var__(map, 0), SetterApplication, cloak_generate:var__(keys, 0)]
    )].


new_optional_clause_body_iterate_case_clause_patterns_binkeytrue__() ->
    [?es:tuple([?es:underscore(), ?es:atom(true)])].


new_optional_clause_body_iterate_case_clause_body_binkeytrue__() ->
    MapsGetKeyApplication = ?es:application(
        ?es:module_qualifier(?es:atom(maps), ?es:atom(get)),
        [cloak_generate:var__(binkey, 0), cloak_generate:var__(map, 0)]
    ),
    MaybeSubstructureApplication = ?es:application(
        ?es:atom(?cloak_generated_function_new_maybe_substructure),
        [cloak_generate:var__(key, 0), MapsGetKeyApplication]
    ),
    SetterApplication = ?es:application(
        ?es:module_qualifier(?es:atom((get(state))#state.module), cloak_generate:var__(key, 0)),
        [
            cloak_generate:var__(record, 0),
            MaybeSubstructureApplication
        ]
    ),
    [?es:application(
        ?es:atom(?cloak_generated_function_new_optional),
        [cloak_generate:var__(map, 0), SetterApplication, cloak_generate:var__(keys, 0)]
    )].


new_optional_clause_body_iterate_case_clause_patterns_false__() ->
    [?es:tuple([?es:underscore(), ?es:underscore()])].


new_optional_clause_body_iterate_case_clause_body_false__() ->
    [?es:application(
        ?es:atom(?cloak_generated_function_new_optional),
        [cloak_generate:var__(map, 0), cloak_generate:var__(record, 0), cloak_generate:var__(keys, 0)]
    )].


%% Maybe substructures new


new_maybe_substructure_clauses__() ->
    [
        ?es:clause(
            new_maybe_substructure_clause_patterns_substructures__(FieldName),
            _Guards = none,
            new_maybe_substructure_clause_body_substructures_application__(SubstructureModule)
        ) || {FieldName, SubstructureModule} <- (get(state))#state.nested_substructures
    ] ++ lists:flatten([
        [
            ?es:clause(
                new_maybe_substructure_clause_patterns_substructures_list__(FieldName),
                [?es:application(?es:atom(is_list), [cloak_generate:var__(value, 0)])],
                new_maybe_substructure_clause_body_substructures_list_application__(SubstructureModule)
            ),
            ?es:clause(
                new_maybe_substructure_clause_patterns_substructures_list__(FieldName),
                _Guards = none,
                new_maybe_substructure_clause_body_substructures_list_badarg__(SubstructureModule)
            )
        ] || {FieldName, SubstructureModule} <- (get(state))#state.nested_substructures_list
    ]) ++ [
        ?es:clause(
            new_maybe_substructure_clause_patterns_substructure_return__(),
            _Guards = none,
            new_maybe_substructure_clause_body_substructure_return__()
        )
    ].


new_maybe_substructure_clause_patterns_substructures__(FieldName) ->
    [?es:atom(FieldName), cloak_generate:var__(value, 0)].


new_maybe_substructure_clause_body_substructures_application__(SubstructureModule) ->
    [?es:application(
        ?es:atom(SubstructureModule),
        ?es:atom(?cloak_generated_function_new),
        [cloak_generate:var__(value, 0)]
    )].


new_maybe_substructure_clause_patterns_substructures_list__(FieldName) ->
    [?es:atom(FieldName), cloak_generate:var__(value, 0)].


new_maybe_substructure_clause_body_substructures_list_application__(SubstructureModule) ->
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


new_maybe_substructure_clause_body_substructures_list_badarg__(_SubstructureModule) ->
    [cloak_generate:error_badarg__()].


new_maybe_substructure_clause_patterns_substructure_return__() ->
    [?es:underscore(), cloak_generate:var__(value, 0)].


new_maybe_substructure_clause_body_substructure_return__() ->
    [cloak_generate:var__(value, 0)].
