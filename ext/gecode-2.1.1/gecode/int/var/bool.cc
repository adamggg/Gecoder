/* -*- mode: C++; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/*
 *  Main authors:
 *     Christian Schulte <schulte@gecode.org>
 *
 *  Copyright:
 *     Christian Schulte, 2006
 *
 *  Last modified:
 *     $Date: 2008-01-31 21:06:01 +0100 (Thu, 31 Jan 2008) $ by $Author: schulte $
 *     $Revision: 6024 $
 *
 *  This file is part of Gecode, the generic constraint
 *  development environment:
 *     http://www.gecode.org
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions:
 *
 *  The above copyright notice and this permission notice shall be
 *  included in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 *  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 *  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 *  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 *  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#include "gecode/int.hh"

namespace Gecode {

  BoolVar::BoolVar(Space* home, int min, int max) {
    if ((min < 0) || (max > 1))
      throw Int::NotZeroOne("BoolVar::BoolVar");
    if (min > max)
      throw Int::VariableEmptyDomain("BoolVar::BoolVar");
    if (min > 0)
      varimp = &Int::BoolVarImp::s_one;
    else if (max == 0)
      varimp = &Int::BoolVarImp::s_zero;
    else
      varimp = new (home) Int::BoolVarImp(home,0,1);
  }

  void
  BoolVar::init(Space* home, int min, int max) {
    if ((min < 0) || (max > 1))
      throw Int::NotZeroOne("BoolVar::init");
    if (min > max)
      throw Int::VariableEmptyDomain("BoolVar::init");
    if (min > 0)
      varimp = &Int::BoolVarImp::s_one;
    else if (max == 0)
      varimp = &Int::BoolVarImp::s_zero;
    else
      varimp = new (home) Int::BoolVarImp(home,0,1);
  }

}

// STATISTICS: int-var
