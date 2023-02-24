#!/usr/bin/env sage
import json

# Key generation
def create_keys():
	# Basic Goppa Code Properties
	q = input("Please type in q, e.g. 2^2: \t\t")
	n = int(input("Please type in length n: \t\t"))
	k = int(input("Please type in dimension k: \t\t"))
	t = int(input("Please type in error capacity t: \t"))

	# Generate Galois field
	F_q = None
	if len(q.split("^")) < 2:
	        F_q.<a> = GF(int(q))
	elif len(q.split("^")) == 2:
		F_q.<a> = GF(pow(int(q.split("^")[0]), int(q.split("^")[1])))
	else:
	        print(f"ERROR:\tSorry, unable to work with this q={q}!")

	# Find a Goppa Polynom
	R.<x> = PolynomialRing(F_q)
	g = R.irreducible_element(t)

	if input("\nShould a specific Goppa polynomial \nof degree t be used? [Y/n] \t\t") in ["Y", "y", ""]:
		g = input("Please enter the Goppa polynomial \nwith x as variable: \t\t\t")
		g = R(g)
		if not g.is_irreducible():
			print(f"\nERROR:\tGiven polynomial is reducible over F_{q}")
			exit()

	print(f"\nGoppa polynomial: \t\t\t{g}")

	# Specifiy set L of all non-roots of g
	# In original McEliece approach, L denotes all elements of F_q
	elements = Set()
	for i in enumerate(F_q):
		_, e = i
		elements = elements.union(Set([e]))

	roots = Set()
	for i in g.roots():
		r, _ = i
		roots = roots.union(Set([r]))

	L = elements.difference(roots)

	print(f"\nSet of all elements: \t\t\t{elements}")
	print(f"Set of all non-root elements: \t\t{L}")

	# Construction of the Parity-check Matrix H
	H_rarr = []
	for i in range(0, k):
		row = []
		for j in L:
			row.append((j**i)/g(j))
		H_rarr.append(row)
	H = Matrix(R, H_rarr)

	print(f"\nParity-Check matrix H: \n{H}")
	
	A = H.submatrix(0,0,k,k)
	H_S = A.inverse() * H

	print(f"\nSystematic Parity-check matrix H: \n{H_S}")

	P = H_S.submatrix(0,k)
	I_n_k = identity_matrix(F_q, n-k)
	G = (-(P.T)).augment(I_n_k)

	print(f"\nGenerator matrix G: \n{G}")

	# Construction of G'
	if input("\nShould a specific scrambling \nk x k-matrix S be used? [Y/n]\t\t") in ["Y", "y", ""]:
		S = input("Please enter the S as a list of lists [[...], [...]]:\t\t")
		print(S.split())
		for i in list(S):
			if i not in (['[', ']', ',', ' ', '^'] + [str(e) for e in elements]):
				print("ERROR:\tUnable to process given S!")
				exit()

		S = Matrix(F_q, eval(S))

	else:
		S = random_matrix(F_q, k, density=1.0)

	print(f"\nScrambling Matrix S: \n{S}")

	if input("\nShould a specific permutation \nn x n-matrix P be used? [Y/n]\t\t") in ["Y", "y", ""]:
		P = input(f"Please enter P as a column-index-list, e.g. [1, ..., {n}]:\t\t")
		for i in list(P):
			if i not in (['[', ']', ',', ' '] + [str(e) for e in range(n+1)]):
				print("\nERROR:\tUnable to process given P!")
				exit()
		P = Permutation(eval(P)).to_matrix()

	else:
		P = Permutations(n).random_element().to_matrix()

	print(f"\nPermutation Matrix P: \n{P}")
	

	# Key generation
	k_pub = S * G * P
	print(f"\nPublic key: \n{k_pub}")
	
	# Save Key files
	if input(f"\nShould the PUBLIC key be saved as 'public_key.json'? [Y/n]\t\t") in ["Y", "y", ""]:
		try:	
			f = open("public_key.json", "w")
			f.write(json.dumps({"q": int(a.multiplicative_order()+1), "n": n, "t": t, "k": k, "key": str(k_pub.rows())}))
			f.close()
		except Exception as e:
			print(e)
			print("\nERROR:\tUnable to write keyfile! Check permissions and try again please.")

	if input(f"\nShould the PRIVATE key be saved as 'private_key.json'? [Y/n]\t\t") in ["Y", "y", ""]:
		try:	
			f = open("private_key.json", "w")
			f.write(json.dumps({"q": int(a.multiplicative_order()+1), "n": n, "t": t, "k": k, "g": str(g), "P": str(P.rows()), "S": str(S.rows()), "G": str(G.rows())}))
			f.close()
		
		except Exception as e:
			print(e)
			print("\nERROR:\tUnable to write keyfile! Check permissions and try again please.")


	return {"q": int(a.multiplicative_order()+1), "n": n, "k": k, "t": t, "g": g, "P": P, "S": S, "G": G, "G'": k_pub}


# Encryption
def encrypt(keys):
	message = input("\nPlease type in the plaintext \nmessage as a list: \t\t\t")
	message = eval(message)

	F_q.<a> = GF(keys["q"])
	
	k_pub = keys["G'"]
	t = keys["t"]
	k = keys["k"]

	n = len(k_pub.columns())
	while len(message) % k != 0:
		message.append(0)
	
	message_blocks = []
	ciphertext_blocks = []
	
	for i in range(0, len(message)//k):
		message_blocks.append(vector(F_q, message[k*i:k+(k*i)]))
	
	for block in message_blocks:
		z = []
		for i in range(n):
			if i < t:
				z.append(1)
			else:
				z.append(0)
		z = vector(F_q, z) * Permutations(n).random_element().to_matrix()
		bk = block * k_pub
				
		encrypted_block = bk + z
		ciphertext_blocks.append(encrypted_block)
	
	return ciphertext_blocks


# Decryption (Placeholder)
def decrypt(keys):
	print("\nERROR:\tDecryption is currently not implemented.")
	exit()


if __name__ == "__main__":
	print("### McEliece CRYPTPOSYSTEM ENCRYPTION")
	print("### This sage script allows you to perform a McEliece cryptosystem encryption.")
	print("### (C) Roman Wetenkamp, 2023.\n")

	# Search for valid key files
	keys = {"q": None, "n": None, "t": None, "k": None, "g": None, "P": None, "S": None, "G": None, "G'": None}
	mode = 0	

	try:
		f = open("public_key.json", "r")
		pubcon = json.loads(f.read())
		keys["q"] = pubcon["q"]
		F_q.<a> = GF(keys["q"])
		R.<x> = PolynomialRing(F_q)
			
		keys["n"] = pubcon["n"]
		keys["t"] = pubcon["t"]
		keys["k"] = pubcon["k"]
		
		keys["G'"] = pubcon["key"]
		keys["G'"] = keys["G'"].replace("^", "**")
		keys["G'"] = Matrix(F_q, eval(keys["G'"], {"a": F_q.gen()}))			
		
		try:
			h = open("private_key.json", "r")
			content = json.loads(h.read())
					
			content["g"] = content["g"].replace("^", "**")
			content["S"] = content["S"].replace("^", "**")
			content["G"] = content["G"].replace("^", "**")

			keys["g"] = R(eval(content["g"], {"a": F_q.gen(), "x": R.gen()}))
			keys["P"] = Matrix(F_q, eval(content["P"]))
			keys["S"] = Matrix(F_q, eval(content["S"], {"a": F_q.gen()}))
			keys["G"] = Matrix(F_q, eval(content["G"], {"a": F_q.gen()}))
		
		except Exception as e:
			print(e)
			print("\nWARNING:\tNo private keyfile found - thus only encryption is possible")
			mode = 1						
	
	except Exception as e:
		print(e)
		print("\nNo valid keyfile found - Key generation is starting ...\n")
		keys = create_keys()
	
	if mode == 0:
		mode = int(input("Please choose a mode \n(1 - Encryption, 2 - Decryption):\t"))
	
	if mode == 1:
		print(f"\nCiphertext blocks:\t\t\t{encrypt(keys)}")
	
	if mode == 2:
		decrypt(keys)
