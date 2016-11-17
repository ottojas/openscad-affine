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