/*
 *  Copyright (C) 20016 Otto Smith, <otto@123phase.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 ********************************************************************************/
 
include <paraSolids.scad>  ///// MUST BE <include>,  NOT <use> /////

///A test vector
test = [-1,.5,7,-4,0];

////Some passable functions
function @div72(x) = x/72;
function @square(x) = x*x;
function @xsq_ysq(x,y) = abs(y*y-x*x);
function @add(x,y)  = x+y;
function @sinTimes(a,b) = abs(sin(a)*b/5);
function @sinTimesR(r,a) = abs(r-abs(3*cos(a-1)));


echo([div72,square,add,sinTimes])
echo(map(square, test));
echo(map(div72, test));
echo(reduce(add, test));
echo(reduce(sinTimes,test));
echo(filter(div72,test));
echo("DONE WITH TESTS");

////2D examples Uncomment to see.+
//yIsFx(square,xseg=[-3,3],grid=30);
//rIsFa(div72, angle=330, ticks=30);

///3D

//zIsFxy(xsq_ysq, diag=([[1.5,3],[-1.5,-1.5]]), gridx = 20, gridy = 20);
//zIsFxy(add, diag=([[0,2],[3,0]]));
//rIsFza(sinTimes, zseg=[0,5], ticks=30, grid=30);
//zIsFarIsFa(div72,fra=sinTimesR,ticks=40,grid=20);
 
mandelMax = 150;
function mandel(cons,maxcount=mandelMax,z=[0,0]) =
    maxcount==0 ? mandelMax-maxcount
                :(norm(z)> 2 ? mandelMax-maxcount 
                             : mandel(cons, 
                                      maxcount-1,
                                      [z[0]*z[0]-z[1]*z[1],z[0]*z[1]*2]+cons
                                      )
                  );                               
function @testMandel(x,y) = log(mandel([x,y]))/3; 
//zIsFxy(testMandel,diag=[[-2,2],[2,-2]],gridx=100, gridy=100);