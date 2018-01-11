-module(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


generate(_Forms) ->
    MaybeErrorForms = maybe_errors__(),
    NewForms = new__(),
    GettersForms = [
        getter__(RecordField) || RecordField
        <- (get(state))#state.required_record_fields
        ++ (get(state))#state.optional_record_fields
        ++ (get(state))#state.protected_record_fields
    ],
    SettersForms = [
        setter__(RecordField) || RecordField
        <- (get(state))#state.required_record_fields
        ++ (get(state))#state.optional_record_fields
    ],
    MaybeDefaultValidateStructCallback = [default_validate_struct_callback__((get(state))#state.callback_validate_struct_exists)],
    MaybeDefaultValidateCallback = [default_validate_callback__((get(state))#state.callback_validate_exists)],
    MaybeDefaultUpdatedCallback = [default_updated_callback__((get(state))#state.callback_updated_exists)],
    ExportAttribute = exports__(),
    TypeAttributes = [struct_type__(), struct_type_export__()],
    [
        MaybeErrorForms,
        ExportAttribute,
        TypeAttributes,
        NewForms,
        GettersForms,
        SettersForms,
        MaybeDefaultValidateStructCallback,
        MaybeDefaultValidateCallback,
        MaybeDefaultUpdatedCallback,
        eof__()
    ].


%% New


maybe_errors__() ->
    case {
        (get(state))#state.required_record_fields,
        (get(state))#state.optional_record_fields
    } of
        {[], []} ->
            []; % TODO: error marker here
        {_, _} ->
            []
    end.


new__() ->
    put(state, (get(state))#state{export = [{new, 1} | (get(state))#state.export]}),
    [
        ?es:function(?es:atom(new), new_clauses__()),
        ?es:function(?es:atom(required_new), required_new_clauses__()),
        ?es:function(?es:atom(optional_new), optional_new_clauses__())
    ].


new_clauses__() ->
    [
        ?es:clause(new_clause_patterns_match__(), _Guards = none, new_clause_body_match__()),
        ?es:clause(new_clause_patterns_mismatch__(), _Guards = none, new_clause_body_mismatch__())
    ].


new_clause_patterns_match__() ->
    [?es:match_expr(?es:map_expr([]), var__(map, 0))].


new_clause_body_match__() ->
    [?es:case_expr(new_clause_body_match_case_argument__(), new_clause_body_match_case_clauses__())].


new_clause_body_match_case_argument__() ->
    ?es:application(?es:atom(?cloak_callback_validate_struct), [
        ?es:application(?es:atom(optional_new), [
            var__(map, 0),
            ?es:application(?es:atom(required_new), [
                var__(map, 0),
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
    [?es:tuple([?es:atom(ok), var__(value, 1)])].


new_clause_body_match_case_clauses_body_match_ok__() ->
    [var__(value, 1)].


new_clause_body_match_case_clauses_patterns_error__() ->
    [?es:tuple([?es:atom(error), var__(reason, 0)])].


new_clause_body_match_case_clauses_body_error__() ->
    [
        error_message__("cloak badarg: struct validation failed with reason: ~p", [var__(reason, 0)]),
        error_badarg__()
    ].


new_clause_patterns_mismatch__() ->
    [?es:underscore()].


new_clause_body_mismatch__() ->
    [error_badarg__()].


%% Required new


required_new_clauses__() ->
    [
        ?es:clause(required_new_clause_patterns_return__(), _Guards = none, required_new_clause_body_return__()),
        ?es:clause(required_new_clause_patterns_iterate__(), _Guards = none, required_new_clause_body_iterate__())
    ].


required_new_clause_patterns_return__() ->
    [?es:underscore(), var__(record, 0), ?es:list([])].


required_new_clause_body_return__() ->
    [var__(record, 0)].


required_new_clause_patterns_iterate__() ->
    [var__(map, 0), var__(record, 0), ?es:list(
        [?es:tuple([
            var__(key, 0), var__(binkey, 0)
        ])], var__(keys, 0)
    )].


required_new_clause_body_iterate__() ->
    [?es:case_expr(required_new_clause_body_iterate_case_argument__(), required_new_clause_body_iterate_case_clauses__())].


required_new_clause_body_iterate_case_argument__() ->
    ?es:tuple([
        ?es:application(
            ?es:module_qualifier(?es:atom(maps), ?es:atom(is_key)),
            [var__(key, 0), var__(map, 0)]
        ),
        ?es:application(
            ?es:module_qualifier(?es:atom(maps), ?es:atom(is_key)),
            [var__(binkey, 0), var__(map, 0)]
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
        [var__(key, 0), var__(map, 0)]
    ),
    SetterApplication = ?es:application(
        ?es:module_qualifier(?es:atom((get(state))#state.module), var__(key, 0)),
        [
            var__(record, 0),
            MapsGetKeyApplication
        ]
    ),
    [?es:application(
        ?es:atom(required_new),
        [var__(map, 0), SetterApplication, var__(keys, 0)]
    )].


required_new_clause_body_iterate_case_clause_patterns_binkeytrue__() ->
    [?es:tuple([?es:underscore(), ?es:atom(true)])].


required_new_clause_body_iterate_case_clause_body_binkeytrue__() ->
    MapsGetKeyApplication = ?es:application(
        ?es:module_qualifier(?es:atom(maps), ?es:atom(get)),
        [var__(binkey, 0), var__(map, 0)]
    ),
    SetterApplication = ?es:application(
        ?es:module_qualifier(?es:atom((get(state))#state.module), var__(key, 0)),
        [
            var__(record, 0),
            MapsGetKeyApplication
        ]
    ),
    [?es:application(
        ?es:atom(required_new),
        [var__(map, 0), SetterApplication, var__(keys, 0)]
    )].


required_new_clause_body_iterate_case_clause_patterns_false__() ->
    [?es:tuple([?es:underscore(), ?es:underscore()])].


required_new_clause_body_iterate_case_clause_body_false__() ->
    [
        error_message__("cloak badarg: required field '~s' is not found", [var__(key, 0)]),
        error_badarg__()
    ].


%% Optional new


optional_new_clauses__() ->
    [
        ?es:clause(optional_new_clause_patterns_return__(), _Guards = none, optional_new_clause_body_return__()),
        ?es:clause(optional_new_clause_patterns_iterate__(), _Guards = none, optional_new_clause_body_iterate__())
    ].


optional_new_clause_patterns_return__() ->
    [?es:underscore(), var__(record, 0), ?es:list([])].


optional_new_clause_body_return__() ->
    [var__(record, 0)].


optional_new_clause_patterns_iterate__() ->
    [var__(map, 0), var__(record, 0), ?es:list(
        [?es:tuple([
            var__(key, 0), var__(binkey, 0)
        ])], var__(keys, 0)
    )].


optional_new_clause_body_iterate__() ->
    [?es:case_expr(optional_new_clause_body_iterate_case_argument__(), optional_new_clause_body_iterate_case_clauses__())].


optional_new_clause_body_iterate_case_argument__() ->
    ?es:tuple([
        ?es:application(
            ?es:module_qualifier(?es:atom(maps), ?es:atom(is_key)),
            [var__(key, 0), var__(map, 0)]
        ),
        ?es:application(
            ?es:module_qualifier(?es:atom(maps), ?es:atom(is_key)),
            [var__(binkey, 0), var__(map, 0)]
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
        [var__(key, 0), var__(map, 0)]
    ),
    SetterApplication = ?es:application(
        ?es:module_qualifier(?es:atom((get(state))#state.module), var__(key, 0)),
        [
            var__(record, 0),
            MapsGetKeyApplication
        ]
    ),
    [?es:application(
        ?es:atom(optional_new),
        [var__(map, 0), SetterApplication, var__(keys, 0)]
    )].


optional_new_clause_body_iterate_case_clause_patterns_binkeytrue__() ->
    [?es:tuple([?es:underscore(), ?es:atom(true)])].


optional_new_clause_body_iterate_case_clause_body_binkeytrue__() ->
    MapsGetKeyApplication = ?es:application(
        ?es:module_qualifier(?es:atom(maps), ?es:atom(get)),
        [var__(binkey, 0), var__(map, 0)]
    ),
    SetterApplication = ?es:application(
        ?es:module_qualifier(?es:atom((get(state))#state.module), var__(key, 0)),
        [
            var__(record, 0),
            MapsGetKeyApplication
        ]
    ),
    [?es:application(
        ?es:atom(required_new),
        [var__(map, 0), SetterApplication, var__(keys, 0)]
    )].


optional_new_clause_body_iterate_case_clause_patterns_false__() ->
    [?es:tuple([?es:underscore(), ?es:underscore()])].


optional_new_clause_body_iterate_case_clause_body_false__() ->
    [?es:application(
        ?es:atom(optional_new),
        [var__(map, 0), var__(record, 0), var__(keys, 0)]
    )].


%% Getters


getter__(#record_field{name = Name}) ->
    put(state, (get(state))#state{export = [{Name, 1} | (get(state))#state.export]}),
    ?es:function(?es:atom(Name), getter_clauses__(Name)).


getter_clauses__(Name) ->
    [
        ?es:clause(getter_clause_patterns_match__(Name), _Guards = none, getter_clause_body_match__(Name)),
        ?es:clause(getter_clause_patterns_mismatch__(Name), _Guards = none, getter_clause_body_mismatch__(Name))
    ].


getter_clause_patterns_match__(Name) ->
    [?es:record_expr(
        ?es:atom((get(state))#state.module),
        [?es:record_field(?es:atom(Name), var__(Name, 0))]
    )].


getter_clause_body_match__(Name) ->
    [var__(Name, 0)].


getter_clause_patterns_mismatch__(_Name) ->
    [?es:underscore()].


getter_clause_body_mismatch__(_Name) ->
    [error_badarg__()].


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
            var__(record, 0)
        ),
        var__(value, 0)
    ].


setter_clause_body_match__(Name) ->
    [?es:case_expr(setter_clause_body_match_case_argument__(Name), setter_clause_body_match_case_clauses__(Name))].


setter_clause_patterns_mismatch__(_Name) ->
    [?es:underscore(), ?es:underscore()].


setter_clause_body_mismatch__(_Name) ->
    [error_badarg__()].


setter_clause_body_match_case_argument__(Name) ->
    ?es:application(?es:atom(?cloak_callback_validate), [
        ?es:atom(Name), var__(value, 0)
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
    [?es:tuple([?es:atom(ok), var__(value, 1)])].


setter_clause_body_match_case_clauses_body_match_newvalue__(Name) ->
    [?es:application(?es:atom(?cloak_callback_updated), [
        ?es:atom(Name),
        ?es:record_expr(
            var__(record, 0),
            ?es:atom((get(state))#state.module),
            [?es:record_field(?es:atom(Name), var__(value, 1))]
        )
    ])].


setter_clause_body_match_case_clauses_patterns_mismatch__(_Name) ->
    [?es:tuple([?es:atom(error), var__(reason, 0)])].


setter_clause_body_match_case_clauses_body_mismatch__(Name) ->
    [
        error_message__("cloak badarg: field '~s' validation failed with reason: ~p", [?es:atom(Name), var__(reason, 0)]),
        error_badarg__()
    ].


%% Default callbacks


default_validate_struct_callback__(true) ->
    [];

default_validate_struct_callback__(false) ->
    ?es:function(?es:atom(?cloak_callback_validate_struct), default_validate_struct_callback_clauses__()).


default_validate_struct_callback_clauses__() ->
    [?es:clause(
        default_validate_struct_callback_clause_patterns_match__(),
        _Guards = none,
        default_validate_struct_callback_clause_body_match__()
    )].


default_validate_struct_callback_clause_patterns_match__() ->
    [var__(value, 0)].


default_validate_struct_callback_clause_body_match__() ->
    [?es:tuple([?es:atom(ok), var__(value, 0)])].


default_validate_callback__(true) ->
    [];

default_validate_callback__(false) ->
    ?es:function(?es:atom(?cloak_callback_validate), default_validate_callback_clauses__()).


default_validate_callback_clauses__() ->
    [?es:clause(
        default_validate_callback_clause_patterns_match__(),
        _Guards = none,
        default_validate_callback_clause_body_match__()
    )].


default_validate_callback_clause_patterns_match__() ->
    [?es:underscore(), var__(value, 0)].


default_validate_callback_clause_body_match__() ->
    [?es:tuple([?es:atom(ok), var__(value, 0)])].


default_updated_callback__(true) ->
    [];

default_updated_callback__(false) ->
    ?es:function(?es:atom(?cloak_callback_updated), default_updated_callback_clauses__()).


default_updated_callback_clauses__() ->
    [?es:clause(
        default_updated_callback_clause_patterns_match__(),
        _Guards = none,
        default_updated_callback_clause_body_match__()
    )].


default_updated_callback_clause_patterns_match__() ->
    [?es:underscore(), var__(record, 0)].


default_updated_callback_clause_body_match__() ->
    [var__(record, 0)].


%% Export attribute


exports__() ->
    [?es:attribute(
        ?es:atom(export), [
            ?es:list(lists:map(fun({Function, Arity}) ->
                ?es:arity_qualifier(?es:atom(Function), ?es:integer(Arity))
            end, (get(state))#state.export))
        ]
    )].


%% Type attributes


%% This code is quite hacky and dirty. Should rewrite it when proper solution is found.

struct_type__() ->
    [merl:quote(
        0,
        lists:flatten(io_lib:format("-type ~p() :: #~p{}.", [?cloak_struct_type, (get(state))#state.module]))
    )].


struct_type_export__() ->
    [merl:quote(
        0,
        lists:flatten(io_lib:format("-export_type([~p/0]).", [?cloak_struct_type]))
    )].


%% Generics


error_message__(Format, Args) ->
    ?es:application(
        ?es:module_qualifier(?es:atom(error_logger), ?es:atom(error_msg)),
        [?es:string(Format), ?es:list(Args)]
    ).


error_badarg__() ->
    ?es:application(?es:atom(error), [?es:atom(badarg)]).


var__(Name, Num) ->
    VarName = lists:flatten(io_lib:format("~s_~s_~B", ["Var", Name, Num])),
    ?es:variable(VarName).


eof__() ->
    ?es:eof_marker().
