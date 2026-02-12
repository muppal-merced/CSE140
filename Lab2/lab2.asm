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

# 9 rows -> s1 (n)
# 10 cols -> s0 (m)
# matrix c -> s4 (base matrix c)
# i -> t0 (row index of matrix C and matrix A)
# j -> t1 (column index of matrix C and matrix B)
# k -> t2 (sums over columns of A / rows of B)
# sum -> t3 (accumulates sum for C[i][j])

# represent 2d arr as 1d by using formula index = matrix (row * width + col) * 4 bytes
# width = num of cols n
# Example:
# to access c[2][3] in 9x9 mat, offset = 2*9 + 3 = 21
# adress = base + 21*4 = base + 84 bytes



	addi t0, x0, 0 # i = 0
loop_i:
	bge	t0, s1, end_i # if i >= 9 done
	addi t1, x0, 0 # j = 0
loop_j:
	bge	t1, s1, end_j # if j >= 9 next i
	addi t2, x0, 0 # k = 0
	addi t3, x0, 0 # sum = 0
	# C[i][j]: matrix_c + (9*i + j)*4
	mul	t4, t0, s1 # t4 = 9*i
	add	t4, t4, t1 # t4 = 9*i + j
	slli t4, t4, 2 # byte offset
	add	t5, s4, t4 # t5 =  adress of C[i][j]
loop_k:
	bge	t2, s0, end_k # if k >= 10 done dot product
	# A[i][k]: matrix_a + (10*i + k)*4
	mul	t4, t0, s0 # t4 = 10*i
	add	t4, t4, t2 # t4 = 10*i + k
	slli t4, t4, 2
	add	t4, s2, t4
	lw	t6, 0(t4) # t6 = A[i][k]
	# B[k][j]: matrix_b + (9*k + j)*4
	mul	t4, t2, s1 # t4 = 9*k
	add	t4, t4, t1 # t4 = 9*k + j
	slli t4, t4, 2
	add	t4, s3, t4
	lw	a0, 0(t4) # a0 = B[k][j]
	mul	t6, t6, a0
	add	t3, t3, t6 # sum += A[i][k]*B[k][j]
	addi t2, t2, 1
	b	loop_k # branch to loop_k
end_k:
	sw	t3, 0(t5) # C[i][j] = sum
	addi t1, t1, 1
	b	loop_j # branch to loop_j
end_j:
	addi t0, t0, 1
	b	loop_i # branch to loop_i
end_i:

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
