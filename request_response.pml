mtype = {request, response, nil}
chan buffer1 = [2] of {mtype}
chan buffer2 = [2] of {mtype}

proctype EndPoint(mtype msg; chan buffer){
    do
    :: buffer?request;
    :: msg = request -> atomic{ buffer!response; msg = nil }
    :: msg = response -> atomic{ msg = nil }
    od
}


proctype Router(mtype msg; chan buffer_from, buffer_to){
    do
    :: buffer_from?msg; buffer_to!msg
    od
}

init{
    atomic{
        run EndPoint(nil, buffer1);
        run Router(nil, buffer1, buffer2);
        run Router(nil, buffer2, buffer1);
        run EndPoint(request, buffer2);
        }
}