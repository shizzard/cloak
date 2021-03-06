-module(cloak_generate_update).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    [
        update_spec__(),
        update__()
    ].


%% Update


update_spec__() ->
    cloak_generate:function_spec__(
        ?cloak_generated_function_update,
        _In = [
            ?es:annotated_type(
                cloak_generate:var__(in_maybe_map, 0),
                ?es:type_union([cloak_generate:built_in_type__(map), cloak_generate:built_in_type__(term)])
            ),
            ?es:annotated_type(
                cloak_generate:var__(in_maybe_record, 0),
                ?es:type_union([cloak_generate:opaque_type__(), cloak_generate:built_in_type__(term)])
            )
        ],
        _Out = ?es:annotated_type(
            cloak_generate:var__(out_record, 0),
            ?es:type_union([cloak_generate:opaque_type__(), cloak_generate:no_return_type__()])
        )
    ).


update__() ->
    ?put_state(?get_state()#state{export = [
        {?cloak_generated_function_update, ?cloak_generated_function_update_arity} | ?get_state()#state.export
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
        ?es:match_expr(?es:map_expr([]), cloak_generate:var__(map, 0)),
        ?es:match_expr(
            ?es:record_expr(?es:atom(?get_state()#state.module), []),
            cloak_generate:var__(record, 0)
        )
    ].


update_clause_body_match__() ->
    [?es:application(?es:atom(?cloak_generated_function_i_on_update), [
        ?es:application(?es:atom(?cloak_generated_function_i_new_optional), [
            cloak_generate:var__(map, 0),
            cloak_generate:var__(record, 0),
            ?es:list([
                ?es:tuple([
                    ?es:atom(Field#record_field.name),
                    ?es:abstract(Field#record_field.binary_name)
                ]) || Field <- ?get_state()#state.required_record_fields ++ ?get_state()#state.optional_record_fields
            ])
        ])
    ])].


update_clause_patterns_mismatch__() ->
    [?es:underscore(), ?es:underscore()].


update_clause_body_mismatch__() ->
    [cloak_generate:error_badarg__()].
