/* -*- c++ -*- */
/*
 * Copyright 2002 Free Software Foundation, Inc.
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

#ifndef _GRATSCFIELDSYNCCORRELATOR_H_
#define _GRATSCFIELDSYNCCORRELATOR_H_

#include <VrHistoryProc.h>

class atsci_fs_correlator;

/*!
 * \brief ATSC field sync correlator (float --> float,float)
 *
 * first output is delayed version of input.
 * second output is set of tags, one-for-one with first output.
 *
 * tag values are defined in atsci_sync_tag.h
 */

class GrAtscFieldSyncCorrelator : public VrHistoryProc<float,float>
{

public:

  GrAtscFieldSyncCorrelator ();
  ~GrAtscFieldSyncCorrelator ();

  const char *name () { return "GrAtscFieldSyncCorrelator"; }

  int work (VrSampleRange output, void *o[],
	    VrSampleRange inputs[], void *i[]);

protected:
  atsci_fs_correlator	*d_fsc;
};

#endif /* _GRATSCFIELDSYNCCORRELATOR_H_ */
