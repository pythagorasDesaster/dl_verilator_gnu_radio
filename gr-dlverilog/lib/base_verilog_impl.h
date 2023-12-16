/* -*- c++ -*- */
/*
 * Copyright 2023 Thomas Kirchner.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef INCLUDED_DLVERILOG_BASE_VERILOG_IMPL_H
#define INCLUDED_DLVERILOG_BASE_VERILOG_IMPL_H

#include <gnuradio/dlverilog/base_verilog.h>

#include "dl_verilator.hpp"

namespace gr {
namespace dlverilog {

class base_verilog_impl : public base_verilog
{
private:
    dlVerilator* model;
    int num_inputs;
    int num_outputs;

public:
    base_verilog_impl(const char* so_file);
    ~base_verilog_impl();

    // Where all the action really happens
    int work(int noutput_items,
             gr_vector_const_void_star& input_items,
             gr_vector_void_star& output_items);
};

} // namespace dlverilog
} // namespace gr

#endif /* INCLUDED_DLVERILOG_BASE_VERILOG_IMPL_H */
