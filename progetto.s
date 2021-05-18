.section .rodata
filename: .asciz "informazione.dat"
read_mode: .asciz "r"
write_mode: .asciz "w"
fmt_menu_title:    
    .ascii "\t ____            _                       \n"
    .ascii "\t|    \\ _ _ ___ _| |___ ___               \n"
    .ascii "\t|  |  | | |   | . | -_|  _|              \n"
    .ascii "\t|____/|___|_|_|___|___|_|                \n"
    .ascii "                                         \n"
    .ascii "\t _____ _ ___ ___ _ _        _ _     _    \n"
    .ascii "\t|     |_|  _|  _| |_|___   | | |_ _| |   \n"
    .ascii "\t| | | | |  _|  _| | |   |  | |  _| . |_  \n"
    .asciz "\t|_|_|_|_|_| |_| |_|_|_|_|  |_|_| |___|_| \n\n"

fmt_menu_line:
    .asciz "+----+---------------------------------+-----------+-----------+-----------------+\n"
fmt_menu_header:
    .asciz "|  # | NOME                            | QUANTITA` | SPESSORE  | PREZZO UNITARIO |\n"
fmt_menu_entry:
    .asciz "|%3d | %-32s|  %-8d |  %-8d | %-8d        |\n"


fmt_menu_options:
    .ascii "\n1: Aggiungi ordine\n"
    .ascii "2: Elimina ordine\n"
    .ascii "3: Calcola prezzo unitario medio\n"
    .ascii "4: Calcola valore complessivo magazzino\n"
    .ascii "5: Calcola quantita' totale ordini\n"
    .ascii "6: Calcola spessore medio\n"
    .ascii "7: Mostra ordini con quantita' maggiori di\n"

    .ascii "8: Mostra ordini con quantita' minori di\n"
    .ascii "9: Mostra dundies del 2021\n"
    .asciz "0: Esci\n"

fmt_prezzo_medio_double: .asciz "\nPrezzo medio: %.2f\n\n"

fmt_scan_int: .asciz "%d"
fmt_scan_str: .asciz "%127s"

fmt_prompt_menu: .asciz "> "
.align 2

.data
n_orders: .word 3

.equ max_orders, 10

.equ size_order_name, 32
.equ size_order_quantity, 4
.equ size_order_thickness, 4
.equ size_order_unit_price, 4

.equ offset_order_name, 0
.equ offset_order_quantity, offset_order_name + size_order_name
.equ offset_order_thickness, offset_order_quantity + size_order_quantity
.equ offset_order_unit_price, offset_order_thickness + size_order_thickness
.equ order_size_aligned, 48


                          //                        |          |         |         |   |
                          // 1 11111111122222222223333   3 3 3 3   3 3 4 4   4 4 4 444
                  //1234567890 12345678901234567890123   4 5 6 7   8 9 0 1   2 3 4 56789
test_order: .asciz "nome test\0                      \x24\0\0\0\x04\0\0\0\x1c\0\0\0\0\0\0"
orders: .asciz "nome test\0                      \x24\0\0\0\x04\0\0\0\x1c\0\0\0\0\0\0" 
        .asciz "risma di carta lucida\0          \x34\0\0\0\x10\0\0\0\x05\0\0\0\0\0\0" 
        .asciz "nome test\0                      \x1A\0\0\0\x08\0\0\0\xF3\0\0\0\0\0\0" 
        .skip order_size_aligned * (max_orders -3)


.bss
tmp_str: .skip 128
tmp_int: .skip 8



.macro read_int prompt
    adr x0, \prompt
    bl printf

    adr x0, fmt_scan_int
    adr x1, tmp_int
    bl scanf

    ldr x0, tmp_int
.endm

.macro read_str prompt
    adr x0, \prompt
    bl printf

    adr x0, fmt_scan_str
    adr x1, tmp_str
    bl scanf
.endm


.text
.type main, %function
.global main
main:
    stp x29, x30, [sp, #-16]!



    adr x0, fmt_menu_title  // logo della compagnia
    bl printf


    # load data from file
    menu_loop:
        bl print_menu

        read_int fmt_prompt_menu

        cmp x0, #0
        beq end_menu_loop
        

        cmp x0, #1
        bne no_aggiungi_ordine
        #bl aggiungi_ordine
        no_aggiungi_ordine:

        cmp x0, #2
        bne no_rimuovi_ordine
        #bl rimuovi_ordine
        no_rimuovi_ordine:

        cmp x0, #3
        bne no_prezzo_unitario_medio
        #bl prezzo_unitario_medio
        no_prezzo_unitario_medio:

        cmp x0, #4
        bne no_valore_complessivo_magazino
        #bl valore_complessivo_magazino
        no_valore_complessivo_magazino:

        cmp x0, #5
        bne no_quantita_totale_ordini
        #bl quantita_totale_ordini
        no_quantita_totale_ordini:

        cmp x0, #6
        bne no_spessore_medio
        #bl spessore_medio
        no_spessore_medio:

        cmp x0, #7
        bne no_filtro_maggiore_di
        #bl filtro_maggiore_di
        no_filtro_maggiore_di:

        cmp x0, #8
        bne no_filtro_minore_di
        #bl filtro_minore_di
        no_filtro_minore_di:

        cmp x0, #9
        bne no_mostra_dundies
        //bl dundies
        no_mostra_dundies:


        b menu_loop
    end_menu_loop:


    mov w0, #0
    ldp x29, x30, [sp], #16
    ret
    .size main, (. - main)



.type print_menu, %function
print_menu:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    str x21, [sp, #-8]!
    
    adr x0, fmt_menu_line       // linea separatrice
    bl printf
    adr x0, fmt_menu_header     // intestazione tabella
    bl printf
    adr x0, fmt_menu_line
    bl printf

    //inizio del corpo della tabella
    mov w19, #0
    ldr w20, n_orders
    adr x21, orders    
    print_orders_loop:
        cmp w19, w20
        bge end_print_orders_loop
 
        adr x0, fmt_menu_entry
        add x1, x19, #1
        add x2, x21, offset_order_name
        ldr w3, [x21, offset_order_quantity]
        ldr w4, [x21, offset_order_thickness]
        ldr w5, [x21, offset_order_unit_price]
        bl printf

        add w19, w19, #1
        add x21, x21, order_size_aligned
        b print_orders_loop
    end_print_orders_loop:
    //fine del corpo della tabella

    adr x0, fmt_menu_line
    bl printf

    adr x0, fmt_menu_options
    bl printf
    
    ldr x21, [sp], #8
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size print_menu, (. - print_menu)
