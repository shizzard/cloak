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
        ?es:function(?es:atom(required_new), required_new_clauses__()),
        ?es:function(?es:atom(optional_new), optional_new_clauses__())
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
        ?es:application(?es:atom(optional_new), [
            cloak_generate:var__(map, 0),
            ?es:application(?es:atom(required_new), [
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


required_new_clauses__() ->
    [
        ?es:clause(required_new_clause_patterns_return__(), _Guards = none, required_new_clause_body_return__()),
        ?es:clause(required_new_clause_patterns_iterate__(), _Guards = none, required_new_clause_body_iterate__())
    ].


required_new_clause_patterns_return__() ->
    [?es:underscore(), cloak_generate:var__(record, 0), ?es:list([])].


required_new_clause_body_return__() ->
    [cloak_generate:var__(record, 0)].


required_new_clause_patterns_iterate__() ->
    [cloak_generate:var__(map, 0), cloak_generate:var__(record, 0), ?es:list(
        [?es:tuple([
            cloak_generate:var__(key, 0), cloak_generate:var__(binkey, 0)
        ])], cloak_generate:var__(keys, 0)
    )].


required_new_clause_body_iterate__() ->
    [?es:case_expr(required_new_clause_body_iterate_case_argument__(), required_new_clause_body_iterate_case_clauses__())].


required_new_clause_body_iterate_case_argument__() ->
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


required_new_clause_body_iterate_case_clauses__() ->
    [
        ?es:clause(
            required_new_clause_body_iterate_case_clause_patterns_keytrue__(),
            _Guards = none,
            required_new_clause_body_iterate_case_clause_body_keytrue__()
        ),
        ?es:clause(
            required_new_clause_body_iterate_case_clause_patterns_binkeytrue__(),
            _Guards = none,
            required_new_clause_body_iterate_case_clause_body_binkeytrue__()
        ),
        ?es:clause(
            required_new_clause_body_iterate_case_clause_patterns_false__(),
            _Guards = none,
            required_new_clause_body_iterate_case_clause_body_false__()
        )
    ].


required_new_clause_body_iterate_case_clause_patterns_keytrue__() ->
    [?es:tuple([?es:atom(true), ?es:underscore()])].


required_new_clause_body_iterate_case_clause_body_keytrue__() ->
    MapsGetKeyApplication = ?es:application(
        ?es:module_qualifier(?es:atom(maps), ?es:atom(get)),
        [cloak_generate:var__(key, 0), cloak_generate:var__(map, 0)]
    ),
    SetterApplication = ?es:application(
        ?es:module_qualifier(?es:atom((get(state))#state.module), cloak_generate:var__(key, 0)),
        [
            cloak_generate:var__(record, 0),
            MapsGetKeyApplication
        ]
    ),
    [?es:application(
        ?es:atom(required_new),
        [cloak_generate:var__(map, 0), SetterApplication, cloak_generate:var__(keys, 0)]
    )].


required_new_clause_body_iterate_case_clause_patterns_binkeytrue__() ->
    [?es:tuple([?es:underscore(), ?es:atom(true)])].


required_new_clause_body_iterate_case_clause_body_binkeytrue__() ->
    MapsGetKeyApplication = ?es:application(
        ?es:module_qualifier(?es:atom(maps), ?es:atom(get)),
        [cloak_generate:var__(binkey, 0), cloak_generate:var__(map, 0)]
    ),
    SetterApplication = ?es:application(
        ?es:module_qualifier(?es:atom((get(state))#state.module), cloak_generate:var__(key, 0)),
        [
            cloak_generate:var__(record, 0),
            MapsGetKeyApplication
        ]
    ),
    [?es:application(
        ?es:atom(required_new),
        [cloak_generate:var__(map, 0), SetterApplication, cloak_generate:var__(keys, 0)]
    )].


required_new_clause_body_iterate_case_clause_patterns_false__() ->
    [?es:tuple([?es:underscore(), ?es:underscore()])].


required_new_clause_body_iterate_case_clause_body_false__() ->
    [
        cloak_generate:error_message__("cloak badarg: required field '~s' is not found", [cloak_generate:var__(key, 0)]),
        cloak_generate:error_badarg__()
    ].


%% Optional new


optional_new_clauses__() ->
    [
        ?es:clause(optional_new_clause_patterns_return__(), _Guards = none, optional_new_clause_body_return__()),
        ?es:clause(optional_new_clause_patterns_iterate__(), _Guards = none, optional_new_clause_body_iterate__())
    ].


optional_new_clause_patterns_return__() ->
    [?es:underscore(), cloak_generate:var__(record, 0), ?es:list([])].


optional_new_clause_body_return__() ->
    [cloak_generate:var__(record, 0)].


optional_new_clause_patterns_iterate__() ->
    [cloak_generate:var__(map, 0), cloak_generate:var__(record, 0), ?es:list(
        [?es:tuple([
            cloak_generate:var__(key, 0), cloak_generate:var__(binkey, 0)
        ])], cloak_generate:var__(keys, 0)
    )].


optional_new_clause_body_iterate__() ->
    [?es:case_expr(optional_new_clause_body_iterate_case_argument__(), optional_new_clause_body_iterate_case_clauses__())].


optional_new_clause_body_iterate_case_argument__() ->
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


optional_new_clause_body_iterate_case_clauses__() ->
    [
        ?es:clause(
            optional_new_clause_body_iterate_case_clause_patterns_keytrue__(),
            _Guards = none,
            optional_new_clause_body_iterate_case_clause_body_keytrue__()
        ),
        ?es:clause(
            optional_new_clause_body_iterate_case_clause_patterns_binkeytrue__(),
            _Guards = none,
            optional_new_clause_body_iterate_case_clause_body_binkeytrue__()
        ),
        ?es:clause(
            optional_new_clause_body_iterate_case_clause_patterns_false__(),
            _Guards = none,
            optional_new_clause_body_iterate_case_clause_body_false__()
        )
    ].


optional_new_clause_body_iterate_case_clause_patterns_keytrue__() ->
    [?es:tuple([?es:atom(true), ?es:underscore()])].


optional_new_clause_body_iterate_case_clause_body_keytrue__() ->
    MapsGetKeyApplication = ?es:application(
        ?es:module_qualifier(?es:atom(maps), ?es:atom(get)),
        [cloak_generate:var__(key, 0), cloak_generate:var__(map, 0)]
    ),
    SetterApplication = ?es:application(
        ?es:module_qualifier(?es:atom((get(state))#state.module), cloak_generate:var__(key, 0)),
        [
            cloak_generate:var__(record, 0),
            MapsGetKeyApplication
        ]
    ),
    [?es:application(
        ?es:atom(optional_new),
        [cloak_generate:var__(map, 0), SetterApplication, cloak_generate:var__(keys, 0)]
    )].


optional_new_clause_body_iterate_case_clause_patterns_binkeytrue__() ->
    [?es:tuple([?es:underscore(), ?es:atom(true)])].


optional_new_clause_body_iterate_case_clause_body_binkeytrue__() ->
    MapsGetKeyApplication = ?es:application(
        ?es:module_qualifier(?es:atom(maps), ?es:atom(get)),
        [cloak_generate:var__(binkey, 0), cloak_generate:var__(map, 0)]
    ),
    SetterApplication = ?es:application(
        ?es:module_qualifier(?es:atom((get(state))#state.module), cloak_generate:var__(key, 0)),
        [
            cloak_generate:var__(record, 0),
            MapsGetKeyApplication
        ]
    ),
    [?es:application(
        ?es:atom(optional_new),
        [cloak_generate:var__(map, 0), SetterApplication, cloak_generate:var__(keys, 0)]
    )].


optional_new_clause_body_iterate_case_clause_patterns_false__() ->
    [?es:tuple([?es:underscore(), ?es:underscore()])].


optional_new_clause_body_iterate_case_clause_body_false__() ->
    [?es:application(
        ?es:atom(optional_new),
        [cloak_generate:var__(map, 0), cloak_generate:var__(record, 0), cloak_generate:var__(keys, 0)]
    )].
