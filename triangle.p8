pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
	tri_clr=6
	txt_clr=4
	
	p1={x=64,y=64}
	p2={x=64,y=127}
	p3={x=127,y=64}
end

function _update()
	handle_btn()
end

function _draw()
	cls()
	
	draw_tri(p1,p2,p3)
	print_len(p1,p2,p3)
end
-->8
function print_len(p1,p2,p3)
	print("dst(p1,p3):"..dst(p1,p3)
		,2,2,txt_clr)
	print("dst(p1,p2):"..dst(p1,p2)
		,2,12)
	print("dst(p2,p3):"..dst(p2,p3)
		,2,22)
	print("p1",p1.x-8,p1.y-6)
	print("p2",p2.x-8,p2.y-6)
	print("p3",p3.x-8,p3.y-6)
end

function print_ang(r1,r2,vrt)
end

function handle_btn()
	if(btn(0) and p1.x>0) p1.x-=1
 if(btn(1) and p1.x<127) p1.x+=1
 if(btn(2) and p1.y>0) p1.y-=1
 if(btn(3) and p1.y<127) p1.y+=1
end

function draw_tri(p1,p2,p3)
	line(p1.x,p1.y,p2.x,p2.y,tri_clr)
	line(p3.x,p3.y)
	line(p1.x,p1.y)
end
-->8
--pythagoras' theorem
--a^2 + b^2 = c^2
--in a right angled triangle
--the square of the hyp is == to
--the sum of the squares of the other two sides

function dst(p1,p2)
	local a=(p2.x-p1.x)^2
	local b=(p2.y-p1.y)^2
	return sqrt(a+b)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000