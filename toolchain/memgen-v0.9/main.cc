/*************************************************************************/
/* MEMGEN: Memory Image Generator Version 0.9.1      ArchLab. TOKYO TECH */
/*************************************************************************/
#include "define.h"

/*************************************************************************/
void usage()
{
    fprintf(stderr, 
            " MEMGEN: Memory Image Generator Version 0.9 (2013-09-03)\n"
            " Usage: ./memgen [-8b] object-file-name memory-size[KB]"
            " > output-file-name\n"
            "  -8: comma insertion every 8bit instead of 32bit\n"
            "  -b: generate binary memory image file instead of COE.\n");
}

/*************************************************************************/
int main (int argc, char **argv)
{
    int write_bin = 0, write_8b = 0;

    if (argc == 4) {
        if (strcmp("-b", argv[1]) == 0) {
            write_bin = 1;
        } else if (strcmp("-8", argv[1]) == 0) {
            write_8b = 1;
        } else {
            usage();
            return 0;
        }
    } else if (argc != 3) {
        usage();
        return 0;
    }
    
    int mem_depth = atoi(argv[2 + write_bin + write_8b]) << 10;

    uint008_t buf[mem_depth];
    for (int i = 0; i < mem_depth; i++) buf[i] = 0;
    
    SimLoader *ld = new SimLoader();

    if (ld->loadfile(argv[1 + write_bin + write_8b])) return 1;

    if (/*(ld->archtype != EM_MIPS) ||*/
        (ld->filetype != ET_EXEC)) { // || (ld->dynamic)) {
        fprintf(stderr, "## ERROR: inproper binary: %s\n", argv[1]);
        return 1;
    }
    
    for (int i = 0; i < ld->memtabnum; i++) {
        if (ld->memtab[i].addr > (uint032_t)(mem_depth - 1)) {
            fprintf(stderr, "## Error!!\n");
            fprintf(stderr, "## mem_size %d, required mem is %d.\n",
		    mem_depth, ld->memtabnum);
            fprintf(stderr, "## Please Enlarge file-size.\n");
            exit(1);
            break;
        } else {
            buf[ld->memtab[i].addr] = ld->memtab[i].data;
        }
    }
    delete ld;
    
    if (write_bin) {
        fwrite(buf, sizeof(uint008_t), mem_depth, stdout);
    } else {
        puts("MEMORY_INITIALIZATION_RADIX=16;");
        puts("MEMORY_INITIALIZATION_VECTOR=");
        for (int i = 0; i < mem_depth; i += 4) {
            if (write_8b) {
                printf("%02x,%02x,%02x,%02x%c",
                       buf[i], buf[i + 1], buf[i + 2], buf[i + 3],
                       (i == (mem_depth - 4)) ? ';' : ',');
            } else {
                printf("%02x%02x%02x%02x%c",
                       buf[i + 3], buf[i + 2], buf[i + 1], buf[i],
                       (i == (mem_depth - 4)) ? ';' : ',');
            }
            if (write_8b && i % 32 == 12)
                puts("");
            if (i % 32 == 28)
                puts("");
        }
    }

    return 0;
}
/*************************************************************************/
