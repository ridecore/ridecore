/**********************************************************************
 * SimMips: Simple Computer Simulator of MIPS    Arch Lab. TOKYO TECH *
 **********************************************************************/
#include "define.h"

enum {
    FI_NONE = 0x0,
    FI_ELF = 0x1,
    FI_COFF = 0x2,
    FI_BIT32 = 0x4,
    FI_BIT64 = 0x8,
    FI_LITTLE = 0x10,
    FI_BIG = 0x20,
    FI_ELF32LSB = 0x15,
    FI_ELF32MSB = 0x25,
    FI_ELF64LSB = 0x19,
    FI_ELF64MSB = 0x29,
};

/**********************************************************************/
SimLoader::SimLoader()
{
    memtab = NULL;
    symtab = NULL;
    fileident = FI_NONE;
    filetype = 0;
    endian = 0;
    archtype = 0;
    memtabnum = 0;
    symtabnum = 0;
    entry = 0;
    stackptr = 0;
    dynamic = 0;
}

SimLoader::~SimLoader()
{
    if (memtab != NULL) {
        delete [] memtab;
        memtab = NULL;
    }
    if (symtab != NULL) {
        for (int i = 0; i < symtabnum; i++)
            delete [] symtab[i].name;
        delete [] symtab;
        symtab = NULL;
    }
}

/**********************************************************************/
int SimLoader::checkfile(const char *file)
{
    unsigned char e_ident[EI_NIDENT];
    fileident = FI_NONE;

    /* read magic */
    memcpy(e_ident, file, EI_NIDENT);
    if (e_ident[EI_MAG0] != ELFMAG0 || e_ident[EI_MAG1] != ELFMAG1 ||
        e_ident[EI_MAG2] != ELFMAG2 || e_ident[EI_MAG3] != ELFMAG3) {
        fprintf(stderr, "## ERROR: file is not ELF format.");
        return(1);
    }
    fileident |= FI_ELF;
    
    /* check class */
    switch (e_ident[EI_CLASS]) {
    case ELFCLASS32:
        fileident |= FI_BIT32;
        break;
    case ELFCLASS64:
        fileident |= FI_BIT64;
        fprintf(stderr, "## ERROR: ELF64 is not supported.");
        return(1);
        break;
    case ELFCLASSNONE:
    default:
        fprintf(stderr, "## ERROR: ELFCLASS none.");
        return(1);
        break;
    }
    
    /* check endian */
    switch (e_ident[EI_DATA]) {
    case ELFDATA2LSB:
        fileident |= FI_LITTLE;
        break;
    case ELFDATA2MSB:
        fileident |= FI_BIG;
        break;
    case ELFDATANONE:
    default:
        fprintf(stderr, "## ERROR: ELFDATA none.");
        return(1);
        break;
    }
    return(0);
}

/**********************************************************************/
int SimLoader::loadelf32(const char *file)
{
    Elf32_Ehdr *ehdr;
    Elf32_Shdr *shdr, *shstr, *str = NULL, *sym = NULL;
    Elf32_Sym *symp;
    
    /* read ELF Header */
    ehdr = (Elf32_Ehdr *)file;
    filetype = ehdr->e_type;
    archtype = ehdr->e_machine;
    entry = ehdr->e_entry;
    
    /* read Section Header */
    memtabnum = 0;
    shstr = (Elf32_Shdr *)(file + ehdr->e_shoff +
                           ehdr->e_shentsize * ehdr->e_shstrndx);
    for (int i = 0; i < ehdr->e_shnum; i++) {
        shdr = (Elf32_Shdr *)(file + ehdr->e_shoff +
                              ehdr->e_shentsize * i);
        char *sname = (char *)(file + shstr->sh_offset + shdr->sh_name);
        if (strcmp(sname, ".strtab") == 0)
            str = shdr;
        if (strcmp(sname, ".stack") == 0)
            stackptr = shdr->sh_addr;
        if (shdr->sh_type == SHT_SYMTAB)
            sym = shdr;
        if (shdr->sh_type == SHT_DYNAMIC)
            dynamic = 1;
        if (shdr->sh_flags & SHF_ALLOC) {
            memtabnum += shdr->sh_size;
        }
    }
    
    /* read Symbol table */
    symtabnum = 0;
    if (sym) {
        for (unsigned int i = 0; i < sym->sh_size / sym->sh_entsize; i++) {
            symp = (Elf32_Sym *)(file + sym->sh_offset +
                                 sym->sh_entsize * i);
            if (!symp->st_name)
                continue;
            symtabnum++;
        }
    }

    /* write to memtab */
    memtab = new memtab_t[memtabnum];
    int count = 0;
    for (int i = 0; i < ehdr->e_shnum; i++) {
        shdr = (Elf32_Shdr *)(file + ehdr->e_shoff +
                              ehdr->e_shentsize * i);
        if (shdr->sh_flags & SHF_ALLOC) {
            for(unsigned int j = 0; j < shdr->sh_size; j++) {
                memtab[count].addr = shdr->sh_addr + j;
                memtab[count].data = (shdr->sh_type & SHT_NOBITS) ? 0 :
                    *(uint008_t *)(file + shdr->sh_offset + j);
                count++;
            }
        }
    }
    
    /* write to symtab */
    if ((!sym) || (!str))
        return(0);

    symtab = new symtab_t[symtabnum];
    count = 0;
    for (unsigned int i = 0; i < sym->sh_size / sym->sh_entsize; i++) {
        symp = (Elf32_Sym *)(file + sym->sh_offset +
                             sym->sh_entsize * i);
        if (!symp->st_name)
            continue;
        if (ELF32_ST_TYPE(symp->st_info) == STT_FUNC)
            symtab[count].type = ST_FUNC;
        else if (ELF32_ST_TYPE(symp->st_info) == STT_OBJECT)
            symtab[count].type = ST_OBJECT;
        else
            symtab[count].type = ST_NOTYPE;
        symtab[count].addr = symp->st_value;
        char *symname = (char *)(file + str->sh_offset + symp->st_name);
        int symlen = strlen(symname) + 1;
        symtab[count].name = new char[symlen];
        strncpy(symtab[count].name, symname, symlen);
        count++;
    }
    return(0);
}

/**********************************************************************/
int SimLoader::loadfile(char *filename)
{
    int fd = 0;
    struct stat sb;
    char *file;
    
    /* open and read file */
    fd = open(filename, O_RDONLY);
    if (fd == -1) {
        fprintf(stderr, "## ERROR: Can't open file. (%s)\n", filename);
        return(1);
    }
    fstat(fd, &sb);
    file = new char[sb.st_size];
    if (read(fd, file, sb.st_size) < sb.st_size) {
        fprintf(stderr, "## ERROR: Can't read file. (%s)\n", filename);
        return(1);
    }
    close(fd);
    if (checkfile(file))
        return(1);
    
    switch (fileident) {
    case FI_ELF32LSB:
        if (loadelf32(file))
            return(1);
        endian = FI_LITTLE;
        break;
    default:
        fprintf(stderr, "## ERROR: non supported file type.\n");
        return(1);
        break;
    }
    delete [] file;
    file = NULL;
    return(0);
}

/**********************************************************************/
