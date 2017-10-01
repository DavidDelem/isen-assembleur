ST7/

;************************************************************************
; TITLE:                
; AUTHOR:               
; DESCRIPTION:          
;************************************************************************

	TITLE "SQUELET.ASM"
	
	MOTOROLA
	
	#include "ST7Lite2.INC"

	; Enlever le commentaire si vous utilisez les afficheurs
	#include "MAX7219.INC"


;************************************************************************
;
;  ZONE DE DECLARATION DES SYMBOLES
;
;************************************************************************



;************************************************************************
;
;  FIN DE LA ZONE DE DECLARATION DES SYMBOLES
;
;************************************************************************

	
	BYTES
	
	segment byte 'ram0'

;************************************************************************
;
;  ZONE DE DECLARATION DES VARIABLES
;
;************************************************************************

compt_un DS.B 1
compt_diz DS.B 1
compte_it DS.B 1

;************************************************************************
;
;  FIN DE LA ZONE DE DECLARATION DES VARIABLES
;
;************************************************************************


        WORDS

	segment byte 'rom'

;************************************************************************
;
;  ZONE DE DECLARATION DES CONSTANTES
;
;************************************************************************




;************************************************************************
;
;  FIN DE LA ZONE DE DECLARATION DES CONSTANTES
;
;************************************************************************

;------------------------------------------------------------------------

;************************************************************************
;
;  ZONE DE DECLARATION DES SOUS-PROGRAMMES
;
;************************************************************************

init_oscRC:
RCCR0 EQU $FFDE
	LD A,RCCR0
	LD RCCR,A
	RET


init_timer:
	LD A,LTCSR1
	AND A,#%00001000
	LD LTCSR1,A
	RET


attend_500ms:
init_it
	CLR compte_it
boucle_it
	LD A,LTCSR1
	OR A,#%00010000
	LD LTCSR1,A
	LD A,compte_it
	CP A,#62 ;~(500/8)
	JRNE boucle_it
	LD A,LTCSR1
	AND A,#%11101111
	LD LTCSR1,A
	RET

init_port_spi:
	LD A,#$0C
	LD SPICR,A
	LD A,#$03
	LD SPISR,A
	LD A,#$5C
	LD SPICR,A

	LD A,PBDDR
	OR A,#%00000100
	LD PBDDR,A
	LD A,PBOR
	OR A,#%00000100
	LD PBOR,A

	RET


affiche_un:
	LD A,#4
	LD DisplayChar_Digit,A
	LD A, compt_un
	LD DisplayChar_Character,A
	CALL MAX7219_DisplayChar
	RET


affiche_diz:
	LD A,#3
	LD DisplayChar_Digit,A
	LD A, compt_diz
	LD DisplayChar_Character,A
	CALL MAX7219_DisplayChar
	RET


;************************************************************************
;
;  FIN DE LA ZONE DE DECLARATION DES SOUS-PROGRAMMES
;
;************************************************************************


;************************************************************************
;
;  PROGRAMME PRINCIPAL
;
;************************************************************************

main:
	CALL init_oscRC
	CALL init_timer
	CALL init_port_spi
	CALL MAX7219_Init
	CALL MAX7219_Clear
	RIM
	CLR A

init_compteur
	CLR compt_un
	CLR compt_diz

boucleA
	CLR compt_un
	CALL affiche_un
	CALL affiche_diz
	INC compt_diz

boucleB
	CALL affiche_un
	CALL attend_500ms

	INC compt_un
	LD X,compt_un
	CP X,#10
	JRNE boucleB

	LD X,compt_diz
	CP X,#10
	JREQ init_compteur
	JP boucleA


;************************************************************************
;
;  ZONE DE DECLARATION DES SOUS-PROGRAMMES D'INTERRUPTION
;
;************************************************************************


dummy_rt:	IRET	; Procédure vide : retour au programme principal.

timer_8ms_interrupt:
	INC compte_it
	LD A,LTCSR1
	AND A,#%11110111
	LD LTCSR1,A
	IRET

;************************************************************************
;
;  ZONE DE DECLARATION DES VECTEURS D'INTERRUPTION
;
;************************************************************************


	segment 'vectit'


		DC.W	dummy_rt	; Adresse FFE0-FFE1h
SPI_it		DC.W	dummy_rt	; Adresse FFE2-FFE3h
lt_RTC1_it	DC.W	timer_8ms_interrupt	; Adresse FFE4-FFE5h
lt_IC_it	DC.W	dummy_rt	; Adresse FFE6-FFE7h
at_timerover_it	DC.W	dummy_rt	; Adresse FFE8-FFE9h
at_timerOC_it	DC.W	dummy_rt	; Adresse FFEA-FFEBh
AVD_it		DC.W	dummy_rt	; Adresse FFEC-FFEDh
		DC.W	dummy_rt	; Adresse FFEE-FFEFh
lt_RTC2_it	DC.W	dummy_rt	; Adresse FFF0-FFF1h
ext3_it		DC.W	dummy_rt	; Adresse FFF2-FFF3h
ext2_it		DC.W	dummy_rt	; Adresse FFF4-FFF5h
ext1_it		DC.W	dummy_rt	; Adresse FFF6-FFF7h
ext0_it		DC.W	dummy_rt	; Adresse FFF8-FFF9h
AWU_it		DC.W	dummy_rt	; Adresse FFFA-FFFBh
softit		DC.W	dummy_rt	; Adresse FFFC-FFFDh
reset		DC.W	main		; Adresse FFFE-FFFFh


	END

;************************************************************************
