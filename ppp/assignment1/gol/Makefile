# Add gol-par-bonus1 and gol-par-bonus2 when available
all: gol-seq gol-par

gol-seq: gol-seq.c
	gcc -Wall -O3 -o gol-seq gol-seq.c -lm 
# gcc -Wall -O3 -o gol-seq gol-seq.c -lm -DFIXED_WORLD	

# assumption is that the MPI module has been preloaded in the environment
gol-par: gol-par.c gol-par-pub.c
	mpicc -Wall -O3 -o gol-par gol-par.c gol-par-pub.c -lm 
# mpicc -Wall -O3 -o gol-par gol-par.c gol-par-pub.c -lm -DFIXED_WORLD -DDEBUG

gol-par-bonus1: gol-par-bonus1.c  gol-par-pub.c
	mpicc -Wall -O3 -o gol-par-bonus1 gol-par-bonus1.c gol-par-pub.c -lm

gol-par-bonus2: gol-par-bonus2.c gol-par-pub.c
	mpicc -Wall -O3 -o gol-par-bonus2 gol-par-bonus2.c gol-par-pub.c -lm

clean:
	rm -f *.o gol-seq gol-par gol-par-bonus1 gol-par-bonus2
