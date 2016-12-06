#!/usr/bin/python

import hashlib
import itertools
import sys
import enum

class Mode(enum.Enum):
	simple = 0
	positional = 1

def decode_password(id, length, mode=Mode.simple):
	def digest_generator(id):
		for i in itertools.count():
			m = hashlib.md5()
			m.update(id.encode('utf-8'))
			m.update(str(i).encode('utf-8'))
			digest = m.hexdigest()
			if digest[0:5] == '00000':
				yield digest
	digest = digest_generator(id)
		
	def decode_simple(id, length):
		password = []
		while len(password) < length:
			password.append(next(digest)[5])
		return password
		
	def decode_positional(id, length):
		password = {}
		while len(password) < length:
			pos, val = next(digest)[5:7]
			print(pos, val)
			try:
				pos = int(pos)
			except ValueError:
				continue
			if pos < length and pos not in password:
				password[pos] = val
		return (password[i] for i in range(0, length))

	return "".join({ 
		Mode.simple: decode_simple, 
		Mode.positional: decode_positional
	}[mode](id, length))

for mode in [Mode.simple, Mode.positional]:
	password = decode_password("abbhdwsy", 8, mode=mode)
	print("{}: {}".format(mode, password))		

