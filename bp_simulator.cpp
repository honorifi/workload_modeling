#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <unistd.h>
#include <memory>
#include <ctime>

using namespace std;
#define DEF_TOTAL_MEMORY ((size_t)256 * 1024 * 1024)
#define DEF_BLOCK_MEMORY ((size_t)16)

#define MOV_ADD_OFFSET 16
#define R_UNROOL1(da, sa) da = sa[0];
#define R_UNROOL2(da, sa) da = sa[1]; R_UNROOL1(da, sa)
#define R_UNROOL3(da, sa) da = sa[2]; R_UNROOL2(da, sa)
#define R_UNROOL4(da, sa) da = sa[3]; R_UNROOL3(da, sa)
#define R_UNROOL5(da, sa) da = sa[4]; R_UNROOL4(da, sa)
#define R_UNROOL6(da, sa) da = sa[5]; R_UNROOL5(da, sa)
#define R_UNROOL7(da, sa) da = sa[6]; R_UNROOL6(da, sa)
#define R_UNROOL8(da, sa) da = sa[7]; R_UNROOL7(da, sa)
#define R_UNROOL9(da, sa) da = sa[8]; R_UNROOL8(da, sa)
#define R_UNROOL10(da, sa) da = sa[9]; R_UNROOL9(da, sa)
#define R_UNROOL11(da, sa) da = sa[10]; R_UNROOL10(da, sa)
#define R_UNROOL12(da, sa) da = sa[11]; R_UNROOL11(da, sa)
#define R_UNROOL13(da, sa) da = sa[12]; R_UNROOL12(da, sa)
#define R_UNROOL14(da, sa) da = sa[13]; R_UNROOL13(da, sa)
#define R_UNROOL15(da, sa) da = sa[14]; R_UNROOL14(da, sa)
#define R_UNROOL16(da, sa) da = sa[15]; R_UNROOL15(da, sa)
#define R_UNROOLN(n, da, sa) R_UNROOL##n(da, sa)                
#define R_UNROOL(n, da, sa) R_UNROOLN(n, da, sa)                    //max of n: 16
#define W_UNROOL1(da, sa) da[0] = sa;
#define W_UNROOL2(da, sa) da[1] = sa; W_UNROOL1(da, sa)
#define W_UNROOL3(da, sa) da[2] = sa; W_UNROOL2(da, sa)
#define W_UNROOL4(da, sa) da[3] = sa; W_UNROOL3(da, sa)
#define W_UNROOL5(da, sa) da[4] = sa; W_UNROOL4(da, sa)
#define W_UNROOL6(da, sa) da[5] = sa; W_UNROOL5(da, sa)
#define W_UNROOL7(da, sa) da[6] = sa; W_UNROOL6(da, sa)
#define W_UNROOL8(da, sa) da[7] = sa; W_UNROOL7(da, sa)
#define W_UNROOL9(da, sa) da[8] = sa; W_UNROOL8(da, sa)
#define W_UNROOL10(da, sa) da[9] = sa; W_UNROOL9(da, sa)
#define W_UNROOL11(da, sa) da[10] = sa; W_UNROOL10(da, sa)
#define W_UNROOL12(da, sa) da[11] = sa; W_UNROOL11(da, sa)
#define W_UNROOL13(da, sa) da[12] = sa; W_UNROOL12(da, sa)
#define W_UNROOL14(da, sa) da[13] = sa; W_UNROOL13(da, sa)
#define W_UNROOL15(da, sa) da[14] = sa; W_UNROOL14(da, sa)
#define W_UNROOL16(da, sa) da[15] = sa; W_UNROOL15(da, sa)
#define W_UNROOLN(n, da, sa) W_UNROOL##n(da, sa)                
#define W_UNROOL(n, da, sa) W_UNROOLN(n, da, sa)                    //max of n: 16

class MemContainer{
    public:
    char *_Memptr;
    int _size;
    
    MemContainer(){
        _Memptr = NULL;
        _size = 0;
    }
    ~MemContainer(){
        if(_Memptr != NULL) delete []_Memptr;
        _size = 0;
    }

    void Apply(int x){
        if(_Memptr != NULL)
            delete []_Memptr;
        try{
            _Memptr = new char[x+MOV_ADD_OFFSET];
        }
        catch(const bad_alloc& e){
	        fprintf(stderr,"memory alloc failed.");
            return ;
        }
        _size = x+MOV_ADD_OFFSET;
    }

    void Read_seq(int x, int of = 0){
        register int _tmp;
        for(int i=of;i<of+x;i+=MOV_ADD_OFFSET){
            R_UNROOL(MOV_ADD_OFFSET, _tmp, (_Memptr+i) );
        }
    }

    void Write_seq(int x, int of = 0){
        register int _tmp;
        for(int i=of;i<of+x;i++){
            W_UNROOL(MOV_ADD_OFFSET, (_Memptr+i), _tmp );
        }
    }

    void Read_interval(int x, int step = 1){
        register int _tmp;
        for(int i=0;i<x;i++){
            _tmp = _Memptr[(i*step)%x];
        }
    }

    void Write_interval(int x, int step = 1){
        register int _tmp;
        for(int i=0;i<x;i++){
            _Memptr[(i*step)%x] = _tmp;
        }
    }

    void Read_random(int total, int block){
        int num_loop = total/block;
        register int _tmp;
        for(int i=0; i<num_loop;i++){
            Read_seq(block, random()%(DEF_TOTAL_MEMORY-block));
        }
    }

    void Write_random(int total, int block){
        int num_loop = total/block;
        register int _tmp;
        for(int i=0; i<num_loop;i++){
            Write_seq(block, random()%(DEF_TOTAL_MEMORY-block));
        }
    }
};


class MemRequestor{
    public:
    int _num_loop;
    MemContainer Mc;
    clock_t clock_begin, clock_end;
    double clock_time;

    int block_size;
    int r_ratio, w_ratio;
    int Throughput;

    MemRequestor(int throughput = 24000, int block = 4096, int r = 1, int w = 1){
        Throughput = throughput;
        _num_loop = Throughput/(DEF_TOTAL_MEMORY>>20);
        block_size = block;
        r_ratio = DEF_TOTAL_MEMORY/(r+w)*r;
        w_ratio = DEF_TOTAL_MEMORY/(r+w)*w;
        Mc.Apply(DEF_TOTAL_MEMORY);
    }

    void update_Throughput(int throughput){
        Throughput = throughput;
        _num_loop = Throughput/(DEF_TOTAL_MEMORY>>20);
    }

    void update_block_size(int block){
        block_size = block;
    }

    void update_r_w(int r, int w){
        r_ratio = DEF_TOTAL_MEMORY/(r+w)*r;
        w_ratio = DEF_TOTAL_MEMORY/(r+w)*w;
    }

    void Request_Seq(){
        while(1){
        clock_begin = clock();
        for(int i=0;i<_num_loop;i++){
            Mc.Read_seq(r_ratio);
            Mc.Write_seq(w_ratio);
        }
        clock_end = clock();
        clock_time = (clock_end - clock_begin)/CLOCKS_PER_SEC*1e6;
        clock_time = 1000000.0 - clock_time;
        usleep(clock_time);
        }
    }

    void Request_Rand(){
        while(1){
        clock_begin = clock();
        for(int i=0;i<_num_loop;i++){
            Mc.Read_random(r_ratio, block_size);
            Mc.Write_random(w_ratio, block_size);
        }
        clock_end = clock();
        clock_time = (double)(clock_end - clock_begin)/CLOCKS_PER_SEC*1e6;
        clock_time = 1000000.0 - clock_time;
        usleep(clock_time);
        }
    }

    void Request_Interval(int step){
        while(1){
        clock_begin = clock();
        for(int i=0;i<_num_loop;i++){
            Mc.Read_interval(r_ratio, step);
            Mc.Write_interval(w_ratio, step);
        }
        clock_end = clock();
        clock_time = (double)(clock_end - clock_begin)/CLOCKS_PER_SEC*1e6;
        clock_time = 1000000.0 - clock_time;
        usleep(clock_time);
        }
    }
};


int main(int argc, char *argv[]){
    int throughput = 24000;                         //unit: MB
    int mode=0, step=10;

    for(int i=1;i<argc;i++){
        if(argv[i][0]=='-'){
            if(argv[i][1]=='m'){
                if(!strcmp(argv[i+1], "Random"))
                    mode = 2;
                else if(!strcmp(argv[i+1], "Interval"))
                    mode = 3;
                else if(!strcmp(argv[i+1], "Seq"))
                    mode = 1;
                else
                    printf("no mode matched with %s\n",argv[i+1]);
            }
            else if(argv[i][1]=='s'){
                step = stoi(argv[i+1]);
            }
            else if(isdigit(argv[i][1])){
                throughput = stoi(argv[i]);
            }
            else if(argv[i][1]=='-' && (!strcmp(argv[i]+2,"help"))){
                puts("-m [str]\t:\tset mode, valid mode: Seq, Random, Interval");
                puts("-s [n]\t:\tset step, valid when using Interval mode, default: 10");
                puts("-[n]\t:\tset throughpu");
            }
            else{
                printf("invalid input:%s\ntry --help\n", argv[i]);
            }
        }
    }
    
    printf("mode : %d\n",mode);
    MemRequestor MR(throughput, DEF_BLOCK_MEMORY, 1, 1);
    MemContainer Mc_r, Mc_w;
    Mc_r.Apply(DEF_TOTAL_MEMORY);
    Mc_w.Apply(DEF_TOTAL_MEMORY);
    if(mode == 1){
        MR.Request_Seq();
        //while(1){
        //    Mc_r.Read_seq(DEF_TOTAL_MEMORY);
        //    Mc_w.Write_seq(DEF_TOTAL_MEMORY);
        //}
    }
    else if (mode == 2){
        MR.Request_Rand();
    }
    else if(mode == 3){
        MR.Request_Interval(step);
    }
    else if(mode == 0){
        return 0;
    }
    else{
        puts("invalid mode");
    }

    return 0;
}