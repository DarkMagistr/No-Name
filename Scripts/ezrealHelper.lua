local player = GetMyHero()
if player.charName == "Ezreal" then

--[[
	Ezreal Helper v1.1 by ikita
	Auto Q after each auto-atk
]]

--SETTINGS
local qAfterAA = true
local alwaysQ = false
local alwaysQKey = 84 -- T
local qWidth = 150 -- can change
local blocked = false
local justAA = false
local AAtimer = 0
local waitTime = 100 --if you have good ping, set it to a value higher than 100 ms. if you have bad ping then change this to zero.
--[[		Code		]]
function altDoFile(name)
    dofile(debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2)..name)
end

altDoFile("libs/target_selector.lua")
altDoFile("libs/vector.lua")
altDoFile("libs/linear_prediction.lua")

local lp = LinearPrediction:new(900,1.2)
local ts = TargetSelector:new(TARGET_LOW_HP,900)
ts.buildarray()


function SpellE(object, spellName)
	if player:CanUseSpell(_Q) == READY and object.name == player.name and ((spellName == "EzrealBasicAttack") or (spellName == "EzrealBasicAttack2") or (spellName == "EzrealCritAttack")) then
		justAA = true
		
		AAtimer = GetTickCount()
	end
end
function tickHandlerE()
	ts:tick()
    lp:tick()
    if GetTickCount() - AAtimer > 600 then
    	justAA = false
    end
	if ts.target ~= nil and player:CanUseSpell(_Q) == READY then
	    predic = lp:getPredictionFor(ts.target.name)
	    blocked = false
	    for k = 1, objManager.maxObjects do
        	local minionObjectE = objManager:GetObject(k)
        	if minionObjectE ~= nil and string.find(minionObjectE.name,"Minion_") == 1 and minionObjectE.team ~= player.team and minionObjectE.dead == false then
--        		--Calculate minion block
--        		if player:GetDistance(minionObjectE) + math.sqrt((predic.x - minionObjectE.x)*(predic.x - minionObjectE.x) + (predic.z - minionObjectE.z)*(predic.z - minionObjectE.z)) 
--        		< math.sqrt((predic.x - player.x)*(predic.x - player.x) + (predic.z - player.z)*(predic.z - player.z)) + 350 then
--        			blocked = true
--        			PrintChat("blocked")
--        		end
        		--Calculate minion block
        		if  player:GetDistance(minionObjectE) < 900 then
        			--Player coordinates
        			ex = player.x
        			ez = player.z
        			--End coordinates
        			tx = predic.x
        			tz = predic.z
        			--Distance apart
        			dx = ex - tx
        			dz = ez - tz
        			--Find (z = mx + c) of Q
        			if dx ~= 0 then
        				m = dz/dx
        				c = ez - m*ex
        			end
        			--Minion coordinates:
        			mx = minionObjectE.x
        			mz = minionObjectE.z
        			
        			--Distance from point to line
        			distanc = (math.abs(mz - m*mx - c))/(math.sqrt(m*m+1))
        			if distanc < qWidth then
        				blocked = true
        			end
            	end
        	end
    	end
		if blocked == false and alwaysQ then
        	CastSpell(_Q, predic.x, predic.z)
        end
        if blocked == false and qAfterAA and justAA and GetTickCount() - AAtimer > waitTime then
        	CastSpell(_Q, predic.x, predic.z)
        	justAA = false
        end
	end
end

function HotkeyE(msg,key)
	if msg == KEY_DOWN then 
    	if key == alwaysQKey then
        	if alwaysQ then
            	alwaysQ = false
                PrintChat(" >> Always Q disabled!")  
            else
                alwaysQ = true
                PrintChat(" >> Always Q enabled!")
            end     
        end
    end   
end


if player.charName == "Ezreal" then 
	BoL:addTickHandler(tickHandlerE,10)
	BoL:addMsgHandler(HotkeyE)
	BoL:addProcessSpellHandler(SpellE)
	PrintChat(" >> Ezreal Helper loaded!")
end
	
	
end