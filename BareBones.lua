-- title:  Bare Bones
-- author: trelemar, level27geek, RushJet1
-- desc:   Gloomy Dungeon Chaos for FC_JAM
-- script: lua
-- saveid: BareBonesFCJAM

local credits={
	"Art: @FredBednarski",
	"Music/Map: @RushJet1",
	"Code/Art: @trelemar",
}

local sin,cos,rand,min,max,pi=math.sin,math.cos,math.random,math.min,math.max,math.pi
local abs=math.abs
local insert,remove=table.insert,table.remove
--need the following dist function for probably moving the crate. These variables are called in the col2 function
function dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end
function angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end
function clamp(low, n, high) return min(max(low, n), high) end
function sign(n) return n>0 and 1 or n<0 and -1 or 0 end
function rsign() return math.random(2) == 2 and 1 or -1 end
function lerp(a,b,t) return (1-t)*a + t*b end
function pal(c0,c1) if(c0==nil and c1==nil)then for i=0,15 do poke4(0x3FF0*2+i,i)end else poke4(0x3FF0*2+c0,c1) end end
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

local sols={1,2,17,18,19,20,21,22,23,35,36,37,38,39,84,85,86,87,90,91,100,101,102,103,104,105,106,107,145,47}
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
--might need this function?
function col2(x1,y1,w1,h1,x2,y2,w2,h2)
	return x1+w1>=x2 and x1<=x2+w2 and y1+h1>=y2 and y1<=y2+h2
end

function printc(text,y,c,scale)
  local string=text
  local width=font(string,0,-200,5,8,6,false,scale or 1)
  pal(15,0)
  font(string,(240-width)//2-1,y,5,8,6,false,scale or 1)
  font(string,(240-width)//2+1,y,5,8,6,false,scale or 1)
  font(string,(240-width)//2,y-1,5,8,6,false,scale or 1)
  font(string,(240-width)//2,y+1,5,8,6,false,scale or 1)
  pal()
  font(string,(240-width)//2,y,5,8,6,false,scale or 1)
end

function box2(x,y,w,h)
	rect(x-2,y,w+4,h,1)
	rect(x,y-2,w,h+4,1)
	rect(x-1,y-1,w+2,h+2,0)
	rect(x,y,w,h,3)
end

function tset(tile)
	mset((p.x+3)//8,(p.y+3)//8,tile)
end

function addParts(n,t)
	for i=1,n do table.insert(parts,t) end
end

function throwBone()
	bone={}
	bone_t=t
	bone.x=p.x+4
	bone.y=p.y
	bone.vx=dirs[bone_dir][1]*3
	bone.vy=dirs[bone_dir][2]*3
end

function checkBone()
	return bone and t-bone_t<30
end

function isEnemy(v)
	return v.type=="blob" or v.type=="fly" or v.type=="knight"
end

function doBone()
	if bone then
		spr(496,bone.x-mx-3,bone.y-my-3,6,1,0,(t/4)%4)
		if t-bone_t<30 then
			if hsol(bone.x,bone.y) or bone.x//240~=p.x//240 or bone.y//136~=p.y//136 then
				for i=1,2 do
					table.insert(parts,{x=bone.x,y=bone.y,size=2,resize=-.1,c=15})
				end
				bone_t=t-40
			end
			for i,v in pairs(ents) do
				if isEnemy(v) and col2(bone.x+bone.vx,bone.y+bone.vy,8,8,v.x,v.y,v.w or 8, v.h or 8) then
					local a=angle(bone.x,bone.y,v.x,v.y)
					hurtEnt(i,a)
					bone_t=t-40
				end
			end
		end
		bone.x=bone.x+bone.vx
		bone.y=bone.y+bone.vy
		if (t/2)%8==0 then
			table.insert(parts,{x=bone.x,y=bone.y})
		end
		if t-bone_t>30 then
			local a=angle(bone.x,bone.y,p.x,p.y)
			bone.vx=cos(a)*3
			bone.vy=sin(a)*3
			if col2(bone.x,bone.y,8,8,p.x,p.y,8,8) then
				bone=nil
				sfx(58)
			end
		end
	end
end

function doParts()
	for i,v in pairs(parts) do
		v.t=(v.t and v.t+1) or 0
		v.x=v.x+(v.vx or 0)
		v.y=v.y+(v.vy or 0)
		v.x=v.x+rand(-1,1)
		v.y=v.y+rand(-1,1)
		v.size=(v.size or 1.5)+(v.resize or 0)

		circ(v.x-mx,v.y-my,v.size or 1.5,v.c or 15)

		if v.c2 and v.size then 
			circ(v.x-mx-1,v.y-my-1,v.size-1,v.c2)
		end

		if v.t>((v.max and v.max) or 20) then 
			table.remove(parts,i) 
		end
	end
	--print(#parts,0,0)
end

ani={blob={},kni={}}
ani.blob.idle={384}
ani.blob.walk={384,386,388,386}
ani.blob.hit={384,390,392}
ani.blob.spit={0,4,5,5}
ani.kni={
	hwalk={418,420,422,418},
	dwalk={450,452,454,450},
	uwalk={482,484,486,482}
}

function blobDraw(t)

end

function doEnts()
	for i,v in pairs(ents) do
		if v.type=="knight" then
			if v.vx<0 then 
				v.f=1
			else 
				v.f=0
			end

			if sol(v.x+v.vx,v.y) or sol(v.x+15+v.vx,v.y) or sol(v.x+v.vx,v.y+7) or sol(v.x+15+v.vx,v.y+7) then
				v.vx=-v.vx
			end

			if sol(v.x,v.y+v.vy) or sol(v.x,v.y+7+v.vy) or sol(v.x+15,v.y+v.vy) or sol(v.x+15,v.y+7+v.vy) then
				v.vy=-v.vy
			end
			--not sure what this is doing might be getting coords for the object in a table on where to draw it.
			for ib,b in pairs(ents) do
				if b.type=="crate" or b.type=="blob" then
					if col2(v.x+v.vx,v.y,15,8,b.x,b.y,b.w,b.h) then
						v.vx=-v.vx
					end
					if col2(v.x,v.y+v.vy,15,8,b.x,b.y,b.w,b.h) then
						v.vy=-v.vy
					end
				end
			end

			if (v.vx~=0 or v.vy~=0) and ((t/5)%4==0) then
				for i=1,2 do
					table.insert(parts,{x=v.x+(i%2*16),y=v.y+7,vx=v.vx/4,vy=v.vy/4,max=20,size=1.5,resize=-.05,c=15,c2=3})
				end
			end

			
			if abs(v.vx)>abs(v.vy) then
				v.ani=v.anis.hwalk
			elseif abs(v.vy)>abs(v.vx) and v.vy>0 then
				v.ani=v.anis.dwalk
				v.f=0
			elseif abs(v.vy)>abs(v.vx) and v.vy<0 then
				v.ani=v.anis.uwalk
				v.f=0
			end

			v.x=v.x+v.vx
			v.y=v.y+v.vy
			v.spr=v.ani[((t//6)% #v.ani)+1]
		elseif v.type=="blob" then
			local a=angle(v.x,v.y,p.x,p.y)

			if t-v.hurt_t>20 then
				v.vx=cos(a)/2
				v.vy=sin(a)/2
			else
				v.vx=v.vx+(-sign(v.vx)/10)
				v.vy=v.vy+(-sign(v.vy)/10)
			end

			if sol(v.x,v.y+v.vy) or sol(v.x+15,v.y+v.vy) or sol(v.x,v.y+7+v.vy) or sol(v.x+15,v.y+7+v.vy) then
				v.vy=0
			end

			if sol(v.x+v.vx,v.y+v.vy) or sol(v.x+15+v.vx,v.y+v.vy) or sol(v.x+v.vx,v.y+7+v.vy) or sol(v.x+15+v.vx,v.y+7+v.vy) then
				v.vx=0
			end
			--not sure what this is doing looks like some type of positioning?
			for ib,b in pairs(ents) do
				if b.type=="crate" then
					if col2(b.x,b.y,b.w,b.h,v.x+v.vx,v.y,15,8) then
						v.vx=0
					end
					if col2(b.x,b.y,b.w,b.h,v.x,v.y+v.vy,15,8) then
						v.vy=0
					end
				end
				if b.type=="blob" then
					if i~=ib then
						if col2(v.x+v.vx,v.y,15,8,b.x+b.vx,b.y,15,8) then
							v.vx=0
						end
						if col2(v.x,v.y+v.vy,15,8,b.x,b.y+b.vy,15,8) then
							v.vy=0
						end
					end
				end
			end

			if col2(v.x+v.vx,v.y,15,8,p.x,p.y,8,8) then
				v.vx=0
			end

			if col2(v.x,v.y+v.vy,15,8,p.x,p.y,8,8) then
				v.vy=0
			end

			if (v.vx>0 or v.vy>0) then
				v.ani=v.anis.walk
				if (t/4)%2==0 then
					insert(parts,{x=v.x+8,y=v.y,t=0,c=6})
				end
			else
				v.ani=v.anis.idle
			end

			if t-v.hurt_t<20 then
				v.ani=v.anis.hit
			else
				if v.vx>0 then v.f=0 else v.f=1 end
			end



			v.x=v.x+v.vx
			v.y=v.y+v.vy
			v.spr=v.ani[((t//6)% #v.ani)+1]

		elseif v.type=="fly" then
			local a=angle(p.x,p.y,v.x,v.y)
			v.x=v.x+rand(-2,2)
			v.y=v.y+rand(-2,2)
			v.x=lerp(v.x,p.x,0.02)
			v.y=lerp(v.y,p.y,0.02)

		elseif v.type=="item" then
			if col2(v.x,v.y,8,8,p.x,p.y,8,8) and t-p.hurt_t>40 then
				if v.id==3 then
					msg(fstr.."Body")
				elseif v.id==4 then
					p.hands=true
					msg(fstr.."Hands")
				elseif v.id==5 then
					p.pelvis=true
					msg(fstr.."Pelvis")
				elseif v.id==6 then
					p.feet=true
					msg(fstr.."Feet")
				end

				if v.id>=3 and v.id<=6 then
					p.parts[v.id]=true
				end


				if v.id==7 then
					sfx(61,"F-5")
					msg("Key found")
					keys=keys+1
				else
					sfx(56,"F-5")
				end
				for i=1,4 do
					insert(parts,{x=v.x+rand(0,8),y=v.y+rand(0,8),t=0,c=0,size=rand(1,2)+.5})
				end
				remove(ents,i)
			end

			if sol(v.x+v.vx,v.y) or sol(v.x+7+v.vx,v.y) or sol(v.x+v.vx,v.y+7) or sol(v.x+7+v.vx,v.y+7) then
				v.vx=-v.vx
			end

			if sol(v.x,v.y+v.vy) or sol(v.x+7,v.y+v.vy) or sol(v.x,v.y+v.vy+7) or sol(v.x+7,v.y+v.vy+7) then
				v.vy=-v.vy
			end

			if math.abs(v.vx)>0.2 then
				v.vx=v.vx+(-sign(v.vx)/10)
			else
				v.vx=0
			end

			if math.abs(v.vy)>0.2 then
				v.vy=v.vy+(-sign(v.vy)/10)
			else
				v.vy=0
			end

			v.x=v.x+v.vx
			v.y=v.y+v.vy

		elseif v.type=="crate" then
		end
	end
end

function drawBlob(v)
	rect(v.x-mx-1,v.y-my+8,18,1,0)
	rect(v.x-mx,v.y-my+7,16,3,0)
	rect(v.x-mx+3,v.y-my+6,10,5,0)
	pal()
	if t-v.hurt_t<10 and t%4==0 then
		pal(0,15)
	end
	spr(v.spr,v.x-mx,v.y-my-7,11,1,v.f,0,2,2)
	pal()
end

function drawKnight(v)
	rect(v.x-mx-1,v.y-my+8,18,1,0)
	rect(v.x-mx,v.y-my+7,16,3,0)
	rect(v.x-mx+3,v.y-my+6,10,5,0)
	pal()
	if t-v.hurt_t<10 and t%4==0 then
		pal(0,15)
	end
	local dx,dy=v.x-mx,v.y-my-7
	local sx,sy=dx-7,dy+8
	local sf,sr=0,0
	local first=false
	if v.spr==v.ani[1] then sx=sx+1 end
	if v.ani==v.anis.hwalk and v.f==0 then
		sx=dx+15,dy+8 sf=1
		if v.spr==v.ani[1] then sx=sx-1 end
	elseif v.ani==v.anis.dwalk then 
		sx,sy=dx,dy+15 sr=3
		if v.spr==v.ani[1] then sy=sy-1 end
	elseif v.ani==v.anis.uwalk then
		sx,sy=dx+11,dy
		sf=1
		sr=1
		first=true
		if v.spr==v.ani[1] then sy=sy+1 end
	end
	if first then
		spr(417,sx,sy,11,1,sf,sr)
	end
	spr(v.spr,dx,dy,11,1,v.f,0,2,2)
	if not first then
		spr(417,sx,sy,11,1,sf,sr)
	end

	pal()
end

function drawFly(v)
	--rectb(v.x-mx,v.y-my,8,8,15)
	local dx=cos(t/4)*3-4
	local dy=sin(t/2)-4
	rect(v.x+2-mx+dx,v.y+3-my,4,2,0)
	rect(v.x+3-mx+dx,v.y+2-my,2,4,0)
	if t-v.hurt_t<20 and (t//4)%2==0 then
		pal(0,15)
	end
	spr(41+(t//2)%2,v.x-mx+dx,v.y-my-6+dy,11)
	pal()
end
--this gets the info from addEnts table
function drawCrate(self)
	spr(self.spr,self.x-mx,self.y-my,6,1,0,0,2,2)
end

function drawItem(self)
	circ(self.x+4-mx,self.y+3.5-my,2+(sin(t/8)*.5),0)
	circ(self.x+3-mx,self.y+3.5-my,2+(sin(t/8)*.5),0)
	spr(self.id,self.x-mx,self.y-my-4+(sin(t/8)*2),1)
end

function drawPlayer(self)
	for i=1,14 do pal(i,1) end
	pal(10,10)

	if self.parts[6] then --feet
		pal(7,7)
		pal(11,10)
	end
	if self.parts[4] then --Hands
		pal(14,15)
	end
	if self.parts[3] then --Body
		pal(8,8)
		pal(2,2)
	end
	if self.parts[5] then --Belt/Pelvis
		pal(4,4)
	end
	rect(self.x-mx,self.y-my+6,8,3,0)
	rect(self.x-mx-1,self.y-my+7,10,1,0)

	if t-self.hurt_t<20 and (t//4)%2==0 then
		pal(0,15)
	end
	spr(self.spr,self.x-mx-4,self.y-my-8,6,1,self.f,0,2,2)
	pal()
end

function hurtEnt(i,a)
	sfx(62,"C-5")
	local v=ents[i]
	local vel=2
	if ents[i].type=="knight" then vel=1.5 end
	v.vx=cos(a)*vel
	v.vy=sin(a)*vel
	v.hurt_t=t
	v.hp=v.hp-1
	if v.hp<=0 then
		remove(ents,i)
	end
end

function doPlayer()
	if btn(0) then
		p.vy=-1
		p.spr=160+((t//8)%4)*2
		bone_dir=0
	elseif btn(1) then
		p.vy=1
		p.spr=128+((t//8)%4)*2
		bone_dir=1
	else
		p.vy=p.vy+(-sign(p.vy)/8)
	end

	if btn(2) then
		p.vx=-1
		p.f=1
		p.spr=192+((t//5)%4)*2
		bone_dir=2
	elseif btn(3) then
		p.vx=1
		p.spr=192+((t//5)%4)*2
		p.f=0
		bone_dir=3
	else
		p.vx=p.vx+(-sign(p.vx)/8)
	end

	if btnp(4) or (btnp(5) and not bone) then
		local sprs={224,226}
		sfx(63)
		p.punch_t=t
		p.phand=sprs[rand(1,2)]
		p.vx,p.vy=0,0
		if btnp(4) then
			for i,v in pairs(ents) do
				if v.type=="blob" or v.type=="knight" then
					if col2(p.x-2+p.vx,p.y-2+p.vy,12,12,v.x+v.vx,v.y+v.vy,16,8) then
						sfx(62)
						local a=angle(p.x+4,p.y,v.x+8,v.y)
						hurtEnt(i,a)
						for i=1,(v.hp<=0 and 8) or 4 do
							insert(parts,{x=v.x+8,y=v.y,t=0,size=rand(1,2)+.5,c=6})
						end
						if v.hp<=0 then
							remove(ents,i)
						end
					end
				elseif v.type=="fly" then
					if col1(v.x,v.y,p.x-2+p.vx,p.y-2+p.vy,12,12) then
						sfx(62)
						local a=angle(p.x+4,p.y+4,v.x,v.y)
						for i=1,2 do
							insert(parts, {x=v.x,y=v.y,t=0,size=.5+rand(1,2),c=15})
						end
						v.x=v.x+cos(a)*8
						v.y=v.y+sin(a)*8
						v.hp=v.hp-1
						if v.hp<=0 then
							remove(ents,i)
						end
					end
				end
			end
		end
	end 

	if t-p.punch_t<10 then
		p.spr=p.phand
		p.vx=0
		p.vy=0
	end

	if btnp(5) then
		--table.insert(bones,{x=p.x+4,y=p.y,vx=dirs[bone_dir][1]*3,vy=dirs[bone_dir][2]*3})
		if not bone then throwBone() sfx(57) end
	end

	--Particles
	if (btn(0) or btn(1) or btn(2) or btn(3)) and ((t/5)%4==0) then
		for i=1,2 do
			table.insert(parts,{x=p.x+(i%2*8),y=p.y+7,vx=p.vx/4,vy=p.vy/4,max=20,size=1.5,resize=-.05,c=15,c2=3})
		end
	end

	for i,v in pairs(ents) do
		if v.type=="knight" then
			if col2(p.x+p.vx,p.y+p.vy,8,8,v.x+v.vx,v.y+v.vy,16,8) then
				local a=angle(v.x+8,v.y,p.x+4,p.y)
				p.vx=cos(a)*2
				p.vy=sin(a)*2
				if t-p.hurt_t>20 then
					hurtPlayer(a)
				end
			end
		elseif v.type=="blob" then

			if col2(p.x+p.vx,p.y+p.vy,8,8,v.x+v.vx,v.y+v.vy,16,8) then
				local a=angle(v.x+8,v.y,p.x+4,p.y)
				p.vx=cos(a)*2
				p.vy=sin(a)*2
				if t-p.hurt_t>20 then
					hurtPlayer(a)
				end
			end

		elseif v.type=="crate" then

			if col2(p.x+p.vx,p.y+p.vy,8,8,v.x,v.y,v.w,v.h) then
				--print("true",2,16)
				sfx(55,"F-2")

				p.vx,p.vy=p.vx/2,p.vy/2
				local dest_x,dest_y=v.x+p.vx,v.y+p.vy
				local hit=false
				--crate
				for ib,b in pairs(ents) do
					if b.type=="crate" then
						if i~=ib and col2(dest_x,dest_y,v.w,v.h,b.x,b.y,b.w,b.h) and b.type=="crate" then
							hit=true
						end
					elseif b.type=="blob" then
						if col2(dest_x,dest_y,v.w,v.h,b.x+b.vx,b.y+b.vy,16,8) and b.type=="blob" then
							hit=true
						end
					end
				end

				if not (sol(dest_x,dest_y) or sol(dest_x+(v.w-1),dest_y) or sol(dest_x,dest_y+(v.h-1)) or sol(dest_x+(v.w-1),dest_y+(v.h-1))) and not hit then
					v.x,v.y=dest_x,dest_y
					if t%6==0 then
						table.insert(parts,{x=v.x+8,y=v.y+16,t=5})
					end
				else
					p.vx,p.vy=0,0
				end

			end
		end
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

	--[[for i=1,14 do pal(i,1) end
			pal(10,10)
		
			if p.parts[6] then --feet
				pal(7,7)
				pal(11,10)
			end
			if p.parts[4] then --Hands
				pal(14,15)
			end
			if p.parts[3] then --Body
				pal(8,8)
				pal(2,2)
			end
			if p.parts[5] then --Belt/Pelvis
				pal(4,4)
			end
			rect(p.x-mx,p.y-my+6,8,3,0)
			rect(p.x-mx-1,p.y-my+7,10,1,0)
		
			if t-p.hurt_t<20 and (t//4)%2==0 then
				pal(0,15)
			end
			spr(p.spr,p.x-mx-4,p.y-my-8,6,1,p.f,0,2,2)
			pal()--]]

	--rectb(p.x,p.y,8,8,14)
	--pix(p.x+3,p.y+3,14)
	--print(obj,0,0)
end

function hurtPlayer(a)
	--This function will remove a body part from player and add it as an item back on the map.
	--If only the player's head is left, he will die.
	sfx(62,"c#4")
	p.hurt_t=t
	local vx=cos(a)*2
	local vy=sin(a)*2
	local id=false
	if p.parts[6] then
		p.parts[6]=false
		id=6
	elseif p.parts[5] then
		p.parts[5]=false
		id=5
	elseif p.parts[4] then
		p.parts[4]=false
		id=4
	elseif p.parts[3] then
		p.parts[3]=false
		id=3
	end
	if id then
		table.insert(ents, {type="item",id=id,x=p.x+4,y=p.y,vx=vx,vy=vy} )
	else
		reset=true
	end
end

function msg(string)
	msg_t=t
	message=string
end

function draw_msg()
	if t-msg_t<80 then
	local w=font(message,0,-8,5,7,8,false)
	local dx=120-(w/2)
	box2(dx-2,120,w+4,10)
	font(message,dx,121,5,7,8,false)
	end
end

function addEnts()
	for i=2,#ents do ents[i]=nil end
	for x=mx/8,mx/8+29 do
		for y=my/8,my/8+16 do
			local id=mget(x,y)
			if id>=3 and id<=7 then
				insert(ents,{type="item",id=id,x=x*8,y=y*8,vx=0,vy=0})
			end
			if id==80 or id==82 then
				local bw,bh=12,14
				if id==82 then bw,bh=11,14 end
				table.insert(ents,{type="crate",spr=id,x=x*8,y=y*8,w=12,h=14})
			end
			if id==57 then
				table.insert(ents,{type="blob",spr=384,x=x*8,y=y*8,vx=0,vy=0,anis=ani.blob,hurt_t=0,hp=4,w=16,h=8})
			end
			if id==58 or id==59 then
				local vx,vy=0,.5
				if id==59 then vx,vy=.5,0 end
				table.insert(ents,{type="knight",spr=418,x=x*8,y=y*8,vx=vx,vy=vy,anis=ani.kni,hurt_t=0,hp=5,w=16,h=8})
			end
			if id==41 then
				table.insert(ents,{type="fly",spr=id,x=x*8,y=y*8,vx=0,vy=0,hurt_t=0,hp=2,w=1,h=1})
			end

			local mapx,mapy=x-mx,y-my
			--[[
			if (mapx%30==14 or mapx%30==15) and mapy%17>=15 then mset(x,y,8) end
			if (mapy%17==7 or mapy%17==8) and (x>2 and mapx%30>=28 or mapx%30<=1) then mset(x,y,8) end
			--]]
		end
	end
end

local doors={
	{x=14*8,y=0},
	{x=28*8,y=7*8},
	{x=14*8,y=15*8},
	{x=0,y=7*8}
}

function init()
	pmem(0,pmem(0)+1)
	music(pmem(0)%6)
	reset=false
	solved=false
	keys=0
	state=0
	t=0
	ents={
		{
		type="player",
		x=108,
		y=72,
		w=8,
		h=16,
		vx=0,
		vy=0,
		spr=128,
		f=0,
		}
	}
	p=ents[1]

	p.parts={
		[3]=true,
		[4]=true,
		[5]=true,
		[6]=true
	}

	p.hands=false
	p.feet=false
	p.body=false
	p.pelvis=false

	p.punch_t=-20
	p.hurt_t=0

	--ents={}
	parts={}
	bones={}
	boxes={}
	items={}
	bone_dir=1

	mx=p.x//240*240
	my=p.y//136*136
	msg_t=-80
	fstr="You found your "

	addEnts()
end

init()
dc={
	{14,0},
	{28,27},
	{14,15},
	{0,15}

}
function TIC()
	t=t+1
	if state==0 then
		if btnp(4) then state=1 end
		printc("Bare Bones",38,15,3)
		for i=1,#credits do local s=credits[i]
			printc(s,68+i*10,15)
		end
		printc("Press A",136-12,15)
		msg("Dungeon 1")
	elseif state==1 then
		if t-p.hurt_t<10 then
			poke(0x03ff9,rand(-2,2))
			poke(0x03ff9+1,rand(-2,2))
		else
			poke(0x03ff9,0)
			poke(0x03ff9,0)
		end
		--mx=lerp(mx,p.x+p.vx-120,0.04)
		--my=lerp(my,p.y+p.vy-68,0.04)
		if p.x//240*240~=mx or p.y//136*136~=my then
			mx=p.x//240*240
			my=p.y//136*136
			addEnts()
		end
		cls(1)
		local buttons=0
  local sbuttons=0
		if not solved then
			for i,v in pairs(doors) do
				if not (sol(v.x+mx,v.y+my)) or locks[mget((v.x//8)+mx,(v.y//8)+my)] then
					spr(8,v.x,v.y,-1,1,0,i-1,2,2)
				end
			end
		end
		map(mx//8,my//8,30,17,0,0,1,1,function(id,x,y)
			local f,r=0,0

			if id==1 then
				if mget(x-1,y)==17 and mget(x,y+1)==17 then
					r=1
				elseif mget(x-1,y)==17 and mget(x,y-1)==17 then
					r=2
				elseif mget(x+1,y)==17 and mget(x,y-1)==17 then
					r=3
				end
			elseif id==2 then
				if mget(x-1,y)==18 and mget(x,y+1)==18 then
					r=1
				elseif mget(x-1,y)==18 and mget(x,y-1)==18 then
					r=2
				elseif mget(x+1,y)==18 and mget(x,y-1)==18 then
					r=3
				end
			end

			if id==17 then
				if mget(x,y+1)==18 or mget(x,y+1)==2 then
					r=1
				elseif mget(x-1,y)==18 or mget(x-1,y)==2 then
					r=2
				elseif mget(x,y-1)==18 or mget(x,y-1)==2 then
					r=3
				end
			elseif id==18 then
				if mget(x,y-1)==17 then
					r=1
				elseif mget(x+1,y)==17 then
					r=2
				elseif mget(x,y+1)==17 then
					r=3
				end
			end

			if id==33 then
				if mget(x-1,y)==49 and mget(x,y+1)==49 then
					r=1
				elseif mget(x-1,y)==49 and mget(x,y-1)==49 then
					r=2
				elseif mget(x+1,y)==49 and mget(x,y-1)==49 then
					r=3
				end
			end

			if id==49 then
				if mget(x,y-1)==18 then
					r=1
				elseif mget(x+1,y)==18 then
					r=2
				elseif mget(x,y+1)==18 then
					r=3
				end
			end

			if spawns[id] then
				id=0
			end

			if id==0 then
				if x%2==0 and y%2==0 then
					r=2
				elseif x%2==0 then
					r=1
				elseif y%2==0 then
					r=3
				end
			end
			if id==112 then
			buttons=buttons+1
				for i,v in pairs(ents) do
					if col2(x*8,y*8,8,8,v.x,v.y,v.w or 8, v.h or 8) and v.type~="fly" then
						id=113
						sbuttons=sbuttons+1 break
					end
				end
			end

			if id==0 then end

			return id,f,r
		end
		)
		--doBoxes()
		--doItems()
		--doPlayer()
		pal()
		doEnts()
		doPlayer()

		doParts()
		badcount=0
		for i,v in spairs(ents, function(t,a,b) return t[a].y < t[b].y end) do
			if v.type=="player" then
				drawPlayer(v)
			elseif v.type=="blob" then
				drawBlob(v)
				badcount=badcount+1
			elseif v.type=="fly" then
				drawFly(v)
				badcount=badcount+1
			elseif v.type=="knight" then
				drawKnight(v)
				badcount=badcount+1
			elseif v.type=="item" then
				drawItem(v)
			elseif v.type=="crate" then
				drawCrate(v)
			end
		end
		if buttons>0 and sbuttons==buttons then solved=true 
		elseif badcount==0 and buttons>=0 then solved=true
		else solved=false end
		if not solved then p.x=clamp(mx+16,p.x,mx+240-24)
		p.y=clamp(my+16,p.y,my+136-24)
		end
		doBone()
		--line(120,0,120,136,15)
		--line(0,68,240,68,15)
		draw_msg()
		--print(#ents,0,0)
		--print(p.body,0,8)
		--print("Ents: "..#ents.."Bads: "..badcount.."\nMX, MY: "..mx.." "..my)
	elseif state==2 then
		printc("GAME OVER",68,15,2)
		printc("Press A",78,15,1)
		if btnp(4) then init() end
	end

	if reset then init() end
end
-- <TILES>
-- 000:1111111111111111111111111111111111111111111111111111111111111111
-- 001:1100000019999011094494990949949909999000004404940199099001990409
-- 002:9000000009044444004011110404011104104000041101010411001004110101
-- 003:1111111110111101020000800228888002288880102288011100001111111111
-- 004:1111111111111111100110010ff00ff00f0110f0101111011111111111111111
-- 005:1111111111111111111111111100001110444401110000111111111111111111
-- 006:11111111111111111101101110a007010a700370100110011111111111111111
-- 007:1100000110ee999010e00090110ee901111090111110e9011110940111110011
-- 008:0000000010777777917777779133333310033333103333331033333310333333
-- 009:0000000077777701777777193333331933333001333333013333330133333301
-- 016:0000000010777777917777779133333310033333103333331033333310333333
-- 017:0199044101990441019940000199044101990441019904410199044101990441
-- 018:0411011004110110000001100411011004110000041101100411011004110110
-- 019:1111111111444411141111444100001141040400400100411400001014010100
-- 020:1111111411444441441011101100000100404114140011010100001000101001
-- 021:4111111114444411011101441000001141140400101100410100001010010100
-- 022:1111111111444411441111411100001400404014140010040100004100101041
-- 023:1400000014000000140000001400000040000000400000004000000014000000
-- 024:0033333310333333103333331033333300033333103333331033333300000000
-- 025:3333330033333301333333013333330133333000333333013333330100000000
-- 032:0033333310333333103333331033333300033333103333331033333300000000
-- 033:0101010110101010010111111011111101111111101111110111111110111111
-- 034:1111111111110101110111101111111011011100110000001110000111111111
-- 035:4000000040000000140000001400000014000000114440001111140011111144
-- 036:0000000000000000000000000000000000000000000000004444000411114441
-- 037:0000000000000000000000000000000000000000000000004000444414441111
-- 038:0000000400000004000000410000004100000041000444110041111144111111
-- 039:0000004100000041000000410000004100000004000000040000000400000041
-- 040:6669966666100966610000966100009666100966661009666600096666666666
-- 041:aabbbbaa7aa00aa7b70ee07bb0e2ee0bb0ceee0bbb0cc0bbbbb00bbbbbbbbbbb
-- 042:bbbbbbbbbbb00bbbbb0ee0bbb0e2ee0bb0ceee0bb70cc07baa7007aabbbbbbbb
-- 047:1111111111111111111111111111111111111111111111111111111111111111
-- 048:1111111111110011111111111011111110111111111111111111101111111111
-- 049:1011111101111111101111110111111110111111011111111011111101111111
-- 050:1111111111111100111100551110555b110555b511105b551105b5551105b555
-- 051:1111111111100011010555005055b555b55b5b5b5bb555555555555555555555
-- 052:11111111111111110010111155050111bb55501155b55011555b55015555b501
-- 053:105b55551105b55511105b5511105b55111105b511110555111055b5111055b5
-- 054:555b501155b5011155b55011555b55015555b501555b550155555011555b5011
-- 055:5555555555555555555555555555555555555555555555555555555555555555
-- 056:555b55555555eb5555555ebe555555e5be55e5555be55555555ee5555555b555
-- 057:6666666666ee66646eeee6646eeee66466ee6644666666460006664600000666
-- 058:bbbbbbbbb3bbbb3bb033330bb360063bbb3003bbbb3003bbbb3003bbbb3333bb
-- 059:bbbbbbbbbbbb303b333363bb300003bb300003bb333363bbbbbb303bbbbbbbbb
-- 064:22809e0122809e0122809e0122809e0100049e01999990014999009100000991
-- 065:1111111111001111111111111111110111111101111111111101111111111111
-- 066:105b55551055b55511055b55110555bb11105055111101001111111111111111
-- 067:555555555555555555555bb5b5b5b55b555b5505005550101100011111111111
-- 068:555b5011555b501155b501115b555011b5550111550011110011111111111111
-- 069:5555b501555b501155b5011155b501115b501111555011115b5501115b550111
-- 070:1105b555110555551055b555105b55551055b55511055b5511105b551105b555
-- 071:5555555555eb5b555eb555555b5555b555555be5b5555e555bb555555eeb5555
-- 072:5555555555bb55555eeeb55555ee55555555555555555eb555555bb555555555
-- 080:6000000009999999091111110914444409199999091999990949999909444444
-- 081:0000066699999066111190664441906699919066999190669994906644449066
-- 082:6000000009999999099000000904040409494949094949490949494909910101
-- 083:0000666699990666009906660409066649190666491906664919066601990666
-- 084:1110000011099999101911111019199901191999011919990119199901191444
-- 085:0000011199999011111194019991940199919410999194109991941044419410
-- 086:1111110011110099111099991109999911011999110111991011111110114444
-- 087:0001111199901111999901119991011199440111944401114414401144999101
-- 088:1111111111111111111111111111111111111111111111111111111111111111
-- 089:1111111111111111111111111111111111111111111111111111111111111111
-- 090:1111111111111100111110991111099911110999110011111099914410999919
-- 091:0000111199940111999440119914440111449901449994019999940199991440
-- 092:1111111111111111111111111111111111111119111111101111110011111100
-- 093:1111111111111111111111111111111191111111091111110091111100911111
-- 096:0999999904444444040000000404444404144444041111110444444460000000
-- 097:9999906644444066000040664440406644414066111140664444406600000666
-- 098:0999999904111111011000000101010101414141014444440111111160000000
-- 099:9999066611140666001106660101066641410666444106661111066600006666
-- 100:0119111101199999011944440194444401944444094444440911111100000000
-- 101:1111941099999410444494104444491044444910444444901111119000000000
-- 102:0114444409999444099999440199914400011411001444400001144410001140
-- 103:4144990141110001111444011144444011444440114444100144410000041000
-- 104:1100000110999990101999911014991101444444011444441011144111001114
-- 105:1111111100011111999011119999011199999011199990111114401141110111
-- 106:0999991909999111109991111009911410091144101111111101111111101000
-- 107:9114444014444440444444404441144044441140444411011141101111110011
-- 108:1111111011111110111111001111111111111111111111111111111111111111
-- 109:0911111109111111091111111111111111111111111111111111111111111111
-- 112:1000000104444440049999400499994004999940041111400444444010000001
-- 113:1000000109999990091111900944449009444490094444900999999010000001
-- 128:666666666666600066660fff6660ffff6660af0f6660a00f6660aaff666600a0
-- 129:6666666600066666fff06666ffff0666ff0f0666f00f0666ffff06660f006666
-- 130:6666600066660fff6660ffff6660af0f6660a00f6660aaff666600a0666602aa
-- 131:00066666fff06666ffff0666ff0f0666f00f0666ffff06660f006666ff806666
-- 132:666666666666600066660fff6660ff0f6660a00f6660afff6660aaff666600a0
-- 133:6666666600066666fff06666ff0f0666f00f0666ffff0666ffff06660f006666
-- 134:6666600066660fff6660ffff6660af0f6660a00f6660aaff666600a0666602aa
-- 135:00066666fff06666ffff0666ff0f0666f00f0666ffff06660f006666ff806666
-- 136:bbbbbb00bbbbb046bbbb0466bbb04469bbb0446ebbb04466bbbb0446bbbbb040
-- 137:0000bbbb66690bbb666690bb90f960bbe11e60bbeeee60bb66660bbb4040bbbb
-- 138:bbbbbb00bbbbb046bbbb0466bbb04469bbb0446ebbb04466bbbb0446bbbb0400
-- 139:0000bbbb66690bbb666690bb90f960bbe11e60bbeeee60bb66660bbb4040bbbb
-- 140:bbbbbb00bbbbb046bbbb0466bbb04469bbb0446ebbb04466bbbb0446bbbbb040
-- 141:0000bbbb66690bbb666690bb90f960bbe11e60bbeeee60bb66660bbb4040bbbb
-- 142:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 143:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 144:666602aa6660222266602288666600286660ee446660e0306666077066666006
-- 145:ff80666688880666882806668200666644ee06660b0e066607b0666660066666
-- 146:6660222266602288666600286660ee446660e000666600b066660b7066666006
-- 147:888806668828066682ee0666440e066603006666073066666006666666666666
-- 148:666602aa6660222266602288666600286660ee446660e0306666077066666006
-- 149:ff80666688880666882806668200666644ee06660b0e066607b0666660066666
-- 150:66602222666022886660ee286660e04466660030666607706666600666666666
-- 151:88880666882806668200666644ee0666000e06660b00666607b0666660066666
-- 152:bb00b060b0ee0060bb009600bbbb00b0bbbbbbb0bbbbbbb0bbbbbb0ebbbbbbb0
-- 153:6060bbbb6060bbbb6060bbbb6090bbbb60e0bbbb900bbbbb0bbbbbbbbbbbbbbb
-- 154:bbbb0600b00006000e966006b0000b06bbbbbb06bbbbb090bbbb0e0bbbbbb0bb
-- 155:6060bbbb6060bbbb0060bbbb090bbbbb0e0bbbbbb0bbbbbbbbbbbbbbbbbbbbbb
-- 156:bb000600b09660b00e000b06b00ee060bbb0090bbbbbb0bbbbbbbbbbbbbbbbbb
-- 157:6060bbbb690bbbbbe0bbbbbb0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 158:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 159:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 160:666666666666600066660fff6660ffff6660afff6660afff6660aaff666600aa
-- 161:6666666600066666fff06666ffff0666ffff0666ffff0666ffff0666ff006666
-- 162:6666600066660fff6660ffff6660afff6660afff6660aaff666600aa66660222
-- 163:00066666fff06666ffff0666ffff0666ffff0666ffff0666ff00666688806666
-- 164:666666666666600066660fff6660ffff6660afff6660afff6660aaff666602aa
-- 165:6666666600066666fff06666ffff0666ffff0666ffff0666ffff0666ff806666
-- 166:6666600066660fff6660ffff6660afff6660afff6660aaff666600aa66660222
-- 167:00066666fff06666ffff0666ffff0666ffff0666ffff0666ff00666688806666
-- 168:bbbbbb00bbbbb088bbbb0fddbbb02eefbbb02dedbbb02ddebbb02dfebbb0f8de
-- 169:000bbbbb8880bbbbddef0bbbdedd80bbeddd80bbfeeef0bbeddf80bb8edd80bb
-- 170:bbbbbb00bbbbb088bbbb08ddbbb02dddbbb0fefdbbb02deebbb02dddbbb018de
-- 171:000bbbbb8f80bbbbded80bbbedddf0bbedee80bbeefd80bbfddd80bbeedf80bb
-- 172:bbbbbb00bbbbb08fbbbb08febbb02dddbbb02dddbbb02ddebbb0feedbbb018df
-- 173:000bbbbb8880bbbbdddf0bbbefed80bbeded80bbfedd80bbeddef0bbeeed80bb
-- 174:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 175:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 176:666602226660228866602288666600886660ee446660e0706666037066666006
-- 177:8880666688880666882806668800666644ee06660b0e066607b0666660066666
-- 178:6660228866602288666600886660ee446660e000666600306666037066666006
-- 179:888806668828066688ee0666440e06660b00666607b066666006666666666666
-- 180:6660222266602288666600886660ee446660e030666607706666600666666666
-- 181:88880666882806668800666644ee06660b0e066607b066666006666666666666
-- 182:66602288666022886660ee886660e04466660030666607706666600666666666
-- 183:88880666882806668800666644ee0666000e06660b0066660bb0666660066666
-- 184:bbbb0eedbbbbb011bbbbbb00bbbbbb01bbbbb014bbbbb014bbbb0111bbbb0011
-- 185:2ed80bbb21f0bbbb000bbbbb9e0bbbbb49e0bbbb4990bbbb449e0bbb14440bbb
-- 186:bbbb0feebbbbb011bbbbbb00bbbbbb01bbbbb014bbbbb014bbbb0111bbbb0011
-- 187:2de80bbb21f0bbbb000bbbbb9e0bbbbb49e0bbbb4990bbbb449e0bbb14440bbb
-- 188:bbbb018ebbbbb0febbbbbb00bbbbbb01bbbbb014bbbbb014bbbb0111bbbb0011
-- 189:edd80bbb2210bbbb000bbbbb9e0bbbbb49e0bbbb4990bbbb449e0bbb14440bbb
-- 190:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 191:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 192:6666666666666600666660ff66660fff66660fff66660af066660aff6666600a
-- 193:6666666600066666fff06666ffff06660fff06660ff00666ffff066600f06666
-- 194:66666600666660ff66660fff66660fff66660af066660aff6666600a6666022a
-- 195:00066666fff06666ffff06660fff06660ff00666ffff066600f06666aff06666
-- 196:6666666666666600666660ff66660fff66660fff66660af066660aff6666600a
-- 197:6666666600066666fff06666ffff06660fff06660ff00666ffff066600f06666
-- 198:666666666666666666666600666660ff66660fff66660ff066660aff66660aff
-- 199:666666666666666600066666fff066660fff06660ff00666ffff0666ffff0666
-- 200:beebbbbbbb228bebb28deebbe2dfd2bbbeed82bbbb022ebbbbbbbbebbbbbbbbb
-- 201:bbbbeebbeb228bbbbe8fd8bbb2edeebbb02d82ebbb022bbbbbbeebbbbbbbbbbb
-- 202:bebbbbbbbbe28bbbb2eed8ebe2fdd2ebbe2e82bbbb02ebbbbbbebbbbbbbbbbbb
-- 203:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 204:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 205:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 206:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 207:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 208:6666028a6660288866608828666600886660ee446660e0706666003766666600
-- 209:aff0666688806666882066668206666644e066660be0666607b0666660066666
-- 210:66602882666088286660888e6666088e6666600e6666660b6666607766666600
-- 211:888066668820666682066666e40666660066666606666666b066666606666666
-- 212:6666028a6660288866608888666600886660ee446660e0706666003766666600
-- 213:aff0666688806666882066662206666644e066660be0666607b0666660066666
-- 214:6666600a6666082a66608882660e828860ee0028660700446603700066600666
-- 215:00f06666aff06666222006668882e0668882ee06440b00660007b06666600666
-- 216:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 217:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 218:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 219:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 220:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 221:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 222:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 223:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 224:6666666666666600666660ff66660fff66660fff66660af066660aaf6666600a
-- 225:6666666600066666fff06666ffff06660fff06660ff00666ffff0666a0a00606
-- 226:66666666666666666666600066660fff6660ffff6660fff06660af006660afff
-- 227:666666666666666600666666ff066666fff06666fff06666ff006666fff00606
-- 228:6666666666666666666666666666666666666666666666666666666666666666
-- 229:6666666666666666666666666666666666666666666666666666666666666666
-- 230:6666666666666666666666666666666666666666666666666666666666666666
-- 231:6666666666666666666666666666666666666666666666666666666666666666
-- 232:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 233:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 234:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 235:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 236:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 237:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 238:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 239:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 240:6666602866660288666608886666088266660444666070006607306666600666
-- 241:888880e0888880e02200060620666666406666660b06666607b0666660066666
-- 242:666022a0600888aa0ee0288260e0028866060444666070006607306666600666
-- 243:0f8880e0ff2280e02000060620666666406666660b06666607b0666660066666
-- 244:6666666666666666666666666666666666666666666666666666666666666666
-- 245:6666666666666666666666666666666666666666666666666666666666666666
-- 246:6666666666666666666666666666666666666666666666666666666666666666
-- 247:6666666666666666666666666666666666666666666666666666666666666666
-- 248:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 249:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 250:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 251:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 252:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 253:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 254:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 255:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- </TILES>

-- <SPRITES>
-- 032:5555555555555555555555555555555555555555555555555555555555555555
-- 033:555f5555555f5555555f5555555f555555555555555f55555555555555555555
-- 034:555f5f5555f5f555555555555555555555555555555555555555555555555555
-- 035:5555555555f5f5555fffff5555f5f5555fffff5555f5f5555555555555555555
-- 036:5555555555ffff555f5f555555fff555555f5f555ffff5555555555555555555
-- 037:5555555555f555555f5f5f5555f5f555555f5f5555f5f5f555555f5555555555
-- 038:55555555555f555555f5f55555ff55555f555f555f55f55555ff5f5555555555
-- 039:555f5555555f55555555f5555555555555555555555555555555555555555555
-- 040:5555f555555f5555555f5555555f5555555f5555555f5555555f55555555f555
-- 041:555f55555555f5555555f5555555f5555555f5555555f5555555f555555f5555
-- 042:555555555f555f5555f5f555555f555555f5f5555f555f555555555555555555
-- 043:55555555555f5555555f55555fffff55555f5555555f55555555555555555555
-- 044:5555555555555555555555555555555555555555555555555555f555555f5555
-- 045:5555555555555555555555555555555555ffff55555555555555555555555555
-- 046:555555555555555555555555555555555555555555555555555f555555555555
-- 047:5555555555555f555555f555555f555555f555555f5555555555555555555555
-- 048:55555555555ff55555f55f5555f5ff5555ff5f5555f55f55555ff55555555555
-- 049:55555555555f555555ff5555555f5555555f5555555f555555fff55555555555
-- 050:55555555555ff55555555f55555ff55555f5555555f55f55555ff55555555555
-- 051:5555555555fff55555555f55555ff55555555f5555f55f55555ff55555555555
-- 052:55555555555f5f5555f55f5555ffff5555555f5555555f5555555f5555555555
-- 053:5555555555ffff5555f5555555fff55555555f5555f55f55555ff55555555555
-- 054:55555555555ff55555f5555555fff55555f55f5555f55f55555ff55555555555
-- 055:5555555555fff5555555f555555ff5555555f5555555f5555555f55555555555
-- 056:55555555555ff55555f55f55555ff55555f55f5555f55f55555ff55555555555
-- 057:55555555555ff55555f55f5555f55f55555fff5555555f55555ff55555555555
-- 058:5555555555555555555555555555f555555555555555f5555555555555555555
-- 059:555555555555555555555555555555555555f555555555555555f555555f5555
-- 060:555555555555f555555f555555f55555555f55555555f5555555555555555555
-- 061:555555555555555555ffff555555555555ffff55555555555555555555555555
-- 062:55555555555f55555555f55555555f555555f555555f55555555555555555555
-- 063:55555555555ff55555f55f555555f555555f555555555555555f555555555555
-- 064:55555555555fff5555f555f55f55fff55f5f55f55f5f5ff555f5f5f555555555
-- 065:5fffff55f55f55f5f55f55f55f5ffff5555f55f5555f55f555ff55f555555555
-- 066:5fffff55f55f55f5f55f55f55f5fff55555f55f5555f55f555fffff555555555
-- 067:555fff5555f555f55f5555555f5555555f5555555ff555f555ffff5555555555
-- 068:5fffff55f55f55f5f55f55f55f5f55f5555f55f5555f55f555fffff555555555
-- 069:5ffffff5f55f5555f55f55555f5fff55555f5555555f555555fffff555555555
-- 070:5ffffff5f55f5555f55f55555f5fff55555f5555555f555555fff55555555555
-- 071:555fff5555f555f55f5555555f555ff55f5555f55ff555f555ffff5555555555
-- 072:5ff555f5f55f55f5f55f55f55f5ffff5555f55f5555f55f5555f55f555555555
-- 073:55ff55555f55f5555f55f55555f5f5555555f5555555f555555fff5555555555
-- 074:555ff55555f55f5555f55f55555f5f5555555f555f555f5555fff55555555555
-- 075:5ff555f5f55f55f5f55f55f55f5fff55555f55f5555f55f555ff55f555555555
-- 076:5ff55555f55f5555f55f55555f5f5555555f5555555f555555fffff555555555
-- 077:5fff5f55f5f5f5f5f5f5f5f555f5f5f555f5f5f555f5f5f555f5f5f555555555
-- 078:5fff5f55f55ff5f5f55f55f55f5f55f5555f55f5555f55f5555f55f555555555
-- 079:555fff5555f55ff55f5555f55f5555f55f5555f55ff55f5555fff55555555555
-- 080:5fffff55f55f55f5f55f55f55f5fff55555f5555555f555555fff55555555555
-- 081:55fff5555f55ff55f5555f55f5555f55f5555f55ff55f5f55fffff5555555555
-- 082:5fffff55f55f55f5f55f55f55f5fff55555f55f5555f55f555ff55f555555555
-- 083:55fff5555f555f5555f55555555fff55555555f55f5555f555ffff5555555555
-- 084:55fffff55f55f5555f55f55555f5f5555555f5555555f555555fff5555555555
-- 085:5f555f555f555f555f555f555f555f555f555f555f555f5555fff55555555555
-- 086:5ff555f5f55f55f5f55f55f55f5f55f5555f55f5555f5f55555ff55555555555
-- 087:5ff5f5f5f5f5f5f5f5f5f5f555f5f5f555f5f5f555f5f5f555ff5f5555555555
-- 088:55ff55f55f5f55f55f5f55f55555ff55555f55f5555f55f5555f55f555555555
-- 089:5ff555f5f5f555f5f55fff555555f5555555f5555555f5555555f55555555555
-- 090:5fffff5555555f555555f555555f555555f555555f555f555ffff55555555555
-- 091:555ff555555f5555555f5555555f5555555f5555555f5555555f5555555ff555
-- 092:555555555f55555555f55555555f55555555f55555555f555555555555555555
-- 093:555ff5555555f5555555f5555555f5555555f5555555f5555555f555555ff555
-- 094:555ff55555f55f555f5555f55555555555555555555555555555555555555555
-- 095:5555555555555555555555555555555555555555555555555555555555ffff55
-- 096:555f5555555f55555555f5555555555555555555555555555555555555555555
-- 097:5555555555555555555ff55555f55f5555f55f5555f5fff5555f5f5555555555
-- 098:555ff55555f5555555f5f55555ff5f5555f55f5555f55f5555fff55555555555
-- 099:5555555555555555555ff55555f55f5555f5555555f55f55555ff55555555555
-- 100:555ff55555555f55555f5f5555f5ff5555f55f5555f55f55555ff5f555555555
-- 101:5555555555555555555fff5555f55f5555fff55555f555f555ffff5555555555
-- 102:555ff55555f5555555ff555555f5555555f5555555f5555555f5555555555555
-- 103:5555555555555555555ff55555f55f5555f55f5555fffff555555f5555fff555
-- 104:555ff55555f5555555f5f55555ff5f5555f55f5555f55f5555f55f5555555555
-- 105:555f55555555555555ff5555555f5555555f5555555ff555555f555555555555
-- 106:5555f55555555555555ff5555555f5555555f55555f5ff55555ff55555555555
-- 107:55f5555555f55f5555f5f55555ff5f5555f55f5555f55f5555f55f5555555555
-- 108:55f5555555f5555555f5555555f5555555f5555555f55555555f555555555555
-- 109:55555555555555555ff5ff5555fff5f555f5f5f555f5f5f555f5f5ff55555555
-- 110:555555555555555555ff5f55555ff5f5555f55f5555f55f5555f55ff55555555
-- 111:5555555555555555555ff55555f55f5555f55f5555f55f55555ff55555555555
-- 112:555555555555555555ffff55555f55f5555f55f5555fff55555f5555555f5555
-- 113:5555555555555555555ff55555f55f5555f55f55555fff5555555f5555555f55
-- 114:555555555555555555ff5f55555ff5f5555f5555555f5555555f555555555555
-- 115:5555555555555555555ff55555f55555555ff55555555f5555fff55555555555
-- 116:55f5555555f555555fff555555f5555555f5555555f55555555f555555555555
-- 117:555555555555555555f55f5555f55f5555f55f5555f5fff5555f5f5555555555
-- 118:555555555555555555ff55f5555f55f5555f55f5555f5f55555ff55555555555
-- 119:555555555555555555ff5f5f555f5f5f555f5f5f555f5f5f555ff5f555555555
-- 120:555555555555555555f55f5555f55f55555ff55555f55f5555f55f5555555555
-- 121:555555555555555555f55f5555f55f5555f5ff55555f5ff555555f5555fff555
-- 122:555555555555555555fff5555555f555555f555555f55f5555fff55555555555
-- 123:5555f555555f5555555f555555f55555555f5555555f55555555f55555555555
-- 124:555f5555555f5555555f5555555f5555555f5555555f5555555f555555555555
-- 125:555f55555555f5555555f55555555f555555f5555555f555555f555555555555
-- 126:555555555555555555555555555f5f5555f5f555555555555555555555555555
-- 127:5555555555555555555555555555555555555555555555555555555555555555
-- 128:bbbbb000bbbb0666bbb06666bbb06666bbbee666bbeeee46bbeeea46bbbaa466
-- 129:000bbbbb6640bbbb66660bbb664640bb664664eb646664eb666664ab606040bb
-- 130:bbbbbbbbbbbbbbb0bbbbbb06bbbbb066bbbbb066bbbbbee6bbbbeeeebbbbeeea
-- 131:bbbbbbbb00000bbb666640bb666640bb6664640b6664640e4646640e4666640a
-- 132:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0bbbbbb06bbbbbb06bbbbbee6bbbbeeee
-- 133:bbbbbbbbbbbbbbbb00000bbb666640bb6666640b6666640b6664660b4664640e
-- 134:bb000000b06666640666666606666664666666646eee4646eeea4666baa46660
-- 135:bbbbbbbb0bbbbbbb0bbbbbbb600bbbbb6666bbbb64eebbbb64aabbbb604bbbbb
-- 136:bbbb0000bbb06666bb066666bb066666bbee6666beeee464beeea466bbaa4666
-- 137:0bbbbbbb40bbbbbb660bbbbb4640bbbb466eebbb664eebbb664aabbb6660bbbb
-- 138:bbbbbbb0bbbbbb06bbbbb066bbbbb066bbbbbee6bbbbeeeebbbbeeeabbbbbaa4
-- 139:0000bbbb66640bbb666660bb6664640b6664664e4646664e4660064a660000bb
-- 140:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 141:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 142:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 143:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 144:bbb06666bb066660bb066660bb066600b066666606666666b0666660bb000000
-- 145:00000bbb00000bbb006040bb606660bb6666660b6666660b4400600b000000bb
-- 146:bbbbbaa4bbbbb066bbbbb066bbb00646bb066440bb066666b0666666bb000000
-- 147:6606040b600000bb000000bb0006040b0606666066666660604444600000000b
-- 148:bbbbeeeabbbbbaa4bbbbb666bbbb0666bb006600b066660006666666b0000000
-- 149:4646640e6606040a600000bb000000bb0006060066666660666600600000000b
-- 150:b0666600b0666000b0666006b0660066b0666666b066666606666604b0000000
-- 151:000bbbbb000bbbbb6040bbbb66660bbb666660bb6666660b4006600b000000bb
-- 152:bb066666bb066600bb066000bb066600b0666644b066666606666604b0000000
-- 153:664bbbbb000bbbbb0640bbbb666600bb6666660b6666660b4006600b000000bb
-- 154:bbbbb066bbbb0666b0bb0666060066660666666606666666b0666660bb000000
-- 155:660000bb640000bb640000bb4660040b6664460b6666660b4400600b000000bb
-- 156:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 157:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 158:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 159:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 160:bbbbbbbbbbbbbbbbbbb00bbbbb0000bbbb0000bbbbb00bbbbbbbbbbbbbbbbbbb
-- 161:bbbbbbbbb000000008888888b0222222bb000000bbbbbbbbbbbbbbbbbbbbbbbb
-- 162:bfbbbb00befbb0aabbeff3aabbbef1aabbb01303bbb03306bbb0333abb00033a
-- 163:00bbbfbbaa0bfebbaaa0ebbbaaa0bbbb3330bbbb0060bbbb00a0bbbb00a0bbbb
-- 164:bbbbbbbbbfbbbb00befbb0aabbeff3aabbbef1aabbb01303bbb03306bb00033a
-- 165:bbbbbbbb00bbbfbbaa0bfebbaaa0ebbbaaa0bbbb3330bbbb0060bbbb00a0bbbb
-- 166:bfbbbb00befbb0aabbeff3aabbbef1aabbb01303bbb03306bb00033ab0333a0a
-- 167:00bbbfbbaa0bfebbaaa0ebbbaaa0bbbb3330bbbb0060bbbb00a0bbbb00a0bbbb
-- 168:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 169:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 170:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 171:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 172:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 173:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 174:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 175:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 178:b0333a00b0333a0a033333a0033333a0033333a0b0333a11b0333a10bb000300
-- 179:0000b0bb00a00a0baa03a30b3303330b3300030b1030b0bb010bbbbb0030bbbb
-- 180:b0333a3ab0333a03033333a3033333a0033333a0b0333a11b0333a10bb000030
-- 181:00a0bb0b003000a0aa303a3033303330330000301030bb0b010bbbbb030bbbbb
-- 182:b0333a00033333aa033333a3033333a0b0333a00b0333a11bb000010bbbbbb03
-- 183:000bbb0b00a000a0aa303a3033303330330000301030bb0b10bbbbbb0bbbbbbb
-- 184:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 185:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 186:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 187:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 188:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 189:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 190:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 191:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 194:bfbbbb00bffbb0aabbfffaaabbbee3aabbbb0333bbbb0060bbb00aa0bb0a33a0
-- 195:00bbbbfbaa0bbfebaaaffebbaa3eebbb3330bbbb0600bbbb0a30bbbb033000bb
-- 196:bbbbbbbbbfbbbb00bffbb0aabbfffaaabbbee3aabbbb0333bbbb0060bbb00aa0
-- 197:bbbbbbbb00bbbbfbaa0bbfebaaaffebbaa3eebbb3330bbbb0600bbbb0a3000bb
-- 198:bfbbbb00bffbb0aabbfffaaabbbee3aabbbb0333bbbb0060bbbb0aa0bbb003a0
-- 199:00bbbbfbaa0bbfebaaaffebbaa3eebbb3330bbbb0600bbbb0a3000bb03a3330b
-- 200:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 201:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 202:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 203:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 204:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 205:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 206:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 207:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 210:b0a33000bb0000a0b0a3003ab03300330a333003b0000001bbbbb010bbbbb030
-- 211:00a3330b00a3330baa3333303a3333303a33333011a3330b00a3330b000000bb
-- 212:bb0a33a0b0a330a0bb00003ab0a30033b03300030a333001b0000010bbbbb030
-- 213:03a3330b00a3330baa3333303a3333303a33333011a3330b00a3330b003000bb
-- 214:bb0a3000b0a330a0bb00003ab0a30033b03300030a333001b0000030bbbbb000
-- 215:00a3330b0a333330aa3333303a33333033a3330b11a3330b001000bb0030bbbb
-- 216:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 217:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 218:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 219:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 220:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 221:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 222:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 223:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 224:0123456789abfdef000000000000000000000000000000000000000000000000
-- 226:bbfbbbb0bbefbb0abbbeff3abbbbee3abbbbb0aabbbbb0aabbbbb03abbbaa003
-- 227:000bbbbfaaa0bbffaaa3fffbaaa3eebbaa330bbbaa330bbba3330bbb333000bb
-- 228:bbbbbbbbbbfbbbb0bbefbb0abbbeff3abbbbee3abbbbb0aabbbaa0aabba33033
-- 229:bbbbbbbb000bbbbfaaa0bbffaaa3fffbaaa3eebbaa330bbba3330bbb333300bb
-- 230:bbfbbbb0bbefbb0abbbeff3abbbbee3abbbbb0aabbbbb0aabbbaa03abba33003
-- 231:000bbbbfaaa0bbffaaa3fffbaaa3eebbaa330bbbaa330bbba3330bbb33300bbb
-- 232:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 233:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 234:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 235:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 236:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 237:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 238:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 239:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 240:666600666660ff066660fff0600ffff00ffff0060fff066660ff066666006666
-- 241:00000ff000000fff0000ffff00000f0000f00000ffff0000fff000000ff00000
-- 242:bba33000bb030000ba330a0ab030a30ab030a00abb030001bb033303bbb00000
-- 243:00003a0ba30033a03330000b333003a0333003303310000b0010bbbb0030bbbb
-- 244:bb030003ba330a00b030a30ab030a00abb03000abb033301bbb00001bbbbbb03
-- 245:33303a0ba30033a03330000b333003a0333003303310000b0010bbbb0030bbbb
-- 246:bb030000ba330a00b030a30ab030a00abb03000abb033301bbb00001bbbbbb03
-- 247:000000bba3003a0b333033a03330000b333003a0331003300030000b0000bbbb
-- 248:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 249:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 250:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 251:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 252:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 253:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 254:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 255:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- </SPRITES>

-- <MAP>
-- 000:101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110
-- 001:112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011
-- 002:112112131313131313131313131313131313131313131313131313122111112112131313131313131313131313131313131313131313131313122111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 003:112113a30000000000000014140000000000002200000000920000132111112113050000000000000000920000000092000003000000000307132111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 004:112113030000001400000500000000920000000000140000000300132111112113000000002200000000000000000000000000000000000000132111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 005:112113000000920000000000000000000000000000003161000000132111112113000031610000000023333333333333430000000031610000132111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 006:112113000000000000003141514151415141516170003262000000132111112113000071720000000064737373737373630014000071720000132111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 007:112113000000002200003294949494949494949461000000000022000000000000050071720000000064738473737473630000000071720000132111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002111
-- 008:112113000000000000000032424252949494949462000022000000000000000000000071720000140064737373737373630000000071720000132111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002111
-- 009:112113920000000000070000000000719494946200000000000000132111112113000071720000000064737373837373630000000071720000132111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 010:112113002343000000000000000000324252620086960000b31400132111112113000071720000000064737373737373630000000071720000132111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 011:112113142444000365750000000000000000000000000000000000132111112113000032620000000024343434343434440000220032620000132111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 012:1121333343000000667600001400000007000014000093002500001321111121130000000300000000000000000000000000000000a5b50000132111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 013:1121747363009200000000000000000000002200000000000000001321111121130000000000000000009200000000920000000000a6b60007132111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 014:112173846313131313131313131300001313131313131313131313122111112112131313131313131313131300001313131313131313131313122111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 015:112021212121212121212121212100002121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011
-- 016:101111111111111111111111111100001111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110
-- 017:101111111111111111111111111100001111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110
-- 018:112021212121212121212121212100002121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011
-- 019:112113131313131313131313131300001313131313131313131313132111112112131313131313131313131313131313131313131313131313122111112122000014000093000000000000001400000000930000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 020:112113000092000000000000000014000000220000000000000093132111112113140000000000001400000000000000000000000000000000132111112100000000000000000000140000220000000022000000140000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 021:112113000000000000000022000000000000000000000000000000132111112113009300000045550000930092920000930000000022000000132111112100002333333333333333333333333333333333333333334300002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 022:112151415141514151415141514151415141514151415161000000132111112113000000000046564555000000000000000000000000000000132111112193005373737373737373737373737373737373737373736300142111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 023:112194949494949494949494949494949494949494949472000000132111112113000000140000004656001400000000000000000014000000132111112100006473738484837384737473848373738473737373735493002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 024:112152425242524252425242524252425242524252425262000022132111112113009200000000704555000000000000000000000000000000000000000000005373747373737383737384737373847373737373746300002111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002111
-- 025:11211300000000000000000000000022000000000000b300000000132111112113009200000045554656000000002200140000000000000000000000000000006473737374737373737373747373737383737384735400222111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002111
-- 026:112113002200000014000000000000000000000000000000000000132111112113220000000046560000000000000000000000000000000000132111112123337373737373737374847373738473737384737384736300002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 027:112113000031514151415141514151415141514151415141514151412111112113000000000000000000001400000000000000002200000000132111112153737383737373737373847373738373747373737373735414002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 028:112113a30071949494949494949494949494949494949494949494942111112113000000001400000000000000000000000000000000000000132111112164737384738384737473737373737373737373737373736300002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 029:112113000032524252425242524252425242524252425242524252422111112113009300000000000093000092920000930000000000001400132111112153738474737373747373733434343434343434343434344400002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 030:112113000000000093000000000022000000000000000092000000132111112113000000002200000000000000000000000000000000000000132111112164737373737373737373735400000014002200000000930000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 031:112113131313131313131313131300001313131313131313131313132111112112131313131313131313131313131313131313131313131313122111112124343434343434343434344400000000000000140000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 032:112021212121212121212121212100002121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011
-- 033:101111111111111111111111111100001111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110
-- 034:101111111111111111111111111100001111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110
-- 035:112021212121212121212121212100002121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011
-- 036:112113131313131313131313131300001313131313131313131313132111112131514161002200000000316100009300000031610014000000002111112100000000000000000000000000220000000000001400009300002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 037:1121130093000000000014000000002200006575000000000000001321111121719494720000000000007172000000000014717200000000a3002111112145554555455545554555455500000000000000000000220000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 038:11211300000000000000000000000000000066760000920000140013211111217194947200003161a300717200003161000071720000316100002111112146564656465646564656465600001400000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 039:112113006575a5b56575a5b56575a5b56575a5b500000092000000132111112171949472930071720000717222007172140071720000717200002111112145554555455545554555455545554555455545554555455500002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 040:112113006676a6b66676a6b66676a6b66676a6b600000092000000132111112132524262000071720014717200007172000032620000717200222111112146564656465646564656465646564656465646564656465600002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 041:11211314a5b56575a5b56575a5b56575a5b5657500140022920000000000000000142200000071720000717200007172000000930000717200000000000000000014000000220000000000000014009300000093000022002111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002111
-- 042:11211300a6b66676a6b66676a6b66676a6b6667600000000000000000000000000000000000071720022717200007172000022000000717200000000000000000000000000000000001400000000000000000000000000002111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002111
-- 043:112113006575a5b56575a5b56575a5b56575a5b500000000000000132111112131415141514194720000717200147172000031610000717200222111112145554555455545554555455545554555455545554555455500002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 044:112113006676a6b66676a6b66676a6b66676a6b600140000000000132111112132524252425242622200717200007172000071721400717200002111112146564656465646564656465646564656465646564656465600222111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 045:11211300a5b56575a5b56575a5b56575a5b5657500000000140000132111112100000000930000000000717200007172000071720000717200002111112145554555455545554555455545554555455545554555455500002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 046:11211300a6b66676a6b66676a6b66676a6b6667600930000000000132111112100220000000000000000326200007172002271720000326200142111112146564656465646564656465646564656465646564656465614002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 047:112113930000000000140000000000002200000000000000000000132111112131415141514151610000000093007172000071720000220000002111112145554555455545554555455500000014000000002200009300002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 048:112113131313131313131313131313131313131313131313131313132111112132524252425242620000000000003262000032620000000000002111112146564656465646564656465622000000000014000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 049:112021212121212121212121212121212121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011
-- 050:101111111111111111111111111111111111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110
-- 051:101111111111111111111111111111111111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110
-- 052:112021212121212121212121212121212121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011
-- 053:112194425242524252425242524252425242524252429494949494942111112113131313131313131313131300001313131313131313131313132111112100000000001400000071720000000071720000000022000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 054:11217200009300000000000000140000000000930000329494949494211111211300000000002200000000000000220000000000000000000013211111210000000000b3000000717200000000717200000000b3000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 055:112172000000000000001400000000002200000000000032949494942111112113000025000000000000001400000000000000000014002200132111112100002200000000000032620000000032620000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 056:112194510022000041514151415141514151415161000000329494942111112113000000000000000000000000000000000000000000000000132111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 057:112194944100000032949494949494949494949494610014003252422111112113000000000000002200002200000000000022000000000000132111112100000000000000220000001400000000001400002200000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 058:112194949451000000329494949494949494949494946100000000000000c5d500220000000000000093000000000000000000000093000000132111112100000000000000000000000000000000000000000000000000002111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002111
-- 059:112194949494410000003252425242524252425242949461220000000000c6d600000000000000000000000000000014000000000000000000132111112100220000000000000000000000220000000000000000000000002111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002111
-- 060:112194949494945100000000140000009300000000329494415141512111112113000000000014000000000070000000000000001400000000132111112100000000220000000000314151415141610000000000000000222111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 061:112194949494949441000000001400000000000000003294949494942111112113000000000000000000000000000000000000000000000000132111112100001400000000000000325242524252620000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 062:112194949494949494514151415141514151410000000071949494942111112113000022000000070000000000001400000700000000001400132111112100000000000000000000a300000000a3000000001400000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 063:112194949494949494949494947293000014002200005194949494942111112113000000000000000000000000000000000000220000000000132111112100000000002200000000000000700000000000140000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 064:112194949494949494949494947200000000000000419494949494942111112113000000000000000000140000000000000000000000000000132111112114000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 065:112194949494949494949494947200005141514151949494949494942111112113131313131313131313131313131313131313131313131313132111112100000000000000000000315141514151610000000022000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 066:1120212121212121212121212121c5d52121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011
-- 067:1011111111111111111111111111c6d61111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110
-- 068:101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110
-- 069:112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011
-- 070:112100000000000000000000000000140022000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 071:112122000000001400000000000000000000000000000000000000142111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 072:11210000a3220000000000000000316100b3000000002200000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 073:112100000000000000000022000071720000000000220000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 074:11210000000000000000000000007172000000000000000000b300002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 075:112100000000000000000000000071720000000014000000000000002111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002111
-- 076:112100000000000000000000000071720000000000000000000000002111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002111
-- 077:112100000000220000001400000071720000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 078:112100000000000000000000000071720000000000220000000000222111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 079:112100220000000000000000000071720000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 080:112100000000000000000000a300326200b3002200000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 081:112100000000000000000000000000000000000000000014000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 082:112100000000140000000022000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 083:1120212121212121212121212121c5d52121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011
-- 084:1011111111111111111111111111c6d61111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110
-- 085:101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110
-- 086:112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011
-- 087:11212200000000001400220000000000a5b5a5b5a5b5a5b5a5b5a5b52111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 088:11210000140000000000000000001400a6b6a6b6a6b6a6b6a6b6a6b62111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 089:112100008686968696869686968696869686968696869686968696862111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 090:112100008696869300868696930086968693008686969322869693002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 091:112100148686960000869686000086869600228696860000868600002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 092:112100000000000014000000000000000000000000000000000000002111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002111
-- 093:112100000000220000000000000000000000001400000000001400002111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002111
-- 094:112165756575657586000086968600008696860000869686968600002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 095:112166766676667686930086869693008686969300868696869600002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 096:112165756575657586000086968600008696860000869686968600002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 097:112166766676667686968696869686968696869686968696869600222111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 098:112165756575657586869686968622000000000000001400000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 099:112166766676667686968696869600001400000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 100:112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011
-- 101:101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110
-- 102:101111111111111111111111111100001111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110
-- 103:112021212121212121212121212100002121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011
-- 104:112100000014000000000000000000140000000000000000009300002111112100000000000000000000000000002200000000000022000000002111112127277293007127272727272727272727425227272727272727272111112100000000a3000000000000000000000000000000a300000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 105:11210000000000000000220000000000000000000000001400000000211111210014000000a3000000a3140000a3000000a3000000a30000000021111121272772000071272727272727272727729300712742522727272721111121000000000000000000a3000000000000a30000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 106:1121a3006575657565756575657565756575657565756575657565752111112100000000000000000000000000000000000000000000000000002111112127272751412727272727945242522772000071729300712727272111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 107:112100006676667666766676667666766676667666766676667666762111112100000000000000002200000000001400000000000000140093002111112127272727272727272794620000003227514127720000712727272111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 108:112100008696000000000000000000930000002200000000009300322111112100002200000000000000000000000000000000b30000002200002111112142424242424242424262000000000071272727275141272727272111112100000045550000000000000000000000000000000045550000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 109:11210000869614000000000000220000000000000000140000000000000000000000000000000000000000000022000000000000000000009300000000000000000000001400000000cfcf000071272727272727272727272111112100000046565500000000000000000000000000004546560000002111112100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002111
-- 110:1121002286960000a5b5a5b5a5b5a5b5a5b5a5b5a5b5a5b5a5b50000000000000000000000001414000000000000000014000000000000000000000000000000140000000000000000cfcf000071272727272727425227272111112100000045465655000000000000000000000000454656550000002111112100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002111
-- 111:1121000086960000a6b6a6b6a6b6a6b6a6b6a6b6a6b6a6b6a6b641412111112100000000220000000000002200000000000000000000000093002111112151415141514151415100000000000071272727272772930071272111112100000046564656550000000000000000000045465646560000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 112:112193008696930000000000000000000000000022000000003294942111112100000000000000000000000000220000000000b30000000000002111112127272727272727272761000000003127272727272772000071272111112100000046560046565500000000000000004546560046560000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 113:112100008696000000000000001400000000000000000000000071942111112100001400000000220000000000000000000000000022000000002111112127272742522727272727514151412727274252272727514127272111112100000046560000465655000000000000454656000046560000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 114:112100228696869686968696869686968696869686968696000071942111112100000000000000000000001400000000000000000000000000002111112127277293007127272727425227272727729300712727272727272111112100000046560000004656550000000045465600000046560000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 115:112100000014000000000000000000930000000000000000220071942111112100000000000000140000000000220000000000000000000014002111112127277200007127272772930071272727720000712727272727272111112100000046560000000046565500004546560000000046560000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 116:112100000000000000001400000000000000220000000000003194942111112100002200000000000000000000000000000000000000000000002111112127272751412727272772000071272727275141272727272727272111112170000046560000000000465600004656000000000046560000702111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 117:112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011
-- 118:101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110
-- 119:101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110101111111111111111111111111100001111111111111111111111111110
-- 120:112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011112021212121212121212121212100002121212121212121212121212011
-- 121:112100000000000000455500000045550000004555000000000000002111112100000000000000000000000000000000000000000000000000002111112172220000719472000071949472007194949494727194949471942111112194949494949494949494720000000000000000000000000093002111112100000000000000000053738393000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 122:112100000000000000464555000045550000455556000000000000002111112100000000004555455545554555455531610000000000000000002111112172000000719472140071949472007194949494727194949471942111112194949494949494949494946100000000000000000000000000002111112100000000000000000064737383000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 123:112100000000000000004645554555455545554555455545554555452111112100000000004645554555455545554571720000000000000000002111112172002200719472000071949472037194949494727194949471942111112194949494949494949494949451415141514151415141516100002111112100000000000000000053737373839300930000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 124:112100000000000000000045554656465646564656465646564656462111112100000000000046455545554555455571720000000000000000002111112172000000719472000071949472007194949494727194949471942111112194949494949494949494949494949494949494949494947200002111112100000000000000000064737373738300000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 125:112100000000000000000045550000000000000000000000000000002111112100000000000000465646564656465671720000000000000000002111112142524252425242524252424242424242425242424252424242522111112142524252425242524252425242524252425242524252426200002111112100000000000000000046564656465646560000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 126:112145554555455545554545550000000000000000000000000000000000000000000000000000b3000000000070007172000000000000000000820000000000000000000000000000930000220000009300000000229300000000000000a30000000000a30000000000a300000000a30000000000000000000000000000000000000000b30000000000000000000000000000b30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002111
-- 127:112146564656465646564645550000000000000000000000000000000000000000000000000000000000000000000071720000000000000000000000000000220000000000000022000000000000000022000022000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002111
-- 128:112100000000000000000045554555455545554555455545554555452111112100000000000000455545554555455571720000000000000000002111112151415141514151415141514151415141514151415141514151412111112100000000000000000000000000000000000000000000000000002111112100000000000000000045554555455545550000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 129:112100000000000000004555564645555646455556465646564656462111112100000000000045465646564656465671720000000000000000002111112172002200719472000071949472007194949494727194949471942111112100000000000000000000000000000000000000000000000000002111112100000000000000000053737373737383000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 130:112100000000000000455556000045550000464555000000000000002111112100000000004546564656465646564671720000000000000000002111112172000000719472001471949472007194949494727194949471942111112100000000000000000000000000000000000000000000000000002111112100000000000000000064737373738393000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 131:11210000000000004555560000004555000000464555000000000000211111210000000000465646564656465646563262000000000000000000211111217200220071947200007194947203719494949472719494947194211111210000000000a300000000a3000093000000a300000000a30000002111112100000000000000000053737373830000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 132:112100000000004555560000000045550000000046455500000000002111112100000000000000000000000000000000000000000000000000002111112172220000719472140071949472007194949494727194949471942111112100000000000000000000000000000000000000000000000093002111112100000000000000000064737383930000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 133:112100000000004656000000000046560000000000465600000000002111112100000000000000000000000000000000000000000000000000002111112172000000719472000071949472007194949494727194949471942111112100000000000000000000000000000000000000000000000000002111112100000000000000000064738300000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111112100000000000000000000000000000000000000000000000000002111
-- 134:112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011112021212121212121212121212121212121212121212121212121212011
-- 135:101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110101111111111111111111111111111111111111111111111111111111110
-- </MAP>

-- <WAVES>
-- 000:00ffffffffffffff00ffffffffffffff
-- 001:ffff000000000000ffff000000000000
-- 002:ffffffff00000000ffffffff00000000
-- 003:0123456789abcdeffedcba9876543210
-- 004:01234567898653effedcba9876543210
-- 006:8899acdeeffeedca8653211001123567
-- 007:aaaabcdeeffeedca8653211001123455
-- 008:cccccddeeffeedca8653211001122333
-- 009:ffffffffffffffff0000000000000000
-- 010:753226686544333334456789aabbbaa9
-- 011:753226ac6544334334456789aabbbaa9
-- 012:753203dfe544335434456789aabbbaa9
-- 013:01236547898653effedcba9875783210
-- 014:bacbe755caa9c645dccac52286658212
-- 015:1134567899bcdeffcca9887665432100
-- </WAVES>

-- <SFX>
-- 000:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000ff
-- 001:010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100307000000000
-- 002:020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200204000000000
-- 003:0300530073008300a30073009300b3008300c3009300c300d300a300d300b300d300d300b300d300d300c300d300d300d300c300c300b300b300a300664000000000
-- 004:04000400040004000400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400500000000000
-- 005:050015003500550075009500a500c500c500d500e500e500e500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500000000000000
-- 006:05006500b500d500e500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500000000000000
-- 007:050015001500250025003500450045005500550065006500750075008500850095009500a500a500b500b500c500c500d500d500e500e500f500f500003000000000
-- 008:0d009db00d309d000d709d300db09d700d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d00364000080800
-- 009:010001010102010301030103010201010100010f010e010d010d010e010f010001010102010301030103010201010100010f010e010d010d010d010e30500000000f
-- 010:020002010202020302030203020202010200020f020e020d020d020e020f020002010202020302030203020202010200020f020e020d020d020d020e30500000000f
-- 011:0a100b100c100c100c100b100b100b100a000b000c000c000c000b000b000b000a000a000a000a000a000a000a000a000a000a000a000a000a000a00572000000001
-- 012:0a000b000c000c000c000b000b000b000a200b200c200c200c200b200b200b200a200a200a200a200a200a200a200a200a200a200a200a200a200a20570000000000
-- 013:350045004500550055006500750075008500850095009500a500a500b500b50005001500150025002500350045004500550055006500650075007500000000000000
-- 014:0802070e95f0a5f0b5f0c5f0c5f0d5f0d5f0d5f0e5f0e5f0e5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0b05000000000
-- 015:05f805f808d008ff08ff07fe07fe06fd06fc06fc06fb06fb06fb06fa06fa06fa06f906f906f8f6f8f6f8f6f8f6f8f6f8f6f8f6f8f6f8f6f8f6f8f6f8cb7000000000
-- 016:0dc09d300db09dc00d709db00d309d700d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d00364000080800
-- 017:010001000100012001200120010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100307000000600
-- 018:010001000100013001300130010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100307000000600
-- 019:010001000100014001400140010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100307000000600
-- 020:010001000100015001500150010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100307000000600
-- 021:04000400040004000450045004500450047004700470047004c004c004c004c004000400040004000400040004000400040004000400040004000400252000000000
-- 022:04000400040004000440044004400440049004900490049004c004c004c004c004000400040004000400040004000400040004000400040004000400152000000000
-- 023:0400040004000400040044009400f4000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400272000080000
-- 024:045004500450045004000400040004000450045004500450048004800480048004000400040004000400040004000400040004000400040004000400252000000000
-- 025:4508750812f132ff95f0b5f7c5f7d5f7d5f7e5f7e5f7f5f7450865081200120fb20ec50d05fd25fd02f175f7a5f7b5f7c5f7d5f7e5f7f508f508f508902000000000
-- 026:65087508850885089508a50802f122ff650775079507c50702200200750895089508c50802000220a210b210c200d200f200f200f500f500f500f500900000000000
-- 027:2508450822f142ff95f7b5f7c5f7d5f7d5f7e5f7e5f7f5f775089508a508c508d508d508d508e508e508e508e508e508f508f508f508f508f508f508900000000000
-- 028:01000100010001300130013041006100710081009100a10001000100010001000100010041006100710081009100a100a100a100a100a100a100a100305000000600
-- 029:01000100010001400140014041006100710081009100a10001000100010001000100010041006100710081009100a100a100a100a100a100a100a100300000000600
-- 030:01000100010001500150015041006100710081009100a10001000100010001000100010041006100710081009100a100a100a100a100a100a100a100300000000600
-- 031:040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400300000000000
-- 032:0a0f0b000c000c000c000c000c000c000c000c000b000b000b000b000b000b000b000b000a000a000a000a000a000a000a000a000a000a000a000a00502000000001
-- 033:0a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a00407000000000
-- 034:0a000a030a050a070a070a070a050a030a0e0a0c0a090a090a090a0b0a0d0a000a010a020a000a000a000a000a000a000a000a000a000a000a000a0040200000000f
-- 035:060006000600060006000600060006000600060006000600060006000600060006000600060006000600060006000600060006000600060006000600402000000000
-- 036:060006020604060506050605060406020600060e060c060b060b060c060e06000601060206000600060006000600060006000600060006000600060040100000000f
-- 037:06000630067006b006000630067006b006b0060006000600060006000600060006000600060006000600060006000600060006000600060006000600403000000800
-- 038:060006000630067006700600063006300670060006000600060006000600060006000600060006000600060006000600060006000600060006000600403000000900
-- 039:060006000640067006700600064006400670060006000600060006000600060006000600060006000600060006000600060006000600060006000600406000000900
-- 040:060006000640069006900600064006400690060006000600060006000600060006000600060006000600060006000600060006000600060006000600400000000900
-- 041:060006000650068006800600065006500680060006000600060006000600060006000600060006000600060006000600060006000600060006000600400000000900
-- 042:06000600064006b006b006000640064006b0060006000600060006000600060006000600060006000600060006000600060006000600060006000600404000000900
-- 043:95d0c5d0d5d0e5d05c009b005c209b205c005b005b005b005b005b005b005b005b005b005b005b005b005b005b005b005b005b005b005b005b005b005d2000000000
-- 044:95f0c5f0d5f0e5f05c009b005c009b005c005b005b005b005b005b005b005b005b005b005b005b005b005b005b005b005b005b005b005b005b005b005d4000000000
-- 047:0100010001100110010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001003c5000000400
-- 048:e000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000110000
-- 049:0e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e00300000000001
-- 050:320042005200520062007200720082009200a200b200b200327042705270527062707270727082709270a270b270b270f200f200f200f200f200f200270000000000
-- 051:42b052705240620062007200720072008200820082008200920092009200a200a200b200b200b200c200c200c200d200d200d200e200e200e200f200370000000400
-- 052:f200f200f200f200f200f200f200f200f200f200f200f200327042705270527062707270727082709270a270b270b270f200f200f200f200f200f200270000000000
-- 053:85004541259265f485bdb578f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500c07000000000
-- 054:069066c136f245a3c5447504f5a5f5d6f5e6f5e7f5f7f5f7f5f7f5f7f5f7f5f7f5f7f5f7f5f7f5f7f5f7f5f7f5f7f5f7f5f7f5f7f5f7f5f7f5f7f5f7a07000000000
-- 055:b580a550955095b085307570753075a0754075a0758075e085a085d095a09520a530a530b560c590c5a0d590e560f590f570f550f5b0f520f570f57000500000ff00
-- 056:0f010fa20ff3ff05ff09ff06ff06ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00c05000000000
-- 057:a5209560858075a065b065b055b045b045a045a05590758085709560a540b530d520f520f510f500f500f500f500f500f500f500f500f500f500f500334000000000
-- 058:3500c50055d0d5d0f5d0f5d0f5d0f5d0f5d0f5d0f5d0f5d0f5d0f5d0f5d0f5d0f5d0f5d0f5d0f5d0f5d0f5d0f5d0f5d0f5d0f5d0f5d0f5d0f5d0f5d0300000000000
-- 059:42809280427092704240924042009200421092104250925042a092a042f092f0b2f0c2f0d2f0e2f0f2f0f2f0f2f0f2f0f2f0f2f0f2f0f2f0f2f0f2f0542000000000
-- 060:01000130156015501550255025003500350045004500650065007500750085008500850095009500a500a500a500b500c500c500d500e500e500f500909000000400
-- 061:72008200a200c200d200d200d200d2009250a250b250c250d250d250e250e250e250e25062a072a082a092a0a2a0b2a0c2a0d2a0e2a0e2a0e2a0f2a0e25000000000
-- 062:41006160a5b0d5f0f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500c80000000000
-- 063:050085f7f587ff80ff80ff80ff80ff80ff80ff80ff80ff80ff80ff80ff80ff80ff80ff80ff80ff80ff80ff80ff80ff80ff80ff80ff80ff80ff80ff80a04000000f00
-- </SFX>

-- <PATTERNS>
-- 000:966126866126966126e66124966126866126966126e66124466126566126466126e66124d66124e66124466126566126966126866126966126e66126466128e66126d66126e66126d66126a66126d66126a66126966126766126966126a66126966126866126966126e66124966126866126966126e66124466126566126466126e66124d66124e66124466126566126966126866126966126e66126466128e66126d66126e66126d66126a66126d66126a66126966126766126966126a66126
-- 001:0000009221a68221a69221a6e221a49221a68221a69221a6e221a44221a65221a64221a6e221a4d221a4e221a44221a65221a69221a68221a69221a6e221a64221a8e221a6d221a6e221a6d221a6a221a6d221a6a221a69221a67221a69221a6555116455116555116955114555116455116555116955114d55114e55114d55114955114855114955114d55114e55114555116455116555116955116d55116955116955116955116955116555116855116555116555116455116555116555116
-- 002:cff1f8000000f4417e0000009ff1e6000000f4417ecff1f8000000cff1f8f4417e0000009ff1e6000000f4417e000000cff1f8000000f4417e0000009ff1e6000000f4417ecff1f8000000cff1f8f4417e0000009ff1e6000000cff1f8000000cff1f8000000f4417e0000009ff1e6000000f4417ecff1f8000000cff1f8f4417e0000009ff1e6000000f4417e000000cff1f8000000f4417e0000009ff1e6000000f4417ecff1f8000000cff1f8f4417e0000009ff1e6000000cff1f8000000
-- 003:eaa1f3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaa1f50000000000000000000000000000000000000000007aa1f5000000000000000000000000000000000000000000eaa1f34aa1f55aa1f54aa1f5eaa1f39aa1f5aaa1f59aa1f5eaa1f34aa1f55aa1f54aa1f5eaa1f39aa1f5aaa1f59aa1f5aaa1f5eaa1f54aa1f75aa1f74aa1f7eaa1f5aaa1f59aa1f57aa1f5eaa1f54aa1f75aa1f74aa1f77aa1f75aa1f7eaa1f5
-- 004:5559f40000000000000000000000000000000000000000009559f4000000000000000000000000000000000000000000e559f40000000000000000000000000000000000000000005559f60000000000000000000000000000000000000000005559f40000000000000000000000000000000000000000009559f4000000000000000000000000000000000000000000e559f40000000000000000000000000000000000000000005559f6000000000000000000000000000000000000000000
-- 005:000000eaa9064aa9085aa9080000005aa9285559280000000000005aa9087aa9088aa9089aa908000000aaa9080000009aa9080000009aa928955928eaa906000000eaa926e559260000005aa9084aa908eaa906daa906eaa906daa906aaa9069aa9069559064aa9084559085aa908555908daa906d55906eaa906e55906aaa908a559089aa9089559088aa9088559089aa9080000009aa9280000000000009559280000000000007aa9085aa9084aa9085aa9084aa908eaa906daa906eaa906
-- 006:466919000000000000000000d66917000000000000000000c66917000000000000000000466919000000000000000000b66917000000000000000000766917000000000000000000e66917000000000000000000466919000000000000000000466919000000000000000000d66917000000000000000000c66917000000000000000000466919000000000000000000e66917000000000000000000766917000000000000000000e66917000000000000000000466919000000000000000000
-- 007:766919000000000000000000466919000000000000000000000000000000000000000000b66917000000000000000000e66917000000000000000000c669170000000000000000006669190000000000000000007669190000000000000000007bb9060000006bb9064bb906dbb904000000ebb9044bb906cbb906000000bbb9069bb9067bb9060000006bb9064bb9069bb906bbb906dbb9064bb9086bb1b86bb1b84bb1c87bb1c86bb9080000007bb9086bb9084bb908bbb9089bb9084bb90a
-- 008:b66919000000000000000000966919000000000000000000000000000000000000000000766919000000000000000000766919000000000000000000466919000000000000000000966919000000000000000000b66919000000000000000000b66919000000000000000000966919000000000000000000000000000000000000000000766919000000000000000000000000000000000000000000466919000000000000000000966919000000000000000000b66919000000000000000000
-- 009:4aa1f50000000000000000009aa1f50000000000000000000000000000000000000000004aa1f50000000000000000007aa1f5000000000000000000caa1f5000000000000000000eaa1f30000000000000000004aa1f50000000000000000004aa1750000000000000000009aa1750000000000000000000000000000000000000000004aa1750000000000000000007aa175000000000000000000caa175000000000000000000eaa1730000000000000000004aa1750000009771d49bb1d4
-- 010:7bb1f50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007661f50000000000000000007bb1f50000009bb1f5000000abb1f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a661f5000000000000000000abb1f50000009bb1f5000000
-- 011:7aa9680000000000000000000000000000007559680000000000000000000000000000007aa9580000007559580000007aa9680000000000000000000000000000007559680000000000000000000000000000007aa958000000755958000000daa988000000000000000000000000000000d55988000000000000000000000000000000daa9a8000000d559a8000000daa988000000000000000000000000000000d55988000000000000000000000000000000daa998000000d55998000000
-- 012:7ff9ca00000000000072290a6ff9ca00000000000062290a4ff9ca00000000000042290a4ff9ba000000444127444117444127000000000000000000e44135000000000000000000444145000000000000000000744135000000000000000000b6692c00000000000000000096691a00000000000000000000000000000000000000000076692c000000000000000000e6692a00000000000000000076692c000000000000000000e6691a00000000000000000046692c000000000000000000
-- 013:4ff9ca00000000000042290aeff9c8000000000000e22908cff9c8000000000000c229087ff9ca000000b44145000000b44145000000000000000000944145000000000000000000c44135000000000000000000b4414500000000000000000076691c000000000000000000d6691a000000000000000000c6692a00000000000000000046691c00000000000000000076691c00000000000000000046692c00000000000000000066692c00000000000000000076692c000000000000000000
-- 014:bff9ba000000000000b2290abff9ba000000000000b2290a9ff9ba00000000000092290abff9ca000000000000b2290abff9ba000000b4491ab2290abff9ba000000b4491a67790a9ff9ba00000094491a77790a4ff9ba00000044491a42290a66691c00000000000000000046692c000000000000000000000000000000000000000000b6692a000000000000000000b6692a00000000000000000076691a00000000000000000096692c000000000000000000b6692c000000000000000000
-- 015:4aa1f50000004aa155000000eaa1f3000000eaa1630000009aa1f50000004aa1850000007aa1f54aa1f5baa1f54aa1f54aa175000000000000000000eaa1730000000000000000009aa1750000000000000000004aa175000000000000000000b6692a00000000000000000096692c00000000000000000000000000000000000000000076692a00000000000000000076692a000000000000000000c6691a00000000000000000096692a000000000000000000b6692a000000000000000000
-- 016:c88919c88917a88919c88917c88919c88917888919c88917a88919c88917788919c88917888919c88917588919c88917488919c88917588919c88917788919c88917888919c88917a88919c88917888919c88917788919c88917588919c88917c88919c88917a88919c88917c88919c88917888919c88917a88919c88917788919c88917888919c88917588919c88917488919c88917588919c88917788919c88917888919c88917a88919c88917888919c88917788919c88917588919c88917
-- 017:7bb1860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007bb107000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000abb186000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000abb107000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 018:9bb1449bb1469bb1449bb1449bb1469bb1449bb1469bb1469bb1449bb1469bb1449bb1449bb1469bb1449bb1469bb1468bb1448bb1448bb1468bb1448bb1468bb1468bb1448bb1467bb1447bb1447bb1467bb1447bb1467bb1467bb1447bb1466bb1446bb1446bb1466bb1446bb1466bb1466bb1446bb1466bb1446bb1466bb1446bb1446bb1466bb1446bb1466bb1465bb1445bb1445bb1465bb1445bb1465bb1465bb1445bb1465bb1445bb1465bb1445bb1445bb1465bb1445bb1465bb144
-- 019:9bb958000000000000000000000000000000000000000000cbb9880000000000000000000000000000000000000000008bb958000000000000000000bbb9880000000000000000007bb958000000000000000000abb9880000000000000000006bb9580000000000000000000000000000000000000000009bb9880000000000000000000000000000000000000000005bb9580000000000000000000000000000000000000000005bb968000000000000000000000000000000000000000000
-- 020:9bb1860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008bb1070000000000000000000000000000000000000000007bb1860000000000000000000000000000000000000000006bb1860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005bb107000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 021:5cc1f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dcc1f3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 022:acc1f30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005cc1f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 023:8ee9380000000000000000008ee9480000008669480000000000007ee9388ee9387ee9380000005ee9387ee9385ee938cee936000000000000cee946000000000000c66946000000000000aee936cee936dee936fee936dee936cee936aee9365ee9380000000000000000005ee948000000000000566948000000000000cee938000000aee9380000008ee9380000007ee9380000005ee9380000004ee9380000005ee9380000007ee9380000008ee9380000007ee9380000005ee938000000
-- 024:8ee9380000000000000000008ee9480000008669480000005ee9387ee9380000008ee938000000cee938000000aee9380000008ee938aee9388ee9380000007ee9388ee9387ee9380000005ee9387ee9385ee9380000004ee938cee9364ee9385ee9380000000000000000005ee948000000000000000000566948000000000000000000000000000000000000000000000000000000522948000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 025:8ee9380000000000000000008ee9480000008669480000005ee9387ee9380000008ee938000000cee938000000aee9380000008ee938aee9388ee9380000007ee9388ee9387ee9380000005ee9387ee9385ee9380000004ee938cee9364ee9385ee9380000000000000000005ee9480000000000000000005669480000000000000000000000000000000000000000000000000000005229480000000000000000000000000000000000004ee9385ee9387ee9388ee9387ee938aee938cee938
-- 026:8ee93a0000000000000000008ee94a00000000000085594a0000006ee93a8ee93a6ee93a0000005ee93a6ee93a5ee93a000000fee9385ee93afee938000000dee938fee938dee938000000bee938aee938bee938000000bee938dee938eee938fee938000000000000000000fee948000000000000f55948000000dee938fee938dee938bee938aee9386ee9385ee9386ee9388ee9386ee9385ee938fee936000000000000000000fee946000000000000000000f55946000000000000000000
-- 027:8cc1f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fcc1f3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 028:b88919888919a88919888919b88919888919d88919888919b8891988891948891b888919f88919888919d88919888919b88919888919d88919888919b88919888919a88919888919b8891988891948891b88891968891b88891948891b888919f88919688919d88919688919f88919688919a88919688919b88919688919a88919688919888919688919588919688919588919f88917e88917f88917588919f88917588919688919588919688919888919688919888919a88919988919a88919
-- 029:8ee968000000000000000000866968000000000000000000833968000000000000000000bee978000000b669780000008ee968000000000000000000866968000000000000000000833968000000000000000000bee978000000b669780000006ee988000000000000000000666988000000000000000000633988000000000000000000aee998000000a669980000006ee988000000000000000000666988000000000000000000633988000000000000000000aee998000000a66998000000
-- 030:bee988000000000000000000b66988000000000000000000b33988000000000000000000bee9a8000000b669a8000000bee988000000000000000000b66988000000000000000000b33988000000000000000000bee9a8000000b669a8000000fee968000000000000000000f66968000000000000000000f33968000000000000000000000000000000000000000000aee9980000000000000000006ee988000000000000000000fee966000000000000000000aee996000000000000000000
-- 031:7bb1860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007bb107000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fbb184000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fbb105000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 032:788114000000000000000000788194000000744194000000988114000000000000000000988194000000944194000000a88114000000000000000000a88194000000a44194000000c88114000000000000000000c88194000000c44194000000d88114000000000000000000000000000000d88194000000000000d44194000000000000588116000000000000000000c88116000000d88116000000c88116000000588116000000000000000000588196000000000000544196000000000000
-- 033:cff1f8cff1f8000000cff1f89ff1e6000000cff1f8cff1f8000000cff1f8cff1f80000009ff1e6000000cff1f8000000cff1f8cff1f8000000cff1f89ff1e6000000cff1f8cff1f8000000cff1f8cff1f80000009ff1e6000000cff1f8000000cff1f8cff1f8000000cff1f89ff1e6000000cff1f8cff1f8000000cff1f8cff1f80000009ff1e6000000cff1f8000000cff1f8cff1f8000000cff1f89ff1e6000000cff1f8cff1f8000000cff1f8cff1f80000009ff1e60000009ff1e69ff1e6
-- 034:a77917777917977917777917a77917777917c77917777917a77917777917977917777917a77917777917c77917777917a77917777917977917777917a77917777917c77917777917a77917777917977917777917a77917777917c77917777917d77917577917c77917577917d77917577917f77917577917d77917577917c77917577917d77917577917a77917577917d77917577917c77917577917d77917577917f77917577917d77917577917c77917577917c77917577917a77917577917
-- 035:7bb1447bb1447bb1447bb1447bb1467bb1447bb1447bb1447bb1447bb1467bb1447bb1447bb1467bb1447bb1467bb1467bb1447bb1447bb1447bb1447bb1467bb1447bb1447bb1447bb1447bb1467bb1447bb1447bb1467bb1447bb1467bb146abb144abb144abb144abb144abb146abb144abb144abb144abb144abb146abb144abb144abb146abb144abb146abb146abb144abb144abb144abb146abb144abb144abb146abb144abb146abb144abb144abb146abb144abb144abb146abb144
-- 036:988114000000000000000000944114000000000000000000b88114000000000000000000988114000000000000000000b88114000000000000000000b44114000000000000000000f88114000000000000000000888116000000000000000000b88116000000000000000000988116000000788116000000688116000000000000000000488116000000000000000000788116000000000000000000744116000000000000000000f88114000000000000000000a88116000000000000000000
-- 037:977917477917b77917477917c77917477917b77917477917977917477917b77917477917977917477917877917477917877917f77915f77917877917d77917877917b77917877917d77917877917b77917877917a77917877917b77917a77917b77917777917477919777917f77917777917b77917777917c77917777917b77917777917a77917777917b77917777917f77917a77917577919a77917f77917a77917e77917a77917f77917a77917e77917a77917f77917a77917577919a77917
-- 038:9bb1449bb1449bb1449bb1449bb1469bb1449bb1449bb1449bb1449bb1469bb1449bb1449bb1469bb1449bb1469bb1468bb1448bb1448bb1448bb1448bb1468bb1448bb1448bb1448bb1448bb1468bb1448bb1448bb1468bb1448bb1468bb1464bb1444bb1444bb1444bb1444bb1464bb1444bb1464bb1464bb1444bb1464bb1444bb1444bb1464bb1444bb1464bb146fbb142fbb142fbb142fbb142fbb144fbb142fbb142fbb142fbb142fbb144fbb142fbb142fbb144fbb142fbb144fbb144
-- 039:988114000000000000000000000000000000000000000000b88114000000000000000000c88114000000000000000000f88114000000000000000000000000000000000000000000888116000000000000000000a88116000000000000000000788137788137744137788137788137744137788137788137744137788137788137744137000000000000000000000000788127788127744127788127788127744127788127788127744127788127788127744127000000000000000000000000
-- 040:a88126788126688126788126e88124788126688126788126e88126a88126988126a88126788126a88126988126a88126d88126a88126988126a88126788126a88126988126a88126e88126a88126988126788126688126788126988126788126588126000000000000000000544126000000000000000000a88124000000000000000000a44124000000000000000000d88124000000000000000000d44124000000000000000000f88124000000000000000000f44124000000000000000000
-- 041:cff1f8cff1f8000000cff1f89ff1e6000000cff1f8cff1f8000000cff1f8cff1f80000009ff1e6000000cff1f8000000cff1f8cff1f8000000cff1f89ff1e6000000cff1f8cff1f8000000cff1f8cff1f80000009ff1e6000000cff1f80000009ff1e69ff1e6cff1f89ff1e69ff1e6cff1f89ff1e69ff1e6cff1f89ff1e69ff1e6cff1f8cff1f8cff1f8cff1f8cff1f89ff1e69ff1e6cff1f89ff1e69ff1e6cff1f89ff1e69ff1e6cff1f89ff1e69ff1e6cff1f8cff1f8cff1f8cff1f8cff1f8
-- 042:a88116988116a88116000000788116000000000000744116000000000000988116a88116c88116a88116988116c88116a88116988116a88116000000788116000000000000744116000000000000788116988116a88116988116788116e88114d88114c88114d88114000000a88114000000000000a44114000000000000c88114d88114f88114d88114f88114488116588116688116588116000000d88114000000000000d44114000000000000588116f88114588116d88114c88114a88114
-- 043:488126c88124b88124c88124988124c88124b88124c88124488126c88124b88124c88124988124c88124b88124c88124988126488126f88124488126c88124488126f88124488126988126488126f88124488126e88124488126c88124488126888126000000000000000000844126000000000000000000b88126000000000000000000b44126000000000000000000a88126000000000000000000a44126000000000000000000f88124000000000000000000f44124000000000000000000
-- 044:c77917977917b77917977917c77917977917e77917977917c77917977917b77917977917c77917977917e77917977917c77917977917b77917977917c77917977917e77917977917477919977917e77917977917c77917977917b77917977917b77917877917a77917877917b77917877917d77917877917b77917877917a77917877917b77917877917d77917877917f77917877917477919877917f77917877917677919877917477919877917f77917877917d77917877917b77917877917
-- 045:9bb1469bb1449bb1449bb1469bb1449bb1449bb1469bb1449bb1469bb1449bb1449bb1469bb1449bb1449bb1469bb1449bb1469bb1449bb1449bb1469bb1449bb1449bb1469bb1449bb1469bb1449bb1449bb1469bb1449bb1449bb1469bb1448bb1468bb1448bb1448bb1468bb1448bb1448bb1468bb1448bb1468bb1448bb1448bb1468bb1448bb1448bb1468bb1448bb1468bb1448bb1448bb1468bb1448bb1448bb1468bb1448bb1468bb1448bb1448bb1468bb1448bb1448bb1468bb144
-- 046:755125000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555145000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 047:e55143000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d55133000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 048:a55135000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a55145000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 049:a55135000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a55125000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 050:6ff1380000000000000000006ff1380000000000000000006ff13a0000000000000000006ff13c000000000000000000000000000000dff138000000000000bff1380000000000006ff138000000000000bff1380000000000000000000000000000000000000000000000005ff138000000000000eff138000000000000cff13a0000000000000000000000000000000000000000000000000000009ff13a0000000000008ff13a0000000000006ff13a000000000000000000000000000000
-- 051:0000009ff1380000000000000000009ff1380000000000000000009ff13a0000000000000000000000000000000000006ff138000000000000bff1380000000000009ff1380000000000008ff138000000000000dff1380000000000000000000000000000000000000000000000008ff1380000000000005ff13a000000000000eff13a0000000000000000000000000000000000000000000000000000008ff13a0000000000006ff13a0000000000008ff13a000000000000000000000000
-- 052:000000000000dff138000000000000000000dff138000000000000000000dff13a0000000000000000000000000000000000009ff138000000000000fff1380000000000008ff1380000000000009ff138000000000000000000000000000000000000000000000000000000000000000000cff1380000000000008ff13a0000000000005ff13c0000000000000000000000000000000000000000000000000000009ff13a0000000000005ff13a0000000000006ff13a000000000000000000
-- 053:000000000000000000fff138000000000000000000fff138000000000000000000fff13a0000000000000000000000006661f5000000000000000000000000000000000000000000000000000000000000000000d661f50000000000000000000000000000000000000000005661f50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006661f5000000000000000000000000000000000000000000000000000000000000000000
-- 054:eff13a000000000000000000bff13a0000000000000000004ff13c000000000000000000eff13a000000000000000000dff13a0000000000000000009ff13a000000000000000000eff13a000000000000000000dff13a000000000000000000bff13a0000000000000000006ff13a0000000000000000006ff13a0000000000000000004ff13a0000006ff13a0000000000000000009ff13a0000008ff13a000000000000000000dff13a000000eff13a000000000000000000000000000000
-- 055:000000bff13a0000000000000000009ff13a000000000000000000dff13a0000000000000000006ff13a000000000000000000bff13a000000000000000000bff13a000000000000000000dff13a0000000000000000009ff13a0000000000000000006ff13a000000000000000000eff138000000000000bff13a0000000000000000009ff13a000000bff13a000000000000000000eff13a000000dff13a0000000000000000009ff13a000000bff13a000000000000000000000000000000
-- 056:0000000000004ff13c000000000000000000eff13a0000000000000000009ff13a000000000000000000bff13a0000000000000000008ff13a0000000000000000004ff13c000000000000000000bff13a0000000000000000006ff13a0000000000000000004ff13a0000000000000000006ff13a0000006ff13c0000000000000000004ff13c0000006ff13c0000000000000000009ff13c0000008ff13c0000000000000000004ff13c0000006ff13c000000000000000000000000000000
-- 057:b661f300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080013c9ff13adff13aeff13a000000dff13a000000eff13adff13aeff13a0000006ff13c0000004ff13cdff13a4ff13c000000eff13a0000004ff13c8ff13c4ff13c6ff13ceff13a
-- 058:7bb1447bb1447bb1447bb1447bb1467bb1447bb1447bb1447bb1447bb1467bb1447bb1447bb1467bb1447bb1467bb1467bb1447bb1447bb1447bb1447bb1467bb1447bb1447bb1447bb1447bb1467bb1447bb1447bb1467bb1447bb1467bb146fbb142fbb142fbb142fbb142fbb144fbb142fbb142fbb142fbb142fbb144fbb142fbb142fbb144fbb142fbb144fbb144fbb142fbb142fbb142fbb142fbb144fbb142fbb142fbb142fbb142fbb144fbb142fbb142fbb144fbb142fbb144fbb144
-- 059:755125000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000655135000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </PATTERNS>

-- <TRACKS>
-- 000:0801015406010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0
-- 001:702982d83f04000000000000000000000000000000000000000000000000000000000000000000000000000000000000ab00b0
-- 002:0851980c5198264616264756267cd6267c97267cd7000000000000000000000000000000000000000000000000000000000020
-- 003:0003290883292683292ea3292696e9a2a6e926a32922bdabf2c329fac329000000000000000000000000000000000000000000
-- 004:33d5bd73e9be0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0
-- 005:00c3cbf2c3c2fac3c2f683c2fea3c2f2c3c2f2c2f8fe22f8000000000000000000000000000000000000000000000000000040
-- 006:009384309c84309c843c44553c445521c4eb02fb7c000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <SCREEN>
-- 000:110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011
-- 001:199990111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111099991
-- 002:094494999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999494490
-- 003:094994999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999499490
-- 004:099990000000040000000400000004000000040000000400000004000000040000000400000004000000040000000400000004000000040000000400000004000000040000000400000004000000040000000400000004000000040000000400000004000000040000000400000004000000040000099990
-- 005:004404944444404444444044444440444444404444444044444440444444404444444044444440444444404444444044444440444444404444444044444440444444404444444044444440444444404444444044444440444444404444444044444440444444404444444044444440444444404449404400
-- 006:019909904444404444444044444440444444404444444044444440444444404444444044444440444444404444444044444440444444404444444044444440444444404444444044444440444444404444444044444440444444404444444044444440444444404444444044444440444444404409909910
-- 007:019904091111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101190409910
-- 008:019904419000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000914409910
-- 009:019904410904444444444044444440444444404444444044444440444444404444444044444440444444404444444044444440444444404444444044444440444444404444444044444440444444404444444044444440444444404444444044444440444444404444444044444440444444409014409910
-- 010:019940000040111111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111040014409910
-- 011:019904410404011111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111110404014409910
-- 012:019904410410400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004014014409910
-- 013:0199044104110101111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101110ee001111111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011111010114000049910
-- 014:019904410411001011101111111011111110111111101111111011111110111111101111111011111110111111101111111011111110110e2ee01111111001111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011110100114014409910
-- 015:019904410411010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ceee00000000ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010114014409910
-- 016:0199044104110110010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010170cc07010100e2ee010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101101010100110114014409910
-- 017:0199044104110110101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101aa7007aa010100000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010010101010110114014409910
-- 018:01994000000001100101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110ffffff0111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110100110114014409910
-- 019:0199044104110110101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100ffffffff011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111010000114014409910
-- 020:01990441041100000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110ee00fff0fa011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100110114014409910
-- 021:0199044104110110101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110e2ee00ff00a011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111010110000000049910
-- 022:0199044104110110011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110ceee0ffffaa011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100110114014409910
-- 023:01990441041101101011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110011170cc07f00a00111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111010110114014409910
-- 024:01990441041101101011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100001aa7007aafaa20111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100110114014409910
-- 025:019904410411011001111111111111111111111111111111111111111111111111111111111111111111111111001111110011111111111000011110088882222011111111111111111111111111010111111111111111111111111111111111111111111111111111111111111111010110114014409910
-- 026:0199400000000110101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110ee01110ee02888822011111111111111111111111101111011111111111111111111111111111111111111111111111111111111111111100110114014409910
-- 027:019904410411011001111111111111111111111111111111111111111111111111111111111111111111111111111101111111011111110e2ee010e2ee0288200111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111010000114014409910
-- 028:019904410411000010111111111111111111111111111111111111111111111111111111111111111111111111111101111111011111110ceee010ceee04444ff011111111111111111111111101110011111111111111111111111111111111111111111111111111111111111111100110114014409910
-- 029:0199044104110110011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111170cc07170cc0710000f011111111111111111111111100000011111111111111111111111111111111111111111111111111111111111111010110000000049910
-- 030:0199044104110110101111111f111100001111f1111111111111111111111111111111111111111111111111110111111101111111111aa7007aaa7007aa00a00111111111111111111111111110000111111111111111111111111111111111111111111111111111111111111111100110114014409910
-- 031:0199044104110110011111111ff110aaaa011fe1111111111111111111111111111111111111111111111111111111111111111111111111111111000000007a0111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111010110114014409910
-- 032:01990441041101101011111111fffaaaaaaffe1111111111111111111111111111111111111111111000000000000111111111111111111111111100000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100110114014409910
-- 033:019904410411011001111111111ee3aaaa3ee11111111111111111111100111111111111111111110999999999999011111111111111111111111110000000000111111111111111111111111111111111111111110011111111111111111111111111111111001111111111111111010110114014409910
-- 034:019940000000011010111111111103333330111111111111111111111111111111111111111111110911111111119011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100110114014409910
-- 035:019904410411011001111111101100600600111111111111111111111111110111111111111111110914444444419011111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111011111111111111111111010000114014409910
-- 036:01990441041100001011111110100aa00a30131111111111111111111111110111111111111111110919999999919011111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111011111111111111111111100110114014409910
-- 037:019904410411011001111111100000000000000011111111111111111111111111111111111111110919999999919011111111111111111100111110011111100000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111010110000000049910
-- 038:0199044104110110101131110fffffffffffffff011111111111111111011111111111111111111109499999999490111111111111111110000111000011110fffffffffffffff01111111111111111111111111110111111111111111111111111111111111101111111111111111100110114014409910
-- 039:019904410411011001111f110fffffffffffffff011111111111111111111111111111111111111109444444444490111111111111111110000111000011110fffffffffffffff01111111111111111111111111111111111111111111111111111111111111111111111111111111010110114014409910
-- 040:0199044104110110101111000fffffffffffffff000111111111111111111111111111111111111109999999999990111111111111111111001111100111000fffffffffffffff00011111111111111111111111111111111111111111111111111111111111111111111111111111100110114014409910
-- 041:0199044104110110011110fff000000fff000000fff011111111111111111111111111111111111104444444444440111111111111111111111111111110fff000000fff000000fff01111111111111111111111111111111144441111444411111111111111111111111111111111010110114014409910
-- 042:0199400000000110101110fff033300fff033330fff011111111111111111111111111111111111104000000000040111111111111111111111111111110fff011110fff011110fff01111111111111111000001111111111411114444111141111111111111111111111111111111100110114014409910
-- 043:0199044104110110011110fff000000fff033300fff011111000000111111111000000111000111104044000000000111111111111111111111111111110fff011110fff011110fff01111100000011110e00000011100014100001111000000000011111111100000011111111111010000114014409910
-- 044:0199044104110000101110fff082000fff033300fff011110ffffff011111110ffffff010fff011104140fffffffff011111111111111111111111111110fff011110fff011110fff011110ffffff011100ffffff010fff041040400000fffffffff011111110ffffff01111111111100110114014409910
-- 045:0199044104110110011110fff082000fff000000fff011110ffffff011111110ffffff010fff011104110fffffffff011111111111111111111111111110fff011110fff011110fff011110ffffff011110ffffff010fff040010041140fffffffff011111110ffffff01111111111010110000000049910
-- 046:0199044104110110101110fff000000fff000000fff011000ffffff000111110ffffff000fff000104000fffffffff011111111111111111111111111110fff000110fff000000fff011000ffffff000110ffffff000fff000000010000fffffffff011111000ffffff01111111111100110114014409910
-- 047:0199044104110110011111000fff000fffffffff000110fff000000fff011111000ffffff000fff010fff000000fff011111111111111111111111111111000fff010fffffffff000110fff000000fff011000ffffff000fff010100fff000000fff011110fff00000011111111111010110114014409910
-- 048:0199044104110110101111110fff010fffffffff011110fff011110fff011111110ffffff010fff010fff011110fff044111111111111114411111111111110fff010fffffffff044110fff011110fff011090ffffff010fff000000fff000040fff011110fff01111111111111111100110114014409910
-- 049:0199044104110110011111110fff010fffffffff000110fff011110fff011111110ffffff010fff010fff000000fff011444441111444441144444111144440fff040fffffffff000440fff011440fff011100ffffff010fff000000fff000000fff011110fff00000011111111111010110114014409910
-- 050:0199400000000110101111111000110fff000000fff010fff011110fff011111110fff000111000110fffffffff000100111014444101110011101444410111000110fff000000fff010fff044110fff011000fff000110fff000000fffffffff000111111000ffffff01111111111100110114014409910
-- 051:0199044104110110011111111101110fff011110fff010fff011110fff011111110fff011111111140fffffffff000011000001111000001100000111100000110000fff010000fff000fff011000fff010000fff011110fff000000fffffffff011111111110ffffff01111111111010000114014409910
-- 052:0199044104110000101111111111110fff011110fff010fff011000fff000111110fff011111111140fffffffff041000114040000404114411404000040411441140fff004040fff010fff000400fff011000fff011110fff000000fffffffff011000111110ffffff00011111111100110114014409910
-- 053:0199044104110110011111111111110fff011110fff010fff010fffffffff011110fff011111111140fff000000010fff011004114001101101100411400110110110fff040010fff010fff014000fff011110fff011110fff044000fff000000110fff011111000000fff01111111010110000000049910
-- 054:0199044104110110101111111111110fff011110fff010fff010fffffffff011110fff011111111110fff010010000fff000001001000010010000100100001001000fff010000fff000fff001000fff011110fff011110fff011400fff011111110fff011111111110fff01111111100110114014409910
-- 055:0199044104110110011111111111000fff000000fff010fff000fffffffff011110fff011111111110fff000000000fff001010000101001100101000010100110000fff000000fff000fff000000fff011110fff011110fff000140fff000000000fff011000000000fff01111111010110114014409910
-- 056:0199044104110110101111111110fffffffffffffff011000fff000fff000111110fff011111111140ffffffffffff000000000000000000000000000000000000fffffffffffffff000000ffffff000111110fff011110ffffff010ffffffffffff000110fffffffff00011111111110110111011119910
-- 057:0199044104110110011111111110fffffffffffffff011110fff010fff010101110fff011111111140ffffffffffff000000000000000000000000000000000000fffffffffffffff000000ffffff000114440fff011110ffffff010ffffffffffff011110fffffffff00101111111110000000000001100
-- 058:0199400000000110101111111110fffffffffffffff011110fff010fff011110110fff011111111110ffffffffffff000000000000000000000000000000000000fffffffffffffff000000ffffff000441110fff011110ffffff010ffffffffffff011110fffffffff01110111111110330333333303770
-- 059:019904410411011001111111111100000000000000011111100011100011111011100011111111111400000000000000000000000000000000000000000000000000000000000000000000000000000011000000011111100000011100000000000011111100000000011110111111110333333333333770
-- 060:019904410411000010111111111111111111111111111111111111111101110011111111111111111400000000000000000000000000000000000000000000000000000000000000000000000000000000404014111111111111111111111111111111111111111111011100111111110333333333333770
-- 061:019904410411011001111111111111111111111111111111111111111100000011111111111111111144400000000000000000000000000000000000000000000000000000000000000000000000000014001004111111111111111111111111111111111111111111000000111111110333333333333770
-- 062:019904410411011010111111111111111111111111111111111111111110000111111111111111111111140000000000000000000000000000000000000000000000000000000000000000000000000001000041111111111111111111111111111111111111111111100001111111110333333333333770
-- 063:019904410411011001111111111111111111111111111111111111111111111111111111111111111111114400000000000000000000000000000000000000000000000000000000000000000000000000101041111111111111111111111111111111111111111111111111111111110333333333333770
-- 064:019904410411011010111111111111111111111111111111111111111111111111111111111111111111111140000000000000000000000000000000000000000000000000000000000000000000000000000004111111111111111111111111111111111111111111111111111111110333333333333770
-- 065:019904410411011001111111111111111111111111111111111111111111111111111111111111111111111140000000000000000000000000000000000000000000000000000000000000000000000000000004111111111111111111110101111111111111111111111111111111110333333333333770
-- 066:019940000000011010111111111111111111111111111111111111111111111111111111111111111111111114000000000000000000000000000000000000000000000000000000000000000000000000000041111111111111111111011110111111111111111111111111111111110333333333333770
-- 067:019904410411011001111111111111111111111111111111111111111111111111111111111111111111111114000000000000000000000000000000000000000000000000000000000000000000000000000041111111111111111111111110111111111111111111111111111111110333333333333770
-- 068:019904410411000010111111111111111111111111111111111111111111111111111111111111111111111114000000000000000000000000000000000000000000000000000000000000000000000000000041111111111111111111011100111111111111111111111111111111110333333333333770
-- 069:019904410411011001111111111111111111111111111111111111111111111111111111111111111111111111444000000000000000000000000000000000000000000000000000000000000000000000044411111111111111111111000000111111111111111111111111111111110330333333303770
-- 070:019904410411011010111111111111111111111111111111111111111111111111111111111111111111111111111400444400044444000440004444000000000000000000000000000000000000000000411111111111111111111111100001111111111111111111111111111111110000000000001100
-- 071:019904410411011001111111111111111111111111111111111111111111111111111111111111111111111111111144111144411111444114441111000000000000000000000000000000000000000044111111111111111111111111111111111111111111111111111111111111110110111011119910
-- 072:019904410411011010111111111111111111111111111111111111111111111111111111100000011111111111111111111111111111111111111111140000000000000000000000000000000000000411111111111111111111111111111111111111111111111111111111111111100110114014409910
-- 073:019904410411011001111111111111111111111111111111111111111111111111111111044444401111111111111111111111111111111111111111140000000000000000000000000000000000000411111111111111111111111111111111111111111111f11110000111f11111010110114014409910
-- 074:019940000000011010111111111111111111111111111111111111111111111111111111049999401111111111111111111111111111111111111111140000000000000000000000000000000000004111111111111111111111111111111111111111111111ef110aaaa01fe11111100110114014409910
-- 075:0199044104110110011111111111111111111111111111111111111111111111111111110499994011111111111111111111111111111111111111111400000000000000000000000000000000000041111111111111111111111111111111111111111111111eff3aaaaa0e111111010000114014409910
-- 076:01990441041100001011111111111111111111111111111111111111111111111111111104999940111111111111111111111111111111111111111140000000000000000000000000000000000000411111111111111111111111111111111111111111111111ef1aaaaa01111111100110114014409910
-- 077:019904410411011001111111111111111111111111111111111111111111111100000111041111001111111111111111111000000111111111111110000000000000000000000000000000000004441111111111011111011111111111111111111111111111110130333301111111010110000000049910
-- 078:0199044104110110101111111111111111111111111111111111111111111110fffff011044440f01111111111111000110ffffff01111111111110ff0000fffff000000000ff000000000000041111111111110f01010f01111111111111111111111111111110330600601111111100110114014409910
-- 079:019904410411011001111111111111111111111111111111111111111111110f00f00f00000000f01111111111110fff00f00f0001001011100011100f00f00f00f0000000000f00000000000011100101110010f00f00011111111111111111111111111111110333a00a01111111010110114014409910
-- 080:019904410411011010111111111111111111111111111111111111111111110f00f00f0ff0f00fff001111111110f000f0f00f0010ff0f010fff010f0f00f00f00f00fff000f0f00ff0f0000ff010ff0f000ff00f0f00ff01111111111111111111111111111100033a00a01111111100110114014409910
-- 081:0199044104110110011111111111111111111100111111111111111111111110f0ffff00ff0f00f00f011111110f00fff00f0fff010ff0f0f00f00f0ff000f0fff00f00f00f0ff000ff0f00f00f010ff0f0f0090ff0f00f011111111111111111111111111000333a0000001011111010110114014409910
-- 082:019940000000011010111111111111111111005500101111111111111111111100f00f00f01010f010111111110f0f00f0100f00110f0100fff000f00f00000f00f0fff000f00f000f00f00f00f010f01010ff00f00f00f011111111111111111111111111110333a0a00a00a00000000110114014409910
-- 083:019904410411011001111111111111111110555b55050111111111111111111110f00f00f01110f00f011111110f0f0ff0110f01110f0110f000f0f00f00660f00f0f000f0f00f000f00f00f0fff00f0101000f0f00f00ff011111111111111111111111111033333a0aa03a388888880000114014409910
-- 084:01990441041100001011111111111111110555b5bb55501111111111111111110ff00f00f011110f001111111110f0f0f010fff0110f0110ffff010ff0f060fffff0ffff000ff0f00f00ff00f0f010f0010fff00f00f00f0111111111111111111111111111033333a033033322222200110114014409910
-- 085:0199044104110110011111111111111111105b5555b55011111111111111111110011011011111101111111111110101011100011110111100001110010ee600000600000000000000040011010111010110004409909001111111111111111111111111111033333a033000300000010110000000049910
-- 086:019904410411011010111111111111111105b555555b550111111111111111111111111111111111111111111111111111111111111111111111111111eeee46646664e4400044440041111111111111101114411114401111111111111111111111111111010333a1110300011111100110114014409910
-- 087:019904410411011001111111111111111105b5555555b50111111111111111100010111111111111110111111111111110001011111111111111111111eeea4666666400000411114411111110011110010011144101011111111111111111111111111111100333a1001000000111010110114014409910
-- 088:01990441041101101011111111111111105b5555555b5011111111111111110fff0f01000001111110f01111111111010fff0f011111111111111111111aa466000040fffff01111111111110ff0110ff011111110f011011111111111111111111111111100000030000300000011100110114014409910
-- 089:019904410411011001111111110011111055b555555b501111111111111100f0f0f0f0099090100110011100111110f0f0f0f0f0100111000011111111106660fff00f00f00f001101110010f00110f00f01000110f010f01111111111111111111311111110000000000000000111010110114014409910
-- 090:0199400000000110101111111111111111055b5555b5011111111111111110f0f0f0f0f00f090ff00ff010ff01110f00f0f0f0f00ff010ffff0101111106660f000f0f00f00f0f00f010ff00f0f010f00f00fff00fff0ff011111111111111111111f1111111110000000000111111100110114014409910
-- 091:01990441041101100111111111111101110555bb5b5550111111111110111100f0f0f0f00f00f00110f00f00f010f01100f0f0f0f00f010f00f0f011110660f00fff00f0fff00f00f00f0010ff0f010f0f0f00f010f010f01111111111111111111111111111111111111111111111010000114014409910
-- 092:0199044104110000101111111111110111105055b55501111111111110111110f0f0f0f00f040ff010f00f01010f011110f0f0f0f00f010f00f00111110660f0f00f0000f00f0f00f010ff00f00f00100f0fff0010f010f01111111111111111111111111111111111111111111111100110114014409910
-- 093:0199044104110110011111111111111111110100550011111111111111111110f0f0f0f0fff0000f00ff0f00f0f0111110f0f0f0f0fff00fff00f011106660f0f0ff0600f00f0f0fff0000f0f00f0f000f0f000f00f010f01111111111111111111111111111111111111111111111010110000000049910
-- 094:0199044104110110101111111101111111111111001111111111111111111010f0f0f00f0f00fff010f010ff0101111110f0f0f00f0f010f001101110666660f0f0f060ff00f00f0f00fff00f00f00fff00ffff0110f0fff0111111111111111111111111111111111111111111111100110114014409910
-- 095:019904410411011001111111111111111111111111111111111111111111111100010440409900011101110011111111110101011010110f01111111006666604000600001101101011000110110110001100001111010001111111111111111111111111111111111111111111111010110114014409910
-- 096:019904410411011011111111111111111111111111111111111111111111111101144444414499011111111111111111111111111111111011111110000000000000000001111111111111111111111111111111111111111111111111111111100000000000111111111111111111100110114014409910
-- 097:019904410411011011100011111000111111111111111111111111111111111109900044411100001111111111111111000001111111110111111111000000000000000011111111110111111100111111111111111111111111111111111111099999999999011111111111111111010110114014409910
-- 098:0199400000000110010555000105550000101111111111111111111111111111090fff04111440ff0111111111111010fffff011111110f01111111111100000000f01901111111110f011111111111111111111111111111111111111111111099000000099011111111111111111100110114014409910
-- 099:01990441041101105055b5555055b5555505011111111111111111111111111100f000f010044400f011000111110f0f00f00f00010110f01111111111110fff090f04001011100010f011000110010011110011100101111111111111111111090404040409011111111111111111010000114014409910
-- 100:0199044104110000b55b5b5bb55b5b5bbb5550111111111111111111111111110f0114010ff040f0f010fff01110f00f00f00f0ff0f00fff001111111110f000f0fff0ff0f010fff00f010fff00ff0ff0110ff010ff0f0111111111111111111094949494919011111111111111111100110114014409910
-- 101:01990441041101105bb555555bb5555555b550111111111111111111111111110f044440f00f0f0ff00f00f0110f0110f0ffff00ff0f00f00f011111110f00fff00f040ff0f0f00f00f00f00f010fff0f00f00f010ff0f011111111111111111094949494919011111111111111111010110000000049910
-- 102:01990441041101105555555555555555555b55011111111111111111111111110f011400f00f0f00f00fff0010f0111100f00f00f01010f010111111110f0f00f00f090f0100fff000f00fff0000f0f0f00f00f010f010111111111111111111094949494919011111111111111111100110114014409910
-- 103:019904410411011055555555555555555555b5011111111111111111111111110ff000f0f00f0f00f00f000f0f01111110f00f00f01110f00f011111110f0f0ff00f000f0110f000f0f00f000f00f0f0f00f0fff00f011111111111111111111099101010199011111111111111111010110114014409910
-- 104:01990441041101105555555555555555555b501111111111111111111111111110ffff010ff010ff0f0ffff0101111110ff00f00f011110f001111111110f0f0f010f00f0110ffff010f0ffff010f0f0ff00f0f010f011111111111111111111099999999999011111111111111111100110114014409910
-- 105:019904410411011055eb5b555555555555b5011111111111111111111111111111000011100111001010000111111111100110110111111011111111111101010111011011110000111000000111010100110101110111111111111111111111041111111114011111111111111111010110114014409910
-- 106:01994000000001105eb555555555555555b5501111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111101111111111111111111111111111111111111111011000000011011111111111111111100110114014409910
-- 107:01990441041101105b5555b555555555555b550111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111010101010101011111111111111111010000114014409910
-- 108:019904410411000055555be5555555555555b50111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110111001111111111111111111111111111111111111111014141414141011111111111111111100110114014409910
-- 109:0199044104110110b5555e5555555555555b550111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110000001111111111111111111111111111111111111111014444444441011111111111111111010110000000049910
-- 110:01990441041101105bb55555555555555555501111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000011111111111111111111111111111111111111111011111111111011111111111111111100110114014409910
-- 111:01990441041101105eeb555555555555555b501111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000111111111111111111010110114014409910
-- 112:01990441041101105555555555555555555b501111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111010110114014409910
-- 113:01990441041101105555555555bb555555b5011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100110114014409910
-- 114:0199400000000110555555555eeeb55555b5501111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111010110114014409910
-- 115:01990441041101105555555555ee5555555b550111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000114014409910
-- 116:019904410411000055555555555555555555b50111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111010110114014409910
-- 117:01990441041101105555555555555eb5555b550111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110100110000000049910
-- 118:01990441041101105555555555555bb55555501101010101010101010101010101010101010101010101010101010101010101010101010111111111111111110101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010110114014409910
-- 119:01990441041101105555555555555555555b501110101010101010101010101010101010101010101010101010101010101010101010101011111111111111111010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100110114014409910
-- 120:019904410411010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010114014409910
-- 121:019904410411001011110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011110333333333333011111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101110100114014409910
-- 122:019940000411010111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111111011110333333333333011111011111110111111101111111011111110111111101111111011111110111111101111111011111110111111101111010114014409910
-- 123:019904410410400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004014014409910
-- 124:01990441040401111101111111011111110111111101111111011111110111111101111111011111110111111101111110fffff011011111103333333333330111011110fffff011110111111101111111011111110111111101111111011111110111111101111111011111110111111110404014409910
-- 125:0199044100401111110111111101111111011111110111111101111111011111110111111101111111011111110111110f00f00f0001011100033300333003011101110f00f00f01110111111101111111011111110111111101111111011111110111111101111111011111110111111111040000049910
-- 126:0199044109044444440444444404444444044444440444444404444444044444440444444404444444044444440444440f00f00f0ff0f040fff030ff030ff0014404440f00f00f04440444444404444444044444440444444404444444044444440444444404444444044444440444444444409014409910
-- 127:01990441900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0fff000ff0f0f00f00f0030f0030000000000f0ffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000914409910
-- 128:0199040911011111110111111101111111011111110111111101111111011111110111111101111111011111110111111100f00110f0100fff0030ff030ff0011101111100f00f01110111111101111111011111110111111101111111011111110111111101111111011111110111111101111190409910
-- 129:0199099044044444440444444404444444044444440444444404444444044444440444444404444444044444440444444400f04440f0440f000f0000f0000f014404444440f00f04440444444404444444044444440444444404444444044444440444444404444444044444440444444404444409909910
-- 130:004404944404444444044444440444444404444444044444440444444404444444044444440444444404444444044444440fff0440f0440ffff00fff00fff001440444440ff00f04440444444404444444044444440444444404444444044444440444444404444444044444440444444404444449404400
-- 131:099990000040000000400000004000000040000000400000004000000040000000400000004000000040000000400000004000000000000000033000330000010040000000000000004000000040000000400000004000000040000000400000004000000040000000400000004000000040000000099990
-- 132:094994999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999991333333333333199999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999499490
-- 133:094494999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999991777777777777199999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999494490
-- 134:199990111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110777777777777011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111099991
-- 135:110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011
-- </SCREEN>

-- <PALETTE>
-- 000:140c1c44243430346d4e4a4e854c30346524d04648757161597dced27d2c8595a16daa2cd2aa996dc2cadad45edeeed6
-- </PALETTE>

