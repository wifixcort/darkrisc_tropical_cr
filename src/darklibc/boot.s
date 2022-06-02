/*
 * Copyright (c) 2018, Marcelo Samsoniuk
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * * Neither the name of the copyright holder nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */

	.option nopic
	.text
	.section .boot
	.align	2
	.globl  check4rv32i
    .globl  set_mtvec
    .globl  set_mepc
    .globl  set_mie
    .globl  get_mtvec
    .globl  get_mepc
    .globl  get_mie
    .globl  get_mip

/*
	boot:
	- read and increent thread counter
	- case not zero, jump to multi thread boot
	- otherwise continue	
*/

_boot:

	la	a0,threads
	lw 	a1,0(a0)
	addi	a2,a1,1
	sw	a2,0(a0)
	la	a3,io
	bne	a1,x0,_multi_thread_boot

/*
	normal boot here:
	- set stack
	- set global pointer
	- plot boot banner
	- print memory setup
	- call main
	- repeat forever
*/

_normal_boot:

	la	sp,_stack
	la	gp,_global

	call 	banner

	la	a0,_boot0msg
	la	a1,_text
	la	a2,_etext
	sub	a2,a2,a1
	la	a3,_data
	la	a4,_edata
	sub	a4,a4,a3
	la	a5,_stack
	call	printf

	la	  a0,_boot1msg
	la	  a1,_stack
	la	  a2,_edata
	sub	 a1,a1,a2
	call	printf

	call	main

	j	_normal_boot

/*
	multi-thread boot:
	- set io base
	- write thread number to io.gpio
	- increent thread number
	- repeat forever
*/

_multi_thread_boot:

	sh	a1,10(a3)
	addi	a1,a1,1
	j 	_multi_thread_boot

/*
	rv32e/rv32i detection:
	- set x15 0
	- set x31 1
	- sub x31-x15 and return the value
	why this works?!
	- the rv32i have separate x15 and x31, but the rv32e will make x15 = x31
	- this "feature" probably works only in the darkriscv! :)
*/

check4rv32i:

        .word 	0x00000793 	/* addi    x15,x0,0   */
        .word   0x00100f93	/* addi    x31,x0,1   */
        .word   0x40ff8533	/* sub     a0,x31,x15 */

	ret

/*
    access to CSR registers (set/get)
*/

set_mtvec:
    csrw mtvec,a0
    ret

set_mepc:
    csrw mepc,a0
    ret

set_mie:
    csrw mie,a0
    ret

get_mtvec:
    addi  a0,x0,0
    csrr a0,mtvec
    ret

get_mepc:
    addi a0,x0,0
    csrr a0,mepc
    ret

get_mie:
    addi a0,x0,0
    csrr a0,mie
    ret

get_mip:
    addi a0,x0,0
    csrr a0,mip
    ret

/*
	data segment here!
*/

	.section .rodata
	.align	2

_boot0msg:
	.string	"boot0: text@%d+%d data@%d+%d stack@%d "
_boot1msg:
    .string "(%d bytes free)\n"
