pico-8 cartridge // http://www.pico-8.com
version 32
__lua__


light_x = -1.5
light_y = -1.5
light_z = 0
cube_size = 0.45
sphere_x = 0
sphere_z = 0
--sphere_size = 0.535
sphere_size = 0.135
rotate = 0
function _update60()
  t += 1
  sphere_z = -0.65*sin(t/800)
  --light_x = 1.5*cos(t/1000)
  --light_y = -3 + 1.5*sin(t/1200)
  rotate += 0.001
  --sphere_x = 0
  --cube_size = 0.35 + 0.2*sin(t/500)
end

function vec_len(v)
  return sqrt(sqr(v[1]) + sqr(v[2]) + sqr(v[3]))
end

function normalize(v)
  local xx = vec_len(v)
  return {v[1]/xx, v[2]/xx, v[3]/xx}
end

function sqr(x)
  return x * x
end

last_p = {0, 0, 0}
last_dist = 0

res_x = 32
res_y = 32

t = 0

res_x_inv = 128 / res_x
res_y_inv = 128 / res_y

function rayDir(x, y)
  local xx = x - res_x / 2
  local yy = y - res_y / 2
  local focal_len = 1/16 -- not in radians in pico 8 repr
  local tan_focal_len = sin(focal_len) / cos(focal_len)
  local z = res_y / tan_focal_len
  return normalize({xx, yy, z})
end

function rotate_x(p, theta)
  local ct = cos(theta)
  local st = sin(theta)
  return {p[1], ct * p[2] - st * p[3], st * p[2] + ct * p[3]}
end

function rotate_y(p, theta)
  local ct = cos(theta)
  local st = sin(theta)
  return {ct * p[1] + st * p[3], p[2], -st * p[1] + ct * p[3]}
end

function sceneSDF(p)
  --local dist = vec_len(p) - 0.5
  --dist = max(dist, cubeSDF(p))
  --dist = max(dist, -cubeSDF(p))

  --local dist = vec_len({p[1] - sphere_x, p[2], p[3] - sphere_z}) - sphere_size
  --local dist = vec_len(p) - 0.35
  --dist = max(cubeSDF(p), -dist)
  --local dist = max(cubeSDF(p), -infCylinderSDF(rotate_y(p, rotate)))
  --local p2 = {p[1] + sphere_z, p[2], p[3]}
  --local dist = cubeSDF(rotate_y(p, 0))
  --local dist = cubeSDF(p)
  local dist = cubeSDF(rotate_y(p, rotate))
  return dist 
end

function cubeSDF(p)
  local dx = abs(p[1]) - cube_size
  local dy = abs(p[2]) - cube_size
  local dz = abs(p[3]) - cube_size
  local inside = min(max(max(dx, dy), dz), 0)
  local outside = vec_len({max(dx, 0), max(dy, 0), max(dz, 0)})
  return inside + outside
end

function infCylinderSDF(p)
  return sqrt(sqr(p[1]) + sqr(p[2])) - 0.25
end

marched = {}

function march(eye, dir)
  --local marched = {}
  --local dists = {}
  local depth = 0
  local p = {eye[1], eye[2], eye[3]}
  local k = 0.2
  --local dx = dir[1]*k
  --local dy = dir[2]*k
  --local dz = dir[3]*k

  for i=0,16 do
    local dist = sceneSDF(p)
    local last_dist = dist
    if dist < k then
      --[[
      printh("MARCH")
      for i,x in pairs(marched) do
        printh("x: " .. x[1])
        printh("y: " .. x[2])
        printh("z: " .. x[3])
        printh("DIST : " .. dists[i])
      end
      printh("last p")
      printh("x: " .. p[1])
      printh("y: " .. p[2])
      printh("z: " .. p[3])
      ]]--
      last_p = p
      return depth
    end

    if depth > 7 then
      return depth
    end
    
    local incr = max(dist, k)
    p[1] += dir[1]*incr
    p[2] += dir[2]*incr
    p[3] += dir[3]*incr
    --add(marched, {p[1], p[2], p[3]})
    --add(dists, dist)
    --p[1] += dx
    --p[2] += dy
    --p[3] += dz
    depth = depth + incr
  end

  return depth
end

rays = {}

local i = 0
for x=0,res_x do
  for y=0,res_y do
    local dir = rayDir(x, y)
    i += 1
    rays[i] = dir
  end
end

cls(6)
function _draw()
  local times = {}
  local i = 0
  for x=0,res_x do
    for y=0,res_y do
      i += 1
      --if y < res_y / 2 and rnd(10) > 9 then
      if rnd(20) > 19 then
        --printh("x ".. dir[1])
        --printh("y ".. dir[2])
        --printh("z ".. dir[3])
        local t_0 = stat(1)
        local dir = rays[i]
        local eye = {0, -0.25, 6}
        local dist = march(eye, dir)
        local t_1 = stat(1)

        --printh(dist)

        local col = 9

        --local t_2 = 0
        record_time = false
        if dist < 7 then
          --local dist_y_0 = sceneSDF({last_p[1], last_p[2] + 0.05, last_p[3]})
          --local dist_y_1 = sceneSDF({last_p[1], last_p[2] - 0.05, last_p[3]})

          col = 5

          local k = 0.011
          local dist_x_0 = sceneSDF({last_p[1] - k, last_p[2], last_p[3]})
          local dist_x_1 = sceneSDF({last_p[1] + k, last_p[2], last_p[3]})
          local dist_y_0 = sceneSDF({last_p[1], last_p[2] - k, last_p[3]})
          local dist_y_1 = sceneSDF({last_p[1], last_p[2] + k, last_p[3]})
          local dist_z_0 = sceneSDF({last_p[1], last_p[2], last_p[3] - k})
          local dist_z_1 = sceneSDF({last_p[1], last_p[2], last_p[3] + k})
          local grad_x = dist_x_1 - dist_x_0
          local grad_y = dist_y_1 - dist_y_0
          local grad_z = dist_z_1 - dist_z_0
          local grad = normalize({grad_x, grad_y, grad_z})
          --local grad_x = dist_x_1 - last_dist
          --local grad_y = dist_y_1 - last_dist
          --local grad_z = dist_z_1 - last_dist

          local light_dir = normalize({light_x - last_p[1], light_y - last_p[2], light_z - last_p[3]})

          local dot = grad[1] * light_dir[1] + grad[2] * light_dir[2] + grad[3] * light_dir[3]
          dot += rnd(0.005)
          --printh("x : " .. x)
          --printh("y : " .. y)
          --printh("dot : " .. dot)

          dot += 0.5
          if dot < 0 then
            col = 0
          else
            --col = 7
            col = 4 + sqrt(dot) * 3
          end

          --t_2 = stat(1)
          --record_time = true

          --col = 5 + grad_y * 40
          --pset(x, y, 1)
        end

        local xx = x*res_x_inv + rnd(res_x_inv)
        local yy = y*res_y_inv + rnd(res_y_inv)
        --local w = rnd(res_x_inv)
        --local h = rnd(res_y_inv)
        local w = res_x_inv
        local h = res_y_inv
        rectfill(xx, yy, xx + w, yy + h, col)

        --local t_3 = stat(1)

        if record_time then
          --add(times, {t_1 - t_0, t_2 - t_0, t_3 - t_0})
        end
      end
    end

    --for y=0,127 do
    --  local from = 0x6000 + y*64
    --  local to = from + 32
    --  memcpy(to, from, 32)
    --  -- copy screen mem
    --end
    --for y=0,63 do
    --  if (rnd(5) > 4) then
    --    local from = 0x6000 + y*64
    --    --local to = from + 64 * 64
    --    --local to = from + (127 - y) * 64
    --    local to = 0x7FFF - (y+1) * 64
    --    memcpy(to, from, 64)
    --    -- copy screen mem
    --  end
    --end
  end
  print(stat(7), 10, 10, 7)

  for i,x in pairs(times) do
    printh("t: " .. i)
    printh(x[1])
    printh(x[2])
    printh(x[3])
  end
end