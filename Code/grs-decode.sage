#!/usr/bin/env sage
print("### GENERALIZED REED-SOLOMON DECODING")
print("### This sage script allows you to perform a GRS decoding over a finite field F_q.")
print("### (C) Roman Wetenkamp, 2023.\n")

# Basic Code properties
q = input("Please type in q, e.g. 2^2: \t")
n = int(input("Please type in length n: \t"))
k = int(input("Please type in dimension k: \t"))

# Generate Galois field
F_q = None
if len(q.split("^")) < 2:
	F_q.<a> = GF(int(q))
elif len(q.split("^")) == 2:
	F_q.<a> = GF(pow(int(q.split("^")[0]), int(q.split("^")[1])))
else:
	print(f"Sorry, unable to work with this q={q}!")

# Generate GRS-Code
ae = input(f"\nPlease type in evaluation tupel \na = (a_0, a_1, ..., a_{n-1}): \t")
ae = [F_q(x) for x in ae[1:-1].split(",")]

if len(ae) != n:
        print(f"ERROR:\tTupel length {len(ae)} differs from code length {n}!")
        exit(1)

for element in ae:
        if ae.count(element) > 1:
                print("ERROR:\tElements of a must be pairwise distinct!")
                exit(1)
        else:
                pass

v = input(f"Please type in weight tupel \nv = (v_0, v_1, ..., v_{n-1}): \t")
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
 
y = input(f"\nPlease type in word tupel\n(r0,r1,...,r{n-1}) of F_({q})^{n}: \t")
y = [F_q(x) for x in y[1:-1].split(",")]

if len(y) != n:
	print("\nERROR: The provided codeword has not exactly n digits!")
	exit()

# Generate Generator matrix G
rows = []
i = 0
while i < k:
        row = []
        j = 0
        while j < n:
                row.append(v[j]*(ae[j]**i))
                j += 1
        rows.append(row)
        i += 1

G = matrix(F_q, rows)
A = G.submatrix(0,0,k,k)
G_S = A.inverse() * G

d = []
for i in range(len(v)):
	d_c = ~v[i] * prod(~(ae[i] - ae[j]) for j in range(0, n) if i != j)
	d.append(d_c)

# Now generate Parity check matrix H
P = G_S.submatrix(0,k)
I_n_k = identity_matrix(F_q, n-k)
H = (-(P.T)).augment(I_n_k)

# print("\nParity-check Matrix H:\n")
# print(H)
print(f"\nParity-check Coefficients d: \t{d}")

# Syndrome computation
S = []
for i in range(0, n-k):
	S_j = 0
	for j in range (0, n):
		S_j += y[j] * d[j] * ae[j]**i
	S.append(S_j)

print(f"\nSyndromes: \t\t\t{S}")

if S[1] == 0 and S[1:].count(S[1]) == len(S[1:]):
	print("\n\nINFO: The provided word is a correct codeword and was received error-free!") 
	exit(0)

R.<x> = PolynomialRing(F_q)

# Construct Syndrom-matrix M
mu = (n-k)//2
M = []
for i in range(0, n-k-mu):
	row = []
	for j in range(i, mu+i+1):
		row.append(S[j])
	M.append(row)
print(f"Matrix M_{mu}: \t\t\t{M}")
M = Matrix(R, M)
		
print(f"\nMaximal number of Errors: \t{mu}")

# Key Equation
# S_0 \sigma_e-1 + S_1 \sigma_e-2 + ... + S_e-1 \sigma_0 = 0	
SigCoeff = M.right_kernel().basis()[0]
print(f"\nCoefficients of ELP \sigma: \t{list(SigCoeff)}")

G.<z> = PolynomialRing(F_q)
sigma = sum(G(SigCoeff[i]) * z^(i) for i in range(0, mu+1))

print(f"\nError-locator Polynomial: \t{sigma}")

err_loc = []
for i in range(0, n):
	if sigma(ae[i]) == 0:
		print(f"Found an error at \t\t{i}")
		err_loc.append(i)

# Compute Error Magnitudes E_1, ..., E_v
S_m = []
X_m = []
for i in range(0, n-k):
	S_m.append(S[i])
	X_row = []
	for j in range(0, len(err_loc)):
		X_row.append(d[err_loc[j]] * ae[err_loc[j]]**i)
	X_m.append(X_row)

S_m = Matrix(R, S_m)
X_m = Matrix(R, X_m)

E_m = X_m.solve_right(S_m.T)
E_m = E_m.list()

print(f"\nError magnitudes: \t\t{E_m}")

# Construct Error-Correction Codeword
e = []
for i in range(n):
	if i in err_loc:
		e.append(E_m[err_loc.index(i)])
	else:
		e.append(0)

print(f"Error-Correction Codeword e: \t{e}")

# Correct Errors
c = []
for i in range(n):
	c.append(y[i] - e[i])

print(f"\nCorrected Codeword c: \t\t{c}")
