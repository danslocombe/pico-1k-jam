pico-8 cartridge // http://www.pico-8.com
version 32
__lua__

d = 0.5
e = 0.2

time = 50

::_::

local x0, y0, count = flr(rnd(128)-64), flr(rnd(128)-64), 0
local x,y = x0,y0
--e-=0.0001
--e = 0.2 + 0.1*sin(t()/time)
--d = 0.5 + 0.1*cos(t()/time)
--
--e = 0.2 + 0.1*sin(t()/time)
--d = 0.5
--
d=1
--e=4*sin(1/18)
e=0.91939+0.01*sin(t()/time)

::loop::
--x += y >> 4
--y -= x >> 4
x = x - flr(d*y)
y = y + flr(e*x)
count += 1
if (count > 64 or (x == x0 and y == y0)) then
    --pset(x+64, y+64, count)
    rectfill(x0+64,y0+64,x0+66,y0+66, count + flr(rnd(1.01)))
    goto _
end
goto loop