%%% This module is based on Discord API user object
%%% see https://discordapp.com/developers/docs/resources/user
%%% Main idea and the goal of this module is to use specified datastructure
%%% to be imported in and exported out, but represent the data in more
%%% convenient way for the inner system.
-module(priv_complex).
%%-compile({parse_transform, cloak_transform}).
%%
%%-export([is/2, format/1, format_username/1]).
%%
%%%% `field_name?` notation is used to specify the field as an optional one.
%%%% `?type` notation is used to specify nullable type.
%%% id                snowflake       the user's id
%%% username          string          the user's username, not unique across the platform
%%% discriminator     string          the user's 4-digit discord-tag
%%% avatar            ?string         the user's avatar hash
%%% bot?              boolean         whether the user belongs to an OAuth2 application
%%% mfa_enabled?      boolean         whether the user has two factor enabled on their account
%%% locale?           string          the user's chosen language option
%%% verified?         boolean         whether the email on this account has been verified
%%% email?            string          the user's email
%%% flags             integer         the flags on a user's account
%%% premium_type?     integer         the type of Nitro subscription on a user's account
%%-record(?MODULE, {
%%    id :: id(),
%%    username :: username(),
%%    discriminator :: discriminator(),
%%    avatar = undefined :: avatar() | undefined,
%%    bot = false :: bot(),
%%    mfa_enabled = false :: mfa_enabled(),
%%    locale = undefined :: locale(),
%%    verified = false :: verified(),
%%    email = undefined :: email(),
%%    flags :: flags(),
%%    premium_type = undefined :: premium_type()
%%}).
%%
%%-type id() :: pos_integer().
%%-type username() :: unicode:unicode_binary().
%%-type discriminator() :: unicode:unicode_binary().
%%-type avatar() :: unicode:unicode_binary().
%%-type bot() :: boolean().
%%-type mfa_enabled() :: boolean().
%%-type locale() :: binary().
%%-type verified() :: boolean().
%%-type email() :: unicode:unicode_binary().
%%-type flags() :: non_neg_integer().
%%-type t() :: #?MODULE{}.
%%
%%-export_type([
%%    id/0, username/0, discriminator/0, avatar/0, bot/0, mfa_enabled/0,
%%    locale/0, verified/0, email/0, flags/0, t/0
%%]).
%%
%%
%%%% Check if user is the same.
%%-spec is(
%%    User :: t(),
%%    AnotherUser :: id() | t()
%%) ->
%%    Ret :: boolean().
%%
%%is(#?MODULE{id = _UserId}, _UserId) -> true;
%%is(#?MODULE{id = _AnotherUserId}, _UserId) -> false;
%%is(#?MODULE{id = _UserId}, #?MODULE{id = _UserId}) -> true;
%%is(#?MODULE{id = _AnotherUserId}, #?MODULE{id = _UserId}) -> false.
%%
%%
%%%% Internal Discord user-string representation; used to mention
%%%% someone in the channel, for example.
%%-spec format(User :: t()) ->
%%    Ret :: binary().
%%
%%format(#?MODULE{id = Id}) ->
%%    <<"<@", Id/binary, ">">>.
%%
%%
%%%% Same as above, but it tells the notification server to resolve nicknames
%%%% when pushing notification to the mobile clients. Recommended.
%%-spec format_username(User :: t()) ->
%%    Ret :: binary().
%%
%%format_username(#?MODULE{id = Id}) ->
%%    <<"<@!", Id/binary, ">">>.
%%
%%
%%%% Cloak callbacks
%%on_validate_id(Value) when is_binary(Value) andalso Value /= <<>> ->
%%    {ok, Value};
%%
%%on_validate_username(Value) when is_binary(Value) andalso Value /= <<>> ->
%%    {ok, Value};
%%
%%on_validate_discriminator(Value) when is_binary(Value) andalso Value /= <<>> ->
%%    {ok, Value};
%%
%%on_validate_avatar(null) ->
%%    {ok, undefined};
%%
%%on_validate_avatar(Value) when is_binary(Value) andalso Value /= <<>> ->
%%    {ok, Value};
%%
%%on_validate_bot(Value) when is_boolean(Value) ->
%%    {ok, Value};
%%
%%on_validate_mfa_enabled(Value) when is_boolean(Value) ->
%%    {ok, Value};
%%
%%on_validate_verified(Value) when is_boolean(Value) ->
%%    {ok, Value};
%%
%%on_validate_email(Value) when is_binary(Value) andalso Value /= <<>> ->
%%    {ok, Value};
%%
%%on_validate_email(null) ->
%%    {ok, undefined};
%%
%%cloak_validate(_, _) ->
%%    {error, invalid}.
%%
%%
%%export(#?MODULE{
%%    id = Id,
%%    username = Username,
%%    discriminator = Discriminator,
%%    avatar = Avatar,
%%    bot = Bot,
%%    mfa_enabled = MfaEnabled,
%%    verified = Verified,
%%    email = Email
%%}) ->
%%    #{
%%        <<"id">> => Id,
%%        <<"username">> => Username,
%%        <<"discriminator">> => Discriminator,
%%        <<"avatar">> => marvin_pdu2:nullify(Avatar),
%%        <<"bot">> => Bot,
%%        <<"mfa_enabled">> => MfaEnabled,
%%        <<"verified">> => Verified,
%%        <<"email">> => marvin_pdu2:nullify(Email)
%%    }.
