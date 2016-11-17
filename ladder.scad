use <turtle.scad>     
$fn=13;
function ladderPath(xdim,ydim,steps=1) =  ///steps should be one or greater..
    concat(
           [[go(0)],[goTo([xdim,0,0])]],
           [for(i=[0:steps-1]) for(j=[0:1]) [j ? goTo([xdim,0,0]) : goTo([-xdim,ydim,0])]]
          );
ladder = ladderPath(10,15,5);         
turtlePath(ladder,mod=[2,1]){sphere(.75);}
turtlePath(ladder,mod=[1,2]){cube(1.5,center=true);}