import csv
import sys


input_file = open("./output/stdout",'r').readlines()
output_file = open("./output/sieveout.csv",'w')
writer = csv.writer(output_file)


args = len(sys.argv)
header = []
if args > 1 :
    if sys.argv[1] == 'memory':
        header = ['bandwidth', 'latency', 'qps']
    elif sys.argv[1] == 'cpu':
        header = ['%CPU limit', 'qps']


writer.writerow(header)


message_cnt = 0
tmp_sum = 0
for cont in input_file:
    pos_qps = cont.find("qps")
    sieve_out = ""
    if pos_qps != -1:
        sieve_out += cont[0:cont.find("]")+1] + " "
        sieve_out += cont[pos_qps:cont.find("(")] + "\n"
        tmp_sum += float(sieve_out.split()[4])
        message_cnt += 1
    elif cont.find("Limit") != -1:
        avg_qps = "%.2f"%(tmp_sum/message_cnt)
        sieve_out = "avg: " + avg_qps + ";\n" + cont
        message_cnt = 0
        tmp_sum = 0
        cont = cont.split()
        limit_pos = cont.index("%")
        limit = cont[limit_pos-1]
        writer.writerow([limit, avg_qps])
    print(sieve_out, end='')


output_file.close()