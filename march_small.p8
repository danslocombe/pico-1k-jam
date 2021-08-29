pico-8 cartridge // http://www.pico-8.com
version 32
__lua__

res_x = 32
res_y = 32

light_x = -1.5
light_y = -1.5
light_z = 0

res_x_inv = 128 / res_x
res_y_inv = 128 / res_y

sphere_x=0
sphere_z=0
cube_size = 0.45

function vec_len(v)
  return sqrt(v[1]*v[1]+v[2]*v[2]+v[3]*v[3])
end

function normalize(v)
  local xx = vec_len(v)
  return {v[1]/xx, v[2]/xx, v[3]/xx}
end

function rotate_y(p, theta)
  local ct = cos(theta)
  local st = sin(theta)
  return {ct * p[1] + st * p[3], p[2], -st * p[1] + ct * p[3]}
end

function rotate_x(p, theta)
  local ct = cos(theta)
  local st = sin(theta)
  return {p[1], ct * p[2] - st * p[3], st * p[2] + ct * p[3]}
end

function rayDir(x, y)
  local xx = x - res_x / 2
  local yy = y - res_y / 2
  local focal_len = 1/16 -- not in radians in pico 8 repr
  local tan_focal_len = sin(focal_len) / cos(focal_len)
  local z = res_y / tan_focal_len
  local ray = normalize({xx, yy, z})
  return rotate_y(ray, 0.08)
end

rays = {}

for x=0,res_x do
  for y=0,res_y do
    add(rays, rayDir(x,y))
  end
end

function cubeSDF(p)
  local dx = abs(p[1]) - cube_size
  local dy = abs(p[2]) - cube_size
  local dz = abs(p[3]) - cube_size
  local inside = min(max(max(dx, dy), dz), 0)
  local outside = vec_len({max(dx, 0), max(dy, 0), max(dz, 0)})
  return inside + outside
end

function repxz(p, k)
  local xx = p[1] % k - 0.5*k
  --local yy = p[2] % k - 0.5*k
  --local zz = p[3] % k - 0.5*k
  --return {xx, yy, zz}
  return {xx, p[2], p[3]}
end

function sceneSDF(p)
  local dist = cubeSDF(rotate_x(repxz(p, 2), rotate))
  --local dist = cubeSDF(repxz(p, 4))
  --local dist = cubeSDF(p)

  return dist 
end

rotate = 0.18

eye_z = 6
eye_x = 0



function make_note(pitch, instr, vol, effect)
  return { pitch + 64*(instr%4) , 16*effect + 2*vol + flr(instr/4) } -- flr may be redundant when this is poke'd into memory
end

function get_note(sfx, time)
  local addr = 0x3200 + 68*sfx + 2*time
  return { peek(addr) , peek(addr + 1) }
end

function set_note(sfx, time, note)
  local addr = 0x3200 + 68*sfx + 2*time
  poke(addr, note[1])
  poke(addr+1, note[2])
end

function get_speed(sfx)
  return peek(0x3200 + 68*sfx + 65)
end

function set_speed(sfx, speed)
  poke(0x3200 + 68*sfx + 65, speed)
end

function get_loop_start(sfx)
  return peek(0x3200 + 68*sfx + 66)
end

function get_loop_end(sfx)
  return peek(0x3200 + 68*sfx + 67)
end

function set_loop(sfx, start, endd)
  local addr = 0x3200 + 68*sfx
  poke(addr + 66, start)
  poke(addr + 67, endd)
end

--note = make_note(32, 1, 3, 0)
set_loop(0, 0, 1)
--poke2(0x3266, 0x0001)
--poke(0x3200 + 66, 0x00)
--poke(0x3200 + 67, 0x01)
sfx(0)

note_pat = {12, 5, 0}

::main_start::
  --t=(t+1) % 600*32
  --t+=1
  note_off = note_pat[((t() * 5) % 3)\1 + 1]
  --note = make_note(8+(eye_x*10 % 16), cos(eye_x/7), 3, 0)
  --note = make_note(8+note_off, cos(eye_x/7), 3, 0)
  note = make_note(6+(t()\(8) % 2)*2+note_off, 1, 3, 0)
  --note = make_note(6+note_off, 4+cos(t/4000)\1, 3, 0)
  set_note(0, 0, note)
  --[[
  t+=1 
  --note = make_note(10+(eye_x*100 % 1), cos(eye_x/7), 3, 0)
  instr = cos(eye_x/7)
  sid = 2
  if (t) % 8 < 1 then
    sid=2
    instr = 6
  end
  note = make_note(9+(eye_x*9 % 16), instr, 3, 0)
  set_note(sid, 0, note)
  set_note(sid, 1, note)
  set_note(sid, 2, note)
  --if rnd(10) < 1 then
    sfx(sid)
  --end
  ]]--

  --eye_z -= 0.02
  eye_x -= 0.0002
  light_x -= 0.0002
  rotate += 0.00003
  local x=flr(rnd(res_x))
  local y=flr(rnd(res_y))
  local dist=0
  local depth=0
  local i=1+x+y*(res_x+1)
  local dir = rays[i]
  local timeout=16
  local col = 0
  local p = {eye_x, 0, eye_z}
  local incr=0.2
  ::march_start::
    if timeout == 0 then
      col=2
      goto draw
    end 

    dist = sceneSDF(p)
    --local last_dist = dist
    if dist < 0.2 then
      --last_p = p
      col=6

      local k = 0.01
      local x0 = sceneSDF({p[1] - k, p[2], p[3]})
      local x1 = sceneSDF({p[1] + k, p[2], p[3]})
      local y0 = sceneSDF({p[1], p[2] - k, p[3]})
      local y1 = sceneSDF({p[1], p[2] + k, p[3]})
      local z0 = sceneSDF({p[1], p[2], p[3] - k})
      local z1 = sceneSDF({p[1], p[2], p[3] + k})
      local grad = normalize({x1 - x0, y1-y0, z1-z0})

      local light_dir = normalize({light_x - p[1], light_y - p[2], light_z - p[3]})

      local dot = grad[1] * light_dir[1] + grad[2] * light_dir[2] + grad[3] * light_dir[3]
      --dot += rnd(0.05)
      if dot < 0 then
        col = 0
      else
        col = 4 + sqrt(dot) * 3
      end
      goto draw
    end

    if depth > 7 then
      --col = timeout/4 - 2
      col=2
      goto draw
    end
    
    incr = max(dist, 0.2)
    p[1] += dir[1]*incr
    p[2] += dir[2]*incr
    p[3] += dir[3]*incr
    depth = depth + incr
    timeout-=1
    goto march_start
  ::draw::
  local xx = x*res_x_inv + rnd(res_x_inv)
  local yy = y*res_y_inv + rnd(res_y_inv)
  local w = res_x_inv
  local h = res_y_inv
  rectfill(xx, yy, xx + w, yy + h, col)
goto main_start