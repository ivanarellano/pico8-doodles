pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function _init()
	cartdata("breakout")
	cls()
	mode="start"
	shake=0
	level=""
	levelnum=1
	levels={}
	--levels[1]="b9bb9bb9bb9bb9bp9p"
	levels[1]="/x4b/s3s3s3/b9"
	--levels[2]="bxhxsxixpxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbx"
	debug=""
	
	--highscore
	hs={}
	hs1={}
	hs2={}
	hs3={}
	hsx=128
	hsdx=128
	loghs=false

	loadhs()
	hschars={"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"," "} 
	
	blink_col=7
	blink_col_i=1
	blinkframe=0
	blinkspeed=10
	
	blink_grey=7
	blink_grey_i=1
	
	blink_w=7
	blink_w_i=1
	
	start_count=-1
	gover_count=-1
	
	fadeperc=1
	
	arrowmult=1
	arrowmult_2=1
	arrow_count=0
	
	--particles
	prt={}
	
	lasthitx=0
	lasthity=0
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
	
	sticky=false
	
	timer_mega=0
	timer_slow=0
	timer_expand=0
	timer_reduce=0
	
	serveball()
end

function nextlevel()
	mode="game"
	
	sticky=false
	combo_mult=1

	pad_x=30
	pad_y=120
	pad_dx=0
	
	levelnum+=1
	if levelnum>#levels then
		mode="start"
		return
	end
	
	level=levels[levelnum]
	
	makebricks(level)
	
	serveball()
end

function levelfinished()
	for brick in all(bricks) do
		if brick.v and brick.t!="i" then
			return false
		end
	end
	return true
end

function makebricks(lvl)
	local i,j,char,last
	bricks={}
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

function addbrick(i,t)
	local b={}
	b.x=4+((i-1)%11)*(brick_w+2)
	b.y=20+flr((i-1)/11)*(brick_h+2)
	b.v=true
	b.t=t
	b.flash=0
	b.ox=0
	b.oy=-(128+rnd(128))
	b.dx=0
	b.dy=rnd(64)
	
	add(bricks,b)
end

function gameover()
	mode="gameoverwait"
	gover_count=60
	blinkspeed=16
end

function levelover()
	mode="leveloverwait"
	lover_count=60
end

function wingame()
	mode="winnerwait"
	lover_count=60
	
	--check if cur score is new hs
	if points>hs[5] then
		loghs=true
	else
		loghs=true
	end
end

function serveball()
	balls={}
	balls[1]=newball()
	
	balls[1].x=pad_x+flr(pad_w/2)
	balls[1].y=pad_y-ball_r
	balls[1].dx=1
	balls[1].dy=-1
	balls[1].ang=1
	balls[1].stuck=true
	
	combo_mult=1
	points_mult=1
	
	sticky_x=flr(pad_w/2)
	
	pups={}
	
	timer_mega=0
	timer_slow=0
	timer_expand=0
	timer_reduce=0
end

function newball()
	local b={}
	b.x=0
	b.y=0
	b.dx=1
	b.dy=-1
	b.ang=1
	b.stuck=false
	return b
end

function copyball(b)
	local new={}
	new.x=b.x
	new.y=b.y
	new.dx=b.dx
	new.dy=b.dy
	new.ang=b.ang
	new.stuck=b.stuck
	return new
end

function multiball()
	local rnd_ball=balls[flr(rnd(#balls)+1)]
	local b2=copyball(rnd_ball)
	
	if rnd_ball.ang==0 then
		setangle(b2,2)
	elseif balls[1].ang==1 then
		setangle(b2,2)
		setangle(rnd_ball,0)
	else
		setangle(b2,0)
	end
	
	b2.stuck=false
	balls[#balls+1]=b2
end

function setangle(ball,ang)
	ball.ang=ang
	if ang==2 then
		ball.dx=0.5*sign(ball.dx)
		ball.dy=1.3*sign(ball.dy)
	elseif ang==0 then
		ball.dx=1.3*sign(ball.dx)
		ball.dy=0.5*sign(ball.dy)
	else
		ball.dx=sign(ball.dx)
		ball.dy=sign(ball.dy)
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
--collision

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
--draw

function _draw()
	if mode=="game" then
		draw_game()
	elseif mode=="start" then
		draw_start()
	elseif mode=="gameover" then
		draw_gameover()
	elseif mode=="gameoverwait" then
		--draw_game()
	elseif mode=="levelover" then
		draw_levelover()
	elseif mode=="leveloverwait" then
		draw_game()
	elseif mode=="winner" then
		draw_winner()
	elseif mode=="winnerwait" then
		draw_game()
	end
	
	pal()
	if fadeperc!=0 then
		fadepal(fadeperc)
	end
end

function draw_game()	
	cls()
	rectfill(0,0,127,127,1)
	
	--draw bricks
	for i=1,#bricks do
		local b=bricks[i]
		
		if b.v or b.flash>0 then
			local col=brick_col[b.t]
			if b.flash>0 then
				col=7
				b.flash-=1
			end
			
			local bx=b.x+b.ox
			local by=b.y+b.oy
			
			rectfill(bx,by,bx+brick_w,by+brick_h,col)
		end
	end
	
	drawparts()
	
	--draw powerups
	for pup in all(pups) do
			if pup.t==5 then
				palt(0,false)
				palt(11,true)
			end
			
			spr(pup.t,pup.x,pup.y)
			palt()
	end
	
	--balls
	for i=#balls,1,-1 do
		local b=balls[i]
		local ballc=10
		
		if timer_mega>0 then
			ballc=14
		end
		
		circfill(b.x,b.y,ball_r,ballc)
		
		if b.stuck then
			--serve preview
			pset(
				b.x+b.dx*4*arrowmult,
				b.y+b.dy*4*arrowmult,10)
			pset(
				b.x+b.dx*4*arrowmult_2,
				b.y+b.dy*4*arrowmult_2,10)
		end
	end
	
	rectfill(pad_x,pad_y,pad_x+pad_w,pad_y+pad_h,7)
	
	rectfill(0,0,128,7,0)
	if debug!="" then
		print(debug,1,1,7)
		return
	end
	
	print("lives:"..lives,1,1,7)
	print("score:"..points,35,1,7)
	
	local combo_str=""
	if combo_mult>1 then
		combo_str=""..combo_mult.."x"
	end
	print("combo:"..combo_str,90,1,7)
end

function draw_start()
	cls()
	
	prinths(hsx)
	
	print("pico hero breakout",hsx-100,40,7)
	print("press ❎ to start",30,70,blink_col)
	print("press ⬅️ to see high scores",9,87,11)
end

function draw_gameover()
	rectfill(0,60,128,76,0)
	print("game over",46,62,7)
	print("press ❎ to restart",27,70,blink_grey)
end

function draw_levelover()
	rectfill(0,60,128,76,0)
	print("stage clear",46,62,7)
	print("press ❎ to continue",27,70,blink_grey)
end

function draw_winner()
	if loghs then
		--has a hs
		local y=40
		rectfill(0,y,128,y+52,14)
	
		print("★congratulations!★",24,y+4,blink_w)
		print("you are a breakout hero.",14,y+12,7)
		print("enter your initials for",16,y+18,7)
		print("the high score list.",14,y+24,7)
		print("mvm",56,y+36,2)
		
		--print("press ❎ for main menu",20,y+44,10)
		print("use ⬅️➡️❎🅾️",36,y+44,2)
	else
		--not a hs
		local y=40
		rectfill(0,y,128,y+52,14)
	
		print("★congratulations!★",24,y+4,blink_w)
		print("you are a breakout winner.",14,y+12,7)
		print("however you didn't make",16,y+18,7)
		print("it to the high score list.",14,y+24,7)
		print("try again!",46,y+36,7)
		
		print("press ❎ for main menu",20,y+44,10)
	end
end
-->8
--update

function _update60()
	doblink()
	doshake()
	updateparts()
	
	if mode=="game" then
		update_game()
	elseif mode=="start" then
		update_start()
	elseif mode=="gameover" then
		update_gameover()
	elseif mode=="gameoverwait" then
		update_gameoverwait()
	elseif mode=="levelover" then
		update_levelover()
	elseif mode=="leveloverwait" then
		update_leveloverwait()
	elseif mode=="winner" then
		update_winner()
	elseif mode=="winnerwait" then
		update_winnerwait()
	end
end

function update_start()
	--slide high score list
	if hsx!=hsdx then
		--ease in
		hsx+=(hsdx-hsx)/5
	end
	
		--fade in game
	if fadeperc!=0 then
		fadeperc-=.05
		if fadeperc<0 then
			fadeperc=0
		end
	end
	
	if start_count<0 then
		if btnp(5) then
			sfx(9)
			start_count=80
			blinkspeed=1
		end
		
		if btnp(0) then
			hsdx=20
		end
		if btnp(1) then
			hsdx=128
		end
	else
		start_count-=1
		fadeperc=(80-start_count)/80
		if start_count<=0 then
			start_count=-1
			blinkspeed=10
			startgame()
		end
	end
end

function update_gameover()
 if gover_count<0 then
  if btnp(5) then
   gover_count=80
   blinkspeed=1
   sfx(9)
  end
 else
  gover_count-=1
  fadeperc=(80-gover_count)/80
  if gover_count<=0 then
   gover_count= -1
   blinkspeed=8
   startgame()
  end 
 end
end

function update_gameoverwait()
	gover_count-=1
	if gover_count<=0 then
		gover_count=-1
		mode="gameover"
	end
end

function update_leveloverwait()
	lover_count-=1
	if lover_count<=0 then
		lover_count=-1
		mode="levelover"
	end
end

function update_winnerwait()
	lover_count-=1
	if lover_count<=0 then
		lover_count=-1
		mode="winner"
	end
end

function update_levelover()
 if lover_count<0 then
  if btnp(5) then
   lover_count=80
   blinkspeed=1
   sfx(9)
  end
 else
  lover_count-=1
  fadeperc=(80-lover_count)/80
  if lover_count<=0 then
   lover_count= -1
   blinkspeed=8
   nextlevel()
  end 
 end
end

function update_winner()
 if lover_count<0 then
  if btnp(5) then
   lover_count=80
   blinkspeed=1
   sfx(9)
  end
 else
  lover_count-=1
  fadeperc=(80-lover_count)/80
  if lover_count<=0 then
   lover_count= -1
   blinkspeed=8
			mode="start"
   hsx=128
   hsdx=20
  end 
 end
end

function update_game()
	local btn_press = false
	local nextx,nexty
	local brickhit
	
	--fade in game
	if fadeperc!=0 then
		fadeperc-=.05
		if fadeperc<0 then
			fadeperc=0
		end
	end
	
	if timer_expand>0 then
		--pad expand
		pad_w=flr(pad_wo*1.5)
	elseif timer_reduce>0 then
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
		pointstuck(-1)
	end
	if btn(1) and pad_x<127-pad_w then 
		pad_dx = 2.5
		btn_press = true
		pointstuck(1)
	end
	
	if btnp(5) then
		releasestuck()
	end
	
	if not btn_press then
		pad_dx *= .7
	end
	
	pad_x+=pad_dx
	pad_x=mid(0,pad_x,127-pad_w)
	
	--ball loop
	for bi=#balls,1,-1 do
		updateball(bi)
	end
	
	local del_pups={}
	for pup in all(pups) do
		--move powerups
		pup.y+=.5
		--check coll for powerup
		if pup.y>127 then
			add(del_pups,pup)
		elseif box_box(pup.x,pup.y,8,6,pad_x,pad_y,pad_w,pad_h) then
			sfx(1)
			applypower(pup.t)
			spawnpowpuff(pup.x,pup.y,pup.t)
			add(del_pups,pup)
		end
	end
	
	for del_pup in all(del_pups) do
		del(pups,del_pup)
	end
	
	if levelfinished() then
		_draw()
		
		if levelnum>=#levels then
			wingame()
		else
			levelover()
		end
	end
	
	--powerup timers
	if timer_mega>0 then
		timer_mega-=1
	end
	if timer_slow>0 then
		timer_slow-=1
	end
	if timer_expand>0 then
		timer_expand-=1
	end
	if timer_reduce>0 then
		timer_reduce-=1
	end
	
	checkexplosions()
	
	animatebricks()
end

function updateball(i)
	local b=balls[i]
	
	if b.stuck then
		b.x=pad_x+sticky_x
		b.y=pad_y-ball_r-1
		return
	end
	
	if timer_slow>0 then	
	-- calculate next pos
	-- before applying to ball
		nextx = b.x + (b.dx/2)
		nexty = b.y + (b.dy/2)
	else
		nextx = b.x + b.dx
		nexty = b.y + b.dy
	end

	--check if ball hit wall
	if nextx>124 or nextx<3 then
		nextx=mid(0,nextx,127) --clamp
		b.dx = -b.dx
		sfx(1)
		spawnpuff(nextx,nexty)
	end
	if nexty<10 then
		nexty=mid(0,nexty,127) --clamp
		b.dy = -b.dy
		sfx(1)
		spawnpuff(nextx,nexty)
	end
	
	-- check if ball hit pad
	if ball_box(nextx,nexty,pad_x,pad_y,pad_w,pad_h) then
		-- find out in which direction to deflect
		if deflx_ball_box(b.x,b.y,b.dx,b.dy,pad_x,pad_y,pad_w,pad_h) then
			--ball hit paddle on the side
			b.dx = -b.dx
			if b.x<pad_x+pad_w/2 then
				--left
				nextx=pad_x-ball_r
			else
				--right
				nextx=pad_x+pad_w+ball_r
			end
		else
			--ball hit paddle on the top/bottom
			b.dy = -b.dy
			if b.y>pad_y then
				--bottom
				nexty=pad_y+pad_h+ball_r
			else
				--top
				nexty=pad_y-ball_r
				if abs(pad_dx)>2 then
					if sign(pad_dx)==sign(b.dx) then
						--flatten angle
						setangle(b,mid(0,b.ang-1,2))
					else
						--raise angle
						if ball_ang==2 then
							b.dx=-b.dx
						else
							setangle(b,mid(0,b.ang+1,2))
						end
					end
				end
			end
		end
		spawnpuff(nextx,nexty)
		sfx(1)
		combo_mult=1
		
		--catch
		if sticky and b.dy<0 then
			releasestuck()
			sticky=false
			b.stuck=true
			sticky_x=b.x-pad_x
		end
	end
	
	brickhit=false
	for i=1,#bricks do
		if brickhit then break end
		
		-- check if ball hit brick
		if bricks[i].v and ball_box(nextx,nexty,bricks[i].x,bricks[i].y,brick_w,brick_h) then
			if timer_mega>0 and bricks[i].t=="i"
			or timer_mega<=0 then
				lasthitx=b.dx
				lasthity=b.dy
				-- find out in which direction to deflect
				if deflx_ball_box(b.x,b.y,b.dx,b.dy,bricks[i].x,bricks[i].y,brick_w,brick_h) then
					b.dx = -b.dx
				else
					b.dy = -b.dy
				end
			end
			
			brickhit=true
			hitbrick(i,true)
		end
	end

	b.x = nextx
	b.y = nexty
	
	--trail particles
	if timer_mega>0 then
		spawnmegatrail(nextx,nexty)
	else
		spawntrail(nextx,nexty)
	end
	
	--ball missed paddle
	if nexty>127 then
		sfx(0)
		spawndeath(b.x,b.y)
		if #balls>1 then
			shake+=0.1
			del(balls,b)
		else
			shake+=0.4
			lives-=1
			if lives<0 then
				gameover()
			else
				serveball()
			end
		end
	end
end

function releasestuck()
	for i=1,#balls do
		if balls[i].stuck then
			balls[i].stuck=false
			balls[i].x=mid(3,balls[i].x,124)
		end
	end
end

function pointstuck(sign)
	for i=1,#balls do
		--ball stuck to pad
		--can be targeted
		if balls[i].stuck then
			balls[i].dx=abs(balls[i].dx)*sign
		end
	end
end

function applypower(p)
	if p==1 then
		--slowdown
		timer_slow=900
	elseif p==2 then
		--life
		lives+=1
	elseif p==3 then
		--catch
		--check for stuck balls
		hasstuck=false
		for i=1,#balls do
			if balls[i].stuck then
				hasstuck=true
			end
		end
		if hasstuck==false then
			sticky=true
		end
	elseif p==4 then
		--expand
		timer_expand=900
		timer_reduce=0
	elseif p==5 then
		--reduce
		timer_reduce=900
		timer_expand=0
	elseif p==6 then
		--megaball
		timer_mega=300
	elseif p==7 then
		--multiball
		multiball()
	end
end

function hitbrick(i,combo)
	local brick=bricks[i].t
	local flashtime=8
	
	if brick=="b" then
		--regular brick
		sfx(1+combo_mult)
		--spawn particles
		shatterbrick(bricks[i],lasthitx,lasthity)
		bricks[i].flash=flashtime
		bricks[i].v=false
		if combo then
			points+=10*combo_mult*points_mult
			combo_mult+=1
			combo_mult=mid(1,combo_mult,6)
		end
	elseif brick=="i" then
		--indestructible
		sfx(8)
	elseif brick=="h" then
		--hardened
		if timer_mega>0 then
			sfx(1+combo_mult)
			bricks[i].flash=flashtime
			bricks[i].v=false
		if combo then
			points+=10*combo_mult*points_mult
			combo_mult+=1
			combo_mult=mid(1,combo_mult,6)
		end
		else
			sfx(8)
			bricks[i].t="b"
		end
	elseif brick=="p" then
		--powerup
		sfx(1+combo_mult)
		bricks[i].flash=flashtime
		
		--spawn particles
		shatterbrick(bricks[i],lasthitx,lasthity)
		bricks[i].v=false
		if combo then
			points+=10*combo_mult*points_mult
			combo_mult+=1
			combo_mult=mid(1,combo_mult,6)
		end
		spawnpowerup(bricks[i].x,bricks[i].y)	
	elseif brick=="s" then
		--exploding
		sfx(1+combo_mult)
		shatterbrick(bricks[i],lasthitx,lasthity)
		bricks[i].t="zz"
		shake+=0.1
		if combo then
			points+=10*combo_mult*points_mult
			combo_mult+=1
			combo_mult=mid(1,combo_mult,6)
		end
	end
end

function spawnpowerup(x,y)
	local p={}
	p.x=x
	p.y=y
	p.t=flr(rnd(7))+1
	add(pups,p)
end

function checkexplosions()
	for i=1,#bricks do
		if bricks[i].t=="zz" and bricks[i].v then
			bricks[i].t="z"
		end
	end
	
	for i=1,#bricks do
		local b=bricks[i]
		if b.t=="z" and b.v then
	
			explodebrick(i)
			spawnexplosion(b.x,b.y)
		end
	end
	
	for i=1,#bricks do
		if bricks[i].t=="zz" then
			bricks[i].t="z"
		end
	end
end

function explodebrick(i)
	bricks[i].v=false
	
	for j=1,#bricks do
		if j!=i and bricks[j].v
		and abs(bricks[j].x-bricks[i].x) <= brick_w+2
		and abs(bricks[j].y-bricks[i].y) <= brick_h+2 then
			hitbrick(j,false)
		end
	end
end
-->8
--juicyness

function doshake()
	-- -16 +16
	local shakex=16-flr(rnd(32))
	local shakey=16-flr(rnd(32))
	
	shakex*=shake
	shakey*=shake
	
	camera(shakex,shakey)
	
	shake*=.95
	if shake<.05 then
		shake=0
	end
end

function doblink()
	local col={3,11,10,7}
	local grey_col={5,6,7,6}
	local win_col={2,7,15,7}
	
	--text blink
	blinkframe+=1
	if blinkframe>blinkspeed then
		blinkframe=0
		blink_col_i+=1
		if blink_col_i>#col then
			blink_col_i=1
		end
		blink_col=col[blink_col_i]
		
		blink_grey_i+=1
		if blink_grey_i>#grey_col then
			blink_grey_i=1
		end
		blink_grey=grey_col[blink_col_i]
	
		blink_w_i+=1
		if blink_w_i>#win_col then
			blink_w_i=1
		end
		blink_w=win_col[blink_w_i]
	end
	
	--arrow anim
	arrow_count+=1
	if arrow_count>30 then
		arrow_count=0
	end
	
	local af2=arrow_count+15
	if af2>30 then
		af2=af2-30
	end
	
	arrowmult=1+(2*(arrow_count/30))
	arrowmult_2=1+(2*(af2/30))
end

function fadepal(_perc)
 -- 0 means normal
 -- 1 is completely black
 
 local p=flr(mid(0,_perc,1)*100)
 
 -- these are helper variables
 local kmax,col,dpal,j,k
 dpal={0,1,1, 2,1,13,6,
          4,4,9,3, 13,1,13,14}
 
 -- now we go trough all colors
 for j=1,15 do
  --grab the current color
  col = j
  
  --now calculate how many
  --times we want to fade the
  --color.
  kmax=(p+(j*1.46))/22  
  for k=1,kmax do
   col=dpal[col]
  end
  
  --finally, we change the
  --palette
  pal(j,col,1)
 end
end

--particles
function addpart(x,y,dx,dy,typ,maxage,col,s)
	local p = {}
	p.x=x
	p.y=y
	p.dx=dx
	p.dy=dy
	p.typ=typ
	p.maxage=maxage
	p.age=0
	p.col=0
	p.colarr=col
	p.rot=0
	p.rottimer=0
	p.size=s
	p.os=s
	add(prt,p)
end

function shatterbrick(b,vx,vy)
	if shake<.5 then
		shake+=.07
	end
	
	sfx(10)
	
	--bump the brick
	b.dx=vx*.7
	b.dy=vy*.7
	
	for x=0,brick_w do
		for z=0,brick_h do
			if rnd()<.5 then
				local ang=rnd()
				local dx=cos(ang)*rnd(2)+vx
				local dy=sin(ang)*rnd(2)+vy
				
				addpart(
					b.x+x,b.y+z,
					dx,dy,1,80,{7,6,5})
			end
		end
	end
	
	local chunks=1+flr(rnd(5))
	for i=1,chunks do
		local ang=rnd()
		local dx=cos(ang)*rnd(1.5)+vx/2
		local dy=sin(ang)*rnd(1.5)+vy/2
		--rnd sprite: 16-19
		local spri=16+flr(rnd(10))
		
		addpart(
			b.x,b.y,
			dx,dy,3,100,{spri})
	end
end

function animatebricks()
	for i=1,#bricks do
		local b=bricks[i]
		if b.v or b.flash>0 then
			--see if bricks are moving
			if b.dx!=0 or b.dy!=0 or b.oy!=0 or b.ox!=0 then
				--apply speed to brick
				b.ox+=b.dx
				b.oy+=b.dy
				
				--adjust speed towards 0
				b.dx-=b.ox/10
				b.dy-=b.oy/10
				
				--speed will overshoot 0
				--bring back to a min
				--with dampening
				if abs(b.dx)>(b.ox) then
					b.dx=b.dx/1.3
				end	
				if abs(b.dy)>(b.oy) then
					b.dy=b.dy/1.3
				end
				
				--snap to 0 (rest position)
				--when offset+speed are
				--close to resting
				if abs(b.oy)<.2 and abs(b.dy)<.25 then
					b.oy=0
					b.dy=0
				end
				if abs(b.ox)<.2 and abs(b.dx)<.25 then
					b.ox=0
					b.dx=0
				end
			end
		end
	end
end

function spawnexplosion(x,y)
	--first smoke
	for i=1,10 do
		local ang=rnd()
		local dx=cos(ang)*rnd(2)
		local dy=sin(ang)*rnd(2)
		local col={0,0,5,5,6}

		addpart(x,y,dx,dy,2,10+rnd(15),col,1+rnd(4))
	end
	
	--fireball
	for i=1,15 do
		local ang=rnd()
		local dx=cos(ang)*(rnd(2)+1.2)
		local dy=sin(ang)*(rnd(2)+1.2)
		local col={7,10,9,8,5}

		addpart(x,y,dx,dy,2,20+rnd(20),col,1+rnd(4))
	end	
end

function spawndeath(x,y)
	for i=1,20 do
		local ang=rnd()
		local dx=cos(ang)*(rnd(3)+1.2)
		local dy=sin(ang)*(rnd(3)+1.2)
		local col={10,10,9,4,0}

		addpart(x,y,dx,dy,2,20+rnd(15),col,1+rnd(4))
	end	
end

--puff in powerup color
function spawnpowpuff(x,y,t)
	for i=1,20 do
		local ang=rnd()
		local dx=cos(ang)*(rnd(2)+1.2)
		local dy=sin(ang)*(rnd(2)+1.2)
		local col
		
  if t == 1 then
   -- slowdown -- orange
   col={9,9,4,4,0}
  elseif t == 2 then
   -- life -- red
   col={8,8,2,2,0}
  elseif t == 3 then
   -- catch -- green
   col={11,11,3,3,0}
  elseif t == 4 then
   -- expand -- blue
   col={12,12,5,5,0}
  elseif t == 5 then
   -- reduce -- black
   col={0,0,5,5,6}
  elseif t == 6 then
   -- megaball -- pink
   col={14,14,13,2,0}
  else
   -- multiball -- red
   col={8,8,4,2,0}
  end  
	
		addpart(x,y,dx,dy,2,20+rnd(15),col,1+rnd(4))
	end	
end

function spawnpuff(x,y)
	for i=1,5 do
		local ang=rnd()
		local dx=cos(ang)*1.3
		local dy=sin(ang)*1.3
	
		addpart(x,y,dx,dy,2,15+rnd(15),{7,6,5},1+rnd(2))
	end
end

function spawntrail(x,y)
	--reduces amt of parts
	if rnd()<.5 then
		local ang=rnd()
		local ox=cos(ang)*ball_r*.4
		local oy=sin(ang)*ball_r*.4
	
		addpart(x+ox,y+oy,
			0,0,
			0,15+rnd(15),
			{10,9},0)
	end
end

function spawnmegatrail(x,y)
	--reduces amt of parts
	if rnd() then
		local ang=rnd()
		local ox=cos(ang)*ball_r
		local oy=sin(ang)*ball_r
	
		addpart(x+ox,y+oy,
			0,0,
			2,30+rnd(15),
			{14,2,5},1+rnd(2))
	end
end

--type 0: pixel prt
--type 1: gravity prt
--type 2: ball of smoke
--type 3: rotating spr
function updateparts()
	for i=#prt,1,-1 do
		local p=prt[i]
		
		p.age+=1
		if p.age>p.maxage then
			del(prt,p)
		elseif p.x<-20 or p.x>148 then
			del(prt,p)
		elseif p.y<-20 or p.y>148 then
			del(prt,p)
		else
			--change colors
			if #p.colarr==1 then
				p.col=p.colarr[1]
			else
				--0-1,mult by color len,flr
				--set is ints: [0-arrlen]
				local ci=1+flr((p.age/p.maxage)*#p.colarr)
				p.col=p.colarr[ci]
			end
			
			--gravity
			if p.typ==1 or p.typ==3 then
				p.dy+=.08
			end
			
			--rotate
			if p.typ==3 then
				p.rottimer+=1
				if p.rottimer>2 then
					p.rot+=1
					if p.rot>=4 then
						p.rot=0
					end
				end
			end
			
			--shrink
			if p.typ==2 then
				--start at 100
				local per=1-(p.age/p.maxage)
				p.size=per*p.os
			end
			
			--friction/drag
			if p.typ==2 then
				p.dx/=1.1
				p.dy/=1.1
			end
			
			--move particle
			p.x+=p.dx
			p.y+=p.dy
		end
	end
end

function drawparts()
	for i=1,#prt do
		local p=prt[i]
		
		--pixel particle
		if p.typ==0 or p.typ==1 then
			pset(p.x,p.y,p.col)
		elseif p.typ==2 then
			circfill(p.x,p.y,p.size,p.col)
		elseif p.typ==3 then
			local fx,fy
			
			if p.rot==2 then
				fx=false
				fy=true
			elseif p.rot==3 then
				fx=true
				fy=true
			elseif p.rot==4 then
				fx=true
				fy=false
			else
				fx=false
				fy=false
			end
			
			spr(p.col,p.x,p.y,1,1,fx,fy)
		end
	end
end
-->8
--highscore

function reseths()
	hs={500,400,300,200,100}
	hs1={9,13,10,1,1}
	hs2={1,22,12,1,1}
	hs3={27,13,1,1,1}
	savehs()
end

function loadhs()
	local slot=0
	
	--flags: 1=there is data
	--       0=no data
	if dget(0)==1 then
		slot+=1
		for i=1,5 do
			hs[i]=dget(slot)
			hs1[i]=dget(slot+1)
			hs2[i]=dget(slot+2)
			hs3[i]=dget(slot+3)
			slot+=4
			
		end
	else
		--hs list is empty
		reseths()
	end
end

function savehs()
	local slot=0
	--1 indicates hs exists
	dset(0,1)
	
	slot=1
	for i=1,5 do
		dset(slot,hs[i])
		dset(slot+1,hs1[i])
		dset(slot+2,hs2[i])
		dset(slot+3,hs3[i])
		
		slot+=4
	end
end

function prinths(x)
	rectfill(x+10,8,x+78,16,12)
	print("high score list",x+15,10,7)

	for i=1,5 do
		--rank
		print(i.." - ",x+10,15+7*i,5)
		
		local c=7
		if i==1 then
			c=blink_grey
		end
		
		--name
		local name=""..hschars[hs1[i]]..hschars[hs2[i]]..hschars[hs3[i]]
		print(name,x+30,15+i*7,c)
		
		--score
		local score=" "..hs[i]
		print(score,x+78-(#score*4),15+7*i,c)
	end
end

--sort high score list
--ia: class sort would be nice
function sorths()
 for i=1,#hs do
  local j = i
  while j > 1 and hs[j-1] < hs[j] do
   hs[j],hs[j-1]=hs[j-1],hs[j]
   hs1[j],hs1[j-1]=hs1[j-1],hs1[j]
   hs2[j],hs2[j-1]=hs2[j-1],hs2[j]
   hs3[j],hs3[j-1]=hs3[j-1],hs3[j]
   j = j - 1
  end
 end
end

function addhs(score,chars)
 add(hs,score)
 add(hs1,chars[1])
 add(hs2,chars[2])
 add(hs3,chars[3])
 sorths()
end

__gfx__
0000000006777760067777600677776006777760b677776b06777760067777600000000000000000000000000000000000000000000000000000000000000000
00000000659449556582885565bbbb5565cccc556500005565eeee5565aaaa550000000000000000000000000000000000000000000000000000000000000000
00700700559499555582885555bbbb5555cccc555500005555eeee5555aaaa550000000000000000000000000000000000000000000000000000000000000000
00077000559449555582885555bbbb5555cccc555500005555eeee5555aaaa550000000000000000000000000000000000000000000000000000000000000000
00077000559949555582285555bbbb5555cccc555500005555eeee5555aaaa550000000000000000000000000000000000000000000000000000000000000000
00700700059449500582285005bbbb5005cccc50b500005b05eeee5005aaaa500000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000bbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000bbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000007700000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777000007700000007777007700000006666000006600000660000006660000006660000050000000500000000000000000000000000000000000000000000
00077000000770000000077000777700000606000066660000666000006666000066600000555500005550000000000000000000000000000000000000000000
00000000000770000000000000077000000000000006600000660000000600000060000000055000000550000000000000000000000000000000000000000000
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
000300001875018750287502875018750187502875028750197501975028750287500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002c6301f6201a620156200f6100b6100461002610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
