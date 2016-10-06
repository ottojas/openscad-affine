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
 *************************************************************************************
 Tests and examples for affine.scad
 */
 include <affine.scad>

//// Module constructed from affine aRpp to rotate about line through two points.
module rotatepp(angle,p1,p2)
{
    arot = aRpp(angle,p1,p2);
    apply(arot) children();
}

//// Module constructed from affine aMpp to mirror about plane
//// everywhere orthogonal to vector p2-p1 through p1.
module mirrorpp(p1,p2)
{
    amirror = aMpp(p1,p2);
    apply(amirror) children();
}

////Builds one step of a stair for test1
module stair(depth,incAngle,rin,rout)
{
   cas = tan(incAngle);
   linear_extrude(height=depth){ polygon([[rin,0],[rin,cas*rin],[rout,cas*rout],[rout,0]]); }
}

//// Set only one test to true or get ugly results
test1=true;
test2=false;
test3=false;
test4=false;
test5=false;

//// Some values for tests
origin = [0,0,0];
v1 = [1,1,1];
v2 = [2,2,2];
v3 = [0,0,3];
v11=[-4,2,7];
v22=[-1,-3,-1];


if(test1)
{
//// TEST1 affine power.  affine times affine
   //// Stair case   
   rin = 2.1;
   rout = 4.5;
   depth = .03;
   rise = .21;
   totalAngle = 450;
   numberStairs = 50;
   incAngle=totalAngle/numberStairs;
   totalAffine = aXa(aS(off=[0,0,rise]),aRv(-incAngle,[0,0,1]));
   for(i=[0:numberStairs])
   {
     apply(aPow(totalAffine,i)) stair(depth,incAngle,rin,rout);
   }  
}   


if(test2)
{
//// TEST 2.  Print out 4 rotations.  Last should be equal to first (its close!)
rot = aRpp(90,v3,v2);
echo([rot,aPow(rot,1),aPow(rot,2),aPow(rot,3),aPow(rot,4)]);
}
   
if(test3)
{    
   //// This shows that the modules above for rotate and mirror work
   ///Draw cylinder through v3, v2 to show axis of rotation.
    hull() {translate(v2) sphere(.2); translate(v3) sphere(.2);}

   ///Draw rect solid
   cube([.5,2,3]);
   /// Draw rotated solid about v2,v3
   rotatepp(165,v3,v2) cube([.5,2,3]);
   /// Draw mirrored on plane through v3
   mirrorpp(v3,v2) rotatepp(165,v3,v2)  cube([.5,2,3]);
}

if(test4)
{
   //// Generates the same as the above using affines directly
   ///Draw cylinder through v3, v2 to show axis of rotation.
    hull() {translate(v2) sphere(.2); translate(v3) sphere(.2);}

   ///Affine to rotate as above
   rot = aRpp(165,v3,v2);
   //Affine to mirror as above
   mir = aMpp(v3,v2);
   ///combined mirror rotate
   mrt = aXa(mir,rot); //really wish we overloaded '*' here

   cube([.5,2,3]);
   apply(rot) cube([.5,2,3]);
   apply(mrt) cube([.5,2,3]); //We used a cube to distinguish from solid.
}

if(test5)
{
///////////////// Miscelaneous test data from original debugs
///////////////// Both printed and displayed.    
   echo("\n  TEST VARIABLES "); 
   testM3 = [[2,3,4],[-2,5,7],[.1,-3,6]];
   testM2 = [[2,3],[-2,5]];
   testV = [-1,2,-3];
   echo("testM3 = [[2,3,4],[-2,5,7],[.1,-3,6]];");
   echo("testM2 = [[2,3],[-2,5]];"); 
   echo("testV = [-1,2,-3];");  
    
   echo("\n  TEST 22 matrix inverses");
   echo("mI(testM2) =", mI(testM2)); 
   echo("mI(testM3) =", mI(testM3));
   echo("testM3 * mI(testM3) =", testM3 * mI(testM3)); 
    
   echo("\n  TEST 4444 matrix transpose"); 
   echo("mT(testM2) =",mT(testM2));
   echo("mT(testM3) =",mT(testM3));
   
   echo("\n  MORE TEST VARIABLES "); 
   testM4 = [[2,3,4,-1],[-2,5,7,2],[.1,-3,6,0],[0,0,0,1]];
   echo("testM4 = [[2,3,4,-1],[-2,5,7,2],[.1,-3,6,0,-3],[0,0,0,1]];");
   
   echo("\n  55555 affine form from transform matrix and back");
   echo("aDm(testM4) =",aDm(testM4));
   echo("mDa(aDm(testM4)) =",mDa(aDm(testM4)));
   echo("aDm(testM4) =",aDm(testM4));
   echo("mDa(aDm(testM4)) =",mDa(aDm(testM4)));
   
   echo("\n  666666 affine times a vector");
   echo("aXv(aDm(testM4),testV) =",aXv(aDm(testM4),testV));
   echo("aXv(aDm(testM4),testV) =",aXv(aDm(testM4),testV));
   
   echo("\n  7777777 affine inverse returns original vector");
   echo("aXv(aI(aDm(testM4),testV),aXv(aDm(testM4),testV)) =",
         aXv(aI(aDm(testM4),testV),aXv(aDm(testM4),testV)));
   echo("aXv(aI(aDm(testM4),testV),aXv(aDm(testM4),testV)) =",
         aXv(aI(aDm(testM4),testV),aXv(aDm(testM4),testV)));  
     
   echo("\n  88888888 affine generator functions");
   echo("arxy(45) =", arxy(45));
   echo("aDpppp([[1,5,1],[0,.5,2],[2,1,2]],[1,1,1]) =",
         aDpppp([[1,5,1],[0,.5,2],[2,1,2]],[1,1,1]));
   echo("aRv(90,[1,1,3]) =", aRv(90,[1,1,3]));      
        
 
   echo("\n\n\n");

//// test aRpp
$fn=31;
angle=190;
twi = 125;

hull()
{translate(v11) sphere(.2); translate(v22) sphere(.2);}

//translate(-v11) hull()
//{translate(v11) sphere(.2); translate(v22) sphere(.2);}

myrot = aRpp(angle,v11,v22);

for( i=[0:60:angle] )
{  
apply (aMpp(v11,v22))    
apply(aRpp(i,v11,v22)) translate([0,1,4])
   linear_extrude(height=3,center=true, twist=twi)
   { polygon([[0,0],[0,1],[4,0]]); }
   
 apply(aRpp(i,v11,v22)) translate([0,1,4])
   linear_extrude(height=3,center=true, twist=twi)
   { polygon([[0,0],[0,1],[4,0]]); }  
}
translate([0,1,4]) linear_extrude(height=3,center=true, twist=twi)
  { polygon([[0,0],[0,1],[4,0]]); }
  
  
} 

/*
Observations::
We can multiply any number of affines together to get a new affine.
Applying these to a shape is more efficient that using multiple transforms from
modules.

An affine moves us from one coordinate system to another, as do the built in
transformations,  The new coordinate system can be rotated, mirrored or distorted both
angularly and stretched on any axis.

The inverse of an affine moves a point, or object back to the original
coordinate system it was called from.
*/




