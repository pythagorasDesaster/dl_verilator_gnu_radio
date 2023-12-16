#include "dl_verilator.hpp"

#include <iostream>
#include <string>

#include <cstdint>
#include <cassert>

#include <dlfcn.h>

#include <json/json.h>

dlVerilator::dlVerilator (const char* so_file) {
	// open shared object
	dl_handle = dlopen(so_file, RTLD_LAZY);
	if (dl_handle == NULL) {
	    std::cout << "cant open failed shared object" << std::endl;
	}

	constructor = (void (*)(void))dlsym(dl_handle, "Vtop_Vtop");
	assert(constructor != NULL);
	modelName = (const char* (*)(void))dlsym(dl_handle, "Vtop_modelName");
	assert(modelName != NULL);
	getInfo = (const char* (*)(void))dlsym(dl_handle, "Vtop_getInfo");
	assert(getInfo != NULL);
	eval = (void (*)(void))dlsym(dl_handle, "Vtop_eval");
	assert(eval != NULL);
	setInputs = (void (*)(uint32_t*))dlsym(dl_handle, "Vtop_setInputs");
	assert(setInputs != NULL);
	getOutputs = (void (*)(uint32_t*))dlsym(dl_handle, "Vtop_getOutputs");
	assert(getOutputs != NULL);

	constructor();

	Json::Value  root;
    Json::Reader reader;
    reader.parse(getInfo(), root);

	name        = root["name"].asString();

	for (int i = 0; i < root["inputs"].size(); i++) {
		auto e = root["inputs"][i];
		ports.push_back((port_t){e[0].asString(), PORT_IN, (uint8_t)i, (uint8_t)e[1].asUInt()});
	}

	for (int i = 0; i < root["outputs"].size(); i++) {
		auto e = root["outputs"][i];
		ports.push_back((port_t){e[0].asString(), PORT_OUT, (uint8_t)i, (uint8_t)e[1].asUInt()});
	}

	clock_port.type = PORT_NONE;
	if (root["clock"].size() > 0) {
		auto clock_name = root["clock"][0].asString();
		for (int i = 0; i < root["inputs"].size(); i++) {
			auto e = root["inputs"][i];
			if (e[0].asString() == clock_name) {
				clock_port = (port_t){clock_name, PORT_IN, (uint8_t)i, (uint8_t)e[1].asUInt()};
				break;
			}
		}
	}
}

dlVerilator::~dlVerilator () {
	dlclose(dl_handle);
}


void dlVerilator::proccess(uint32_t* in, uint32_t* out) {
	if (in != NULL)  setInputs(in);
	eval();
	if (out != NULL) getOutputs(out);
}

std::vector<dlVerilator::port_t> dlVerilator::get_ports() {
	return ports;
}

std::string dlVerilator::get_name() {
	return name;
}