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
    .asciz "%3d %-10s %-20s %-20s %8d\n" #DA CAMBIARE

fmt_prezzo_medio_double: .asciz "\nPrezzo medio: %.2f\n\n"

fmt_scan_int: .asciz "%d"
fmt_scan_str: .asciz "%127s"

fmt_prompt_menu: .asciz "> "
.align 2

.data
n_orders: .word 0

.equ max_orders, 10

.equ order_size_aligned, 64

.bss
tmp_str: .skip 128
tmp_int: .skip 8
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
