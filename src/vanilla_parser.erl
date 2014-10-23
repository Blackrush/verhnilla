-module(vanilla_parser).

-export([parse/2]).

-define(VERSION, <<"1.29.1">>).

parse(_Conn, {version, ?VERSION}) ->
	ok;

parse(Conn, {version, _Invalid}) ->
	vanilla_tcp:send(Conn, [<<"AlEv">>, ?VERSION]),
	vanilla_tcp:close(Conn);

parse(Conn, {auth, _Username, _Password}) ->
	% TODO parse auth
	vanilla_tcp:send(Conn, <<"AlEf">>);

parse(Conn, get_queue) ->
	% TODO parse get_queue
	vanilla_tcp:send(Conn, <<"Af2;1000;500;1;1">>);

parse(Conn, get_characters) ->
	% TODO parse get_characters
	vanilla_tcp:send(Conn, <<"AxK31500000|1,3">>);

parse(_Conn, _Msg) ->
	ok.
