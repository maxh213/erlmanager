-module(main).

-compile([export_all]).

start() -> 
    register(updater, spawn(main, updater, [])),
    register(inserter, spawn(main, inserter, [])),
    Work = getWork(),
    register(delagator, spawn(main, delagator, [Work])).

delagator([Work|WorkLeft]) ->
    delagator(Work, WorkLeft).

delagator(Work, []) ->
    sendWorkToCorrectDestination(Work);

delagator(Work, [NextWork|WorkLeft]) ->
    sendWorkToCorrectDestination(Work),
    delagator(NextWork, WorkLeft).

sendWorkToCorrectDestination(Work) when Work rem 2 =:= 0 ->
    updater ! {Work, self()};
    
sendWorkToCorrectDestination(Work) ->
    inserter ! {Work, self()}.

updater() ->
    receive
        {Work, PID} ->
            io:fwrite("U: ~w\n",[Work]),
            updater()
    end.

inserter() ->
    receive
        {Work, PID} ->
            io:fwrite("I: ~w\n",[Work]),
            inserter()
    end.

%TODO: 
%each process in it's own file
%make a process that checks for db updates/inserts periodically and sends them to the delagator (only useful if sybase)

getWork() ->
    [rand:uniform(999) || _ <- lists:seq(1, 10000)].
