-module(test).
-include_lib("mongodb/include/mongo_protocol.hrl").
-compile(export_all).

start() ->
    application:start(bson),
    application:start(crypto),
    application:start(mongodb),
    application:start(mongotest),
    start(1).

start(0) -> done;
start(N) ->
    erlang:spawn(fun() -> do(N) end),
    start(N-1).

do(N) ->
    UuidState = uuid:new(erlang:self()),
    {Uuid, UuidState2} = uuid:get_v1(UuidState),
    ProductKey = erlang:list_to_binary(uuid:uuid_to_string(Uuid)),

    {Uuid2, _UuidState3} = uuid:get_v1(UuidState2),
    Did = erlang:list_to_binary(uuid:uuid_to_string(Uuid2)),

    loop(N, ProductKey, Did).

loop(N, ProductKey, Did) ->
    Collection = <<"raw1">>,

    Payload = <<"AAAAAxgAAJEVASAAAKUAAAAAAAAAAAAAAACaAXY=">>,

    Types = [<<"dev2app">>, <<"dev2app">>, <<"dev2app">>, <<"dev2app">>, <<"dev2app">>, <<"dev2app">>, <<"app2dev">>, <<"dev_reg">>, <<"user_reg">>, <<"dev_online">>, <<"dev_re_online">>, <<"user_online">>, <<"user_offline">>, <<"dev_ping">>, <<"dev_protocol_ver">>],
    Type = lists:nth(random:uniform(erlang:length(Types)), Types),

    Timestamp = epoch_milliseconds()/1000,

    Re = insert(Collection, {Did, Timestamp, ProductKey, Type, Payload}),

    io:format("[~p] ~p~n", [N, Re]),
    %timer:sleep(100),

    loop(N, ProductKey, Did).

epoch_milliseconds() ->
    {A1,A2,A3} = erlang:now(),
    A1*1000000000 + A2*1000 + (A3 div 1000).

insert(Collection, {Did, Timestamp, ProductKey, Type, Payload}) ->
    PoolName = mongo_conn_pool,
    Worker = poolboy:checkout(PoolName),
    gen_server:call(Worker, #insert{collection = Collection,
                                             documents = [{<<"did">>, Did, 
                                                           <<"timestamp">>, Timestamp,
                                                           <<"product_key">>, ProductKey,
                                                           <<"type">>, Type,
                                                           <<"payload">>, Payload
                                                          }]
                                            }),
    poolboy:checkin(PoolName, Worker),
    ok.
