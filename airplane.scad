use <turtle.scad>
$fn=13;
module airplane()
{
 paths=[
          [
           [go(0)],
           [reSize(1.5),go(4.5)],
          ],
    
          [
           [reSize([1,1,.63]),go(.5),goTo([-1.5,0,0])],
           [goTo([3,0,0])]
          ],
    
          [
           [reSize([1,1.3,.63]),go(3.75),goTo([-4,0,0])],
           [goTo([8,0,0])]
          ],
    
          [
           [goTo([0,.5,1]),reSize([.5,1,1.5])]
          ]
      ];
 for (path=paths){ turtlePath(path){ sphere(1); }}
}

usepath=concat([[turnLeft(90),go(0)],[go(20)],[lookGo([0,20,1])]],[for(i=[0:13]) [lookGo([13,20,1+i/15])]],[[rollLeft(13),go(20)],[go(20)]]);
            
turtlePath(usepath,mod=[]){airplane();} 