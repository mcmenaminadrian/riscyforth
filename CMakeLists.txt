cmake_minimum_required(VERSION 3.18 FATAL_ERROR)

project(riscyforth LANGUAGES ASM)

add_executable(riscyforth 
	riscyforth.S
	basics.S
	core.S
	decision.S
	integer.S
	listwords.S
	loops.S
	macros.S
	outerloop.S
	search_create.S
	stackop.S
	transitions.S
	)

target_link_libraries(riscyforth
	libc
	)
