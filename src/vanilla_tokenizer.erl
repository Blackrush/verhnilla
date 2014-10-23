-module(vanilla_tokenizer).

-export([tokenize/2]).

-define(SEP, <<"\r\n">>).

tokenize(State, Data) ->
	tokenize(State, Data, []).

tokenize(State, Data, Acc) when is_binary(Data) ->
	Splitted = binary:split(Data, ?SEP),
	tokenize(State, Splitted, Acc);

tokenize(State, [], Acc) -> {State, lists:reverse(Acc)};

tokenize(State, [<<>>|Parts], Acc) ->
	tokenize(State, Parts, Acc);

tokenize(State, [Part|Parts], Acc) ->
	lager:debug("~p", [Part]),
	case token(State, Part) of
		{NewState, Msg} when is_integer(NewState) ->
			tokenize(NewState, Parts, [Msg|Acc]);
		Msg ->
			tokenize(State, Parts, [Msg|Acc])
	end.

token(0, Data) ->
	{1, {version, Data}};

token(1, Data) ->
	[Username, Password] = binary:split(Data, <<"\n#1">>),
	{2, {auth, Username, Password}};

token(_, <<"Af">>) ->
	get_queue;

token(_, <<"Ax">>) ->
	get_characters;

token(_State, Data) ->
	{invalid, Data}.
