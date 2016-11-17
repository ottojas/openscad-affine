# openscad-affine

Main contents are: affine.scad transform library to import into openscad and turtle.scad library which uses affine.scad.
Some documentation for affine is in a comment at the top of the affine.scad library.  The programs oddpart.scad, ladder.scad
and airplane.scad are short programs that demonstrate turtle.scad usage.

### turtle.scad Examples.

An (invisible) turtle is sitting at the origin on the xy plane facing in the y direction.
The command go(<distance>) moves it forward along the y axis.  

In order to use turtlePath to actually move a real shape we need to 
put turtle moves into a list of lists as in the following short program.
This is the same list as above. A complete program is then:

```
use <turtle.scad>

path = [
                [go(0)],
                [go(20)],
                [reSize(.7),turnRight(45)],
                [go(15)],
                [turnUp(90),reSize(.7),go(10/(.7*.7))],
                [go(10)],
                [goTo([10,10,30])]
        ];
turtlePath(path){cube(5,center=true);}
```

This will connect each object with the following object in the list with a convex 
hull to create a path.  Each sublist represents one placement of the object.
In the above, the [go(0)], sublist is to get an object at the origin.  [go(2)], 
Moves the turtle forwards 20 units. Every sublist results in the placement of an object.

See result image at: <https://github.com/ottojas/openscad-affine/blob/master/images/oddpart.png>

If you wish to see the locations without the connections change:
          
turtlePath(path){cube(5,center=true);}
to:
turtlePath(path,mod=0){cube(5,center=true);}

See result image at: <https://github.com/ottojas/openscad-affine/blob/master/images/oddpart2.png>

The mod argument sets the objects that are connected by a convex hull.
Each sublist represents a single object.  The above program produced 7 shapes
that are sequentially connected with a convex hull.  The default definition is:

module turtlePath(path,mod=[1,1],cycle=false)

This takes the sequence in the list modulo 1, (always 0) and if it equals zero, 
connects to the next item in the list.  mod=[1,2] would skip an object and connect 
to an object beyond the next.  mod=[2,1] would connect in pairs. mod=[1,2,3], 
connects in groups of three objects.

An example of the use of "mod=" is in the following program:

```
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
```

See result image at: <https://github.com/ottojas/openscad-affine/blob/master/images/ladder.png>

To see the effect of cycle, in the first program above, the oddpart.scad program, set cycle=true, invoke:

turtlePath(path,cycle=true){cube(1,center=true);}

See result image at: <https://github.com/ottojas/openscad-affine/blob/master/images/oddpartCycle.png>

In summary, in the turtle system we are moving our coordinate system.  Each
move applies an affine transform to the previous move.  Any affine transform
can be substituted for a move. The subgrouping of the moves tells use where to
put the child object(s).  The moves listed above are simply wrappers around the functions
in the affine library.  Any affine transform can be substituted for a move.  The
object we are moving, the child object(s), are always located in the new coordinate system at
the same coordinates as they were in the original coordinate system.

There are the following commands to move the turtle.  These are taken verbatum from
the turtle.scad library. turtle.scad uses the affine.scad library.

```
function turnRight(deg) = a_Rv(deg,[0,0,1]);
function turnLeft(deg) = a_Rv(deg,[0,0,-1]);
function turnUp(deg) = a_Rv(deg,[-1,0,0]);
function turnDown(deg) = a_Rv(deg,[1,0,0]);                     
function go(distance) = a_S(off=[0,distance,0]);
function goTo(vec) = a_S(off=vec);
function rollRight(deg) = a_Rv(deg,[0,-1,0]); 
function rollLeft(deg) = a_Rv(deg,[0,1,0]);
function reSize(vecA) = a_S(vec =(vecA[0]==undef ? [vecA,vecA,vecA] : vecA));  
function lookAt(vec) = a_Xa(
                             turnRight(atan(vec[0]/vec[1])),
                             ((len(vec)==3) ? 
                             turnUp(90-atan(norm([vec[0],vec[1]])/vec[2])) 
                             : ident
                             )
                           );                           
function lookGo(vec) = a_Xa(lookAt(vec),go(norm(vec)));
```  

Cavaet: turtlePath applied to non-convex objects in default mode will take much longer to render
than applying turtlePath to the convex hull of the object.

I would like to connect with some other methods than the hull, but that really is not easy
without indirect passable functions.  On the other hand, these packages work in the current system.
