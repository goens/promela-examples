#define N 100

proctype counter(int i){
    do
    :: (i < N) -> i = i + 1
    od
}

init{
    run counter(0)
}