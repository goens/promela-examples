mtype = {request, response, nil}

proctype EndPoint(chan buffer_from_requests, buffer_to_requests, buffer_from_responses, buffer_to_responses){
    mtype msg = nil;
    do /* non-determinstically, an EndPoint can do one of the following : */
    /* read a `msg` from the buffer */
    :: atomic{ (msg == nil) && buffer_from_requests?[msg] && !buffer_from_responses?[msg] -> buffer_from_requests?msg}
    :: atomic{ (msg == nil) && buffer_from_responses?[msg] -> buffer_from_responses?msg}
    /* if it received a request, send a response */
    /* this atomicity might make a difference for deadlock */
    :: atomic{ (msg == request) -> buffer_to_responses!response; msg = nil } 
    /* if it received a response, consume it */
    :: atomic{ (msg == response) ->  msg = nil }
    /* (non-deterministically) decide to send a new request */
    /* no flow control */
    :: atomic{msg == nil && !buffer_from_requests?[msg] && !buffer_from_responses?[msg] -> buffer_to_requests!request}
    od
}


proctype Router(chan buffer_from, buffer_to){
    mtype msg = nil;
    do /* a router just keeps forwarding messages */
    /* no flow control: */
     :: buffer_from?msg  -> buffer_to!msg
    od
}

chan buffer1_reqs = [2] of {mtype}
chan buffer1_responses = [2] of {mtype}
chan buffer2_reqs = [2] of {mtype}
chan buffer2_responses = [2] of {mtype}
chan buffer3_reqs = [2] of {mtype}
chan buffer3_responses = [2] of {mtype}
chan buffer4_reqs = [2] of {mtype}
chan buffer4_responses = [2] of {mtype}

init{
    atomic{
        run EndPoint(buffer4_reqs, buffer1_reqs, buffer4_responses, buffer1_responses);
        run Router(buffer1_reqs, buffer2_reqs);
        run Router(buffer1_responses, buffer2_responses);
        run EndPoint(buffer2_reqs, buffer3_reqs, buffer2_responses, buffer3_responses);
        run Router(buffer3_reqs, buffer4_reqs);
        run Router(buffer3_responses, buffer4_responses);
        }
}