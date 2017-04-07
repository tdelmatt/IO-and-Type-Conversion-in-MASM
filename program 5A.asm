;Taylor Del Matto
;CS 271-400
;Program #5A
;8/10/2015
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Description: This program obtains 10 integers from the user, and converts these from 
;string to numeric using readVal, then stores these values in an array
;the values are converted back into strings using writeval, and are then displayed 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Extra credit options 1 and 3 have been successfully completed
; the user input is numbered, subtotal is displayed, and ReadVal and WriteVal procedures
;are recursive
;**EC: 1) number input display running subtotal COMPLETE SEE PROGRAM OUTPUT
;**EC: 3) make your ReadVal and WriteVal procedures recursive COMPLETE SEE PROGRAM OUTPUT 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

INCLUDE Irvine32.inc

getString macro keyIn, prompt1
	push edx
	push ecx
	push esi

	mov edx, prompt1
	call writestring
	mov edx, keyIn
	mov ecx, 100
	call readstring

	pop esi
	pop ecx
	pop edx
ENDM

displayString macro disaddress
	push edx
	mov edx, disaddress
	call writestring
	pop edx
ENDM

countLine macro usintotal1
	push eax
	add usintotal, 1
	mov eax, usintotal
	call writedec
	pop eax
ENDM

MAXSIZE = 100
.data
	stringIn BYTE MAXSIZE DUP(?)
	prompt1 BYTE " Please enter an unsigned number: ", 0
	prompt2 BYTE "Error INVALID ENTRY!", 0
	numberarray dword 10 DUP(0)
	totalN DWORD 0
	currentN DWORD 0
	count1 DWORD 0
	stringOut BYTE MAXSIZE DUP(?)
	count2 DWORD 0
	prompt3 BYTE "Running subtotal is ", 0
	subtotal DWORD 0
	usintotal DWORD 0
	prompt4 BYTE ": ", 0
	prompt5 BYTE "You entered the following numbers: ", 0
	prompt6 BYTE ", ", 0
	prompt7 BYTE "The sum of these numbers is: ", 0
	prompt8 BYTE "The average is: ", 0
	prompt9 BYTE "Thanks for playing", 0
	prompt10 BYTE "PROGRAMMING ASSIGNMENT 6: Designing low-level I/O prodecures", 0
	prompt11 BYTE "Written by: Taylor Del Matto", 0
	prompt12 BYTE "Please Provide 10 unsigned decimal integers.", 0
	prompt13 BYTE "Each number needs to be small enough to fit inside a 32 bit register.", 0
	prompt14 BYTE "After you have finished inputting the raw numbers I will display a list", 0
	prompt15 BYTE "of the integers, their sum and their average value.", 0
	prompt16 BYTE "**EC: Option 1) number each line of user input and display a running subtotal ", 0
	prompt17 BYTE "**EC: Option 3) make ReadVal and WriteVal procedures recursive", 0

.code

main PROC

	;intro
	mov edx, OFFSET prompt10
	call writestring
	call crlf
	mov edx, OFFSET prompt11
	call writestring
	call crlf
	call crlf

	;extra credit descriptions
	mov edx, OFFSET prompt16
	call writestring
	call crlf
	call crlf
	mov edx, OFFSET prompt17
	call writestring
	call crlf
	call crlf

	mov edx, OFFSET prompt12
	call writestring
	call crlf
	mov edx, OFFSET prompt13
	call writestring
	call crlf
	mov edx, OFFSET prompt14
	call writestring
	call crlf
	mov edx, OFFSET prompt15
	call writestring
	call crlf
	call crlf

	;get string values using readval, store each value in number array
	;loop count
	mov ecx, 10
l10:
	;to preserve ecx (loopcount), push
	push ecx
	mov eax, ecx
	
	;call readval
	push OFFSET stringIn
	push OFFSET prompt2
	push OFFSET totalN
	push OFFSET prompt1
	push OFFSET stringIn
	call readval

	;mov number into array, running subtotal
	mov eax, totalN
	mov ebx, OFFSET numberarray
	mov edx, count2
	mov [ebx + edx], eax
	add count2, 4
	add subtotal, eax
	mov eax, subtotal
	mov edx, OFFSET prompt3
	call writestring
	call writedec
	call crlf
	
	pop ecx
	loop l10
	
	;you entered the following numbers
	call crlf
	mov edx, OFFSET prompt5
	call writestring
	call crlf

	mov ecx, 10
	mov count2, 0
l12:
	;move values out of number array and display using write val
	push ecx

	;mov number from array into currentN (for passing to writeval)
	mov ebx, OFFSET numberarray
	mov edx, count2
	mov eax, [ebx + edx]
	mov currentN, eax

	;call writeval
	push OFFSET stringOut
	push OFFSET currentN
	push OFFSET stringOut
	push count1
	call writeval

	mov edx, OFFSET prompt6
	call writestring
	
	add count2, 4

	pop ecx
	loop l12
	
	;total
	call crlf
	mov edx, OFFSET prompt7
	call writestring
	mov eax, subtotal
	call writedec
	
	;div total by 10 for average
	mov ebx, 10
	mov edx, 0
	div ebx
	call crlf
	
	;average
	mov edx, OFFSET prompt8
	call writestring
	call writedec

	;Outro
	call crlf
	call crlf
	mov edx, OFFSET prompt9
	call writestring
	call crlf

	exit
main ENDP


readVal PROC
	push ebp
	mov ebp, esp

	;set esi to stringin (is iterated by lodsb)
	mov esi, [EBP + 8]
	mov eax, esi
	
	;set ecx to string in (first position)(is not iterated by lodsb)
	mov ecx, [ebp + 24]
	
	;if this is not the first recursive call, jump to endget
	cmp ecx, esi
	jne endget

	jmp getstr

errorMessage:
	mov edx, [ebp + 20]
	call writestring

	;string (position) must be reset because of error
	mov ecx, [ebp + 24]
	mov esi, ecx
	mov [ebp+8], esi

	;get string values, set proper registers/variables
getstr:
	;set total N to 0
	mov eax, 0
	mov ebx, [ebp + 16]
	mov [ebx], eax

	;numbered user input
	countline ebx
	getstring [ebp + 8], [ebp + 12]
endget:
	
	;if next bit != 0, loop innerloop 
	;mov next number into Al register
	mov eax, 0
	lodsb 
	cmp al, 0
	je endreadval

	push eax

	;multiply total by 10
	mov	eax,  [ebp + 16]
	mov eax, [eax]
	mov edx, 0
	mov ebx, 10
	mul ebx
	mov edx, [ebp+16]
	mov [edx], eax

	pop eax

	;jump if not a number
	;if less than 0 (ascii), jump
	cmp al, 48
	jl errormessage
	;if greater than 9 (ascii), jump
	cmp al, 57
	jg errormessage

	;new total
	sub al, 48
	mov ebx, [ebp + 16]
	add [ebx], al
	mov eax, [ebx]

	;if total greater than 32 bit, jump errormessage
	mov edx, 2147483647
	cmp [ebx], edx
	jg errormessage

	;RECURSIVE CALL
	push [ebp + 24]
	push [ebp + 20]
	push [ebp + 16]
	push [ebp + 12]
	push esi
	call readval

endreadval:
	pop ebp
	ret 20
readVal ENDP



writeval PROC
	push ebp
	mov ebp, esp

	;mov string out into edi
	mov edi, [ebp + 12]

	;mov current num into eax
	mov eax, [ebp + 16]
	mov eax, [eax]
	
	;if num = 0 and no strings have been added, basecase 0 
	cmp eax, 0
	jne startloop
	mov ebx, [ebp + 20]
	cmp ebx, edi
	jne startloop
	;if eax == 0, then currentN == 0
	;currentN==0
	mov ecx, [ebp + 20]
	cmp edi, ecx
	jne startloop
	add eax, 48
	stosb
	mov eax, 0
	stosb
	mov edx, [ebp + 20]
	displaystring [ebp + 20]
	;return
	jmp endwrval

startloop:
	mov ebx, 1
initloop:
	;if edi != jump endcount
	mov edx, [ebp + 20]
	cmp edi, edx
	jne endcountloop

	;increment count1
	mov eax, 1
	add [ebp + 8], eax



	;mul ebx*10
	mov eax, ebx
	mov ecx, 10
	mul ecx
	mov ebx, eax

	;mov current num into eax
	mov eax, [ebp + 16]
	mov eax, [eax]

	;divide by ebx
	mov edx, 0
	div ebx

	cmp eax, 0
	jne initloop

endcountloop: 
	;if count is 0, call writestring jend 
	mov eax, [ebp + 8]
	
	cmp eax, 0
	jne endif2
	mov edx, [ebp + 20]
	mov eax, 0
	stosb
	displaystring [ebp + 20]
	jmp endwrval
endif2:

	mov ebx, 10
	mov eax, 1
	mov ecx, [ebp + 8]
makeeb:
	;make ebx
	mul ebx
	loop makeeb
	div ebx

	mov ebx, eax

	;decrement count1
	mov eax, [ebp + 8]
	sub eax, 1
	mov [ebp + 8], eax

	;mov current num into eax
	mov eax, [ebp + 16]
	mov eax, [eax]

	;divide by ebx
	mov edx, 0
	div ebx

	;store string
	add eax, 48
	stosb

	;RECURSIVE CALL
	;mov edx into current number
	push [ebp + 20]
	mov eax, [ebp + 16]
	mov [eax], edx
	push eax
	push edi
	mov edi, 0
	push [ebp + 8]
	call writeval
	
endwrval:
	pop ebp
	ret 16
writeval ENDP

end main
