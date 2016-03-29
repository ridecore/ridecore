######################################################################
# MieruEMB System V1.0  2011-10-01                Arch Lab. TOKYO TECH
######################################################################

TARGET   = init
OBJS = startup.o main.o
#CMDPREF = /home/share/cad/mipsel-emb/usr/bin/
CMDPREF = 

MIPSCC  = $(CMDPREF)riscv64-unknown-elf-gcc
MIPSAS  = $(CMDPREF)riscv64-unknown-elf-as
MIPSLD  = $(CMDPREF)riscv64-unknown-elf-ld
OBJDUMP = $(CMDPREF)riscv64-unknown-elf-objdump
MEMGEN  = memgen

CFLAGS  = -m32 -O2
AFLAGS  = -m32
LFLAGS  = -static -melf32lriscv

.SUFFIXES:
.SUFFIXES: .o .c .S
######################################################################
all:
	$(MAKE) $(TARGET)
	$(MAKE) image

$(TARGET): $(OBJS)
	$(MIPSLD) $(LFLAGS) -T stdld.script $(OBJS) -o $(TARGET)

.c.o:
	$(MIPSCC) $(CFLAGS) -c $(@D)/$(<F) -o $(@D)/$(@F)

.S.o:
	$(MIPSAS) $(AFLAGS) $(@D)/$(<F) -o $(@D)/$(@F)

image:
	$(MEMGEN) -b $(TARGET) 8 > $(TARGET).bin

dump:
	$(OBJDUMP) -S $(TARGET)

copy:
	cp init.bin ../../bin

read:
	readelf -a $(TARGET)

clean:
	rm -f *.o *~ log.txt $(TARGET) $(TARGET).bin
######################################################################
