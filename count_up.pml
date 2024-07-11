#define N 100

proctype counter(int i){
    (i < N) -> i = i + 1
}

init{
    run counter(0)
}