format PE console
entry main
 
include 'win32a.inc'
 
SUCCESS = 0
MIN_MAX_NUMBER = 2
MAX_MAX_NUMBER = 4294967290
 
section '.code' code readable executable
main:
	call input_max_number
	cmp edx, SUCCESS
	jne .custom_exit
	mov [max_number], eax

	call [clock]
	mov [time_at_start], eax
 
	mov eax, [max_number]
	call allocate_memory
	cmp edx, SUCCESS
	jne .custom_exit
	mov [primes_pointer], eax
 
	mov eax, [primes_pointer]
	mov ebx, [max_number]
	call find_primes_with_eratosthenes_sieve
 
	mov eax, [primes_pointer]
	mov ebx, [max_number]
	call count_primes
 
	mov eax, [primes_pointer]
	call free_flags_memory
 
	call [clock]
	sub eax, [time_at_start]

	xor edx, edx
	mov ebx, 1000 ; CLOCKS_PER_SEC
	div ebx

	push edx
	push eax
	push time_fmt
	call [printf]

	.success:
		push str_exit_success
		call [printf]
		jmp .return
		       
	.custom_exit:
		push edx
		call [printf]
	       
	.return:
		call [getchar]
		call [getchar]
		push 0
		call [exit]
       
 
;---------------------------------------------------------------------------------------------------------
;
;			 scans the unsigned int, to which we will count primes
;			 returns SUCCESS in EDX, scanned value in EAX
;---------------------------------------------------------------------------------------------------------
 
input_max_number:
 
	enter 4, 1		;4 bytes for the constant
 
	push str_max_number_label ;greeting, see data
	call [printf]
	add esp, 4
 
	;scanf	will read in a constant
	mov eax, ebp
	sub eax, 4
       
	push eax
	push str_max_number_input_format ;%u - unsigned int
	call [scanf]
	add esp, 8
       
	mov eax, [ebp-4]
 
	;
	cmp eax, MIN_MAX_NUMBER
	jb .number_too_little

	cmp eax, 2
	jb .number_two


	cmp eax, MAX_MAX_NUMBER
	ja .number_too_big
	jmp .success
 
	;?????
	.number_two:
		 mov edx, str_error_max_num_two
		 jmp .return

	.number_too_little:
		mov edx, str_error_max_num_too_little ;massage look data section
		jmp .return    
	       
	.number_too_big:
		mov edx, str_error_max_num_too_big ;massage look data section
		jmp .return    
 
	.success:
		push eax
		push str_max_number_output_format ;YRAAAAA, lets print that we are successful
		call [printf]
		add esp, 4
		pop eax
		mov edx, SUCCESS
       
	.return:
		leave
		ret
 
 
;---------------------------------------------------------------------------------------------------------
;ENTRY: EAX - max number
;
;RETURNS pointer on an array of integers, from 1 to inputed number in EAX, SUCCES in EDX
;---------------------------------------------------------------------------------------------------------
allocate_memory:
	enter 8, 1
 
	inc eax
	mov [ebp-4], eax
       
	push eax
	call [malloc]
	add esp, 4
       
	;assert malloc return
	cmp eax, 0
	je .fail
	mov [ebp-8], eax     ;save it as second variable
       
	;
	mov byte [eax], 0
       
	cld
	mov edi, eax
	inc edi
	mov edx, [ebp-4]
	add edx, eax
       
	mov al, 1
	.write_true:
		stosb
		cmp edi, edx
		jb .write_true
       
	;?????
	mov eax, [ebp-8]
	jmp .success
       
	.fail:
		mov edx, str_error_malloc_failed ;messege malloc failed
		jmp .return
       
	.success:
		mov edx, SUCCESS
		       
	.return:
		leave
		ret
 
;---------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------
free_flags_memory:
	enter 0, 1
       
	push eax
	call [free]
	add esp, 4
       
	leave
	ret
       
       
;---------------------------------------------------------------------------------------------------------
;
;		EBX - MAX number
;		EAX - array pointer
;---------------------------------------------------------------------------------------------------------
find_primes_with_eratosthenes_sieve:
	enter 8, 1
	mov [ebp-4], eax
	       
	add eax, ebx					;add amounts of elements to the adress
	inc eax
	mov [ebp-8], eax
 
	cld
	mov edx, 2					;first prime number is = 2
	mov ecx, 2					;multipier is 2
	.strike_out_cycle:				;<-------------------------------------------------------------------------------|
		;x = c*p				;										 |
		mov eax, edx				;edx - was current prime number, we save it into eax				 |
		push edx				;										 |
		mul ecx 				;ecx - edx, we start to strike out beginning with square of a number		 |
		pop edx 				;to begin with in edx								 |
							;										 |
		cmp eax, ebx				;ebx - max nuber (max adress)							 |   internal cycle
		jbe .strike_out_number			;										 |   to delete all not prime
		jmp .increase_p 			;										 |   numbers from boolean array
							;										 |
		.strike_out_number:			;										 |
			mov edi, [ebp-4]		; array pointer 								 |
			add edi, eax			; current shift 								 |
			mov byte [edi], 0		;										 |
			inc ecx 			;c = c + 1									 |
			jmp .strike_out_cycle		;<--------------------------------------------------------------------------------
		       
		.increase_p:				;<-------------------------------------------------------------------------------|
			mov esi, [ebp-4]		;array start adress								 |
			mov ecx, edx			;										 |
			inc ecx 			;										 |
			add esi, ecx			;add to start of an array current prime + 1					 |
							;										 |
			.check_current_number:		;										 |
				mov eax, ecx		;current prime num + 1								 | external cycle to find
				mul eax 		;extern loop to sqrt(n), not to n						 | next prime number
				cmp eax, ebx		;										 |
				ja .return		;										 |
							;										 |
				lodsb			;										 |
				inc ecx 		;searching for the next non-thero byte - next prime				 |
				cmp al, 0		;										 |
				jne .new_p_found	;										 |
			       jmp .check_current_number;										 |
							;										 |
				.new_p_found:		;										 |
					dec ecx 	;we hve inc ecx one time more than we need					 |
					mov edx, ecx	;edx - current prime number now 						 |
				jmp .strike_out_cycle	;<-------------------------------------------------------------------------------|
       
	.return:
		leave
		ret
	       
;---------------------------------------------------------------------------------------------------------
;EAX - prime nubers array pointer
;EBX - max number (for the 'for' cycle)
;---------------------------------------------------------------------------------------------------------
count_primes:
	enter 16, 1
	mov [ebp-4], eax
	mov [ebp-8], ebx
	mov dword [ebp-16], 0
	push str_print_primes_label
	call [printf]
	add esp, 4
       
	cld
	mov esi, [ebp-4]
	mov edx, esi
	add edx, [ebp-8]
	inc edx
       
	mov [ebp-12], edx
	mov ecx, 0
	.print_cycle:
		lodsb
		cmp al, 0
		jne .print
		jmp .check_finish
		.print:
			inc dword [ebp-16]
			mov edx, [ebp-12]
		.check_finish:
			inc ecx
			cmp esi, edx
			jb .print_cycle

	dec dword [ebp-16]
	push dword [ebp-16]
	push str_prime ;print the total nubmer of primes
	call [printf]
	add esp, 8
 
	push str_cr_lf
	call [printf]
	add esp, 4
		       
	leave
	ret
;---------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------
section '.data' data readable writeable
	max_number: dd 0
	primes_pointer: dd 0
	str_max_number_label: db "Max number: ", 0
	str_max_number_input_format: db "%u", 0
	str_max_number_output_format: db "Using max number %u", 0xD, 0xA, 0
 
	str_print_primes_label: db "Number of primes:", 0xD, 0xA, 0
	str_prime: db "%u", 0x9, 0
	str_cr_lf: db 0xD, 0xA, 0
 
	str_exit_success: db "Success!", 0xD, 0xA, 0
	str_error_max_num_too_little: db "Number of primes: 0", 0xD, 0xA, 0
	str_error_max_num_two: db "Number of primes: 1", 0xD, 0xA, 0
	str_error_max_num_too_big: db "Max number is too big!", 0xD, 0xA, 0
	str_error_malloc_failed: db "Can't allocate memory!", 0xD, 0xA, 0

	time_at_start: dd 0
	time_fmt: db "The program spent %u.%03u seconds", 0xD, 0xA, 0
       
section '.idata' import data readable
library msvcrt,'msvcrt.dll'
import msvcrt,\
printf,'printf',\
scanf,'scanf',\
malloc,'malloc',\
free,'free',\
exit,'exit',\
clock,'clock',\
getchar,'getchar'