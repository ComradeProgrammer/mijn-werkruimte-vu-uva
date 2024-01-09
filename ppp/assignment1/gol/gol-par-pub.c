#include "gol-par-pub.h"

static char *start_world[] = {
    /* Gosper glider gun */
    /* example from https://bitstorm.org/gameoflife/ */
    "..........................................",
    "..........................................",
    "..........................................",
    "..........................................",
    "..........................................",
    "..........................................",
    "........................OO.........OO.....",
    ".......................O.O.........OO.....",
    ".OO.......OO...........OO.................",
    ".OO......O.O..............................",
    ".........OO......OO.......................",
    ".................O.O......................",
    ".................O........................",
    "....................................OO....",
    "....................................O.O...",
    "....................................O.....",
    "..........................................",
    "..........................................",
    ".........................OOO..............",
    ".........................O................",
    "..........................O...............",
    "..........................................",
};

// NewPartialParallelWorld allocate a new PartialParallelWorld object
struct PartialParallelWorld *
NewPartialParallelWorld(int block_id, int total_block_num, int total_row_num,
                        int row_num, int column_num) {
    struct PartialParallelWorld *res =
        malloc(sizeof(struct PartialParallelWorld));
    // init the fields in the struct
    res->block_id_ = block_id;
    res->total_block_num_ = total_block_num;
    res->total_row_num_ = total_row_num;
    res->actual_row_num_ = row_num + 2;
    res->actual_col_num_ = column_num + 2;

    res->cells_ = malloc(sizeof(int *) * res->actual_row_num_);
    int i;
    // allocate space for cell

    for (i = 0; i < res->actual_row_num_; i++) {
        res->cells_[i] = malloc(sizeof(int) * res->actual_col_num_);
        memset(res->cells_[i], 0, sizeof(int) * res->actual_col_num_);
    }

    return res;
}

// BorderWrap will take the horizontal wrap also into consideration
void BorderWrap(struct PartialParallelWorld *world) {
    int i;
    for (i = 0; i < world->actual_row_num_; i++) {
        world->cells_[i][0] = world->cells_[i][world->actual_col_num_ - 2];
        world->cells_[i][world->actual_col_num_ - 1] = world->cells_[i][1];
    }
}

void ParallelWorldInitRandom(struct PartialParallelWorld *world) {
    int **cells = world->cells_;
    int row, col;
    int row_per_block =
        world->total_row_num_ / world->total_block_num_ +
        ((world->total_row_num_ % world->total_block_num_) != 0);
    int row_start = world->block_id_ * row_per_block;
    int row_end = row_start + (world->actual_row_num_ - 2) - 1;
    // Note that rand() implementation is platform dependent.
    // At least make it reprodible on this platform by means of srand()
    srand(1);
    for (row = 0; row < world->total_row_num_; row++) {
        for (col = 0; col < world->actual_col_num_ - 2; col++) {
            float x = rand() / ((float)RAND_MAX + 1);
            int value;
            if (x < 0.5) {
                value = 0;
            } else {
                value = 1;
            }

            // we need to decide whether we need this row, and where we should
            // insert them

            // if this is the last block and we are at the first row
            // this should be put at the last row of this partial block
            // due to wrap
            if (world->block_id_ == world->total_block_num_ - 1 && row == 0) {
                cells[world->actual_row_num_ - 1][col + 1] = value;
            }

            // if this is the last row and we are the first block
            // then this should be the first row of this partial block
            // due to wrap
            if (world->block_id_ == 0 && row == world->total_row_num_ - 1) {
                cells[0][col + 1] = value;
            }

            // if this is the row which lies in [row_start-1,row_end+1]
            if (row >= row_start - 1 && row <= row_end + 1) {
                cells[row - (row_start - 1)][col + 1] = value;
            }
        }
    }
}

void ParallelWorldInitFixed(struct PartialParallelWorld *world) {
    int **cells = world->cells_;
    int row, col;
    int row_per_block =
        world->total_row_num_ / world->total_block_num_ +
        ((world->total_row_num_ % world->total_block_num_) != 0);
    int row_start = world->block_id_ * row_per_block;
    int row_end = row_start + (world->actual_row_num_ - 2) - 1;

    for (row = 0; row < world->total_row_num_; row++) {
        for (col = 0; col < world->actual_col_num_ - 2; col++) {
            int value = 0;
            if ((row < sizeof(start_world) / sizeof(char *)) &&
                (col < strlen(start_world[row - 1]))) {
                value = (start_world[row][col] != '.');
            }
            // we need to decide whether we need this row, and where we should
            // insert them

            // if this is the last block and we are at the first row
            // this should be put at the last row of this partial block
            // due to wrap
            if (world->block_id_ == world->total_block_num_ - 1 && row == 0) {
                cells[world->actual_row_num_ - 1][col + 1] = value;
            }

            // if this is the last row and we are the first block
            // then this should be the first row of this partial block
            // due to wrap
            if (world->block_id_ == 0 && row == world->total_row_num_ - 1) {
                cells[0][col + 1] = value;
            }

            // if this is the row which lies in [row_start-1,row_end+1]
            if (row >= row_start - 1 && row <= row_end + 1) {
                cells[row - (row_start - 1)][col + 1] = value;
            }
        }
    }
    BorderWrap(world);
}

void PrintPartialWorld(struct PartialParallelWorld *world) {
    int **cells = world->cells_;
    int row, col;
    for (row = 1; row <= world->actual_row_num_ - 2; row++) {
        for (col = 1; col <= world->actual_col_num_ - 2; col++) {
            if (cells[row][col]) {
                printf("O");
            } else {
                printf(" ");
            }
        }
        printf("\n");
    }
}

double TimeSecs() {
    struct timeval tv;
    if (gettimeofday(&tv, 0) != 0) {
        fprintf(stderr, "could not do timing\n");
        exit(1);
    }
    return tv.tv_sec + (tv.tv_usec / 1000000.0);
}

int WorldCount(struct PartialParallelWorld *world) {
    int **cells = world->cells_;
    int isum;
    int row, col;

    isum = 0;
    for (row = 1; row <= world->actual_row_num_ - 2; row++) {
        for (col = 1; col <= world->actual_col_num_ - 2; col++) {
            isum = isum + cells[row][col];
        }
    }

    return isum;
}

int IsSameWorld(struct PartialParallelWorld *world,
                struct PartialParallelWorld *old_world) {
    if (old_world == NULL) {
        return 0;
    }
    if (memcmp(world->cells_, old_world->cells_,
               world->actual_col_num_ * world->actual_row_num_ * sizeof(int)) ==
        0) {
        return 1;
    }
    return 0;
}