// Global Variables

// Defining macros









// Assembler Equates
buf_size = 8
alloc = -(16 + buf_size) & -16
dealloc = -alloc
buf_s = 16

        .text
err:    .string "Invalid number of arguments\n"  
file_open_err: .string "Cannot open file!\n"
file_open: .string "Opened File: %s\n"
file_close_str: .string "Closed File: %s\n"
        .text
        .balign 4
        .global main
main:   stp     x29, x30, [sp, alloc]!
        mov     x29, sp 

        mov     w19, w0
        mov     x20, x1

        cmp     w19, 2
        b.ne    err_exit

        mov     w23, 1

        mov     w0, -100
        ldr     x1, [x20, w23, SXTW 3]

        mov     w2, 0       // Read Only
        mov     w3, 0       // Not used
        mov     x8, 56  // 56 I/O request
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
        // w25 in in w0
        mov     w25, w0

        adrp    x0, file_open
        add     x0, x0, :lo12:file_open
        ldr     x1, [x20, w23, SXTW 3]     
        bl      printf
read:
        mov     w0, w25
        add     x1, x29, buf_s
        mov     x2, buf_size
        mov     x8, 63
        svc     0

        // x24 is in x0
        mov     x24, x0
        cmp     x24, buf_size
        b.ne    file_close
        

        // Ready to read next 8 bytes
        b       read

file_close:
        mov     w0, w25
        mov     x8, 57
        svc     0
        // status is in w0
        adrp    x0, file_close_str
        add     x0, x0, :lo12:file_close_str
        ldr     x1, [x20, 8]     
        bl      printf
        b       exit

err_exit:
        adrp    x0, err                             
        add     x0, x0, :lo12:err
        bl      printf

exit:
        ldp     x29, x30, [sp], dealloc
        ret
