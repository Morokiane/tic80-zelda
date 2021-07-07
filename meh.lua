-- title:  game title
-- author: game developer
-- desc:   short description
-- script: lua

local sin,cos,rand,min,max,pi=math.sin,math.cos,math.random,math.min,math.max,math.pi
local abs=math.abs
local insert,remove=table.insert,table.remove
function dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end
function angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end
function clamp(low, n, high) return min(max(low, n), high) end
function sign(n) return n>0 and 1 or n<0 and -1 or 0 end
function rsign() return math.random(2) == 2 and 1 or -1 end
function lerp(a,b,t) return (1-t)*a + t*b end
function pal(c0,c1) if(c0==nil and c1==nil)then for i=0,15 do poke4(0x3FF0*2+i,i)end else poke4(0x3FF0*2+c0,c1) end end
function spairs(t, order) end

p={
		type="player",
		x=108,
		y=72,
		w=8,
		h=16,
		vx=0,
		vy=0,
		spr=256,
		f=0,
	}

t=0
mx=p.x//240*240
my=p.y//136*136

function TIC()
	Player()
	map()
	spr(p.spr,p.x-mx-4,p.y-my-8,4,1,p.f,0,2,2)
	
end

local sols={7,8,9,10,23,24,25,26,39,40,41,42,55,56,57,58}
local hols={19,20,21,22,23,35,36,37,38,39}
local dirs={
	[0]={0,-1},
	{0,1},
	{-1,0},
	{1,0}	
}
local locks={[92]=true,[93]=true,[108]=true,[109]=true}
local function lock(x,y)
	return locks[mget((x)//8,(y)//8)]
end

local solids={}
local holes={}
for i,v in pairs(sols) do solids[v]=true end
for i,v in pairs(hols) do holes[v]=true end
sols=nil
hols=nil
spawns={[80]=true,[82]=true,[240]=true,[241]=true,[242]=true,[224]=true,
[41]=true,[42]=true,[57]=true,[58]=true,[59]=true
}
for i=3,7 do spawns[i]=true end

function sol(x,y)
	return solids[mget((x)//8,(y)//8)]
end

function hsol(x,y)
	return solids[mget((x)//8,(y)//8)] and not holes[mget((x)//8,(y)//8)]
end

function col(t1,t2)
	return t1.x+t1.w>=t2.x and t1.x<=t2.x+t2.w and t1.y+t1.h>=t2.y and t1.y<=t2.y+t2.h
end

function col1(px,py,x,y,w,h)
	return px<=x+w and px>=x and py>=y and py<=y+h
end

function col2(x1,y1,w1,h1,x2,y2,w2,h2)
	return x1+w1>=x2 and x1<=x2+w2 and y1+h1>=y2 and y1<=y2+h2
end

function Player()
	if btn(0) then
		p.vy=-1
		p.spr=258+t%2//10
	elseif btn(1) then
		p.vy=1
		p.spr=spr(258+t%20//10)
	else
		p.vy=p.vy+(-sign(p.vy)/8)
	end

	if btn(2) then
		p.vx=-1
		p.f=0
		p.spr=260+((t//5)%4)*2
	elseif btn(3) then
		p.vx=1
		p.spr=260+((t//5)%4)*2
		p.f=1
	else
		p.vx=p.vx+(-sign(p.vx)/8)
	end

	if sol(p.x,p.y+p.vy) or sol(p.x+7,p.y+p.vy) or sol(p.x,p.y+7+p.vy) or sol(p.x+7,p.y+7+p.vy) then
		p.vy=0
	end

	if sol(p.x+p.vx,p.y+p.vy) or sol(p.x+7+p.vx,p.y+p.vy) or sol(p.x+p.vx,p.y+7+p.vy) or sol(p.x+7+p.vx,p.y+7+p.vy) then
		p.vx=0
	end

	p.x=p.x+p.vx
	p.y=p.y+p.vy

	local obj=mget((p.x+3)//8,(p.y+3)//8)

end
