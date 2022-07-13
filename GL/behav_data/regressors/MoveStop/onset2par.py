import sys

input = open(sys.argv[1])
output = open("GLonset.par", "w")

onset = input.read().split()
map_object = map(float, onset)
onset_float = list(map_object)

output.write("0\t0\t"+repr(onset_float[0])+"\t1.0\tNull\n")

for j in range(0, 9):
    if (j % 2 == 0):
        move = onset_float[j]
        move_dur = onset_float[j+1]
        next_move = onset_float[j+2]
        stop = onset_float[j+12]
        stop_dur = onset_float[j+13]
        move_end = round(stop-(move+move_dur), 3)
        stop_end = round(next_move-(stop+stop_dur), 3)
        output.write(repr(move)+"\t1\t"+repr(move_dur)+"\t1.0\tMOVE\n")
        output.write(repr(round(move+move_dur,3))+"\t0\t"+repr(move_end)+"\t1.0\tNULL\n")
        output.write(repr(stop)+"\t2\t"+repr(stop_dur)+"\t1.0\tSTOP\n")
        output.write(repr(round(stop+stop_dur,3))+"\t0\t"+repr(stop_end)+"\t1.0\tNULL\n")

move = onset_float[10]
move_dur = onset_float[11]
stop = onset_float[22]
stop_dur = onset_float[23]
move_end = round(stop-(move+move_dur), 3)
output.write(repr(move)+"\t1\t"+repr(move_dur)+"\t1.0\tMOVE\n")
output.write(repr(round(move+move_dur,3))+"\t0\t"+repr(move_end)+"\t1.0\tNULL\n")
output.write(repr(stop)+"\t2\t"+repr(stop_dur)+"\t1.0\tSTOP\n")


input.close
output.close
