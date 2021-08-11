-- title:  game title
-- author: game developer
-- desc:   short description
-- script: lua

function TIC()
	cls()
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

			for ib,b in pairs(ents) do
				if b.type=="crate" then
					if col2(b.x,b.y,b.w,b.h,v.x+v.vx,v.y,15,8) then
						v.vx=0
					end
					if col2(b.x,b.y,b.w,b.h,v.x,v.y+v.vy,15,8) then
						v.vy=0
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

function drawCrate(self)
	spr(self.spr,self.x-mx,self.y-my,6,1,0,0,2,2)
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

			local mapx,mapy=x-mx,y-my
			--[[
			if (mapx%30==14 or mapx%30==15) and mapy%17>=15 then mset(x,y,8) end
			if (mapy%17==7 or mapy%17==8) and (x>2 and mapx%30>=28 or mapx%30<=1) then mset(x,y,8) end
			--]]
		end
	end
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
		if v.type=="crate" then

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
end

-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

