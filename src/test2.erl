-module(test2).
-include_lib("mongodb/include/mongo_protocol.hrl").
-compile(export_all).

start() ->
    application:start(bson),
    application:start(crypto),
    application:start(mongodb),
    application:start(mongotest),
    %start(1).
    do(1).

start(0) -> done;
start(N) ->
    erlang:spawn(fun() -> do(N) end),
    start(N-1).

do(N) ->
    %UuidState = uuid:new(erlang:self()),
    %{Uuid, UuidState2} = uuid:get_v1(UuidState),
    %ProductKey = erlang:list_to_binary(uuid:uuid_to_string(Uuid)),
    ProductKey = <<"pk1">>,

    %{Uuid2, _UuidState3} = uuid:get_v1(UuidState2),
    %Did = erlang:list_to_binary(uuid:uuid_to_string(Uuid2)),
    Did = <<"did1">>,

    {ok, Conn} = mongo:connect([{database, <<"test">>}]),

    loop(N, Conn, ProductKey, Did).

loop(N, Conn, ProductKey, Did) ->
    Collection = <<"raw4">>,

    Payload = <<"AAAAAxgAAJEVASAAAKUAAAAAAAAAAAAAAACaAXY=">>,

    %Types = [<<"dev2app">>, <<"dev2app">>, <<"dev2app">>, <<"dev2app">>, <<"dev2app">>, <<"dev2app">>, <<"app2dev">>, <<"dev_reg">>, <<"user_reg">>, <<"dev_online">>, <<"dev_re_online">>, <<"user_online">>, <<"user_offline">>, <<"dev_ping">>, <<"dev_protocol_ver">>],
    %Type = lists:nth(random:uniform(erlang:length(Types)), Types),
    Type = <<"dev2app">>,

    %Timestamp = epoch_milliseconds()/1000,
    Timestamp = 1000,

    Re = insert(Conn, Collection, {Did, Timestamp, ProductKey, Type, Payload}),

    io:format("[~p] ~p~n", [N, Re]),
    %timer:sleep(100),

    loop(N, Conn, ProductKey, Did).

epoch_milliseconds() ->
    {A1,A2,A3} = erlang:now(),
    A1*1000000000 + A2*1000 + (A3 div 1000).

insert(Conn, Collection, {Did, Timestamp, ProductKey, Type, Payload}) ->
%    mongo:insert(Conn, Collection, #{<<"did">> => Did, 
%                                     <<"timestamp">> => Timestamp,
%                                     <<"product_key">> => ProductKey,
%                                     <<"type">> => Type,
%                                     <<"payload">> => Payload
%                                    }),
    mongo:insert(Conn, Collection, {<<"did">>, Did, 
                                     <<"timestamp">>, Timestamp,
                                     <<"product_key">>, ProductKey,
                                     <<"type">>, Type,
                                     <<"payload">>, Payload
                                    }),
   ok.
