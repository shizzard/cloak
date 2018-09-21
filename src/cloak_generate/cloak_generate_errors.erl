-module(cloak_generate_errors).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").

%% This module is supposed to generate error markers in case of invalid or
%% cloak-incompatible module definitions.


%% Generate callback


generate(_Forms) ->
    [maybe_errors__()].


%% Maybe errors


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
