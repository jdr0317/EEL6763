#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

typedef double ttype;

ttype tdiff(struct timespec a, struct timespec b)
{
  ttype dt = ((b.tv_sec - a.tv_sec) + (b.tv_nsec - a.tv_nsec) / 1E9);
  return dt;
}

struct timespec now()
{
  struct timespec t;
  clock_gettime(CLOCK_REALTIME, &t);
  return t;
}

static long long g_localN = 0;
static struct timespec g_begin;
static double g_last_time_spent = 0.0;
static double g_lower = 0.0;
static double g_upper = 0.0;
static long long g_N = 0;

static double f(double x)
{
  return 8.0 * sqrt(2.0 * M_PI) * exp(-pow(2.0 * x, 2.0));
}

void init_rand_seed()
{
  int rank = 0;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  unsigned int seed = (unsigned int)time(NULL) ^ (unsigned int)(rank * 0x9e3779b9u);
  srand(seed);
}

double estimate_g(double lower_bound, double upper_bound, long long int N)
{
  int rank = 0, size = 1;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  g_lower = lower_bound;
  g_upper = upper_bound;
  g_N = N;

  long long base = N / size;
  long long rem = N % size;
  g_localN = base + ((rank < rem) ? 1 : 0);

  double span = upper_bound - lower_bound;
  double local_sum = 0.0;

  for (long long i = 0; i < g_localN; i++) {
    double u = (double)rand() / (double)RAND_MAX;
    double x = lower_bound + span * u;
    local_sum += f(x);
  }

  return (span / (double)N) * local_sum;
}

void collect_results(double *result)
{
  int rank = 0, size = 1;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  double total = 0.0;
  MPI_Reduce(result, &total, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);

  if (rank == 0) {
    *result = total;
    struct timespec end = now();
    g_last_time_spent = tdiff(g_begin, end);

    printf("Reduce Monte Carlo Integration\n");
    printf("a=%.6f b=%.6f N=%lld R=%d\n", g_lower, g_upper, g_N, size);
    printf("estimate=%.12f\n", *result);
    printf("time_spent=%.8f sec\n", g_last_time_spent);
  }
}

int main(int argc, char **argv)
{
  double result = 0.0;
  MPI_Init(&argc, &argv);
  float lower_bound = atof(argv[1]);
  float upper_bound = atof(argv[2]);
  long long int N = atof(argv[3]);
  init_rand_seed();
  g_begin = now();
  result = estimate_g(lower_bound, upper_bound, N);
  collect_results(&result);
  MPI_Finalize();
  return 0;
}
