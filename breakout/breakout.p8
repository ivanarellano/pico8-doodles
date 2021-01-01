pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function _init()
	cls()
	mode="start"
	level=""
	levelnum=1
	levels={}
	levels[1]="p9/p9"
	--levels[1]="////x4b/s9s"
	--levels[2]="bxhxexixpxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbx"
	debug=""
end

function startgame()
	mode="game"
	
	combo_mult=1
	levelnum=1
	level=levels[levelnum]
	
	ball_r=2
	
	pad_x=30
	pad_y=120
	pad_w=24
	pad_wo=24 --og width
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

function nextlevel()
	mode="game"
	
	combo_mult=1
	sticky=true
	pad_x=30
	pad_y=120
	pad_dx=0
	
	levelnum+=1
	if levelnum>#levels then
		--finished game
		mode="start"
		return
	end
	
	level=levels[levelnum]
	
	makebricks(level)
	
	serveball()
end

function levelfinished()
	for i=1,#brick_v do
		if brick_v[i]==true and brick_t[i]!="i" then
			return false
		end
	end
	return true
end

function makebricks(lvl)
	local i,j,char,last
	brick_x={}
	brick_y={}
	brick_v={}
	brick_t={}
	brick_col={
		["b"]=14,["i"]=6,["h"]=15,
		["s"]=9,["p"]=12,["z"]=8,
		["zz"]=8}
	
	--brick types
	--b=normal
	--i=indestructible
	--h=hardened
	--e=exploding
	--p=powerup
	
	j=0
	for i=1,#lvl do
		j+=1
		char=sub(lvl,i,i)
		if char=="b" 
		or char=="i" 
		or char=="h"
		or char=="e"
		or char=="s"
		or char=="p" then
			last=char
			addbrick(j,char)
		elseif char=="x" then
			last="x"
		elseif char=="/" then
			j=(flr((j-1)/11)+1)*11
		elseif char>="0" and char<="9" then
			for o=1,char-1 do
				if last=="b" 
				or last=="i" 
				or last=="h"
				or last=="e"
				or last=="s"
				or last=="p" then
					addbrick(j,last)
				elseif last=="x" then
					--do nothing
				end
				j+=1
			end
			j-=1
		end
	end
end

function resetpowerups()
	pup_x={}
	pup_y={}
	pup_v={}
	pup_t={}
end

function addbrick(i,t)
	add(brick_x,4+((i-1)%11)*(brick_w+2))
	add(brick_y,20+flr((i-1)/11)*(brick_h+2))
	add(brick_v,true)
	add(brick_t,t)
end

function gameover()
	mode="gameover"
end

function levelover()
	mode="levelover"
end

function serveball()
	ball_x=pad_x+flr(pad_w/2)
	ball_y=pad_y-ball_r
	ball_dx=1
	ball_dy=-1
	ball_ang=1
	combo_mult=1
	points_mult=1
	sticky=true
	sticky_x=flr(pad_w/2)
	powerup=0
	powerup_t=0
	resetpowerups()
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

function box_box(box_x,box_y,box_w,box_h,box2_x,box2_y,box2_w,box2_h)
	if box_y > box2_y+box2_h then
		return false
	end
	if box_y+box_h < box2_y then
		return false
	end
	
	if box_x > box2_x+box2_w then
		return false
	end
	if box_x+box_w < box2_x then
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
	elseif mode=="levelover" then
		draw_levelover()
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
			rectfill(brick_x[i],brick_y[i],brick_x[i]+brick_w,brick_y[i]+brick_h,brick_col[brick_t[i]])
		end
	end
	
	--draw powerups
	for i=1,#pup_x do
		if pup_v[i] then
			if pup_t[i]==5 then
				palt(0,false)
				palt(11,true)
			end
			
			spr(pup_t[i],pup_x[i],pup_y[i])
			palt()
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

function draw_levelover()
	rectfill(0,60,128,76,0)
	print("stage clear",46,62,7)
	print("press ❎ to continue",27,70,7)
end
-->8
function _update60()
	if mode=="game" then
		update_game()
	elseif mode=="start" then
		update_start()
	elseif mode=="gameover" then
		update_gameover()
	elseif mode=="levelover" then
		update_levelover()
	end
end

function update_start()
	if btn(5) then
		startgame()
	end
end

function update_gameover()
	if btnp(5) then
		startgame()
	end
end

function update_levelover()
	if btnp(5) then
		nextlevel()
	end
end

function update_game()
	local btn_press = false
	local nextx,nexty
	local brickhit
	
	if powerup==4 then
		--pad expand
		pad_w=flr(pad_wo*1.5)
	elseif powerup==5 then
		--pad reduce
		pad_w=flr(pad_wo/2)
		points_mult=2
	else
		pad_w=pad_wo
		points_mult=1
	end
	
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
		ball_x=mid(3,ball_x,124)
	end
	
	if not btn_press then
		pad_dx *= .7
	end
	
	pad_x+=pad_dx
	pad_x=mid(0,pad_x,127-pad_w)
	
	--move powerups
	for i=1,#pup_x do
		if pup_v[i] then
			pup_y[i]+=.5
			--check coll for powerup
			if pup_y[i]>127 then
				pup_v[i]=false
			end
			if box_box(pup_x[i],pup_y[i],8,6,pad_x,pad_y,pad_w,pad_h) then
				pup_v[i]=false
				applypower(pup_t[i])
				sfx(1)
			end
		end
	end
	
	if levelfinished() then
		_draw()
		levelover()
	end
	
	--powerup timer
	if powerup!=0 then
		powerup_t-=1
		if powerup_t<=0 then
			powerup=0
		end
	end
	
	checkexplosions()
	
	if sticky then
		ball_x=pad_x+sticky_x
		ball_y=pad_y-ball_r-1
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
		
		--catch
		if powerup==3 and ball_dy<0 then
			sticky=true
			sticky_x=ball_x-pad_x
		end
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
			hitbrick(i,true)
		end
	end

	ball_x = nextx
	ball_y = nexty
	
	--ball missed paddle
	if nexty>127 then
		sfx(0)
		lives-=1
		if lives<0 then
			gameover()
		else
			serveball()
		end
	end
	
	debug=powerup
end

function applypower(p)
	if p==1 then
		--slowdown
		powerup=1
		powerup_t=0
	elseif p==2 then
		--life
		powerup=2
		powerup_t=0
		lives+=1
	elseif p==3 then
		--catch
		powerup=3
		powerup_t=900 --60fps*10sec
	elseif p==4 then
		--expand
		powerup=4
		powerup_t=900
	elseif p==5 then
		--reduce
		powerup=5
		powerup_t=900
	elseif p==6 then
		--megaball
		powerup=6
		powerup_t=0
	elseif p==7 then
		--multiball
		powerup=7
		powerup_t=0
	end
end

function hitbrick(i,combo)
	local brick=brick_t[i]
	
	if brick=="b" then
		sfx(1+combo_mult)
		brick_v[i]=false
		if combo then
			points+=10*combo_mult*points_mult
			combo_mult+=1
			combo_mult=mid(1,combo_mult,6)
		end
	elseif brick=="i" then
		sfx(8)
	elseif brick=="h" then
		sfx(8)
		brick_t[i]="b"
	elseif brick=="p" then
		sfx(1+combo_mult)
		brick_v[i]=false
		if combo then
			points+=10*combo_mult*points_mult
			combo_mult+=1
			combo_mult=mid(1,combo_mult,6)
		end
		spawnpowerup(brick_x[i],brick_y[i])	
	elseif brick=="s" then
		sfx(1+combo_mult)
		brick_t[i]="zz"
		if combo then
			points+=10*combo_mult*points_mult
			combo_mult+=1
			combo_mult=mid(1,combo_mult,6)
		end
	end
end

function spawnpowerup(x,y,t)
	pup_x[#pup_x+1]=x
	pup_y[#pup_x]=y
	pup_v[#pup_x]=true
	pup_t[#pup_x]=flr(rnd(7))+1
end

function checkexplosions()
	for i=1,#brick_x do
		if brick_t[i]=="zz" then
			brick_t[i]="z"
		end
	end
	
	for i=1,#brick_x do
		if brick_t[i]=="z" then
			explodebrick(i)
		end
	end
	
	for i=1,#brick_x do
		if brick_t[i]=="zz" then
			brick_t[i]="z"
		end
	end
end

function explodebrick(i)
	brick_v[i]=false
	
	for j=1,#brick_x do
		if j!=i and brick_v[j]
		and abs(brick_x[j]-brick_x[i]) <= brick_w+2
		and abs(brick_y[j]-brick_y[i]) <= brick_h+2 then
			hitbrick(j,false)
		end
	end
end
__gfx__
0000000006777760067777600677776006777760b677776b06777760067777600000000000000000000000000000000000000000000000000000000000000000
00000000659999556588885565bbbb5565cccc556500005565eeee5565aaaa550000000000000000000000000000000000000000000000000000000000000000
00700700559999555588885555bbbb5555cccc555500005555eeee5555aaaa550000000000000000000000000000000000000000000000000000000000000000
00077000559999555588885555bbbb5555cccc555500005555eeee5555aaaa550000000000000000000000000000000000000000000000000000000000000000
00077000559999555588885555bbbb5555cccc555500005555eeee5555aaaa550000000000000000000000000000000000000000000000000000000000000000
00700700059999500588885005bbbb5005cccc50b500005b05eeee5005aaaa500000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000bbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000bbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00100000110501105012050120200c0100a0500d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000190501205011050120501f0501f05021050210501c0500e050090500a00003000000000b0002870000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001805010050150501505015050170501f0502800028000220001300009000010001e0002c0003300036000350002600023000200001b00016000100000c0003e0003a000010000b000000000000000000
00010000240501c050210502105021050230502b0502800028000220001300009000010001e0002c0003300036000350002600023000200001b00016000100000c0003e0003a000010000b000000000000000000
000100002a050280502d0502d0502d0502f050370502800028000220001300009000010001e0002c0003300036000350002600023000200001b00016000100000c0003e0003a000010000b000000000000000000
0001000029150291502d1502d1503115031150351503d00028000220001300009000010001e0002c0003300036000350002600023000200001b00016000100000c0003e0003a000010000b000000000000000000
000100002c1502c15030150311503415033150391503d00028000220001300009000010001e0002c0003300036000350002600023000200001b00016000100000c0003e0003a000010000b000000000000000000
000100002b4502b4502f4502f4503645036450383003d00028000220001300009000010001e0002c0003300036000350002600023000200001b00016000100000c0003e0003a000010000b000000000000000000
000600000e1501b1501a7000050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
