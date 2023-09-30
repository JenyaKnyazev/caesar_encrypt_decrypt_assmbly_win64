option casemap:none
WriteConsoleA proto
ReadConsoleA proto
ExitProcess proto
GetStdHandle proto
Sleep proto
.data
input_handle QWORD ?
output_handle QWORD ?
user_string DB 100 DUP(0)
result DB 100 DUP(0)
key QWORD ?
key_string DB 100 DUP(0)
chars_writen QWORD ?
op DB 3 DUP(0)
menu_string DB 10,"caesar encryption",10,"1 = encrypt",10,"2 = decrypt",10,"other exit",10,0
encrypt_string DB "Enter a line to encrypt: ",0
decrypt_string DB "Enter a line to decrypt: ",0
key_ask_string DB "Enter a key number: ",0
encrypt_string2 DB "Encrypted: ",0
decrypt_string2 DB "Decrypted: ",0
good_bay DB 10,"GOOD BAY",0
arr_help DB "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz~!@#$%^&*()_+:?><{}[]|=-/\,.`:;",34,39
arr DB "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz~!@#$%^&*()_+:?><{}[]|=-/\,.`:;",34,39
end_arr DB 0
.code
	main proc
		mov rcx,-10
		call GetStdHandle
		mov input_handle,rax
		mov rcx,-11
		call GetStdHandle
		mov output_handle,rax
		call play
		mov rcx,5000
		call Sleep
		mov rcx,0
		call ExitProcess
	main endp
	play proc
		run_play:
			call clean_all
			lea rsi,menu_string
			mov rbx,54
			call print_string
			lea rsi,op
			mov rbx,3
			call input_string
			cmp op,'1'
			je enc_play
			cmp op ,'2'
			je dec_play
			mov rsi,offset good_bay
			mov rbx,8
			call print_string
			ret
			enc_play:
			call encrypt
			jmp run_play
			dec_play:
			call decrypt
			jmp run_play
	play endp
	
	print_string proc
		mov rcx,output_handle
		mov rdx,rsi
		mov r8,rbx
		mov r9,offset chars_writen
		push 0h
		call WriteConsoleA
		pop r9
		ret
	print_string endp

	input_string proc
		mov rcx,input_handle
		mov rdx,rsi
		mov r8,100
		mov r9,offset chars_writen
		push 0h
		call ReadConsoleA
		pop r9
		ret
	input_string endp

	encrypt proc
		mov r14,1
		call ask_key
		lea rsi,encrypt_string
		mov rbx,25
		call print_string
		mov rsi,offset user_string
		call input_string
		call remove_enter_char
		call calc
		mov rbx,12
		mov rsi,offset encrypt_string2
		call print_string
		mov rbx,100
		mov rsi,offset result
		call print_string
		ret
	encrypt endp

	decrypt proc
		mov r14,2
		call ask_key
		lea rsi,decrypt_string
		mov rbx,25
		call print_string
		mov rsi,offset user_string
		call input_string
		call remove_enter_char
		call calc
		mov rbx,12
		mov rsi,offset decrypt_string2
		call print_string
		mov rbx,100
		mov rsi,offset result
		call print_string
		ret
	decrypt endp
		
	calc proc
		mov rsi,offset user_string
		run:
			mov rbx,0
			mov bl,[rsi]
			call index_char
			call encrypt_decrypt_char
			mov r12,offset user_string
			mov r13,offset result
			sub rsi,r12
			add rsi,r13
			mov [rsi],bl
			sub rsi,r13
			add rsi,r12
			inc rsi
			cmp byte ptr[rsi],0
			jne run
		ret
	calc endp

	clean_all proc
		mov rsi,offset result
		mov rbx,100
		call clean_arr
		mov rsi,offset user_string
		mov rbx,100
		call clean_arr
		mov rsi,offset key_string
		mov rbx,100
		call clean_arr
		ret
	clean_all endp

	clean_arr proc
		run_clean:
			mov byte ptr[rsi],0
			inc rsi
			dec rbx
			jnz run_clean
		ret
	clean_arr endp

	index_char proc
		mov rdi,offset arr
		run_index:
			cmp [rdi],bl
			je end_run_index
			inc rdi
			jmp run_index
		end_run_index:
		mov r12,offset arr
		sub rdi,r12
		mov r15,rdi
		ret
	index_char endp

	encrypt_decrypt_char proc
		mov rax,r15
		add rax,key
		mov rdx,0
		mov rbx,offset end_arr
		mov r12,offset arr
		sub rbx,r12
		div rbx
		mov rdi,offset arr
		add rdi,rdx
		mov rbx,0
		mov bl,[rdi]
		ret
	encrypt_decrypt_char endp

	ask_key proc
		mov rsi,offset key_ask_string
		mov rbx,20
		call print_string
		mov rsi,offset key_string
		call input_string
		call remove_enter_char
		mov rax,0
		mov rbx,10
		run_convert:
			mov rdx,0
			mul rbx
			mov rcx,0
			mov cl,[rsi]
			sub cl,48
			add rax,rcx
			inc rsi
			cmp byte ptr[rsi],0
			jne run_convert
		mov rdx,0
		mov rbx,offset end_arr
		mov r12,offset arr
		sub rbx,r12
		div rbx
		cmp r14,1
		je end_ask_key
		neg rdx
		end_ask_key:
		mov key,rdx
		ret
	ask_key endp

	remove_enter_char proc
		run_remove_char_enter:
			inc rsi
			cmp byte ptr[rsi],0
			jne run_remove_char_enter
		dec rsi
		mov byte ptr[rsi],0
		dec rsi
		mov byte ptr[rsi],0
		ret
	remove_enter_char endp
end