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

include <affine.scad>

//// Normalize an angle
function pa(angle) = ((angle%360)+360)%360;

//////////////////////////////////////////
//// Common functional language constructs
//////////////////////////////////////////

function reduce(func,vec) =
     len(vec)==2 ? @func(vec[0],vec[1]) : @func(vec[0],reduce(func,[for (i=[1:len(vec)-1]) vec[i]])); 

function map(func,vec) =
       [for (i=vec) @func(vec)];

function filter(func, vec) = 
       [for (i=vec) if(@func(i)) i ]; 
  
function @add(a,b)=a+b;       
function sum(vec)=reduce(add,vec);       

/* Polygon and polyhedron modules generated from functions follow.

   convexity is passed through if declared.
       
   grid is a seperation between parts on a line.
       
   ticks is the number of seperations in a 360 degree circle.
       
   In general the number of points generated is about ticks * grid
   or grid * grid.       
       
*/       
       
//////////////////////////////
//// 2D polygons from function
//////////////////////////////
       
////  function of single variable of x.  Constructs
//// shape by generating y=f(x)
 module yIsFx(fx, xseg=[0,1] , grid=10, convexity=10)
 {
    gridspaceX = (xseg[1]-xseg[0])/grid;
    fpoints = concat([for (i=[0:grid]) let(x=xseg[0]+i*gridspaceX) [x,@fx(x)]],[[xseg[1],0],[xseg[0],0]]);
    polygon( points = fpoints, paths=[[for (i=[0:grid+3]) i%(grid+3)]],convexity=convexity);   
}       
 
//// First argument is a function of a single variable a, rpresenting angle
//// r, the radius = f(a)  Angle can be less than 360 to generate pie type slices.
//// generation is always counter clockwise.  If you want somethign else, use a transform.
module rIsFa(fa, angle=360, ticks=10, convexity=10)
{
    angle = pa(360);
    tickangle = (angle !=0 ? angle : 360)/ticks;
    fpoints = [for (i=[0:ticks]) let( a=i*tickangle, r=@fa(a) ) p2c([r,a])];
    usepoints = angle != 0 ? concat([[0,0]],fpoints) : fpoints;
    count=len(usepoints);
    polygon( points=usepoints, paths=[[for (i=[0:count]) i%count]],convexity=convexity);
}        


////////////////////////////////
//// 3D polyhedron from function
////////////////////////////////

//First argument is a function of two variables,  z=f(x,y)
//Plots on a square defined by diagonal [p1,p2] given grid as the dimension in x and y
//(Works, but needs some work.  First attempt at these.  Will get back to it.
// Final version will not be backwards compatible.)
module zIsFxy(fxy, diag=[[0,0],[1,1]], gridx=10, gridy=10, convexity=10)
{ 
  dg=[[min(diag[0][0],diag[1][0]),min(diag[0][1],diag[1][1])],
      [max(diag[0][0],diag[1][0]),max(diag[0][1],diag[1][1])]
     ];
  gridspaceX = (dg[1][0]-dg[0][0])/(gridx);
  gridspaceY = (dg[1][1]-dg[0][1])/(gridy);
  xvec = [ for(x=[0:gridx]) dg[0][0]+x*gridspaceX];
  yvec = [ for(y=[0:gridy]) dg[0][1]+y*gridspaceY]; 
 
  points = [ for(y=[0:gridy]) for(x=[0:gridx])  [xvec[x],yvec[y],@fxy(xvec[x],yvec[y])]];

  upper3s = [ for(y=[0:gridy-1]) for(x=[0:gridx-1]) 
                     let(ux = y*(gridx+1)+x, uy=(y+1)*(gridx+1)+x)
                     [ [ux, uy ,uy+1], [ux,uy+1,ux+1]]
           ];

   outline = concat( [for(i=[0:gridx]) i],  //
                     [for(j=[1:gridy]) (j+1)*(gridx+1)-1],  //  
                     [for(k=[(gridx+1)*(gridy+1)-2:-1:gridy*(gridx+1)]) k ],
                     [for(l=[(gridy-1):-1:0]) l*(gridx+1) ],
                     []
                   );

   lpt = len(points);
   lout= len(outline);
   allpoints = concat(points,[for (i=outline) [points[i][0],points[i][1],0] ]);
   edge3s = [for(p=[0:lout-2]) 
                let(p1=p+lpt, p2=p+1+lpt, up1=outline[p], up2=outline[p+1]) 
                [[p1,up1,up2],[p1,up2,p2]] 
            ];
  
   face=concat( [for(i=upper3s) for(j=i) j],
                            [for(i=edge3s) for(j=i) j],
                            [[for(p=[0:lout-2]) outline[p]+lpt]]
   
               ); 
      
  polyhedron(points=allpoints, 
              faces=concat( [for(i=upper3s) for(j=i) j],
                            [for(i=edge3s) for(j=i) j],
                            [[for(p=[0:lout-2]) p+lpt]]
                          )
             );       
 
   }


/// First argument is a function of two variables an angle a, and a value z.
/// the radius r = f(a,z) is generated at each angle and point along the z axis.
/// Generates cylinder type shape along Z axis.  Always generates full 360 degrees.
module rIsFza(fz, zseg=[0,1], ticks=10, grid=10, minr=.0001, convexity=10)
{
   tickangle=360/ticks;
   gridspaceZ = (zseg[1]-zseg[0])/grid;
   fpoints = [for (z=[0:grid]) for (a=[0:ticks-1]) 
                                      let(
                                           zz=zseg[0]+z*gridspaceZ,
                                           angle = a*tickangle,
                                           r=@fz(zz,angle),
                                           rok = abs(r ? r : minr),
                                           cc=p2c([rok,angle])
                                           )
                                       [cc[0],cc[1],zz]    
               ];
    tt=ticks-1;
    tris =   [for (z=[0:grid-1]) for (a=[0:ticks-1]) [[z*ticks+a, (z+1)*ticks+a, (z+1)*ticks+(a+1)%ticks],  
                                                     [z*ticks+a, (z+1)*ticks+(a+1)%ticks, z*ticks+(a+1)%ticks]
                                                    ]
             ];
    toppoly = [for (a=[ticks:-1:0]) ticks*grid+a];
    botpoly = [for (a=[0:ticks-1]) a];  
    polyhedron( points=fpoints, faces=concat(concat([for (pair=tris) for (tri=pair) tri],[toppoly]),[botpoly]));
} 


//// This needs two functions.
//// First argument is a function of a single variable a, rpresenting angle.
//// it generates a polygon as in module xxxx above.  r=f(a)
//// Second argument is a function of two variables a and r. And represents
//// the altitude above the polygon.  z=f([r',a]).  r' varies according to grid.
module zIsFarIsFa(fa, fra, ticks=10, minr=.0001, grid=10, convexity=10)
{   
    tickangle=360/ticks;
    avec=[ for (t=[0:ticks-1]) t ? t*tickangle : 360];
    gfact=[ for(i=[grid:-1:1]) i/grid];   
    rvec=[ for (t=[0:ticks-1]) let(val = @fa(avec[t])) abs(val ? val : minr) ];  //counter clockwise    
    lowpoints = concat
    (   [ for (t=[0:ticks-1]) 
             let(a=avec[t], r=rvec[t], xy=p2c([r,a]) ) 
             [xy[0],xy[1],0]
        ],
        [for (g=gfact) for (t=[0:ticks-1])
             let(a=avec[t], rt=rvec[t], r=abs(rt ? rt*g : minr*g), xy=p2c([r,a]) )
             [xy[0],xy[1],@fra(r,a)]
        ]  
     );  
     lastpoint= [[0,0,  sum([for (i=[0:ticks-1]) lowpoints[grid*ticks+i][2]  ])/ticks ]];
     fpoints=concat(lowpoints,lastpoint); 
     for (i=[0:fpoints-1]) translate() sphere(.1+i*.1);   
     tris2= [for (g=[0:grid-1]) 
                  for (a=[0:ticks-1]) 
                  [[g*ticks+a, (g+1)*ticks+a, (g+1)*ticks+(a+1)%ticks],
                   [g*ticks+a, (g+1)*ticks+(a+1)%ticks, g*ticks+(a+1)%ticks]
                  ]
             ];  
     polys = concat 
     (  [[for (i=[0:ticks-1]) i]],
        [for(i=tris2) for(j=i) j],
        [for (a=[0:ticks-1]) let(b=ticks*(grid),t=len(fpoints)-1) [b+a, t, b+(a+1)%ticks ]]
     );   
     polyhedron(points=fpoints,faces=polys,convexity=convexity);    
}  

///TO DO spherical
/// rIsFaa.  where angles are lat and long and r is distance from sphere center.


