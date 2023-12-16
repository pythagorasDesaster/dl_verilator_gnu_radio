from sys import argv
import json

json_file     = argv[1]
template_file = argv[2]
so_file       = argv[3]
try:
	clock_port = argv[4].strip()
except IndexError:
	clock_port = ''

with open(json_file, 'r') as file:
	json_text = file.read()
	dat       = json.loads(json_text)

input_code   = '\n'.join(['- label: ' + port[0] + '\n  domain: stream\n  dtype: int' for port in dat["inputs"] if port[0] != clock_port])
output_code  = '\n'.join(['- label: ' + port[0] + '\n  domain: stream\n  dtype: int' for port in dat["outputs"]])

output_file   = 'dlverilog_' + dat["name"] + '_verilog.block.yml'
# edit template and save as new file
with open(output_file, 'w') as ofile:
	with open(template_file, 'r') as ifile:
		temp = ifile.read()
		temp = temp.replace('# > INPUTS < #', input_code)
		temp = temp.replace('# > OUTPUTS < #', output_code)
		temp = temp.replace('> TOP <', dat["name"])
		temp = temp.replace('> SO_FILE <', so_file)
		ofile.write(temp)
