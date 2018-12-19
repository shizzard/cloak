-module(cloak_generate_errors).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").

%% This module is supposed to generate error markers in case of invalid or
%% cloak-incompatible module definitions.


%% Generate callback


generate(_Forms) ->
    [
        maybe_no_record_definition_error__(),
        maybe_no_basic_fields_error__()
    ].


%% Maybe errors


maybe_no_record_definition_error__() ->
    case (get(state))#state.record_definition_exists of
        false ->
            [cloak_generate:error_compile_time__(?cloak_ct_error_no_record_definition)];
        true ->
            []
    end.


maybe_no_basic_fields_error__() ->
    case {
        (get(state))#state.required_record_fields,
        (get(state))#state.optional_record_fields
    } of
        {[], []} ->
            [cloak_generate:error_compile_time__(?cloak_ct_error_no_basic_fields)];
        {_, _} ->
            []
    end.
