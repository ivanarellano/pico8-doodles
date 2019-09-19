pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
    printh("******")
    ball = {
        pos = {x = 64, y = 64},
        vel = {x = 0, y = 0},
        sz = 2,
        max_vel = 3.5
    }
    paddle = {
        pos = {x = 64, y = 111},
        vel = {x = 0, y = 0},
        len = 4,
        max_vel = 3
    }
    wall = {
        left = {p1 = {x = 0, y = 0 }, p2 = {x = 0, y = 127}},
        top = {p1 = {x = 0, y = 0 }, p2 = {x = 127, y = 0}},
        right = {p1 = {x = 127, y = 0}, p2 = {x = 0, y = 127}}
    }
end

function _update()
    --printh(ball.vel.x ..' ' .. ball.vel.y)
    check_ball_bounds()
    move_ball()
end

function _draw()
    cls()
    color(7)
    
    --ball
    rectfill(ball.pos.x, ball.pos.y,
             ball.pos.x + ball.sz, ball.pos.y + ball.sz)
end
-->8
function move_ball()
	if (btn(0)) ball.vel.x -= .25  --L
	if (btn(1)) ball.vel.x += .25  --R
	if (btn(2)) ball.vel.y -= .25  --D
	if (btn(3)) ball.vel.y += .25  --U

    local mag = sqrt(ball.vel.x * ball.vel.x + ball.vel.y * ball.vel.y)
    if (mag != 0) then
        if (mag > ball.max_vel) then
            ball.vel.x /= mag
            ball.vel.y /= mag

            ball.vel.x *= ball.max_vel
            ball.vel.y *= ball.max_vel
        end
    end

    ball.pos.x += ball.vel.x
    ball.pos.y += ball.vel.y
end

function check_ball_bounds()
    if (ball.pos.x > 127) then 
        ball.pos.x = 0
    elseif (ball.pos.x < 0) then 
        ball.pos.x = 127
    end

    if (ball.pos.y > 127) then 
        ball.pos.y = 0
    elseif (ball.pos.y < 0) then
        ball.pos.y = 127
    end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
