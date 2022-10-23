-----------------
--英雄：帕克
--技能：灵动之翼
--键位：D
--类型：无目标
--前置：puck_illusory_orb
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')
--前置技能
local Q = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/puck_illusory_orb')

--初始数据
local ability = bot:GetAbilityByName('puck_ethereal_jaunt')
local abilityW = bot:GetAbilityByName('puck_waning_rift')

local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 400 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("item_aether_lens");
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end
    
--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
	bot:ActionQueue_UseAbility( ability ) --使用技能
end

--补偿功能
function X.Compensation()
    J.SetQueuePtToINT(bot, true)--临时补充魔法，使用魂戒
end

--技能释放欲望
function X.Consider()

	-- 确保技能可以使用
    if ability == nil
	   or ability:IsNull()
       or not ability:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
	
	local nRadius    = abilityW:GetSpecialValueInt('radius');
	local nRange = bot:GetAttackRange();
	
	if ( J.IsRetreating(bot) and ( bot:WasRecentlyDamagedByAnyHero(5.0) or bot:WasRecentlyDamagedByTower(5.0) ) )
	then
		local loc = J.GetEscapeLoc();
		local bot_dist = GetUnitToLocationDistance(bot, loc);
		local pro = GetLinearProjectiles();
		for _,pr in pairs(pro)
			do
				if pr.ability:GetName() == "puck_illusory_orb" then
					local ProjDist = GetUnitToLocationDistance(bot, pr.location);
					if GetDistance(pr.location, loc) < bot_dist and ProjDist > 625 then
						return BOT_ACTION_DESIRE_MODERATE;
					end
				end	
			end
	end
	
	if J.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if J.IsValidHero(target) 
			and J.CanCastOnNonMagicImmune(target) 
		then
			local pro = GetLinearProjectiles();
			if CanBeCast(abilityW) == true then
				local allies = target:GetNearbyHeroes(1200, true, BOT_MODE_NONE);
				local enemies = target:GetNearbyHeroes(1200, false, BOT_MODE_NONE);
				if ( enemies ~= nil and allies ~= nil and #allies >= #enemies )  
				then
					for _,pr in pairs(pro)
					do
						if pr.ability:GetName() == "puck_illusory_orb" then
							local ProjTgt = GetUnitToLocationDistance(target, pr.location);
							local ProjBot = GetUnitToLocationDistance(bot, pr.location);
							local TgtBot = GetUnitToUnitDistance(bot, TgtBot);
							if ProjBot > TgtBot and ProjTgt < nRadius - 50 then
								return BOT_ACTION_DESIRE_MODERATE;
							end
						end	
					end
				end
			else
				if J.IsInRange(bot, target,  nRange) == false then
					local allies = target:GetNearbyHeroes(1200, true, BOT_MODE_NONE);
					local enemies = target:GetNearbyHeroes(1200, false, BOT_MODE_NONE);
					if ( enemies ~= nil and allies ~= nil and #allies >= #enemies ) 
					then
						for _,pr in pairs(pro)
						do
							if pr.ability:GetName() == "puck_illusory_orb" then
								local ProjTgt = GetUnitToLocationDistance(target, pr.location);
								local ProjBot = GetUnitToLocationDistance(bot, pr.location);
								local TgtBot = GetUnitToUnitDistance(bot, TgtBot);
								if ProjBot > TgtBot and ProjTgt < 0.5*nRange then
									return BOT_ACTION_DESIRE_MODERATE;
								end
							end	
						end
					end
				end
			end
		end
	end
    
	return BOT_ACTION_DESIRE_NONE;

end

function GetDistance(s, t)
    return math.sqrt((s[1]-t[1])*(s[1]-t[1]) + (s[2]-t[2])*(s[2]-t[2]));
end

function CanBeCast(ability)
	return ability:IsTrained() and ability:IsFullyCastable() and ability:IsHidden() == false;
end

return X;