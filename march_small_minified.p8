pico-8 cartridge // http://www.pico-8.com
version 32
__lua__


function nn(v)
local xx=sqrt(v[1]*v[1]+v[2]*v[2]+v[3]*v[3])
return{v[1]/xx,v[2]/xx,v[3]/xx}
end

rays = {}
for i=0,1024 do
r=nn({i%32-16,i\32-16,-77})
ct,st=.876,-.482
add(rays,{ct*r[1]+st*r[3],r[2],-st*r[1]+ct*r[3]})
end

function sc(p)
local px,py,pz=p[1]%2-1,cr*p[2]-sr*p[3],sr*p[2]+cr*p[3]
local dx,dy,dz=abs(px)-.45,abs(py)-.45,abs(pz)-.45
x=min(max(max(dx,dy),dz),0)
local a,b,c=max(dx,0),max(dy,0),max(dz, 0)
return x+sqrt(a*a+b*b+c*c)
end

k = .01
ex,lx=0,-1.5
c=.0002

::s::
ex-=c
lx-=c
cr,sr=cos(lx/25),-sin(lx/26)
cc=lx/4
i=rnd(1024)\1+1
local x,y,d,depth,a,timeout,col,p=i\32,i%32,0,0,rays[i],16,0,{ex,0,6}
::ms::
if timeout == 0 then
col=2
goto d
end 

d = sc(p)

if d<.2 then
local x0,x1,y0,y1,z0,z1=sc({p[1]-k,p[2],p[3]}),sc({p[1]+k,p[2],p[3]}),sc({p[1],p[2]-k,p[3]}),sc({p[1],p[2]+k,p[3]}),sc({p[1],p[2],p[3]-k}),sc({p[1],p[2],p[3]+k})
grad=nn({x1-x0,y1-y0,z1-z0})
ld=nn({lx-p[1],-1.5-p[2],-p[3]})
dot=grad[1]*ld[1]+grad[2]*ld[2]+grad[3]*ld[3]
if dot<0 then
col = 0
else
col=4+cc+sqrt(dot)*3
end
goto d
end

if(depth>7) col=2+cc goto d

p[1]+=a[1]*d
p[2]+=a[2]*d
p[3]+=a[3]*d
depth+=d
timeout-=1 goto ms
::d::
xx,yy=x*4+rnd(4),y*4+rnd(4)
rectfill(xx, yy, xx + 4, yy + 4, col) goto s