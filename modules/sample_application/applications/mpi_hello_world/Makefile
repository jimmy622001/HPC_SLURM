CC = mpicc
CFLAGS = -O3 -Wall
TARGET = mpi_hello_world

all: $(TARGET)

$(TARGET): mpi_hello_world.c
	$(CC) $(CFLAGS) -o $(TARGET) mpi_hello_world.c

clean:
	rm -f $(TARGET)

.PHONY: all clean