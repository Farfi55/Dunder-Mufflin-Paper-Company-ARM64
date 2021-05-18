.section .rodata
filename: .asciz "informazione.dat"
read_mode: .asciz "r"
write_mode: .asciz "w"
fmt_menu_title:    
    .ascii "\t ____            _                       \n"
    .ascii "\t|    \\ _ _ ___ _| |___ ___               \n"
    .ascii "\t|  |  | | |   | . | -_|  _|              \n"
    .ascii "\t|____/|___|_|_|___|___|_|                \n"
    .ascii "                                           \n"
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




fmt_prezzo_medio: .asciz "\nPrezzo unitario medio: %.2f\n\n"

fmt_printf_val_storage: .asciz "Il valore complessivo magazino è: %d€\n\n"

fmt_num_int: .asciz "Inserire il filtro di ricerca (maggione di questa quantità): "

fmt_scan_int: .asciz "%d"
fmt_scan_str: .asciz "%127s"

fmt_prompt_menu: .asciz "> "

fmt_name: .asciz "Ordine: "
fmt_quantity: .asciz "Quantita': "
fmt_thickness: .asciz "Spessore: "
fmt_unit_price: .asciz "Prezzo unitario: "
fmt_fail_add_order: .asciz "Errore: ci sono troppi ordini!"
.align 2

.data
n_orders: .word 0

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

.bss
tmp_str: .skip 128
tmp_int: .skip 8
orders: .skip order_size_aligned * max_orders    //"Scatola" che andiamo a riempire con i dati

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


.macro save_to position, offset, size           //usiamo un alias di memcpy per copiare la stringa in fmt_str nell'array
    add x0, \position, \offset                 
    ldr x1, =tmp_str                            
    mov x2, \size
    bl strncpy

    add x0, \position, \offset + \size - 1
    strb wzr, [x0]                         
.endm



.macro read_orders, records_to_read, FILE
    ldr x0, =orders
    mov x1, order_size_aligned
    mov x2, \records_to_read
    mov x3, \FILE
    bl fread
.endm



//macro per leggere un int e salvarlo sulla variabile temporanea per poi essere letta
.macro scan_filter n
    adr x0, fmt_scan_int
    adr x1, \n
    bl scanf
.endm


.macro open_read_file, FILE
adr x0, filename
adr x1, read_mode
bl fopen
mov \FILE, x0
.endm

// legge i primi 4 byte del file, che indicano il numero di ordini a seguire
.macro read_n_orders, FILE
adr x0, n_orders // carichiamo l'indirizzo della variabile
mov x1, #4      // leggiamo 4 bytes
mov x2, #1      // 1 volta
mov x3, \FILE    
bl fread        // leggiamo i 4 bytes e li inseriamo nell'indirizzo di n_orders 
.endm


//macro da chiamare una volta finito di leggere o scrivere sul file
.macro finish_read, FILE
mov x0, \FILE
bl fclose
.endm


// 3 macro per facilitare il print degli ordini
.macro print_table_header
    print_table_line
    adr x0, fmt_menu_header     
    bl printf
    print_table_line
.endm


.macro print_menu_options
    adr x0, fmt_menu_options    
    bl printf
.endm

.macro print_table_line
    adr x0, fmt_menu_line       
    bl printf
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
        bl print_orders
    skip_print_orders:

        // mostra tutte le possibili opzioni es: 0: esci, 1 aggiungi
        print_menu_options

        read_int fmt_prompt_menu

        cmp x0, #0
        beq end_menu_loop
        

        cmp x0, #1
        bne no_aggiungi_ordine
        bl aggiungi_ordine
        
        no_aggiungi_ordine:

        cmp x0, #2
        bne no_rimuovi_ordine
            #bl rimuovi_ordine
        no_rimuovi_ordine:

        cmp x0, #3
        bne no_prezzo_unitario_medio
            bl prezzo_unitario_medio
        no_prezzo_unitario_medio:

        cmp x0, #4
        bne no_valore_complessivo_magazino
            bl valore_complessivo_magazino
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

            mov x0, #1 
            bl filtro_quantita

            b skip_print_orders
        no_filtro_maggiore_di:

        cmp x0, #8
        bne no_filtro_minore_di
            mov x0, #0
            bl filtro_quantita

            b skip_print_orders
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



.type print_orders, %function
print_orders:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    str x21, [sp, #-8]!
    
    // intestazione tabella
    print_table_header

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

    
    
    ldr x21, [sp], #8
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size print_orders, (. - print_orders)



// OPZIONE 3 - 4
.type prezzo_unitario_medio, %function
.global prezzo_unitario_medio
prezzo_unitario_medio:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!

    mov x1, xzr                             //Azzeriamo il registro (flaot) d1

    ldr w0, n_orders                        //Carichiamo il valore di n_orders in x0
    mov x2, x0                              

    adr x3, orders                          //Inseriramo l'indirizzo di orders nel registro x3
    add x3, x3, offset_order_unit_price     //Sommiamo l'indirizzo precedentemente ottenuto con la posizione del dato da ottenere 

    loop_media:
        sub x2, x2, #1                      //Sottraiamo 1 dal numero di record rimasti nel registro x2 

        ldr x4, [x3]                        //Carichiamo il valore con l'offset precedentemente calcolato e lo inseriamo nel registro x4
        add x1, x1, x4                      //Sommiamo i valori
        add x3, x3, order_size_aligned      //Carichiamo l'offset del prossimo valore da leggere

        cbnz x2, loop_media                  //Se il numero contenuto in x2 == 0 allora esci dal loop

    
    ucvtf d1, x0                            //Convertiamo il valore contenuto in x0 in float
    ucvtf d2, x1                            //Convertiamo il valore contenuto in x0 in float
    fdiv d0, d2, d1                         //Calcoliamo la media

    adr x0, fmt_prezzo_medio                //Stampiamo a video la media
    bl printf

    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16

    ret
.size prezzo_unitario_medio, (. - prezzo_unitario_medio)


.type valore_complessivo_magazino, %function
.global valore_complessivo_magazino
valore_complessivo_magazino:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!

    mov x1, xzr

    ldr w0, n_orders                        //Carichiamo il valore di n_orders in x0
    mov x2, x0                              

    adr x3, orders                          //Inseriramo l'indirizzo di orders nel registro x3

    add x6, x3, offset_order_quantity       //Sommiamo l'indirizzo precedentemente ottenuto con la posizione del dato da ottenere 
    add x3, x3, offset_order_unit_price     //Sommiamo l'indirizzo precedentemente ottenuto con la posizione del dato da ottenere 

    loop_valore_complessivo:
        sub x2, x2, #1                      //Sottraiamo 1 dal numero di record rimasti nel registro x2 

        ldr x4, [x3]                        //Carichiamo il valore con l'offset precedentemente calcolato e lo inseriamo nel registro x4
        ldr x5, [x6]                        //Carichiamo il valore con l'offset precedentemente calcolato e lo inseriamo nel registro x5

        mul x5, x4, x5                      //Moltiplichiamo il numero dei prodotti per il prezzo e lo salviamo nel registro x5
        add x1, x1, x5                      //Sommiamo il risultato con i valori precendenti 
        
        add x3, x3, order_size_aligned      //Carichiamo l'offset del prossimo valore da leggere
        add x6, x6, order_size_aligned      //Carichiamo l'offset del prossimo valore da leggere

        cbnz x2, loop_valore_complessivo    //Se il numero contenuto in x2 == 0 allora esci dal loop


    adr x0, fmt_printf_val_storage          //Stampiamo a video la media
    bl printf

    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16

    ret
.size valore_complessivo_magazino, (. - valore_complessivo_magazino)

// OPZIONE 7 - 8

// se c'e' 1 su x0 mostra solo gli ordini con 
// x0 == 1: quantita maggiore
// x0 == 0: quantita minore
.type filtro_quantita, %function
.global filtro_quantita
filtro_quantita:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
/*  non c'e' bisogno di leggere\scrivere il file se non si apportano modifiche

    adr x0, filename
    adr x1, read_mode
    bl fopen

    cmp x0, #0
    beq end

    mov x19, x0
    read_n_orders
    ldr w20, n_ord
    read_orders
    mov w21, #0
*/


    //salvo la scelta tra maggiore o minore su x23, per riepilogare
    // x0 == 1: mostra ordini con quantita maggiore
    // x0 == 0: mostra ordini con quantita minore
    mov x23, x0  


    adr x0, fmt_num_int
    bl printf
    scan_filter tmp_int
    ldr x22, tmp_int    // x = input("filtra ordini con quantita >= di: ")
    

    // intestazione tabella
    print_table_header

    ldr w20, n_orders
    // inizio della tabella filtrata
    filtro_quantita_loop:
        cmp w21, w20
        beq end_filtro_quantita

        adr x0, orders
        ldr w1, =order_size_aligned
        madd x0, x1, x21, x0

        // quantita = ordini[i].quantita        
        ldr w2, [x0, offset_order_quantity]

        add w21, w21, #1 //incremento i prima


        cbz x23, filtro_minore_di // se x23 == 0

        filtro_maggiore_di:
        cmp x2, x22
        blt filtro_quantita_loop // se la quantita' e' minore, saltiamo l'ordine
            b filter_print_order

        filtro_minore_di:
        cmp x2, x22
        bgt filtro_quantita_loop // se la quantita' e' maggiore, saltiamo l'ordine

        filter_print_order:
            mov w1, w21            
            add x2, x0, offset_order_name
            ldr w3, [x0, offset_order_quantity]
            ldr w4, [x0, offset_order_thickness]
            ldr w5, [x0, offset_order_unit_price]
            adr x0, fmt_menu_entry
            bl printf
        
        b filtro_quantita_loop    

    end_filtro_quantita:

    adr x0, fmt_menu_line       
    bl printf

    mov w0, #0
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size filtro_quantita, (. - filtro_quantita)

.type aggiungi_ordine, %function
aggiungi_ordine:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!

    ldr x19, n_orders           //Numero di item presenti 
    adr x20, orders             //Indirizzo dell'array
    mov x0, order_size_aligned  
    mul x0, x19, x0             //Calcoli la grandezza array (al momento della chiamata)                    
    add x20, x20, x0            //Punti l'indirizzo dove cominciare ad inserire i dati

    cmp x19, max_orders
    bge fail_add_order         //Se l'array e' pieno

        read_str fmt_name
        save_to x20, offset_order_name, size_order_name

        read_int fmt_quantity
        str w0, [x20, offset_order_quantity]

        read_int fmt_thickness
        str w0, [x20, offset_order_thickness]

        read_int fmt_unit_price
        str w0, [x20, offset_order_unit_price]
    
        add x19, x19, #1
        adr x20, n_orders
        str x19, [x20]

        //bl save_data  !!!

        b end_add_order

fail_add_order:
adr x0, fmt_fail_add_order
bl printf

end_add_order:

ldp x19, x20, [sp], #16
ldp x29, x30, [sp], #16
ret
.size add_order, (. - aggiungi_ordine)
        
