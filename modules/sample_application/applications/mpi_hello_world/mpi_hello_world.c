/*
 * MPI Hello World Program
 * A simple MPI program that demonstrates basic MPI functionality
 */

#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

int main(int argc, char** argv) {
    // Initialize the MPI environment
    MPI_Init(&argc, &argv);

    // Get the number of processes
    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);

    // Get the rank of the process
    int world_rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

    // Get the name of the processor
    char processor_name[MPI_MAX_PROCESSOR_NAME];
    int name_len;
    MPI_Get_processor_name(processor_name, &name_len);

    // Print a hello world message
    printf("Hello world from processor %s, rank %d out of %d processors\n",
           processor_name, world_rank, world_size);

    // Additional work to simulate a computation
    if (world_rank == 0) {
        printf("Primary process is performing some additional computation...\n");
        // Sleep for a short time to simulate work
        sleep(2);
        
        printf("Primary process is distributing work to other processes...\n");
        
        // Send a message to each process
        for (int i = 1; i < world_size; i++) {
            char message[100];
            sprintf(message, "Task data for process %d", i);
            MPI_Send(message, strlen(message) + 1, MPI_CHAR, i, 0, MPI_COMM_WORLD);
        }
        
        // Receive results from each process
        for (int i = 1; i < world_size; i++) {
            char result[100];
            MPI_Status status;
            MPI_Recv(result, 100, MPI_CHAR, i, 0, MPI_COMM_WORLD, &status);
            printf("Received result from process %d: %s\n", i, result);
        }
        
        printf("Primary process has completed all work.\n");
    } else {
        // Worker processes wait for a message
        char message[100];
        MPI_Status status;
        MPI_Recv(message, 100, MPI_CHAR, 0, 0, MPI_COMM_WORLD, &status);
        
        printf("Process %d received: %s\n", world_rank, message);
        
        // Simulate computation
        sleep(1);
        
        // Send result back
        char result[100];
        sprintf(result, "Work completed by process %d on %s", world_rank, processor_name);
        MPI_Send(result, strlen(result) + 1, MPI_CHAR, 0, 0, MPI_COMM_WORLD);
    }

    // Finalize the MPI environment
    MPI_Finalize();
    return 0;
}