.global main

@para compilar este código se necesita agregar un '@' al finalizar la entrada
@example 
@ 1
@ 2
@ 3
@ 4
@ 5
@ 7
@ @
main:

	ldr r0, =escritura @var para escritura
	bl printf
	
	ldr r0, =formato_archivo
	ldr r1, =file
	bl scanf
	
	@abrimos el documento
	ldr r0, =file
	mov r1, #0
	mov r2, #0
	mov r7, #5
	svc 0
	
	mov r4, #0
	mov r5, #0
	
lectura_numeros:
	push {r0, r4, r5}     @file handler
	
	ldr r1, =buffer_ascii
	mov r2, #1            @lee el byte
	mov r7, #3
	svc 0
	
	pop {r0, r4, r5}
	
	ldrb r3, [r1], #1
	cmp r3, #64 @establecemos caracter para finalizar ascii @
	beq end
	cmp r3, #10 @compara entrada
	beq entrada
	
	sub r3, #48 @convertir en entero
	mov r2, #10
	mul r4, r2  @multiplica el # por 10 
	add r4, r3
	b lectura_numeros

entrada:
	add r5, #1
	str r4, [sp]
	mov r4, #0
	sub sp, #4
	b lectura_numeros


end:
	lsr r5, #1
	str r5, [sp]
	ldr r0, =linebreak
	bl printf
	ldr r0, =tabla_name
	bl printf
	mov r6, #0

bucle_de_tabla:
	ldr r5, [sp] @pares
	mov r4, #8
	cmp r6, r5
	beq fin_bucle_de_tabla
	sub r5, #1
	sub r5, r6
	mul r5, r4
	add r5, #8
	
	ldr r0, =coordenadas
	ldr r1, [sp, r5]
	sub r5, #4
	ldr r2, [sp, r5]
	
	push {r6}
	bl printf
	pop {r6}
	
	add R6, #1
	b bucle_de_tabla


fin_bucle_de_tabla:
	mov r0, #1
	ldr r2, [sp]

num_centroides:
	mul r1, r0, r0
	cmp r1, r2
	bgt llamada_a_centroides
	add r0, #1
	b num_centroides


llamada_a_centroides:
	sub r0, #1
	add sp, #4
	mov r3, #4
	mul r3, r2
	add r3, #12
	mul r3, r0
	sub sp, r3
	sub sp, #4
	str r2, [sp]
	sub sp, #4
	str r0, [sp]
	mov r2, #0
	mov r3, #0

inicializar_centroides:
	ldr r0, [sp]
	ldr r1, [sp,#4]
	mov r4, #4
	sub r0, r2
	mul r4, r1
	add r4, #12
	mul r4, r0
	add r4, #4
	@r4 guarda el espacio a cluster_actual.x
	
	ldr r0, [sp]
	mov r6, #8
	mov r5, #4
	mul r5, r1
	add r5, #12
	mul r5, r0 
	sub r1, r3 
	mul r1, r6
	add r5, r1 
	add r5, #4

	@empezamos a guardar las parejas ordenadas
	ldr r0, [sp, r5] 
	str r0, [sp, r4] @x
	sub r5, #4
	sub r4, #4
	ldr r0, [sp, r5] 
	str r0, [sp, r4] @y
	sub r4, #4
	mov r0, #1
	@manejamos el stack y el manejo del arreglo
	str r0, [sp, r4] 
	sub r4, #4
	str r3, [sp, r4] 
	add r2, #1
	add r3, #1
	
	ldr r0, [sp]
	cmp r2, r0
	beq setear_ul_cent
	b inicializar_centroides

setear_ul_cent:
	sub r2, #1
	sub r3, #1

ciclar_ul_cent:
	ldr r1, [sp,#4]
	add r3, #1
	cmp r1, r3
	beq endstart_centroides
	sub r4, #4
	str r3, [sp, r4]

	ldr r0, [sp]
	ldr r1, [sp,#4]
	mov r5, #4
	sub r0, r2
	mul r5, r1
	add r5, #12
	mul r5, r0
	sub r5, #4
	ldr r0, [sp, r5]
	add r0, #1
	str r0, [sp, r5]
	
	b ciclar_ul_cent

endstart_centroides:
	mov r2, #0 

ciclo_newcentroides:
	ldr r1, [sp]
	cmp r2, r1
	beq find_clusters
	
	sub sp, #12
	
	mov r1, #0
	str r1, [sp] @n_cluster_y
	str r1, [sp,#4] @n_cluster_x
	str r1, [sp,#8] @cambiado
	
	@de r0 a r2 hace el manejo de los centroides
	push {r2}
	add sp, #16
	mov r0, r2
	ldr r1, [sp]
	ldr r2, [sp, #4]
	bl def_separar_centroides
	sub sp, #16
	pop {r2}
	
	sub r0, #8

	@ instanciamos los indices y hacemos manejo del arreglo
	mov r1, #0 
	add sp, #12
	ldr r3, [sp, r0]
	sub sp, #12
	sub r0, #4 

suma_coordenadas:
	cmp r1, r3
	beq promediar
	
	push {r0, r1, r2, r3}
	add sp, #28
	ldr r0, [sp, r0]
	ldr r1, [sp]
	ldr r2, [sp, #4]
	bl def_separar_coordenadas
	sub sp, #12

	@hacemos manejo de los nuevos centroides en X y Y
	ldr r1, [sp, #4] 
	add sp, #12
	ldr r2, [sp, r0]
	sub sp, #12
	add r1, r2
	str r1, [sp, #4]
	sub r0, #4
	ldr r1, [sp]    
	add sp, #12
	ldr r2, [sp, r0]
	sub sp, #12
	add r1, r2
	str r1, [sp]
	sub sp, #16
	pop {r0, r1, r2, r3}
	
	add r1, #1
	sub r0, #4 
	b suma_coordenadas

promediar:
	vldr s0, [sp, #4] 
	vmov s1, r3
	vdiv.f32 s0, s0, s1
	vstr s0, [sp, #4]
	vldr s0, [sp] 
	vdiv.f32 s0, s0, s1
	vstr s0, [sp]
	
	push {r2}
	add sp, #16
	mov r0, r2
	ldr r1, [sp]
	ldr r2, [sp, #4]
	bl def_separar_centroides
	sub sp, #12
	
	ldr r1, [sp, #4]
	add sp, #12
	ldr r2, [sp, r0]
	bl def_centroidechange
	str r1, [sp, r0]
	sub sp, #12
	sub r0, #4
	ldr r1, [sp]
	add sp, #12
	ldr r2, [sp, r0]
	bl def_centroidechange
	str r1, [sp, r0]
	sub sp, #16
	pop {r2}
	add sp, #12
	add r2, #1
	b ciclo_newcentroides
	

find_clusters:
	sub sp, #4
	ldr r0, [sp]
	add sp, #4
	cmp r0, #0
	bne imprimir
	
	mov r0, #0 @indice de clusters

reset_indices:
	ldr r1, [sp]
	cmp r0, r1
	beq break_reset
	
	ldr r1, [sp]
	ldr r2, [sp, #4]
	
	push {r0}
	bl def_separar_centroides
	sub r0, #8 
	mov r1, #0
	add sp, #4
	str r1, [sp, r0]
	sub sp, #4
	pop {r0}
	
	add r0, #1
	b reset_indices

break_reset:
	mov r0, #0 @contador de pares

size_coordenadas:
	ldr r1, [sp]
	ldr r2, [sp, #4]
	cmp r0, r2
	beq endstart_centroides
	
	mov r3, #4
	mul r3, r1
	sub sp, r3
	mov r5, #0 @contador de clusters
	
	push {r0, r1, r2, r3}
	bl def_separar_coordenadas
	mov r4, r0
	pop {r0, r1, r2, r3}
	add sp, r3

centroide0a:
	ldr r6, [sp, r4] 
	vmov s0, r6 
	vcvt.f32.s32 s0, s0

centroide0d:
	sub r4, #4

centroide1a:
	ldr r6, [sp, r4] 
	vmov s1, r6
	vcvt.f32.s32 s1, s1

centroide1d:
	sub sp, r3
	
distancia_centroides:
	cmp r5, r1
	beq break_dist
	
	push {r0, r1, r2, r3}
	mov r0, r5

clvp1:
	bl def_separar_centroides

centroide1:
	mov r4, r0
	pop {r0, r1, r2, r3}
	add sp, r3
	ldr r6, [sp, r4] @coor x del cluster
	vmov s2, r6
	sub r4, #4
	ldr r6, [sp, r4] @coor y del cluster
	vmov s3, r6
	sub sp, r3

clvfas:
	vsub.f32 s2, s0
	vabs.f32 s2, s2 @distancia x
	vsub.f32 s3, s1
	vabs.f32 s3, s3 @distancia y
	vadd.f32 s2, s3 @distancia a cluster actual
	
	mov r4, #4
	mul r4, r5
	sub r4, r3, r4
	sub r4, #4
	vmov r6, s2
	str r6, [sp, r4]
	add r5, #1
	b distancia_centroides

break_dist:
	push {r0, r1, r2, r3}
	add r0, r3, #16
	bl def_index_min

clvrim:
	mov r4, r0
	pop {r0, r1, r2, r3}
	
	add sp, r3
	
	push {r0, r1, r2}
	mov r0, r4
	bl def_separar_centroides
	add sp, #12
	sub r0, #8 
	ldr r1, [sp, r0]
	add r1, #1
	str r1, [sp, r0]
	mov r2, #4
	mul r2, r1
	sub r1, r0, r2
	sub sp, #12
	pop {r0}
	add sp, #8
	str r0, [sp, r1]
	sub sp, #8
	pop {r1, r2}
	
	add r0, #1
	b size_coordenadas

imprimir:
	ldr r0, =linebreak
	bl printf
	ldr r0, =encabezado_cluster
	bl printf
	mov r6, #0

ciclo_de_imprimir:
	ldr r1, [sp]
	cmp r6, r1
	beq exit
	mov r0, r6
	ldr r2, [sp, #4]

before_end:
	bl def_separar_centroides

after_end:
	@Manejo de impresion para flotantes
	ldr r1, [sp, r0]
	vmov s0, r1
	vcvt.u32.f32 s1, s0
	@posiciones en x
	vmov.f32 r1, s1 
	vcvt.f32.u32 s1, s1
	vsub.f32 s2, s0, s1
	mov r2, #100
	vmov s3, r2
	vcvt.f32.u32 s3, s3
	vmul.f32 s2, s3
	vcvt.u32.f32 s2, s2
	@Posiciones en Y
	vmov.f32 r2, s2 
	sub r0, #4
	ldr r3, [sp, r0]
	vmov s0, r3
	vcvt.u32.f32 s1, s0
	vmov.f32 r3, s1 
	vcvt.f32.u32 s1, s1
	vsub.f32 s2, s0, s1
	
	mov r4, #100
	vmov s3, r4
	vcvt.f32.u32 s3, s3
	vmul.f32 s2, s3
	vcvt.u32.f32 s2, s2
	vmov.f32 r4, s2 


clvpf1:
	ldr r0, =cluster_format
	push {r4, r5, r6}
	bl printf
	pop {r4, r5, r6}
	add r6, #1
	b ciclo_de_imprimir

exit:
	mov r7, #1
	svc 0

def_centroidechange:
	cmp r2, r1
	bne def_notchange
	sub sp, #4
	ldr r2, [sp]
	add r2, #1
	str r2, [sp]
	add sp, #4

def_notchange:
	mov pc,lr

def_index_min:
	sub r1, #1
	mov r2, #0 
	sub r0, #4
	mov r3, #0
	ldr r6, [sp, r0]
	vmov s0, r6

def_ciclo_index:
	cmp r2, r1
	beq def_exit_min
	add r2, #1
	sub r0, #4
	ldr r6, [sp, r0]
	vmov s1, r6
	vcmp.f32 s1, s0
	vmrs APSR_nzcv, FPSCR
	bgt conteo_indices
	mov r3, r2
	vmov s0, s1

conteo_indices:
	b def_ciclo_index

def_exit_min:
	mov r0, r3
	mov pc, lr

def_separar_coordenadas:
	mov r3, #4
	mov r4, #8
	mul r3, r2
	add r3, #12
	mul r3, r1
	sub r2, r0
	mul r2, r4
	add r0, r3, r2
	add r0, #4
	mov pc, lr
	
	@r0 trae el num de cluster
	@r1 trae la cantidad de clusters
	@r2 trae la cantidad de pares

def_separar_centroides:
	mov r3, #4
	mul r3, r2
	add r3, #12
	sub r1, r0
	mul r1, r3
	add r0, r1, #4
	mov pc, lr

@r0 y r2 contiene los centroides y las coordenadas
@4 bY & 4 bX
@4 bY de coordenadas
@4 by * coordenadas (arreglo i)
@resultado= r0*(8+4+4*r2)

.data
	tabla_name: .asciz   "Coordenadas (X,Y):\n"
	coordenadas: .asciz "---> (%d,%d)\n"
	
	formato_archivo: .asciz "%s"
	formato_salida: .asciz "El nombre del archivo es: %s\n"
	escritura: .asciz "Ingresa el nombre del documento a leer: "
	file: .asciz "             "
	
	linebreak: .asciz "\n"
	encabezado_cluster: .asciz "CENTROIDES: \n"
	cluster_format: .asciz "Centroide ==> (%d.%d, %d.%d)\n"
	buffer_ascii: .asciz " "
	conseguido: .asciz "caracter: %s\n"