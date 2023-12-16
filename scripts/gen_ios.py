from sys import argv
import json

verilog_file = argv[1]
module_name  = argv[2]
json_file    = argv[3]
try:
	clock_port = argv[4].strip()
except IndexError:
	clock_port = ''

def between(text, begin, end):
	cnt  = 1
	ret  = []
	half = text.split(begin)
	while True:
		if cnt < len(half):
			ret.append(half[cnt].split(end)[0].strip())
			if (ret[-1] == '') : ret.pop(-1)
			cnt += 1
		else:
			break
	return ret

def parse_bits(io):
	if '[' in io:
		ran = [int(n) for n in between(io, '[', ']')[0].split(':')]
		if (len(ran) != 2):
			print("wtf is that?!?")
			exit(1)
		return ran[0] - ran[1] + 1
	else:
		return 1

with open(verilog_file, 'r') as file : verilog = file.read()

decl = [i for i in between(verilog, 'module', ';') if i.split('(')[0].strip() == module_name][0]
ios  = [i.strip() for i in between(decl, '(', ')')[0].split(',')]

inputs  = []
outputs = []

vode = [m for m in between(verilog, 'module', 'endmodule') if module_name in m.split(';')[0]][0].split(';')

in_code_lut = []

for l in vode:
	if 'input' in l or 'output' in l:
		in_code_lut.append(l.strip())

for io in ios:
	bits = parse_bits(io)
	if (bits > 32):
		print("max supported bits = 32")
		exit(1)

	words = [i.strip() for i in io.split(' ')]
	if (words[0] == 'input'):
		inputs.append((words[-1], bits))
	elif (words[0] == 'output'):
		outputs.append((words[-1], bits))
	else:
		# everybody gets a secound chance
		for e in in_code_lut:
			wl = [i.strip() for i in e.split(' ')]
			for w in wl:
				if w == words[-1]:
					bits = parse_bits(e)
					if (wl[0] == 'input'):
						inputs.append((words[-1], bits))
					elif (wl[0] == 'output'):
						outputs.append((words[-1], bits))
					break

clock_input = ()
if clock_port != '':
	if clock_port in [i[0] for i in inputs]:
		clock_input = inputs[next(i for i, e in enumerate(inputs) if e[0] == clock_port)]
	else:
		print("ERROR: clockport does not exist")
		exit(1)

with open(json_file, 'w') as file:
	file.write(json.dumps({'name': module_name, 'inputs': inputs, 'outputs': outputs, 'clock': clock_input}))

