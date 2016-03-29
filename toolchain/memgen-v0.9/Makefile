SOURCE = main.cc simloader.cc
HEADER = define.h
TARGET = memgen
CC     = g++
OPT    = -O2 -Wall

all: $(SOURCE) $(HEADER) Makefile
	$(CC) $(OPT) $(SOURCE) -o $(TARGET)

%.bin: %
	./$(TARGET) -b $< 52 > $@

clean:
	rm -f *.*~ *.exe $(TARGET)
