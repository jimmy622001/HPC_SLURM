CC = gcc
CFLAGS = -O3 -Wall -fopenmp
TARGET = openmp_example

all: $(TARGET)

$(TARGET): openmp_example.c
	$(CC) $(CFLAGS) -o $(TARGET) openmp_example.c

clean:
	rm -f $(TARGET)

.PHONY: all clean