#!/usr/bin/env sage
print("### GENERALIZED REED-SOLOMON ENCODING")
print("### This sage script allows you to perform a (non-)systematic Generalized Reed-Solomon encoding over a finite field F_q.")
print("### (C) Roman Wetenkamp, 2023.\n")

# Basic Code properties
q = input("Please type in q, e.g. 2^2: \t\t")
n = int(input("Please type in length n: \t\t"))
k = int(input("Please type in dimension k: \t\t"))

# Generate Galois field
F_q = None
if len(q.split("^")) < 2:
	F_q.<a> = GF(int(q))
elif len(q.split("^")) == 2:
	F_q.<a> = GF(pow(int(q.split("^")[0]), int(q.split("^")[1])))
else:
	print(f"ERROR:\tSorry, unable to work with this q={q}!")
	exit(1)

# GRS Code properties
a = input(f"\nPlease type in evaluation tupel \na = (a_0, a_1, ..., a_{n-1}): \t\t")
a = [F_q(x) for x in a[1:-1].split(",")]

if len(a) != n:
	print(f"ERROR:\tTupel length {len(a)} differs from code length {n}!")
	exit(1)

for element in a:
	if a.count(element) > 1:
		print("ERROR:\tElements of a must be pairwise distinct!")
		exit(1)
	else:
		pass

v = input(f"Please type in weight tupel \nv = (v_0, v_1, ..., v_{n-1}): \t\t")
v = [F_q(x) for x in v[1:-1].split(",")]

if len(v) != n:
	print(f"ERROR:\tTupel length {len(v)} differs from code length {n}!")
	exit(1)

for element in v:
	if v == 0:
		print("ERROR:\tElements of v must not be zero!")
		exit(1)
	else:
		pass

# Generate Generator Matrix G of GRS_k(a, v)
rows = []
i = 0
while i < k:
	row = []
	j = 0
	while j < n:
		row.append(v[j]*(a[j]**i))
		j += 1
	rows.append(row)
	i += 1

G = matrix(F_q, rows)

print(f"\nGenerator matrix: \n{G}")

# Generate systematic Generator Matrix G_S of GRS_k(a, v)
A = G.submatrix(0,0,k,k)
G_S = A.inverse() * G
G_S_c = G.rref()
print(f"\nSystematic form matrix: \n{G_S}")
print(f"\nRow-reduced Echelon form: \n{G_S_c}")

# Perform Encoding
h = input(f"\nPlease type in message tupel \nh = (h_0, ..., h_{k-1}): \t\t\t")
h = [F_q(x) for x in h[1:-1].split(",")]

if len(h) != k:
	print(f"ERROR:\tTupel length {len(h)} differs from input word length {k}!")
	exit(1)

h_v = matrix(F_q, h)

C = h_v * G
C_S = h_v * G_S

print(f"\nCodeword non-systematic approach:\t{C.rows()[0]}")
print(f"Codeword systematic approach:\t\t{C_S.rows()[0]}")
