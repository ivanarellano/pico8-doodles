pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function _init()
	box_x = 32
	box_y = 58
	box_w = 64
	box_h = 12

	deg_30=.25/3
	deg_45=.25/2
	deg_15=deg_30/2
	
	rayx=0
	rayy=0
	ray_ang=deg_45
	ray_dst=1
 raydx=cos(ray_ang)*ray_dst
 raydy=-sin(ray_ang)*ray_dst
end

function _update()
	local btn_prs=false
	
 if btn(5) then 
 	ray_ang-=deg_15
 	btn_prs=true
 end
 if btn(4) then
		ray_ang+=deg_15
		btn_prs=true
 end
 if btn(0) then
 	rayx-=raydx
 end
 if btn(2) then
 	rayy-=raydy
 end
 if btn(1) then
 	rayx+=raydx
 end
 if btn(3) then
 	rayy+=raydy
 end
 
 if btn_prs then
 	raydx=cos(ray_ang)*ray_dst
 	raydy=-sin(ray_ang)*ray_dst
 end
end

function _draw()
 cls()
 
 rect(box_x,box_y,box_x+box_w,box_y+box_h,7)
 
	draw_dotted_ln()
	
	local c_pt = {x=box_x+box_w/2, y=box_y+box_h/2}
	local b_pt = {x=rayx, y=c_pt.y}
	
	local a_ln = abs(c_pt.x-b_pt.x)
	local c_ln = abs(rayy-c_pt.y)
	local b_ln = sqrt(a_ln*a_ln+c_ln*c_ln)

	local inc_ang = .5-(.25+ray_ang)
	
	-- side a
	--line(b_pt.x,b_pt.y,c_pt.x,c_pt.y,1)
	-- side c
	--line(rayx,rayy,b_pt.x,b_pt.y)
	-- side b (hyp)
	--line(rayx,rayy,c_pt.x,c_pt.y)
	
	color(7)
	print("ray_ang: "..ray_ang*360)
 --print("a_pt("..rayx..","..rayy..") ln:"..a_ln)
 --print("b_pt("..b_pt.x..","..b_pt.y..") ln:"..b_ln)
 --print("c_pt("..c_pt.x..","..c_pt.y..") ln:"..c_ln)
	print("inc_ang: "..inc_ang*360);
	--print("rdx: "..raydx.." rdy:"..raydy.." dst: "..ray_dst)
end

function draw_dotted_ln()
	if ray_dst<1 then
		return
	end
 local px,py = rayx,rayy
 repeat
  pset(px, py, 8)
  px+=raydx
  py+=raydy
 until px<0 or px>128 
 			or py<0 or py>128
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
