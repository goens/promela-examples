#define N 100

proctype Sender(chan ch; int count){
    do
    :: atomic{count > 0; count = count - 1; ch!1}
    od
}

proctype Receiver(chan ch; int count){
    bool msg;
    end:
      do
      :: atomic{msg == 0 -> ch?msg}
      :: atomic{msg == 1 && count > 0; count = count - 1; msg = 0}
      od
}

chan ch = [2] of {bool}

init{
  atomic{ run Sender(ch, N); run Receiver(ch, N)}
}