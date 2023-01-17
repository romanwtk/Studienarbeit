#!/usr/bin/env sage
print("### REED-SOLOMON ENCODING")
print("### This sage script allows you to perform a systematic Reed-Solomon encoding over a finite field F_q.")
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
m = input(f"\nPlease type in message tupel\n(m0,m1,...,m{k-1}) of F_({q})^{k}: \t")
m = [F_q(x) for x in m[1:-1].split(",")]

if len(m) != k:
	print("\nERROR: The provided message has not exactly k digits!")
	exit()

m_poly = 0
i = 0
while i < len(m):
	m_poly += (m[i])*(x**i)
	i += 1

print(f"\nMessage Polynomial: \t\t{m_poly}")

# Coding steps
(_, r) = (m_poly * x**(n-k)).quo_rem(g)
print(f"\nRemainder Polynomial: \t\t{r}")

m_shifted = (m_poly * x**(n-k))
print(f"\nShifted Message Polynomial: \t{m_shifted}")

c = m_shifted + r
print(f"Concatenated Codeword: \t\t{c}")

coefficients = c.coefficients(sparse=False)

while len(coefficients) < n:
	coefficients = [0]+coefficients

print(f"\nCodeword Coefficients: \t\t{coefficients}")
