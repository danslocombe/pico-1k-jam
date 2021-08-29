pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
function n(v)local l=sqrt(v[1]*v[1]+v[2]*v[2]+v[3]*v[3])return{v[1]/l,v[2]/l,v[3]/l}end
function sc(p)local m,px,py,pz=max,p[1]%2-1,cr*p[2]-sr*p[3],sr*p[2]+cr*p[3]local x,y,z,q=abs(px)-.45,abs(py)-.45,abs(pz)-.45,min(m(m(x,y),z),0)local a,b,c=m(x,0),m(y,0),m(z,0)return q+sqrt(a*a+b*b+c*c)end
function j(p,c,k)a={p[1],p[2],p[3]}a[c]+=k
return sc(a)end
rs={}for i=0,1024do
r=n({i%32-16,i\32-16,-77})ct,st=.876,-.482rs[i]={ct*r[1]+st*r[3],r[2],-st*r[1]+ct*r[3]}end
k=.01ex=0lx=-1.5c=.0002poke2(12866,256)sfx(0)np={12,5,0}::s::
poke2(12800,1606+(t()\8%2)*2+np[t()\.2%3+1])ex-=c
lx-=c
cr=cos(lx/25)sr=-sin(lx/26)cc=lx/4i=rnd(1024)\1+1local x,y,d,s,a,m,q,p=i\32,i%32,0,0,rs[i],16,0,{ex,0,6}::ms::
if(m<1)goto d
d=sc(p)if d<.2then
g=n({j(p,1,k)-j(p,1,-k),j(p,2,k)-j(p,2,-k),j(p,3,k)-j(p,3,-k)})w=n({lx-p[1],-1.5-p[2],-p[3]})f=g[1]*w[1]+g[2]*w[2]+g[3]*w[3]q=0if(f<0)goto d
q=4+cc+3*sqrt(f)goto d
end
if(s>7)q=cc+2goto d
p[1]+=d*a[1]p[2]+=d*a[2]p[3]+=d*a[3]s+=d
m-=1goto ms::d::w,v=x*4+rnd(4),y*4+rnd(4)rectfill(w,v,w+4,v+4,q)goto s