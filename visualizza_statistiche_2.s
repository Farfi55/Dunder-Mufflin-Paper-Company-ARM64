#bl quantita_totale_ordini
#bl valore_totale_magazzino

.section .rodata

.text

.macro open_read_file
adr x0, filename
adr x1, read_mode
bl fopen
mov x22, x0
.endm



.macro read_n_orders
ldr x0, =n_orders
mov x1, #4
mov x2, #1
mov x3, x22
bl fread
.endm



.macro read_orders
ldr x0, =orders
mov x1, order_size_aligned
mov x2, max_orders
mov x3, x22
bl fread
.endm



.macro finish_reading
mov x0, x22
bl fclose
.endm


//------------------------------------------------------------------------------------
 .type quantita_totale_ordini, %function
 .global quantita_totale_ordini

 quantita_totale_ordini:
    stp x29, x30, [sp, #-16]!

    open_read_file
    read_n_orders



    
    read_orders
    finish_reading



    ldp x29, x30, [sp], #16
    ret
    .size quantita_totale_ordini, (. - quantita_totale_ordini)
//-------------------------------------------------------------------------------------









//------------------------------------------------------------------------------------
 .type valore_totale_magazzino, %function
 .global valore_totale_magazzino

 valore_totale_magazzino:



 .size valore_totale_magazzino, (. - valore_totale_magazzino)
//-------------------------------------------------------------------------------------
