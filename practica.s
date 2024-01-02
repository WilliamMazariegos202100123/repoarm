.global principal

principal:
ldr r0, =txt_escribir
bl printf

ldr r0, =nombre_formato
ldr r1, =archivo
bl scanf

ldr r0, =archivo
mov r1, #0
mov r2, #0
mov r7, #5
svc 0

mov r4, #0 @numero leido
mov r5, #0

leer_num:
push {r0, r4, r5}

ldr r1, =buffer_ascii
mov r2, #1
mov r7, #3
svc 0

pop {r0, r4, r5}

ldrb r3, [r1], #1
cmp r3, #36
beq fin
cmp r3, #10
beq enter

sub r3, #48
mov r2, #10
mul r4, r2
add r4, r3
b leer_num

enter:
add r5, #1
str r4, [sp]
mov r4, #0
sub sp, #4
b leer_num

fin:
lsr r5, #1
str r5, [sp]

ldr r0, =salto_linea
bl printf

ldr r0, =encabezado_tabla
bl printf

mov r6, #0

ciclo_tabla:
ldr r5, [sp]
mov r4, #8
cmp r6, r5
beq fin_ciclo_tabla
sub r5, #1
sub r5, r6
mul r5, r4
add r5, #8

ldr r0, =par_ordenado
ldr r1, [sp, r5]
sub r5, #4
ldr r2, [sp, r5]

push {r6}
bl printf
pop {r6}

add r6, #1
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

mov r2, #0
mov r3, #0

iniciar_clusters:
ldr r0, [sp]
ldr r1, [sp,#4]
mov r4, #4
sub r0, r2
mul r4, r1
add r4, #12
mul r4, r0
add r4, #4

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

ldr r0, [sp, r5]
str r0, [sp, r4]
sub r5, #4
sub r4, #4
ldr r0, [sp, r5]
str r0, [sp, r4]
sub r4, #4
mov r0, #1
str r0, [sp, r4]
sub r4, #4
str r3, [sp, r4]
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

mov r2, #0

loop_nuevos_centroides:
ldr r1, [sp]
cmp r2, r1
beq fnc

sub sp, #12

mov r1, #0
str r1, [sp]
str r1, [sp,#4]
str r1, [sp,#8]

push {r2}
add sp, #16
mov r0, r2
ldr r1, [sp]
ldr r2, [sp,#4]
bl func_offset_cluster
sub sp, #16
pop {r2}

sub r0, #8

mov r1, #0
add sp, #12
ldr r3, [sp, r0]
sub sp, #12
sub r0, #4

loop_suma_pares:
cmp r1, r3
beq sacar_promedio

push {r0, r1, r2, r3}
add sp, #28
ldr r0, [sp, r0]
ldr r1, [sp]
ldr r2, [sp,#4]
bl func_offset_par
sub sp, #12

ldr r1, [sp,#4]
add sp, #12
ldr r2, [sp, r0]
sub sp, #12
add r1, r2
str r1, [sp,#4]
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
b loop_suma_pares

sacar_promedio:
vldr s0, [sp,#4]
vmov s1, r3
vdiv.f32 s0, s0, s1
vstr s0, [sp,#4]
vldr s0, [sp]
vdiv.f32 s0, s0, s1
vstr s0, [sp]

push {r2}
add sp, #16
mov r0, r2
ldr r1, [sp]
ldr r2, [sp,#4]
bl func_offset_cluster
sub sp, #12

ldr r1, [sp,#4]
add sp, #12
ldr r2, [sp,r0]
bl func_cambio_centroide
str r1, [sp,r0]
sub sp, #12
sub r0, #4
ldr r1, [sp]
add sp, #12
ldr r2, [sp,r0]
bl func_cambio_centroide
str r1, [sp,r0]
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

mov r0, #0

reiniciar_array_indices:
ldr r1, [sp]
cmp r0, r1
beq salir_reinicio

ldr r1, [sp]
ldr r2, [sp,#4]

push {r0}
bl func_offset_cluster
sub r0, #8 
mov r1, #0
add sp, #4
str r1, [sp,r0]
sub sp, #4
pop {r0}

add r0, #1
b reiniciar_array_indices

salir_reinicio:

mov r0, #0

loop_distancia_puntos:
ldr r1, [sp]
ldr r2, [sp,#4]
cmp r0, r2
beq fin_inicio_clusters

mov r3, #4
mul r3, r1
sub sp, r3
mov r5, #0

push {r0, r1, r2, r3}
bl func_offset_par
mov r4, r0
pop {r0, r1, r2, r3}
add sp, r3

vs0a:
ldr r6, [sp,r4]
vs0d:
sub r4, #4
vs1a:
ldr r6, [sp,r4]
vs1d:
sub sp, r3

loop_dist_clusters:
cmp r5, r1
beq salir_loop_dist

push {r0, r1, r2, r3}
mov r0, r5
bl func_offset_cluster
mov r4, r0
pop {r0, r1, r2, r3}
add sp, r3

ldr r6, [sp,r4]
sub r4, #4
ldr r6, [sp,r4]
sub sp, r3

vfas:

vsub.f32 s2, s0
vabs.f32 s2, s2
vsub.f32 s3, s1
vabs.f32 s3, s3
vadd.f32 s2, s3

mov r4, #4
mul r4, r5
sub r4, r3, r4
sub r4, #4
vmov r6, s2
str r6, [sp,r4]
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
ldr r1, [sp,r0]
add r1, #1
str r1, [sp,r0]
mov r2, #4
mul r2, r1
sub r1, r0, r2
sub sp, #12
pop {r0}
add sp, #8
str r0, [sp,r1]
sub sp, #8
pop {r1, r2}

add r0, #1
b loop_distancia_puntos

resultados:
ldr r0, =salto_linea
bl printf
ldr r0, =encabezado_cluster
bl printf

mov r6, #0

loop_imprimir_res:

ldr r1, [sp]
cmp r6, r1
beq salir

mov r0, r6
ldr r2, [sp,#4]

bl func_offset_cluster

ldr r1, [sp,r0]
vmov s0, r1
vcvt.u32.f32 s1, s0
vmov.f32 r1, s1
vcvt.f32.u32 s1, s1
vsub.f32 s2, s0, s1
mov r2, #1000
vmov s3, r2
vcvt.f32.u32 s3, s3
vmul.f32 s2, s3
vcvt.u32.f32 s2, s2
vmov.f32 r2, s2
sub r0, #4
ldr r3, [sp]
vcvt.u32.f32 s0, s3
vstr s0, [sp]
vstr s0, [sp]

vpf1:
ldr r0, =cluster_format
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

func_indice_minimo:
sub r1, #1
mov r2, #0
sub r0, #4
mov r3, #0
ldr r6, [sp, r0]

loop_func_indice:
cmp r2, r1
beq salir_func_minimo
add r2, #1
sub r0, #4
ldr r6, [sp, r0]
vcmp.f32 s1, s0
vmrs APSR_nzcv, FPSCR
bgt cont_bucle_indice
mov r3, r2
cont_bucle_indice:
b loop_func_indice

salir_func_minimo:
mov r0, r3
mov pc, lr

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

func_offset_cluster:
mov r3, #4
mul r3, r2
add r3, #12
sub r1, r0
mul r1, r3
add r0, r1, #4
mov pc, lr

.data
encabezado_tabla: .asciz   "Lista de puntos:\n"
stxt_escribir: .asciz "Introduce el nombre del archivo:\n"
nombre_formato: .asciz "%s"
buffer_ascii: .space 256
archivo: .space 256
par_ordenado: .asciz "Par ordenado: (%d,%d)\n"
salto_linea: .asciz "\n"

cluster_format: .asciz "Cluster %d: %f,%f\n"

