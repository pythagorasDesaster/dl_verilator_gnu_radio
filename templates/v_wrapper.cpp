#include "V/* > MODULE < */.h"

extern "C" {

static V/* > MODULE < */* Inst;
const char info[] = "/* > INFO < */";

void Vtop_Vtop(void) {
	Inst = new V/* > MODULE < */();
}

const char* Vtop_modelName(void) {
	return Inst->modelName();
}

const char* Vtop_getInfo(void) {
	return info;
}

void Vtop_eval(void) {
	Inst->eval_step();
}

void Vtop_setInputs(uint32_t* in) {
/* > INPUTS < */
}

void Vtop_getOutputs(uint32_t* out) {
/* > OUTPUTS < */
}

}
