mtype = {request, response, nil}

proctype EndPoint(mtype msg; chan buffer_from, buffer_to){
    do /* non-determinstically, an EndPoint can do one of the following : */
    /* read a `msg` from the buffer */
    :: atomic{ buffer_from?msg; assert(msg != nil)}
    /* if it received a request, send a response */
    :: atomic{ msg == request -> buffer_to!response; msg = nil }
    /* if it received a response, consume it */
    :: atomic{ msg == response ->  msg = nil }
    /* (non-deterministically) decide to send a new request */
    :: atomic{ msg == nil -> msg = request}
    od
}


proctype Router(mtype msg; chan buffer_from, buffer_to){
    do /* a router just keeps forwarding messages */
    :: atomic{ buffer_from?msg; assert(msg != nil)} -> buffer_to!msg
    od
}

chan buffer1 = [2] of {mtype}
chan buffer2 = [2] of {mtype}
chan buffer3 = [2] of {mtype}
chan buffer4 = [2] of {mtype}

/*
  [EP1] -- buffer1--> [Router1] -- buffer2 ------>
    ^                                            |
    |                                            v
    <---- buffer4 -- [Router2] <-- buffer3 ----[EP2]
 */

init{
    atomic{
        run EndPoint(nil, buffer4, buffer1);
        run Router(nil, buffer1, buffer2);
        run EndPoint(nil, buffer2, buffer3);
        run Router(nil, buffer3, buffer4);
        }
}

/* I would like to have a statement that a message in a channel will never
 be nil, not sure how to express this, so ussing asserts instead */
