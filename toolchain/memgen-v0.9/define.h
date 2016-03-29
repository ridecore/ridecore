#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <elf.h>
#include <sys/types.h>
#include <sys/stat.h>

typedef unsigned int uint;
typedef signed long long llint;
typedef unsigned long long ullint;

typedef signed char        int008_t;
typedef signed short       int016_t;
typedef signed int         int032_t;
typedef signed long long   int064_t;
typedef unsigned char      uint008_t;
typedef unsigned short     uint016_t;
typedef unsigned int       uint032_t;
typedef unsigned long long uint064_t;

/* simloader.cc *******************************************************/
typedef struct {
    uint032_t addr;
    uint008_t data;
} memtab_t;

/**********************************************************************/
typedef enum {
    ST_NOTYPE,
    ST_FUNC,
    ST_OBJECT,
} symtype_t;

/**********************************************************************/
typedef struct {
    uint032_t addr;
    symtype_t type;
    char *name;
} symtab_t;

/**********************************************************************/
class SimLoader {
 public:
    memtab_t *memtab;
    symtab_t *symtab;
    
    int fileident;
    int filetype;
    int endian;
    int archtype;
    int dynamic;
    uint032_t entry;
    uint032_t stackptr;
    int memtabnum;
    int symtabnum;
    
    SimLoader();
    ~SimLoader();
    int loadfile(char*);
    int checkfile(const char *);
    int loadelf32(const char *);
};

/**********************************************************************/
