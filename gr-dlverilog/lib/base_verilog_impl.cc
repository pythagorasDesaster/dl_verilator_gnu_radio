/* -*- c++ -*- */
/*
 * Copyright 2023 Thomas Kirchner.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "base_verilog_impl.h"
#include <gnuradio/io_signature.h>
#include <iostream>

#define MAX_IO 32

namespace gr {
namespace dlverilog {

using input_type  = u_int;
using output_type = u_int;
base_verilog::sptr base_verilog::make(const char* so_file)
{
    return gnuradio::make_block_sptr<base_verilog_impl>(so_file);
}

/*
 * The private constructor
 */
base_verilog_impl::base_verilog_impl(const char* so_file)
    : gr::sync_block("base_verilog",
                     gr::io_signature::make(
                         1 /* min inputs */, MAX_IO /* max inputs */, sizeof(input_type)),
                     gr::io_signature::make(
                         1 /* min outputs */, MAX_IO /*max outputs */, sizeof(output_type)))
{
    model = new dlVerilator(so_file);
    std::cout << "initialised: " << so_file << std::endl;
    num_inputs = 0;
    for (auto p : model->get_ports()) if (p.type == dlVerilator::PORT_IN) num_inputs++;
    num_outputs = 0;
    for (auto p : model->get_ports()) if (p.type == dlVerilator::PORT_OUT) num_outputs++;
}

/*
 * Our virtual destructor.
 */
base_verilog_impl::~base_verilog_impl() {
    delete model;
}

int base_verilog_impl::work(int noutput_items,
                            gr_vector_const_void_star& input_items,
                            gr_vector_void_star& output_items)
{
    input_type  ins[MAX_IO];
    output_type outs[MAX_IO];

    if (model->clock_port.type == dlVerilator::PORT_NONE) {
        for (int i = 0; i < noutput_items; i++) {
            for (int e = 0; e < num_inputs; e++) {
                ins[e] = static_cast<const input_type*>(input_items[e])[i];
            }
            model->proccess(ins, outs);
            for (int e = 0; e < num_outputs; e++) {
                static_cast<output_type*>(output_items[e])[i] = outs[e];
            }
        }
    } else {
        int offset;
        for (int i = 0; i < noutput_items; i++) {
            offset = 0;
            for (int e = 0; e < num_inputs; e++) {
                if (e == model->clock_port.index) {
                    offset = -1;
                } else {
                    ins[e] = static_cast<const input_type*>(input_items[e + offset])[i];
                }
            }
            ins[model->clock_port.index] = 1;
            model->proccess(ins, outs);
            ins[model->clock_port.index] = 0;
            model->proccess(ins, outs);
            for (int e = 0; e < num_outputs; e++) {
                static_cast<output_type*>(output_items[e])[i] = outs[e];
            }
        }
    }

//    std::cout << model->name << " worked!" << std::endl;

    return noutput_items;
}

} /* namespace dlverilog */
} /* namespace gr */
