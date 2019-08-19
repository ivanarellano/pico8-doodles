pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
	printh("***************")
	local circle = {
		pos = {x=64, y=64}, 
		rad = 24, 
		pts = 16, 
		st_deg = 0, end_deg = 360
	}
	local enemies = rnd_pts(64)

	for k,enm in pairs(enemies) do
		if is_pt_circ_col(enm.pos, circle) then
			enm["col"] = true
		end
	end

	cls()
	draw_circle(circle)
	draw_pts(enemies)
end
-->8
function rnd_pts(cnt)
	local pts = {}
	for i = 0, cnt do
		local pos = {
			x = flr(rnd(129)),
			y = flr(rnd(129))
		}
		add(pts, {pos = pos})
	end

	return pts
end

function is_pt_circ_col(pt, circle)
	local d_x = circle.pos.x - pt.x
	local d_y = circle.pos.y - pt.y
	local dst = sqrt((d_x * d_x) + (d_y * d_y))

	return dst <= circle.rad
end
-->8
function draw_pts(pts)
	for k,pt in pairs(pts) do
		local rnd_col_id = flr(rnd(4)) + 1
		local col_id = pt["col"] == true and 8 or rnd_col_id

		pset(pt.pos.x, pt.pos.y, col_id)
	end
end

function draw_circle(attr)
	color(15)
	line(attr.pos.x + attr.rad, attr.pos.y, 
			 attr.pos.x + attr.rad, attr.pos.y)
	
	local pts = arc_pts(attr)
	for k, pt in pairs(pts) do
		line(attr.pos.x + pt.x, 
				attr.pos.y + pt.y)
	end
end
-->8
function deg_to_tau(deg)
	return deg / 360
end

function arc_pts(attr)
	local pts = {}
	local theta = deg_to_tau(attr.st_deg)
	local arc_stride = (attr.end_deg - attr.st_deg) / attr.pts

	for i = 0, attr.pts do
		local pt = {
				x = attr.rad * cos(theta), 
				y = attr.rad * sin(theta)
		}

		add(pts, pt)
		theta += deg_to_tau(arc_stride)
	  -- printh(pt.x.." "..pt.y)
	end

	return pts
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
