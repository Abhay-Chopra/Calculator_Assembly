// Global Variables

// Defining macros
define(argc_r, w19)
define(argv_r, x20)
define(temp_r, w23)
define(pn, x24)
define(fd, w25)

define(openat, 56)
define(close, 57)
define(FDCWD, -100)
// Assembler Equates
buf_size = 8
alloc = -(16 + buf_size) & -16
dealloc = -alloc
buf_s = 16

        .text
err:    .string "Invalid number of arguments\n"  
file_open_err: .string "Cannot open file!\n"
file_open: .string "Opened File: %s\n"

        .text
        .balign 4
        .global main
main:   stp     x29, x30, [sp, alloc]!
        mov     x29, sp 

        mov     argc_r, w0
        mov     argv_r, x1

        cmp     argc_r, 2
        b.ne    err_exit

        mov     temp_r, 1

        mov     w0, FDCWD
        ldr     x1, [argv_r, 8]

        mov     w2, 0       // Read Only
        mov     w3, 0       // Not used
        mov     x8, openat  // openat I/O request
        svc     0

        cmp     w0, 0
        b.ge    open

        // Handling File errors
        adrp    x0, file_open_err                             
        add     x0, x0, :lo12:file_open_err
        bl      printf
        mov     w0, -1
        b       exit

open:
        adrp    x0, file_open
        add     x0, x0, :lo12:file_open
        ldr     x1, [argv_r, 8]     
        bl      printf
read:
        // fd in in w0
        mov     fd, w0
        add     x1, x29, buf_s
        mov     x2, buf_size
        mov     x8, 63
        svc     0

        // n_read is in x0

file_close:
        mov     w0, fd
        mov     x8, close
        svc     0
        // status is in w0
        b       exit

err_exit:
        adrp    x0, err                             
        add     x0, x0, :lo12:err
        bl      printf

exit:
        ldp     x29, x30, [sp], dealloc
        ret
