-module(vanilla_tcp).

%% API
-export([start_link/0, start_link/4]).
-export([send/2, close/1]).

%% private export
-export([init/4]).

%% API functions
start_link() ->
	lager:debug("listening on 5555..."),
	ranch:start_listener(
		vanilla,        % module????
		1,              % nr of acceptors
		ranch_tcp,      % transport
		[{port, 5555}], % transport options
		?MODULE,        % protocol
		[]              % protocol options????
	).

start_link(Ref, Sock, Transport, Opts) ->
	Pid = spawn_link(?MODULE, init, [Ref, Sock, Transport, Opts]),
	{ok, Pid}.

%% private

create_ticket() -> base64:encode(crypto:rand_bytes(22)).

recv(#{sock := Sock, transport := Transport}) -> Transport:recv(Sock, 0, infinity).
send(#{sock := Sock, transport := Transport}, Data) ->
	lager:debug("SND ~p", [Data]),
	Transport:send(Sock, [Data, <<"\0">>]).
close(#{sock := Sock, transport := Transport}) -> Transport:close(Sock).

init(Ref, Sock, Transport, _Opts) ->
	ok = ranch:accept_ack(Ref),
	Conn = #{sock => Sock, transport => Transport, state => 0},
	send(Conn, [<<"HC">>, create_ticket()]),
	loop(Conn).

loop(Conn) ->
	case recv(Conn) of
		{ok, Data} ->
			lager:debug("RCV ~p", [Data]),
			NewConn = handle(Conn, Data),
			loop(NewConn);
		_ ->
			lager:debug("CLS"),
			ok = close(Conn)
	end.

handle(Conn, Data) when is_binary(Data) ->
	{ok, State} = maps:find(state, Conn),
	{NewState, Tokens} = vanilla_tokenizer:tokenize(State, Data),
	NewConn = maps:put(state, NewState, Conn),
	handle(NewConn, Tokens);

handle(Conn, []) -> Conn;

handle(Conn, [Token|Tokens]) ->
	case vanilla_parser:parse(Conn, Token) of
		{ok, NewConn} -> handle(NewConn, Tokens);
		ok -> handle(Conn, Tokens);
		Error -> Error
	end.
