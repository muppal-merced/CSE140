# Traditional Matrix Multiply program
	.data
matrix_a:
	.word  1,  2,  3,  4,  5,  6,  7,  8,  9, 10
	.word  2,  3,  4,  5,  6,  7,  8,  9, 10,  1
	.word  3,  4,  5,  6,  7,  8,  9, 10,  1,  2
	.word  4,  5,  6,  7,  8,  9, 10,  1,  2,  3
	.word  5,  6,  7,  8,  9, 10,  1,  2,  3,  4
	.word  6,  7,  8,  9, 10,  1,  2,  3,  4,  5
	.word  7,  8,  9, 10,  1,  2,  3,  4,  5,  6
	.word  8,  9, 10,  1,  2,  3,  4,  5,  6,  7
	.word  9, 10,  1,  2,  3,  4,  5,  6,  7,  8

matrix_b:
	.word 1,  2,  3,  4,  5,  6,  7,  8,  9
	.word 2,  3,  4,  5,  6,  7,  8,  9,  1
	.word 3,  4,  5,  6,  7,  8,  9,  1,  2
	.word 4,  5,  6,  7,  8,  9,  1,  2,  3
	.word 5,  6,  7,  8,  9,  1,  2,  3,  4
	.word 6,  7,  8,  9,  1,  2,  3,  4,  5
	.word 7,  8,  9,  1,  2,  3,  4,  5,  6
	.word 8,  9,  1,  2,  3,  4,  5,  6,  7
	.word 9,  1,  2,  3,  4,  5,  6,  7,  8
	.word 8,  7,  6,  5,  4,  3,  2,  1,  9

matrix_c:
	.word   0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	.word   0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	.word   0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	.word   0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	.word   0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	.word   0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	.word   0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	.word   0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	.word   0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	.word   0,  0,  0,  0,  0,  0,  0,  0,  0,  0

m:	.word 10
n:	.word 9

nline:	.string "\n"
space:	.string " "
msga:	.string "Matrix A is: \n"
msgb:	.string "Matrix B is: \n"
msgc:	.string "Matrix C=A*B is: \n"

	.text
	.globl main
main:
	la	s0, m
	lw	s0, 0(s0)
	la	s1, n
	lw	s1, 0(s1)
	la	s2, matrix_a
	la	s3, matrix_b
	la	s4, matrix_c

	la	a0, msga
	la	a1, matrix_a
	add	a2, s0, zero
	add	a3, s1, zero
	jal	PRINT_MAT
	la	a0, msgb
	la	a1, matrix_b
	add	a2, s1, zero
	add	a3, s0, zero
	jal	PRINT_MAT

# Your CODE HERE
# matrix c = s4
# matrix b = s3
# matrix a = s2

# i = rows t0
# j = cols t1
# k = sum index t2
# sum = t3
#s0 = 10 cols (m)
#s1 = 9 rows (n)

# 2d array into 1d array -> matrix + (row*width + col) * byte offset(4)

addi t0, x0, 0 #i = 0

loop_i:
	bge t0, s1, i_done # if i >= 9 (s1) end
	addi t1, x0, 0 # j = 0

loop_j:
	bge t1, s1, j_done # if j >= 9 (s1) end
	addi t2, x0, 0 # k = 0 
	addi t3, x0, 0 # sum = 0
	mul t4, t0, s1 # row (t0 -> i) * width (num of cols)
	add t4, t4, t1 # (row*width + col)
	slli t4, t4, 2 # (row*width + col) * byte offset(4)
	add t5, s4, t4 # t5 = adress of c[i][j]

loop_k:
	bge t2, s0, k_done #if k >= 10 (s0) end
	#A[i][k] = matrix a + (i*10 + k)*4
	mul t4, t0, s0 # i*10
	add t4, t4, t2 # (i*10+k)
	slli t4, t4, 2 # (i*10+k)*4
	add t4, s2, t4 # add address A[i][k] into t4
	lw t6, 0(t4) # load value of A[i][k] into t6
	#B[k][j] = matrix b + (k*9 + j) *4
	mul t4, t2, s1 # k*9
	add t4, t4, t1 # k*9+j
	slli t4, t4, 2 # (k*9+j)*4
	add t4, s3, t4 # load adress of B[k][j] into t4
	lw a0, 0(t4) # load value of B[k][j] into a0 (temp registr for multipying A[i][k] with B[k][j])
	mul t6, t6, a0 # A[i][k] * B[k][j]
	add t3, t3, t6 # sum += A[i][k] * B[k][j]
	addi t2, t2, 1 # k++
	b loop_k

k_done:
	sw t3, 0(t5) #save value of t3(sum) into mem address of c[i][j](t5)
	addi t1, t1, 1 # j++
	b loop_j

j_done:
	addi t0, t0, 1 # i++
	b loop_i

i_done:


# End CODE

	la	a0, msgc
	la	a1, matrix_c
	add	a2, s1, zero			# 9 rows, 9 cols for C
	add	a3, s1, zero
	jal	PRINT_MAT

	li	a7, 10
	ecall

PRINT_MAT:
	li	a7, 4
	ecall
	addi	a4, x0, 0
PL4:	bge	a4, a3, PL1
	addi	a5, x0, 0
PL3:	bge	a5, a2, PL2
	lw	a0, 0(a1)
	li	a7, 1
	ecall
	la	a0, space
	li	a7, 4
	ecall
	addi	a1, a1, 4
	addi	a5, a5, 1
	b	PL3
PL2:	addi	a4, a4, 1
	la	a0, nline
	li	a7, 4
	ecall
	b	PL4
PL1:	jr	ra
