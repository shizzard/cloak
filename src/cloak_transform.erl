-module(cloak_transform).
-export([parse_transform/2, format_error/1]).
-include("cloak.hrl").


-ifdef(cloak_dump).
    maybe_dump_source(Forms0) ->
        DestFile = io_lib:format("~s/~s.erl", [?cloak_dump, ?get_state()#state.module]),
        Forms1 = [?es:revert(T) || T <- lists:flatten(Forms0)],
        Forms2 = epp:restore_typed_record_fields(Forms1),
        Source = iolist_to_binary([erl_pp:form(Form) || Form <- Forms2]),
        io:format(
            "Dumping '~s' source to ~s: ~p~n",
            [?get_state()#state.module, DestFile, file:write_file(DestFile, Source)]
        ).
-else.
    maybe_dump_source(_Forms0) ->
        ok.
-endif.


parse_transform(Forms, _Options) ->
    ?put_state(#state{}),
    _Forms = cloak_collect:collect(Forms),
    GeneratedForms_new = cloak_generate_new:generate(Forms),
    GeneratedForms_update = cloak_generate_update:generate(Forms),
    GeneratedForms_getters = cloak_generate_getters:generate(Forms),
    GeneratedForms_setters = cloak_generate_setters:generate(Forms),
    GeneratedForms_export = cloak_generate_exporters:generate(Forms),
    GeneratedForms_errors = cloak_generate_errors:generate(Forms),
    GeneratedForms_exports = cloak_generate_exports:generate(Forms),
    GeneratedForms_i_new_required = cloak_generate_i_new_required:generate(Forms),
    GeneratedForms_i_new_optional = cloak_generate_i_new_optional:generate(Forms),
    GeneratedForms_i_new_maybe_subtructure = cloak_generate_i_new_maybe_substructure:generate(Forms),
    GeneratedForms_i_set = cloak_generate_i_set:generate(Forms),
    GeneratedForms_i_on_import = cloak_generate_i_on_import:generate(Forms),
    GeneratedForms_i_on_update = cloak_generate_i_on_update:generate(Forms),
    GeneratedForms_i_on_validate = cloak_generate_i_on_validate:generate(Forms),
    MergedForms = do_merge_forms(Forms, lists:flatten([
        % Error markers and `-export` directive
        GeneratedForms_errors,
        GeneratedForms_exports,
        % Exported functions
        GeneratedForms_new,
        GeneratedForms_update,
        GeneratedForms_getters,
        GeneratedForms_setters,
        GeneratedForms_export,
        % Internal functions
        GeneratedForms_i_new_required,
        GeneratedForms_i_new_optional,
        GeneratedForms_i_new_maybe_subtructure,
        GeneratedForms_i_set,
        % Internal functions - callback'd
        GeneratedForms_i_on_import,
        GeneratedForms_i_on_update,
        GeneratedForms_i_on_validate
    ])),
    maybe_dump_source(MergedForms),
    MergedForms.


format_error(?cloak_ct_error_no_record_definition) ->
    io_lib:format("~ts: ~ts", [?MODULE, "no record definition found"]);

format_error(?cloak_ct_error_no_basic_fields) ->
    io_lib:format("~ts: ~ts", [?MODULE, "no required or optional fields found in record definition"]);

format_error(_ErrorDescriptor) ->
    io_lib:format("~ts: ~ts: ~p", [?MODULE, "unknown error", _ErrorDescriptor]).


do_merge_forms(OriginalForms, GeneratedForms) ->
    {PreForms, PostForms} = lists:splitwith(fun is_attribute/1, OriginalForms),
    MergedForms = [PreForms, GeneratedForms, PostForms],
    [?es:revert(Form) || Form <- lists:flatten(MergedForms)].


is_attribute(Form) ->
    ?es:type(Form) == attribute.
