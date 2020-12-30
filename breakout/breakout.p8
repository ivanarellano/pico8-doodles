pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function _init()
	cls()
	mode="start"
	level="b6/x1b1/b8/b9"
	debug=""
end

function startgame()
	mode="game"
	
	combo_mult=1
	
	ball_r=2
	
	pad_x=30
	pad_y=120
	pad_w=25
	pad_h=4
	pad_dx=0
	
	brick_w=9
	brick_h=4
	
	makebricks(level)
	
	lives=3
	points=0
	
	sticky=true
	
	serveball()
end

function makebricks(lvl)
	local i,j,char,last
	brick_x={}
	brick_y={}
	brick_v={}
	
	j=0
	for i=1,#lvl do
		j+=1
		char=sub(lvl,i,i)
		if char=="b" then
			last="b"
			add(brick_x,4+((j-1)%11)*(brick_w+2))
			add(brick_y,20+flr((j-1)/11)*(brick_h+2))
			add(brick_v,true)
		elseif char=="x" then
			last="x"
		elseif char=="/" then
			j=(flr((j-1)/11)+1)*11
		elseif char>="0" and char<="9" then
			--debug=char
			for o=1,char-1 do
				if last=="b" then
					add(brick_x,4+((j-1)%11)*(brick_w+2))
					add(brick_y,20+flr((j-1)/11)*(brick_h+2))
					add(brick_v,true)
				elseif last=="x" then
					--do nothing
				end
				j+=1
			end
			j-=1
		end
	end
end

function gameover()
	mode="gameover"
end

function serveball()
	ball_x = pad_x+flr(pad_w/2)
	ball_y = pad_y-ball_r
	ball_dx = 1
	ball_dy = -1
	ball_ang = 1
	combo_mult = 1
	sticky=true
end

function setangle(ang)
	ball_ang=ang
	if ang==2 then
		ball_dx=0.5*sign(ball_dx)
		ball_dy=1.3*sign(ball_dy)
	elseif ang==0 then
		ball_dx=1.3*sign(ball_dx)
		ball_dy=0.5*sign(ball_dy)
	else
		ball_dx=sign(ball_dx)
		ball_dy=sign(ball_dy)
	end
end

function sign(n)
	if n>0 then
		return 1
	elseif n<0 then
		return -1
	else
		return 0
	end
end
-->8
function ball_box(bx,by,box_x,box_y,box_w,box_h)
	if by-ball_r > box_y+box_h then
		return false
	end
	if by+ball_r < box_y then
		return false
	end
	
	if bx-ball_r > box_x+box_w then
		return false
	end
	if bx+ball_r < box_x then
		return false
	end
	
	return true
end

function deflx_ball_box(bx,by,bdx,bdy,tx,ty,tw,th)
	-- calculate whether to deflect
	-- horizontally or vertically
	if bdx == 0 then
		-- moving vertically
		return false
	elseif bdy == 0 then
		-- moving horizontally
		return true
	else
		-- moving diagonally
		-- calculate slope
		local slp = bdy / bdx
		local cx, cy
		-- check variants
		if slp > 0 and bdx > 0 then
			-- moving down right
			cx = tx-bx
			cy = ty-by
			if cx <= 0 then
				return false
			elseif cy/cx < slp then
				return true
			else
				return false
			end
		elseif slp < 0 and bdx > 0 then
   -- moving up right
   cx = tx-bx
   cy = ty+th-by
   if cx<=0 then
    return false
   elseif cy/cx < slp then
    return false
   else
    return true
   end
  elseif slp > 0 and bdx < 0 then
   -- moving left up
   cx = tx+tw-bx
   cy = ty+th-by
   if cx>=0 then
    return false
   elseif cy/cx > slp then
    return false
   else
    return true
   end
  else
   -- moving left down
   cx = tx+tw-bx
   cy = ty-by
   if cx>=0 then
    return false
   elseif cy/cx < slp then
    return false
   else
    return true
   end
  end
	end
	return false
end
-->8
function _draw()
	if mode=="game" then
		draw_game()
	elseif mode=="start" then
		draw_start()
	elseif mode=="gameover" then
		draw_gameover()
	end
end

function draw_game()	
	cls(1)
	
	circfill(ball_x,ball_y,ball_r,10)
	
	if sticky then
		--serve preview
  line(ball_x+ball_dx*4,ball_y+ball_dy*4,ball_x+ball_dx*6,ball_y+ball_dy*6,10)
	end
	
	rectfill(pad_x,pad_y,pad_x+pad_w,pad_y+pad_h,7)
	
	--draw bricks
	for i=1,#brick_x do
		if brick_v[i] then
			rectfill(brick_x[i],brick_y[i],brick_x[i]+brick_w,brick_y[i]+brick_h,14)
		end
	end
	
	rectfill(0,0,128,7,0)
	if debug!="" then
		print(debug,1,1,7)
		return
	end
	
	print("lives:"..lives,1,1,7)
	print("score:"..points,40,1,7)
	
	local combo_str=""
	if combo_mult>1 then
		combo_str=""..combo_mult.."x"
	end
	print("combo:"..combo_str,80,1,7)
end

function draw_start()
	cls()
	print("pico hero breakout",30,40,7)
	print("press ❎ to start",30,70,11)
end

function draw_gameover()
	rectfill(0,60,128,76,0)
	print("game over",46,62,7)
	print("press ❎ to restart",27,70,7)
end
-->8
function _update60()
	if mode=="game" then
		update_game()
	elseif mode=="start" then
		update_start()
	elseif mode=="gameover" then
		update_gameover()
	end
end

function update_start()
	if btn(5) then
		startgame()
	end
end

function update_gameover()
	if btn(5) then
		startgame()
	end
end

function update_game()
	local btn_press = false
	local nextx,nexty
	local brickhit
	
	if btn(0) and pad_x>0 then
		pad_dx = -2.5
		btn_press = true
		if sticky then ball_dx=-1 end
	end
	if btn(1) and pad_x<127-pad_w then 
		pad_dx = 2.5
		btn_press = true
		if sticky then ball_dx=1 end
	end
	
	if sticky and btnp(5) then
		sticky=false
	end
	
	if not btn_press then
		pad_dx *= .7
	end
	
	pad_x+=pad_dx
	pad_x=mid(0,pad_x,127-pad_w)
	
	if sticky then
		ball_x = pad_x+flr(pad_w/2)
		ball_y = pad_y-ball_r-1
		return
	end
	
	-- calculate next pos
	-- before applying to ball
	nextx = ball_x + ball_dx
	nexty = ball_y + ball_dy

	if nextx>124 or nextx<3 then
		nextx=mid(0,nextx,127) --clamp
		ball_dx = -ball_dx
		sfx(1)
	end
	
	if nexty<10 then
		nexty=mid(0,nexty,127) --clamp
		ball_dy = -ball_dy
		sfx(1)
	end
	
	-- check if ball hit pad
	if ball_box(nextx,nexty,pad_x,pad_y,pad_w,pad_h) then
		-- find out in which direction to deflect
		if deflx_ball_box(ball_x,ball_y,ball_dx,ball_dy,pad_x,pad_y,pad_w,pad_h) then
			--ball hit paddle on the side
			ball_dx = -ball_dx
			if ball_x<pad_x+pad_w/2 then
				--left
				nextx=pad_x-ball_r
			else
				--right
				nextx=pad_x+pad_w+ball_r
			end
		else
			--ball hit paddle on the top/bottom
			ball_dy = -ball_dy
			if ball_y>pad_y then
				--bottom
				nexty=pad_y+pad_h+ball_r
			else
				--top
				nexty=pad_y-ball_r
				if abs(pad_dx)>2 then
					if sign(pad_dx)==sign(ball_dx) then
						--flatten angle
						setangle(mid(0,ball_ang-1,2))
					else
						--raise angle
						if ball_ang==2 then
							ball_dx=-ball_dx
						else
							setangle(mid(0,ball_ang+1,2))
						end
					end
				end
			end
		end
		sfx(1)
		combo_mult=1
	end
	
	brickhit=false
	for i=1,#brick_x do
		if brickhit then break end
		
		-- check if ball hit brick
		if brick_v[i] and ball_box(nextx,nexty,brick_x[i],brick_y[i],brick_w,brick_h) then
			-- find out in which direction to deflect
			if deflx_ball_box(ball_x,ball_y,ball_dx,ball_dy,brick_x[i],brick_y[i],brick_w,brick_h) then
				ball_dx = -ball_dx
			else
				ball_dy = -ball_dy
			end
			brickhit=true
			sfx(1+combo_mult)
			brick_v[i]=false
			points+=10*combo_mult
			combo_mult+=1
			combo_mult=mid(1,combo_mult,6)
		end
	end

	ball_x = nextx
	ball_y = nexty
	
	if nexty>127 then
		sfx(0)
		lives-=1
		if lives<0 then
			gameover()
		else
			serveball()
		end
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00100000110501105012050120200c0100a0500d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000190501205011050120501f0501f05021050210501c0500e050090500a00003000000000b0002870000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001805010050150501505015050170501f0502800028000220001300009000010001e0002c0003300036000350002600023000200001b00016000100000c0003e0003a000010000b000000000000000000
00010000240501c050210502105021050230502b0502800028000220001300009000010001e0002c0003300036000350002600023000200001b00016000100000c0003e0003a000010000b000000000000000000
000100002a050280502d0502d0502d0502f050370502800028000220001300009000010001e0002c0003300036000350002600023000200001b00016000100000c0003e0003a000010000b000000000000000000
0001000029150291502d1502d1503115031150351503d00028000220001300009000010001e0002c0003300036000350002600023000200001b00016000100000c0003e0003a000010000b000000000000000000
000100002c1502c15030150311503415033150391503d00028000220001300009000010001e0002c0003300036000350002600023000200001b00016000100000c0003e0003a000010000b000000000000000000
000100002b4502b4502f4502f4503645036450383003d00028000220001300009000010001e0002c0003300036000350002600023000200001b00016000100000c0003e0003a000010000b000000000000000000
