mtype = {request, response, nil}

proctype EndPoint(mtype msg; chan buffer){
    do /* non-determinstically, an EndPoint can do one of the following : */
    /* read a `msg` from the buffer */
    :: buffer?msg; 
    /* if it received a request, send a response */
    :: atomic{ msg == request -> buffer!response; msg = nil }
    /* if it received a response, cosnume it */
    :: atomic{ msg == response ->  msg = nil }
    /* (non-deterministically) send a new request */
    :: atomic{ msg == nil -> msg = request}
    od
}


proctype Router(mtype msg; chan buffer_from, buffer_to){
    do /* a router just keeps forwarding messages */
    :: atomic{ buffer_from?msg -> buffer_to!msg}
    od
}

chan buffer1 = [2] of {mtype}
chan buffer2 = [2] of {mtype}

init{
    atomic{
        run EndPoint(nil, buffer1);
        run Router(nil, buffer1, buffer2);
        run Router(nil, buffer2, buffer1);
        run EndPoint(request, buffer2);
        }
}