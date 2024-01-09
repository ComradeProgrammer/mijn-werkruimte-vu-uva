#ifndef __GOL_PAR_PUB_H__
#define __GOL_PAR_PUB_H__
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>

struct PartialParallelWorld {
    // global information about the partition
    int block_id_;
    int total_block_num_;
    int total_row_num_;

    // row num of cells_, which the row num of this part of the world +2
    int actual_row_num_;
    // column num of cells_ which is the column num of this part of the world +2
    int actual_col_num_;
    int **cells_;
};
// keep short history since we want to detect simple cycles
#define HISTORY 3

struct PartialParallelWorld *
NewPartialParallelWorld(int block_id, int total_block_num, int total_row_num,
                        int row_num, int column_num);
void BorderWrap(struct PartialParallelWorld *world);
void ParallelWorldInitRandom(struct PartialParallelWorld *world);
void ParallelWorldInitFixed(struct PartialParallelWorld *world);
void PrintPartialWorld(struct PartialParallelWorld *world);

#define TIME_STEP_SINGLE_ELEMEMT(row, col, old, new)                           \
    do {                                                                       \
        int **cells = old->cells_;                                             \
        int row_m, row_p, col_m, col_p, nsum;                                  \
        int newval;                                                            \
        row_m = row - 1;                                                       \
        row_p = row + 1;                                                       \
        col_m = col - 1;                                                       \
        col_p = col + 1;                                                       \
        nsum = cells[row_p][col_m] + cells[row_p][col] + cells[row_p][col_p] + \
               cells[row][col_m] + cells[row][col_p] + cells[row_m][col_m] +   \
               cells[row_m][col] + cells[row_m][col_p];                        \
        switch (nsum) {                                                        \
        case 3:                                                                \
            newval = 1;                                                        \
            break;                                                             \
        case 2:                                                                \
            newval = cells[row][col];                                          \
            break;                                                             \
        default:                                                               \
            newval = 0;                                                        \
            break;                                                             \
        }                                                                      \
        new->cells_[row][col] = newval;                                        \
    } while (0)

#endif