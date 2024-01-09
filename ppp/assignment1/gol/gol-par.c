#include "gol-par-pub.h"
#include <math.h>
#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void ParallelWorldTimeStep(struct PartialParallelWorld *old_world,
                           struct PartialParallelWorld *new_world) {
    // update the board
    int row, col;
    for (row = 1; row <= old_world->actual_row_num_ - 2; row++) {
        for (col = 1; col <= old_world->actual_col_num_ - 2; col++) {
            TIME_STEP_SINGLE_ELEMEMT(row, col, old_world, new_world);
        }
    }
    BorderWrap(new_world);
}
// ParallelWorldStart is a noob implementation of parallel GOL using MPI
// it uses barrier
void ParallelWorldStart(int world_rows, int world_cols, int nsteps,
                        int print_world, int print_cells, int myid,
                        int worker_num) {
    // create the PartialParallelWorld object
    int row_per_block =
        world_rows / worker_num + ((world_rows % worker_num) != 0);
    int row_num = (myid == worker_num - 1)
                      ? (world_rows - (worker_num - 1) * row_per_block)
                      : row_per_block;

    struct PartialParallelWorld *world = NewPartialParallelWorld(
        myid, worker_num, world_rows, row_num, world_cols);
    sleep(myid);

#ifdef FIXED_WORLD
    ParallelWorldInitFixed(world);
#else
    ParallelWorldInitRandom(world);
#endif

    if (print_world > 0) {
        printf("This is worker %d \n", myid);
        printf("\ninitial world:\n\n");
        PrintPartialWorld(world);
    }
}

int main(int argc, char *argv[]) {
    // parse the command line arguements
    int world_rows, world_cols, nsteps, print_world, print_cells, myid,
        worker_num;
    if (argc != 6) {
        fprintf(stderr, "Usage: %s rows cols steps worldstep cellstep\n",
                argv[0]);
        exit(1);
    }
    world_rows = atoi(argv[1]);
    world_cols = atoi(argv[2]);
    nsteps = atoi(argv[3]);
    print_world = atoi(argv[4]);
    print_cells = atoi(argv[5]);

    // initialize MPI components
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &myid);
    MPI_Comm_size(MPI_COMM_WORLD, &worker_num);

    ParallelWorldStart(world_rows, world_cols, nsteps, print_world, print_cells,
                       myid, worker_num);
    MPI_Finalize();
    return 0;
}
