.global main

main:
@rutina para leer el nombre del archivo
ldr r0, =txt_escritura
bl printf

ldr r0, =f_formato
ldr r1, =file
bl scanf

@abre el archivo
ldr r0, =file
mov r1, #0
mov r2, #0
mov r7, #5
svc 0

mov r4, #0 @numero leido
mov r5, #0

leer_num:
push {r0, r4, r5}     @guarda el file handler

ldr r1, =mibuffer
mov r2, #1            @lee un byte
mov r7, #3
svc 0

pop {r0, r4, r5} @recupera el file handler y el numero acumulado

ldrb r3, [r1], #1
cmp r3, #36 @compara el valor de salida
beq end
cmp r3, #10 @caracter de enter
beq enter

sub r3, #48 @convertir en int
mov r2, #10
mul r4, r2  @multiplicar numero actual x10 
add r4, r3
b leer_num

enter:
add r5, #1
str r4, [sp]
mov r4, #0
sub sp, #4
b leer_num


end:
lsr r5, #1
str r5, [sp]

ldr r0, =linebreak
bl printf

ldr r0, =tabla_list
bl printf

mov r6, #0

ciclo_tabla:
ldr r5, [sp] @pares
mov r4, #8
cmp r6, r5
beq fin_ciclo_tabla
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
b ciclo_tabla


fin_ciclo_tabla:

mov r0, #1
ldr r2, [sp]

calculo_num_clusters:
mul r1, r0, r0
cmp r1, r2
bgt instanciar_clusters
add r0, #1
b calculo_num_clusters

@r0 contiene el numero de clusters
@r2 contiene el numero de pares
@para instanciar un cluster se necesita apartar:
@8 bytes (coor_y,coor_x)
@4 bytes (puntos en cluster)
@4 bytes * num_pares (array para los indices)
@bytes por apartar = r0*(8+4+4*r2)

instanciar_clusters:
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

@estructura cluster:
@|arreglo_indices|longitud_arreglo|y|x|

@en este punto el stack se ve asi:
@sp->|num_clusters|num_pares|clusters|pares|
@inicio de cluster =
@sp+8-4+(num_clusters-indice)*(4*num_pares+4+8)


mov r2, #0
mov r3, #0

@r2 es indice clusters, r3 es indice pares

iniciar_clusters:
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
@r5 guarda el espacio a par_actual.x

ldr r0, [sp, r5] 
str r0, [sp, r4] @guarda el x de la pareja actual en cluster.x 
sub r5, #4
sub r4, #4
ldr r0, [sp, r5] 
str r0, [sp, r4] @guarda el y de la pareja actual en cluster.y 
sub r4, #4
mov r0, #1
str r0, [sp, r4] @establece la longitud del arreglo de cluster a 1
sub r4, #4
str r3, [sp, r4] @guardar el indice del par
add r2, #1
add r3, #1

ldr r0, [sp]
cmp r2, r0
beq set_ultimo_cluster
b iniciar_clusters

set_ultimo_cluster:
sub r2, #1
sub r3, #1

loop_ultimo_cluster:
ldr r1, [sp,#4]
add r3, #1
cmp r1, r3
beq fin_inicio_clusters
sub r4, #4
str r3, [sp, r4]

@ accede a la longitud del arreglo del cluster
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

b loop_ultimo_cluster

fin_inicio_clusters:

mov r2, #0 @indice de cluster

loop_nuevos_centroides:
ldr r1, [sp]
cmp r2, r1
beq fnc

sub sp, #12

mov r1, #0
str r1, [sp] @n_cluster_y
str r1, [sp,#4] @n_cluster_x
str r1, [sp,#8] @cambiado

@r0 trae el num de cluster
@r1 trae la cantidad de clusters
@r2 trae la cantidad de pares
push {r2}
add sp, #16
mov r0, r2
ldr r1, [sp]
ldr r2, [sp, #4]
bl func_offset_cluster
sub sp, #16
pop {r2}

@r0 trae el offset a cluster.x

sub r0, #8

mov r1, #0 @indice de lista indices
add sp, #12
ldr r3, [sp, r0] @longitud del arreglo
sub sp, #12
sub r0, #4 

loop_suma_pares:
cmp r1, r3
beq sacar_promedio

@r0 trae la posicion del par
@r1 trae la cantidad de clusters
@r2 trae la cantidad de pares

push {r0, r1, r2, r3}
add sp, #28
ldr r0, [sp, r0]
ldr r1, [sp]
ldr r2, [sp, #4]
bl func_offset_par
sub sp, #12
@ r0 trae el offset a par.x
ldr r1, [sp, #4] @nuevo_x
add sp, #12
ldr r2, [sp, r0]
sub sp, #12
add r1, r2
str r1, [sp, #4]
sub r0, #4
ldr r1, [sp]     @nuevo_y
add sp, #12
ldr r2, [sp, r0]
sub sp, #12
add r1, r2
str r1, [sp]
sub sp, #16
pop {r0, r1, r2, r3}

add r1, #1
sub r0, #4 
b loop_suma_pares

sacar_promedio:
vldr s0, [sp, #4] @nuevo_x
vmov s1, r3
vdiv.f32 s0, s0, s1
vstr s0, [sp, #4]
vldr s0, [sp] @nuevo_y
vdiv.f32 s0, s0, s1
vstr s0, [sp]

push {r2}
add sp, #16
mov r0, r2
ldr r1, [sp]
ldr r2, [sp, #4]
bl func_offset_cluster
sub sp, #12

@set los nuevos valores x y y del cluster
ldr r1, [sp, #4]
add sp, #12
ldr r2, [sp, r0]
bl func_cambio_centroide
str r1, [sp, r0]
sub sp, #12
sub r0, #4
ldr r1, [sp]
add sp, #12
ldr r2, [sp, r0]
bl func_cambio_centroide
str r1, [sp, r0]
sub sp, #16
pop {r2}
add sp, #12
add r2, #1
b loop_nuevos_centroides


fnc:
sub sp, #4
ldr r0, [sp]
add sp, #4
cmp r0, #0
bne resultados

mov r0, #0 @indice de clusters

reiniciar_array_indices:
ldr r1, [sp]
cmp r0, r1
beq salir_reinicio

ldr r1, [sp]
ldr r2, [sp, #4]

push {r0}
bl func_offset_cluster
sub r0, #8 
mov r1, #0
add sp, #4
str r1, [sp, r0]
sub sp, #4
pop {r0}

add r0, #1
b reiniciar_array_indices

salir_reinicio:

mov r0, #0 @contador de pares

loop_distancia_puntos:
ldr r1, [sp]
ldr r2, [sp, #4]
cmp r0, r2
beq fin_inicio_clusters

mov r3, #4
mul r3, r1
sub sp, r3
mov r5, #0 @contador de clusters

push {r0, r1, r2, r3}
bl func_offset_par
mov r4, r0
pop {r0, r1, r2, r3}
add sp, r3
vs0a:
ldr r6, [sp, r4] @coor x del punto
vmov s0, r6 
vcvt.f32.s32 s0, s0
vs0d:
sub r4, #4
vs1a:
ldr r6, [sp, r4] @coor y del punto
vmov s1, r6
vcvt.f32.s32 s1, s1
vs1d:
sub sp, r3

loop_dist_clusters:
cmp r5, r1
beq salir_loop_dist

push {r0, r1, r2, r3}
mov r0, r5
vp1:
bl func_offset_cluster
vs1:
mov r4, r0
pop {r0, r1, r2, r3}
add sp, r3
ldr r6, [sp, r4] @coor x del cluster
vmov s2, r6
sub r4, #4
ldr r6, [sp, r4] @coor y del cluster
vmov s3, r6
sub sp, r3
vfas:

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
b loop_dist_clusters

salir_loop_dist:

push {r0, r1, r2, r3}
add r0, r3, #16

bl func_indice_minimo
vrim:
mov r4, r0
pop {r0, r1, r2, r3}

add sp, r3

push {r0, r1, r2}
mov r0, r4
bl func_offset_cluster
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
b loop_distancia_puntos

resultados:
ldr r0, =linebreak
bl printf
ldr r0, =etcluster1
bl printf

mov r6, #0

loop_imprimir_res:

ldr r1, [sp]
cmp r6, r1
beq salir

mov r0, r6
ldr r2, [sp, #4]
antes_entrar:
bl func_offset_cluster
despues_entrar:
ldr r1, [sp, r0]
vmov s0, r1
vcvt.u32.f32 s1, s0
vmov.f32 r1, s1 @parte entera x
vcvt.f32.u32 s1, s1
vsub.f32 s2, s0, s1
mov r2, #1000
vmov s3, r2
vcvt.f32.u32 s3, s3
vmul.f32 s2, s3
vcvt.u32.f32 s2, s2
vmov.f32 r2, s2 @parte decimal x
sub r0, #4
ldr r3, [sp, r0]
vmov s0, r3
vcvt.u32.f32 s1, s0
vmov.f32 r3, s1 @parte entera y
vcvt.f32.u32 s1, s1
vsub.f32 s2, s0, s1

mov r4, #1000
vmov s3, r4
vcvt.f32.u32 s3, s3
vmul.f32 s2, s3
vcvt.u32.f32 s2, s2
vmov.f32 r4, s2 @parte decimal y

sub r0, #4
ldr r5, [sp, r0] @cantidad de veces limpiadas


vpf1:
ldr r0, =etcluster2
push {r4, r5, r6}
bl printf
pop {r4, r5, r6}
add r6, #1
b loop_imprimir_res

salir:
mov r7, #1
svc 0

func_cambio_centroide:
cmp r2, r1
bne f_no_cambio
sub sp, #4
ldr r2, [sp]
add r2, #1
str r2, [sp]
add sp, #4
f_no_cambio:
mov pc,lr

@r0 trae el puntero al inicio
@r1 trae el numero de clusters

func_indice_minimo:
sub r1, #1
mov r2, #0 @indice actual
sub r0, #4
mov r3, #0
ldr r6, [sp, r0]
vmov s0, r6

loop_func_indice:
cmp r2, r1
beq salir_func_minimo
add r2, #1
sub r0, #4
ldr r6, [sp, r0]
vmov s1, r6
vcmp.f32 s1, s0
vmrs APSR_nzcv, FPSCR
bgt cont_bucle_indice
mov r3, r2
vmov s0, s1
cont_bucle_indice:
b loop_func_indice

salir_func_minimo:
mov r0, r3
mov pc, lr


@r0 trae la posicion del par
@r1 trae la cantidad de clusters
@r2 trae la cantidad de pares

func_offset_par:
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

func_offset_cluster:
mov r3, #4
mul r3, r2
add r3, #12
sub r1, r0
mul r1, r3
add r0, r1, #4
mov pc, lr

.data
tabla_list: .asciz   "Puntos de Referencia:\n"
coordenadas: .asciz "(%d,%d)\n"

f_formato: .asciz "%s"
s_formato: .asciz "Nombre del documento a leer: %s\n"
txt_escritura: .asciz "Ingrese el nombre: "
file: .asciz "             "

linebreak: .asciz "\n"
etcluster1: .asciz "Clusteres: \n"
etcluster2: .asciz "- (%d.%d, %d.%d) - "
mibuffer: .asciz " "
obtenido: .asciz "char: %s\n"
