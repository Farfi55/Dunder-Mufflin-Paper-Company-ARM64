.section .rodata
filename: .asciz "informazione.dat"
read_mode: .asciz "r"
write_mode: .asciz "w"
fmt_menu_title:
    .ascii "\n"
    .ascii "NOME COMPAGNIA YUPPIE YE\n"
    .asciz "\n"


fmt_menu_line:
    .asciz "--------------------------------------------------------------------\n"
fmt_menu_header:
    .asciz "  # NOME          QUANTITA`   SPESSORE    PREZZO UNITARIO\n"
fmt_menu_entry:
    .asciz "%3d %-32s %-8d %-8d %-8d\n" #DA CAMBIARE

fmt_prezzo_medio_double: .asciz "\nPrezzo medio: %.2f\n\n"

fmt_scan_int: .asciz "%d"
fmt_scan_str: .asciz "%127s"

fmt_prompt_menu: .asciz "> "
.align 2

.data
n_orders: .word 0

.equ max_orders, 10

.equ size_order_name, 32
.equ size_order_quantity, 36
.equ size_order_THICCness, 40
.equ size_order_unit_price, 44
.equ order_size_aligned, 48

.bss
tmp_str: .skip 128
tmp_int: .skip 8
                          //                        |          |         |         |   |
                          // 1 11111111122222222223333   3 3 3 3   3 3 4 4   4 4 4 444
                  //1234567890 12345678901234567890123   4 5 6 7   8 9 0 1   2 3 4 567890
test_order: .asciz "nome test\0                      \x24\0\0\0\x04\0\0\0\x1c\0\0\0"

orders: .skip order_size_aligned * max_orders


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


    # load data from file
    menu_loop:
        # bl print_menu

        read_int fmt_prompt_menu

        cmp x0, #0
        beq end_main_loop
        

        cmp x0, #1
        bne no_aggiungi_ordine
        #bl aggiungi_ordine
        no_aggiungi_ordine

        cmp x0, #2
        bne no_rimuovi_ordine
        #bl 
        no_rimuovi_ordine

        cmp x0, #3
        bne no_visualizza_statistiche_1
        #bl prezzo_medio_unitario
        #bl valore_complessivo_magazino
        no_visualizza_statistiche_1

        cmp x0, #3
        bne no_visualizza_statistiche_2
        #bl quantita_totale_ordini
        #bl spessore_medio
        no_visualizza_statistiche_2

        cmp x0, #4
        bne no_filtro_maggiore_di
        #bl filtro_maggiore_di
        no_filtro_maggiore_di

        cmp x0, #5
        bne no_filtro_minore_di
        #bl filtro_minore_di
        no_filtro_minore_di




        b menu_loop
    end_menu_loop:


    mov w0, #0
    ldp x29, x30, [sp], #16
    ret
    .size main, (. - main)
