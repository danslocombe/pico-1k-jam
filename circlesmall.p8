pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
::_::
x0=flr(rnd(128)-64)y0=flr(rnd(128)-64)c=0
x=x0
y=y0
--d=cos(t()/50)
d=1
e=0.91939+0.01*sin(t()/50)
::l::
x-=flr(d*y)y+=flr(e*x)c += 1
if (c<64and(x~=x0 or y~=y0)) then goto l end
col=c+flr(rnd(1.01))
xx,yy=x0+64,y0+64
circ(xx,yy,1,col)
--circ(xx,yy,3,col)
rectfill(xx,yy,xx+1,yy+1,col)
goto _