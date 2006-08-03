/* -*- c++ -*- */
/*
 * Copyright 2005 Free Software Foundation, Inc.
 * 
 * This file is part of GNU Radio
 * 
 * GNU Radio is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 * 
 * GNU Radio is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with GNU Radio; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

GR_SWIG_BLOCK_MAGIC(gr,pll_carriertracking_cc);

gr_pll_carriertracking_cc_sptr
gr_make_pll_carriertracking_cc (float alpha, float beta, 
				float max_freq, float min_freq);

class gr_pll_carriertracking_cc : public gr_sync_block
{
 private:
  gr_pll_carriertracking_cc (float alpha, float beta, float max_freq, float min_freq);
 public:
  bool lock_detector(void);
  bool  squelch_enable(bool);
  float set_lock_threshold(float);

};
