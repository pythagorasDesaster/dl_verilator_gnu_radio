from sys import argv
import json

json_file     = argv[1]
template_file = argv[2]
output_file   = argv[3]

with open(json_file, 'r') as file:
	json_text = file.read()
	dat       = json.loads(json_text)

input_code  = '\n'.join(["	Inst->" + sig[0] + " = in[" + str(num) + "];" for num, sig in enumerate(dat["inputs"])])
output_code = '\n'.join(["	out[" + str(num) + "] = " + "Inst->" + sig[0] + ";" for num, sig in enumerate(dat["outputs"])])

# edit template and save as new file
with open(output_file, 'w') as ofile:
	with open(template_file, 'r') as ifile:
		temp = ifile.read()
		temp = temp.replace('/* > INPUTS < */', input_code)
		temp = temp.replace('/* > OUTPUTS < */', output_code)
		temp = temp.replace('/* > INFO < */', json_text.replace('"', '\\"'))
		temp = temp.replace('/* > MODULE < */', dat["name"])
		ofile.write(temp)

