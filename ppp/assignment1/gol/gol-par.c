#include "gol-par-pub.h"
#include <math.h>
#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
static struct PartialParallelWorld *world_histories[HISTORY];
void ParallelWorldTimeStep(struct PartialParallelWorld *old_world,
                           struct PartialParallelWorld *new_world) {
    // update the board
    int row, col;
    for (row = 1; row <= old_world->actual_row_num_ - 2; row++) {
        for (col = 1; col <= old_world->actual_col_num_ - 2; col++) {
            TIME_STEP_SINGLE_ELEMEMT(row, col, old_world, new_world);
        }
    }
}
// ParallelWorldStart is a noob implementation of parallel GOL using MPI
// it uses barrier
void ParallelWorldStart(int world_rows, int world_cols, int nsteps,
                        int print_world, int print_cells, int myid,
                        int worker_num) {
    int i;
    // init the world history
    for (i = 0; i < HISTORY; i++) {
        world_histories[i] = NULL;
    }
    // create the PartialParallelWorld object
    int row_per_block =
        world_rows / worker_num + ((world_rows % worker_num) != 0);
    int row_num = (myid == worker_num - 1)
                      ? (world_rows - (worker_num - 1) * row_per_block)
                      : row_per_block;

    struct PartialParallelWorld *world = NewPartialParallelWorld(
        myid, worker_num, world_rows, row_num, world_cols);
    world_histories[0] = world;

#ifdef FIXED_WORLD
    ParallelWorldInitFixed(world);
#else
    ParallelWorldInitRandom(world);
#endif

    if (print_world > 0) {
        printf("This is worker %d , row_num %d\n", myid, row_num);
        printf("\ninitial world:\n\n");
        PrintPartialWorld(world);
    }

    // start the calculation
    int world_iter; // the index of current iteration
    double start_time = TimeSecs();
    struct PartialParallelWorld *next_world;

    // data sent to worker 0
    // for first HISTORY-1 integers, report_data[i] indicates whether
    // the world is the same with the world i+1 iterations before
    // the last element report_data[HISTORY-1] is the number of world count
    int report_data[HISTORY] = {0};

    // This Irecv is for checking the message sent by worker 0, that we should
    // quit now
    int cycle = 0;
    for (world_iter = 1; world_iter < nsteps; world_iter++) {
        next_world = world_histories[world_iter % HISTORY];
        if (next_world == NULL) {
            // create one if next world doesn't exist
            next_world = NewPartialParallelWorld(myid, worker_num, world_rows,
                                                 row_num, world_cols);
            world_histories[world_iter % HISTORY] = next_world;
        }

        // 1. We need to communicate about the edge rows with neighbors

        // 1.1 we need to send out our first row to the previous block;
        int target_worker1 = myid == 0 ? worker_num - 1 : myid - 1;
        MPI_Request request1;
        MPI_Status status1;
        int *data1 = world->cells_[1] + 1;
        MPI_Isend(data1, world_cols, MPI_INT, target_worker1, world_iter,
                  MPI_COMM_WORLD, &request1);

        // 1.2 and send the last row the the following block
        int target_worker2 = myid == worker_num - 1 ? 0 : myid + 1;
        MPI_Request request2;
        MPI_Status status2;
        int *data2 = world->cells_[world->actual_row_num_ - 2] + 1;
        MPI_Isend(data2, world_cols, MPI_INT, target_worker2, world_iter,
                  MPI_COMM_WORLD, &request2);

        // 1.3 then we also need to receive the previous row from previous block
        MPI_Recv(world->cells_[0] + 1, world_cols, MPI_INT, target_worker1,
                 world_iter, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        MPI_Recv(world->cells_[world->actual_row_num_ - 1] + 1, world_cols,
                 MPI_INT, target_worker2, world_iter, MPI_COMM_WORLD,
                 MPI_STATUS_IGNORE);

        // 1.4 we need to wait for the finish of sending
        MPI_Wait(&request1, &status1);
        MPI_Wait(&request2, &status2);

        // 2. Start the calculation of this iteration
        // 2.1 wrap the world
        BorderWrap(world);
        // 2.2 calculate the new world
        ParallelWorldTimeStep(world, next_world);
        world = next_world;

        // 3. Print
        // print the cells and worlds
        if (print_world > 0 &&
            (world_iter % print_world) == (print_world - 1)) {
            printf("worker %d at time step %d:\n", myid, world_iter);
            PrintPartialWorld(world);
        }
        int world_count = WorldCount(world);
        if (print_cells > 0 &&
            (world_iter % print_cells) == (print_cells - 1)) {
            printf("worker %d: round %d: %d live cells\n", myid, world_iter,
                   world_count);
        }

        // 4. check cycles and the world count and send them to worker0
        for (i = world_iter - 1; i > world_iter - HISTORY; i--) {
            struct PartialParallelWorld *prev_world = NULL;
            if (i >= 0) {
                prev_world = world_histories[i % HISTORY];
            }

            report_data[world_iter - i - 1] = IsSameWorld(world, prev_world);
        }
        report_data[HISTORY - 1] = world_count;
        if (myid != 0) {
            // if this is not worker 0, just send it
            MPI_Send(report_data, HISTORY, MPI_INT, 0, 0, MPI_COMM_WORLD);
        } else {
            // this is worker 0, we will receive datas from all other workers
            // and merge them
            int buf[HISTORY];
            DPRINTF("Round %d, worker 0,report_data %d %d %d\n", world_iter,
                    report_data[0], report_data[1], report_data[2]);
            // worker 0 will gather the result
            int j;
            for (i = 1; i < worker_num; i++) {
                MPI_Recv(buf, HISTORY, MPI_INT, i, MPI_ANY_TAG, MPI_COMM_WORLD,
                         MPI_STATUS_IGNORE);
                DPRINTF("Round %d, worker %d,report_data %d %d %d\n",
                        world_iter, i, buf[0], buf[1], buf[2]);
                // merge the world count
                report_data[HISTORY - 1] += buf[HISTORY - 1];
                // merge the cycle result
                for (j = 0; j < HISTORY - 1; j++) {
                    report_data[j] = (report_data[j] && buf[j]);
                }
            }
            DPRINTF("Round %d, Total,report_data %d %d %d\n", world_iter,
                    report_data[0], report_data[1], report_data[2]);
            for (j = 0; j < HISTORY - 1; j++) {
                if (report_data[j]) {
                    // we have detected a cycle
                    printf("world iteration %d is equal to iteration %d\n",
                           world_iter, world_iter - j - 1);
                    cycle = 1;
                    break;
                }
            }
        }
        // check whether we should finish
        MPI_Bcast(&cycle, 1, MPI_INT, 0, MPI_COMM_WORLD);
        if (cycle) {
            break;
        }
    }
    double end_time = TimeSecs();
    double elapsed_time = end_time - start_time;
    /*  Iterations are done; sum the number of live cells */
    printf("Number of live cells = %d\n", report_data[HISTORY - 1]);
    fprintf(stderr, "Worker %d Game of Life took %10.3f seconds\n", myid,
            elapsed_time);

    return;
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

    char buf[20];
    sprintf(buf, "%d.txt", myid);
    freopen(buf, "w", stdout);
    ParallelWorldStart(world_rows, world_cols, nsteps, print_world, print_cells,
                       myid, worker_num);
    MPI_Finalize();
    return 0;
}
