/* -*- c++ -*- */
/*
 * Copyright 2023 Thomas Kirchner.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef INCLUDED_DLVERILOG_BASE_VERILOG_H
#define INCLUDED_DLVERILOG_BASE_VERILOG_H

#include <gnuradio/dlverilog/api.h>
#include <gnuradio/sync_block.h>

namespace gr {
namespace dlverilog {

/*!
 * \brief <+description of block+>
 * \ingroup dlverilog
 *
 */
class DLVERILOG_API base_verilog : virtual public gr::sync_block
{
public:
    typedef std::shared_ptr<base_verilog> sptr;

    /*!
     * \brief Return a shared_ptr to a new instance of dlverilog::base_verilog.
     *
     * To avoid accidental use of raw pointers, dlverilog::base_verilog's
     * constructor is in a private implementation
     * class. dlverilog::base_verilog::make is the public interface for
     * creating new instances.
     */
    static sptr make(const char* so_file);
};

} // namespace dlverilog
} // namespace gr

#endif /* INCLUDED_DLVERILOG_BASE_VERILOG_H */
