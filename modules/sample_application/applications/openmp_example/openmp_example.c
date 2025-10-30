/*
 * OpenMP Example Program
 * A simple OpenMP program that demonstrates parallel processing using OpenMP
 */

#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <unistd.h>

#define ARRAY_SIZE 100000000
#define NUM_THREADS 8

void initialize_array(double* array, int size) {
    #pragma omp parallel for
    for (int i = 0; i < size; i++) {
        array[i] = (double)rand() / RAND_MAX;
    }
}

double compute_average(double* array, int size) {
    double sum = 0.0;
    
    #pragma omp parallel for reduction(+:sum)
    for (int i = 0; i < size; i++) {
        sum += array[i];
    }
    
    return sum / size;
}

void transform_array(double* array, int size, double factor) {
    #pragma omp parallel for
    for (int i = 0; i < size; i++) {
        array[i] = array[i] * factor;
        
        // Simulate some computational work
        double temp = 0.0;
        for (int j = 0; j < 10; j++) {
            temp += array[i] * (double)j;
        }
        array[i] = temp / 10.0;
    }
}

int main(int argc, char** argv) {
    printf("Starting OpenMP example with default %d threads...\n", NUM_THREADS);
    
    // Set number of threads
    omp_set_num_threads(NUM_THREADS);
    
    // Allocate memory for the array
    double* data = (double*)malloc(ARRAY_SIZE * sizeof(double));
    if (data == NULL) {
        printf("Failed to allocate memory!\n");
        return 1;
    }
    
    // Initialize the array in parallel
    printf("Initializing array...\n");
    double start_time = omp_get_wtime();
    initialize_array(data, ARRAY_SIZE);
    double end_time = omp_get_wtime();
    printf("Array initialization took %.4f seconds\n", end_time - start_time);
    
    // Compute the average
    printf("Computing average...\n");
    start_time = omp_get_wtime();
    double average = compute_average(data, ARRAY_SIZE);
    end_time = omp_get_wtime();
    printf("Average value is %.6f (calculated in %.4f seconds)\n", average, end_time - start_time);
    
    // Transform the array
    printf("Transforming array...\n");
    start_time = omp_get_wtime();
    transform_array(data, ARRAY_SIZE, 2.0);
    end_time = omp_get_wtime();
    printf("Array transformation took %.4f seconds\n", end_time - start_time);
    
    // Compute the new average
    printf("Computing new average...\n");
    start_time = omp_get_wtime();
    average = compute_average(data, ARRAY_SIZE);
    end_time = omp_get_wtime();
    printf("New average value is %.6f (calculated in %.4f seconds)\n", average, end_time - start_time);
    
    // Print thread information
    printf("\nThread information:\n");
    #pragma omp parallel
    {
        int thread_id = omp_get_thread_num();
        
        #pragma omp critical
        {
            printf("Thread %d is running on CPU core %d\n", thread_id, sched_getcpu());
        }
    }
    
    // Free allocated memory
    free(data);
    
    printf("OpenMP example completed successfully.\n");
    return 0;
}