use <affine.scad>

ident = a_S();
function mreduce(x) = let(lx=len(x))

    (lx>1 ? a_Xa(x[0], mreduce([for(i=[1:lx-1]) x[i]])  )
         : x[0]
    );
    
function mcume(in,out=[],next=ident) = let(li=len(in),lo=len(out))
    li == 0 ? out 
            :          
               mcume( 
                     li-1>0 ? [for(i=[1:li-1]) in[i]] : [],
                     lo>0 ? concat(out,[a_Xa(out[lo-1],next)]) : [in[0]],
                     in[1] 
                   );

function setPath(spec) =
   mcume([for(i=spec) mreduce(i)]);
        
module turtlePath(path,mod=[1,1],cycle=false,rawpath=[])
{  
  usePath = rawpath ? rawpath : setPath(path); 
  if(mod)
  {
    for(i=[0:len(usePath)-1])
    {
      if(i%mod[0]==0)
      { hull()
        {
          apply(usePath[i]){children();}
          if(len(mod)>1)
          {
            for(j=[1:len(mod)-1])
            {
              if(i+mod[j]<len(usePath))
              {
                apply(usePath[i+mod[j]]){children();} 
              }
              else
              { 
                if(cycle)
                {        
                 apply(usePath[(i+mod[j])%len(usePath)]){children();}
                }   
  } } } } } } }
  else
  {
    for(i=usePath) apply(i){children();}   
  }    
}  


///Generate affine turtle moves
///These should have more intuitive names

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



   
                     
         