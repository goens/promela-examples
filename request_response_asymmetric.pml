mtype = {request, response, nil}

proctype EndPointFC(chan buffer_from, buffer_to){
    mtype msg = nil;
    do /* non-determinstically, an EndPoint can do one of the following : */
    /* read a `msg` from the buffer */
    :: atomic{ (msg == nil) && buffer_from?[msg] -> buffer_from?msg}
    /* if it received a request, send a response */
    /* this atomicity might make a difference for deadlock */
    :: atomic{ (msg == request) -> buffer_to!response; msg = nil } 
    /* if it received a response, consume it */
    :: atomic{ (msg == response) ->  msg = nil }
    /* (non-deterministically) decide to send a new request */
    /* no flow control, proritize processing incoming requests before sending new ones */
    :: atomic{(msg == nil && !buffer_from?[msg]) -> buffer_to!request}
    od
}

proctype EndPointNoFC(chan buffer_from, buffer_to){
    mtype msg = nil;
    do /* non-determinstically, an EndPoint can do one of the following : */
    /* read a `msg` from the buffer */
    :: atomic{ (msg == nil) && buffer_from?[msg] -> buffer_from?msg}
    /* if it received a request, send a response */
    /* this atomicity might make a difference for deadlock */
    :: atomic{ (msg == request) -> buffer_to!response; msg = nil } 
    /* if it received a response, consume it */
    :: atomic{ (msg == response) ->  msg = nil }
    /* (non-deterministically) decide to send a new request */
    /* no flow control */
    /* :: buffer_to!request */
    /* flow control, proritize processing incoming requests before sending new ones  */
    :: atomic{ (len(buffer_to) < 2 && !buffer_to?[request] && msg == nil && !buffer_from?[msg]) -> buffer_to!request}
    od
}


proctype Router(chan buffer_from, buffer_to){
    mtype msg = nil;
    do /* a router just keeps forwarding messages */
    /* no flow control: */
    /* :: buffer_from?msg  -> buffer_to!msg */
    /* with flow control */
     :: buffer_from?msg  -> 
     if
     /* forward responses without any issue */
     :: atomic{ (msg == response) -> buffer_to!msg }
     /* flow control for requests */
     :: atomic{ (msg == request && len(buffer_to) < 2 && !buffer_to?[request]) -> buffer_to!msg}
     fi
    od
}

chan buffer1 = [2] of {mtype}
chan buffer2 = [2] of {mtype}
chan buffer3 = [2] of {mtype}
chan buffer4 = [2] of {mtype}

/*
  [EPNoFC] -- buffer1--> [Router1] -- buffer2 --->
    ^                                            |
    |                                            v
    <---- buffer4 -- [Router2] <-- buffer3 --[EPFC]
 */

init{
    atomic{
        run EndPointNoFC(buffer4, buffer1);
        run Router(buffer1, buffer2);
        run EndPointFC(buffer2, buffer3);
        run Router(buffer3, buffer4);
        }
}

never{
    do
    :: buffer1?[nil] || buffer2?[nil] ||buffer3?[nil] ||buffer4?[nil]
    od
}