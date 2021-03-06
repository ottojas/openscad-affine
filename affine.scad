//  Extra linear algebra/geometry additions to open scad.
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
 

Support 2d and 3d functions only.  Some will work with others but not supported.
Affine transform (affine) is implemented as a list of a matrix and a vector.
[ [[,,],[,,],[,,]], [,,] ]

//// Functions from this library include:
aX_      Affine times Affine or vector --- checks for type then a_Xa or a_Xv
m_I      matrix inverse returns (inverse) matrix --2X2 and 3X3 only
a_I      affine inverse returns (inverse) affine transform --2X2 and 3X3 only
m_T      matrix transpose returns transpose matrix --2X2 and 3X3 only
a_Pow    affine power function.  Affine times itself.
//// Functions to convert from 4X4 representation to and from affine transform
a_Dm     affine derived from matrix returns affine -- 2D from 3X3, 3D from 4X4. Last row lost.
m_Da     matrix derived from affine returns matrix --3X3 or 4X4 last row is [0,0,1] or [0,0,0,1]
//// Generate affine to rotate.
a_Rv     returns affine from angle and vector. Clockwise rotation about vector on orthogonal plane 
        intersecting the origin.  Looking towards origin along vector.
a_Rpp    returns affine from angle and two points.  Clockwise rotation about line through points
        looking from second point to first point.
//// Generate affine mirror functions
a_Mv     returns affine from vector that mirrors about the origin.
        apply(aMv([x,y,z])) behaves identically to mirror([x,y,z])
a_Mpp,    returns affine from vector that mirrors about two points. 
        apply(a_Mpp(p1,p2)) behaves identically to translate(p1)mirror(p2-p1)translate(-p1) 
//// Other affine transform generators
a_Dpppp  affine derived from four points.  See library readme for more info
a_S      scale and offset.  a_S([1,1,1],[0,0,0]) returns affine identity.
        first argument sets the diagonal of 3X3 in affine.  Second the vector.
//// aDv aDvp aDppp        
//// Conversions, polar coordinates are a list of [radius, angle], cartesian are [x,y]
p2c     polar to cartesian
c2p     cartesian to polar
//// Modules defined by this library.
apply   Module is passed an affine transform which is applied to all children.
//// Other functions defined by library.
polyflat  Takes lists of points and faces as required as arguments to polyhedron, and combines
          them into a single list of faces and points
*/

//// Scale and translate.  vec is diagonal of 3X3 and generates scaling on 3 axis.
//// For 2D vec must be length of 2
////  off is offset vector. In general require len(vec) == len(off) and no member of vec is zero.
function a_S(vec=[1,1,1], off=[0,0,0]) =
    let( top = len(vec)-1 )
    [[for(i=[0:top]) [for(j=[0:top]) i==j ? vec[i] : 0]] , [for(i=[0:top]) off[i]]];
  
//INVERT MATRIX 2X2, 3X3 only 
function m_I(m) =
   let 
   ( 
     dtr= len(m) == 2 
     ? 1/(m[0][0]*m[1][1]-m[0][1]*m[1][0])  //dtr = determinant reciprocal
     : 1/( m[0][0]*m[1][1]*m[2][2] + m[1][0]*m[2][1]*m[0][2] + m[2][0]*m[0][1]*m[1][2]   
          -m[0][0]*m[2][1]*m[1][2] - m[2][0]*m[1][1]*m[0][2] - m[1][0]*m[0][1]*m[2][2]
         )
   ) 
   len(m) == 2
   ?   
   [  
    [m[1][1]*dtr, -m[0][1]*dtr],
    [-m[1][0]*dtr, m[0][0]*dtr]
   ]
   :       
   [  
    [(m[1][1]*m[2][2]-m[1][2]*m[2][1])*dtr, (m[0][2]*m[2][1]-m[0][1]*m[2][2])*dtr, (m[0][1]*m[1][2]-m[0][2]*m[1][1])*dtr],
    [(m[1][2]*m[2][0]-m[1][0]*m[2][2])*dtr, (m[0][0]*m[2][2]-m[0][2]*m[2][0])*dtr, (m[0][2]*m[1][0]-m[0][0]*m[1][2])*dtr],
    [(m[1][0]*m[2][1]-m[1][1]*m[2][0])*dtr, (m[0][1]*m[2][0]-m[0][0]*m[2][1])*dtr, (m[0][0]*m[1][1]-m[0][1]*m[1][0])*dtr],
   ];

  
//MATRIX TRANSPOSE  2X2 3X3 only    
function m_T(m) =
    len(m) == 2
    ?
    [
     [m[0][0], m[1][0]],
     [m[0][1], m[1][1]]
    ]
    :
    [
     [m[0][0], m[1][0], m[2][0]],
     [m[0][1], m[1][1], m[2][1]],
     [m[0][2], m[1][2], m[2][2]]
    ];
    
// 2d AFFINE FROM 3X3 3D AFFINE FROM 4X4 (looses 3rd/4th row)
function a_Dm(m) =
    len(m) == 3
    ?
    [ 
     [ 
      [m[0][0],m[0][1]],
      [m[1][0],m[1][1]]
     ],
     [m[0][2],m[1][2]]
    ]
    :
    [ 
     [ 
      [m[0][0],m[0][1],m[0][2]],
      [m[1][0],m[1][1],m[1][2]],
      [m[2][0],m[2][1],m[2][2]],
     ],
     [m[0][3],m[1][3],m[2][3]]
    ];

// 2d (3X3 matrix) FROM to 2D AFFINE, 3d 4X4 MATRIX from 3D AFFINE (sets 3rd/4th row to [0,0,1]/[0,0,0,1]
//function m_Da(m) = 
function m_Da(m) =  
    len(m[0]) == 2
    ?   
    [
     [m[0][0][0], m[0][0][1], m[1][0]],
     [m[0][1][0], m[0][1][1], m[1][1]],
     [0,0,1]
    ]
    :
    [
     [m[0][0][0], m[0][0][1], m[0][0][2], m[1][0]],
     [m[0][1][0], m[0][1][1], m[0][1][2], m[1][1]],
     [m[0][2][0], m[0][2][1], m[0][2][2], m[1][2]],
     [0,0,0,1]
    ];
    
//AFFINE TIMES VECTOR
function a_Xv(a,v) = a[0]*v+a[1];

//AFFINE TIMES AFFINE affineXaffine
function a_Xa(aA,aB) = [aA[0]*aB[0],aA[0]*aB[1]+aA[1]];

//AFFINE TIMES, checks for vector or another affine.
function aX(a,x) = len(x[1])==undef ? a_Xv(a,x) : a_Xa(a,x);

//AFFINE INVERSE MATRIX  2D and 3D affine only.
function a_I(a) = let(minv = m_I(a[0])) [minv, -minv*a[1]];

//// papow is specific affine power function 
function papow(aff, pow) =
    pow==1 ? aff : a_Xa(aff,papow(aff, pow-1));

////This is the generalized affine power function
function a_Pow(aff, pow) =
   pow >= 1 ? papow(aff, pow) : (pow == 0 ? a_S() : papow(a_I(aff), abs(pow)));

///  
/// Generate 3d affine transforms
///
/// Utility function for generators
function normv(v) =
    let (
          nv = norm(v),
          vnv = v/nv
        )
     vnv;

/// AFFINE FROM POINTS, first point is an origin
function aDpppp(Vv,v0=[0,0,0]) =   //Vv = [v,v,v] maps coords from current to new or new to current.
    [m_T([Vv[0]-v0,Vv[1]-v0,Vv[2]-v0]),v0];
    
//LOCAL UTILITY get orthogonal unit vector system with vector as z axis
//needed for rotates and mirror
function getc(v) =
    let (
          nv1 = normv(v),
          absnv = [for( i=nv1) abs(i)],
          use = min(absnv),
          dex = search(use,absnv)[0],
          nvtemp = [for(i=[0:2]) i==dex ? (i>=0 ? 1 : -1) : 0],
          nv2 = normv(cross(nv1,nvtemp)),
          nv3 = cross(nv1,nv2)
        )
       aDpppp([nv3,nv2,nv1]); 
          
function aDv(v) = getc(v);

function aDvp(v,p) = 
    let (
          nv1=normv(v),
          p1=cross(nv1,p),
          nv2=normv(p1),
          nv3=cross(nv1,nv2)
         )
        aDpppp([nv3,nv2,nv1]); 
                
///LOCAL UTILITY rotate about z axis - use a_Rv([0,0,1]) in code
function arxy(a) = //rotate about origin - utility to derive general rotates.
    [[[cos(a), -sin(a), 0],[sin(a), cos(a), 0],[0,0,1]],[0,0,0]];

///AFFINE TO ROTATE ABOUT ARBITRARY VECTOR 3D only
///Plane to rotate in is underspecified, but thats OK.          
function a_Rv(angle,v) =
    let (
          am=getc(v),
          ami=a_I(am)
        )
        a_Xa(am,a_Xa(arxy(angle),ami));
 
//AFFINE ROTATE ABOUT LINE THROUGH TWO POINTS 3D only        
function a_Rpp(angle,pA,pB) = 
         a_Xa(a_S(off=pA),a_Xa(a_Rv(angle,pB-pA),a_S(off=-pA)));
 

///AFFINE TO MIRROR ACROSS PLANE DEFINED BY VECTOR PASSING THROUGH ORIGIN
///  SAME AS "MIRROR" COMAND BUT RETURNS AFFINE.
function aMv(v) =
    let (
          am=getc(v),
          ami=a_I(am)
        )      
        a_Xa(am,a_Xa(a_S([1,1,-1]),ami)); 
  
//AFFINE MIRROR FROM TWO POINTS, ABOUT PLANE THROUGH FIRST.     
function a_Mpp(pA,pB) = 
         a_Xa(a_S(off=pA),a_Xa(aMv(pB-pA),a_S(off=-pA)));

////MODULE The module that lets us use affine.
module apply(affine)
{
   multmatrix(m_Da(affine)) children();
} 

////MODULE to render a set of cylinders representing the affine transform.
module showAffine(af,size=0)
{
   sz=size?size
          :min([norm(af[0][0]),
             norm(af[0][1]),
             norm(af[0][2])
                ])/17;
   color([1,0,0]) hull(){translate(af[0][0]+af[1]) sphere(sz); translate(af[1]) sphere(sz);}
   color([0,1,0]) hull(){translate(af[0][1]+af[1]) sphere(sz); translate(af[1]) sphere(sz);}
   color([0,0,1]) hull(){translate(af[0][2]+af[1]) sphere(sz); translate(af[1]) sphere(sz);}
} 

////////////////////////////////////
/// More utilities,
////////////////////////////////////

////UTILITY polar to cartesian, cartesian to polar. polar is [radius,angle].
function p2c(polar) = [polar[0]*cos(polar[1]),polar[0]*sin(polar[1])];
function c2p(cart) = [sqrt(cart[0]*cart[0]+cart[1]*cart[1]),atan2(cart[1],cart[0])];

////UTILITIES for combining multiple lists of points faces [([points],[[face1],[face2]...]]
////into single vector of points and faces that can be used as the two sargs.

 ////LOCAL UTILITY to add a value to a vector                  
function incv(vec,val) =
    [ for(i=vec) i+val ]; 

///LOCAL UTILITY to add a value to every vector in a list of vectors    
function polyinc(vec,val) =
    [ for(i=[0:len(vec)-1]) incv(vec[i],val) ];
        
function accumSum(li,s=0) = 
    concat([s], (len(li)>1 ? accumSum([for(i=[1:len(li)-1]) li[i]], s+li[0]) : [s+li[0]])) ;   

///UTILITY accepting a list of lists
/// points and faces are lists as needed to invoke polyhedron command.
/// We combine multiple lists of points and faces into a single list of points and faces
/// in which the faces have been adjusted to point to the correct points.    
/// x=polyflat([ [[list of points],[list of faces]],[[list of points],[list of faces],]... ]);
/// This allows the construction of a complex polyhedron in parts. polyhedron(x[0],x[1])   
function polyflat(lop) =
    let(
         pointList  = [for(i=lop) i[0]], 
         pointC = [for(i=pointList) len(i)],
         pointCount=accumSum(pointC),
         faceList = [for(i=lop) i[1]],
         points=[for(a=pointList) for(b=a) b ],
         facetious=[for(i=[0:len(faceList)-1]) let(f=faceList[i],add=pointCount[i]) polyinc(f,add)],
         faces=[for(a=facetious) for(b=a) b ]     
       ) 
     [points, faces]; 


