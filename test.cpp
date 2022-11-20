#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <random>
#include <unistd.h>
#include <memory>
#include <ctime>
#include <omp.h>

using namespace std;

int main(){
    default_random_engine e(time(nullptr));
    uniform_int_distribution<unsigned> u(0,100);

    for(int i=0;i<10;i++){
        printf("%d\n", u(e));
    }
    return 0;
}