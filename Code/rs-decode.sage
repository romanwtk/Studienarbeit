#!/usr/bin/env sage
print("### REED-SOLOMON DECODING")
print("### This sage script allows you to perform a Reed-Solomon decoding over a finite field F_q.")
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

# Generate RS-Code
R.<x> = PolynomialRing(F_q)
g = prod(x - a**i for i in range(1, n-k+1))
print(f"\nGenerator Polynomial: \t\t{g}")	

# Convert Message tupel m = (m_0, m_1, ..., m_{k-1}) to polynomial
y = input(f"\nPlease type in codeword tupel\n(c0,c1,...,c{n-1}) of F_({q})^{n}: \t")
y = [F_q(x) for x in c[1:-1].split(",")]

if len(y) != n:
	print("\nERROR: The provided codeword has not exactly n digits!")
	exit()

y_poly = 0
i = 0
while i < len(y):
	y_poly += (y[i])*(x**i)
	i += 1

print(f"\nCodeword Polynomial: \t\t{y_poly}")

# Syndrome computation
S = []
ctr = 0
for i in g.roots():
	(i, _) = i
	S.append(y_poly(x=i))
	ctr += 1
print(f"Syndromes: \t\t\t{S}")

# Syndrome polynomial
S_poly = 0
i = 0
while i < len(S):
	S_poly += (S[i])*(x**i)
	i += 1
print(f"Syndrome Polynomial: \t\t{S_poly}")
