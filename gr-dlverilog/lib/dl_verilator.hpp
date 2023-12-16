#ifndef _DL_VERILATOR_HPP
#define _DL_VERILATOR_HPP

#include <cstdint>
#include <string>
#include <vector>

class dlVerilator {
	public:

	enum port_type_e {
		PORT_IN = 0,
		PORT_OUT,
		PORT_NONE,
	};

	struct port_t {
		std::string name;
		port_type_e type;
		uint8_t     index;
		uint8_t     bits;
	};

	port_t              clock_port;

	dlVerilator (const char* so_file) ;
	~dlVerilator () ;

	void proccess(uint32_t* in, uint32_t* out) ;

	std::vector<port_t> get_ports() ;
	std::string         get_name();

	private:
	void        (*constructor)(void);
	const char* (*modelName)(void);
	const char* (*getInfo)(void);
	void        (*eval)(void);
	void        (*setInputs)(uint32_t*);
	void        (*getOutputs)(uint32_t*);

	void* dl_handle;
	std::vector<port_t> ports;
	std::string         name;
};

#endif//_DL_VERILATOR_HPP