-----------------
--英雄：帕克
--技能：相位转移
--键位：E
--类型：无目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('puck_phase_shift')
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
	   or bot:IsRooted()
       or bot:HasModifier("modifier_puck_phase_shift")
	then
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
	
	local duration = ability:GetSpecialValueInt('duration');
	
	if ( J.IsRetreating(bot) and ( bot:WasRecentlyDamagedByAnyHero(3.0) or bot:WasRecentlyDamagedByTower(3.0) ) )
	then
		local blink = bot:GetItemInSlot(bot:FindItemSlot('item_blink'));
		if blink ~= nil and  blink:GetCooldownTimeRemaining() < duration then
			return BOT_ACTION_DESIRE_MODERATE;
		end
		if ShouldDodge(bot, 200, 'retreat') then
			return BOT_ACTION_DESIRE_MODERATE;
		end
		local pro = GetLinearProjectiles();
		for _,pr in pairs(pro)
		do
			if pr.ability:GetName() == "puck_illusory_orb" then
				local ProjDist = GetUnitToLocationDistance(bot, pr.location);
				if ProjDist < 200 then
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
			and J.IsInRange(bot, target,  1300)
		then
			if ShouldDodge(bot, 200, 'attack') then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
    
	return BOT_ACTION_DESIRE_NONE;

end

function ShouldDodge(bot, range, mode)
	local incProj = bot:GetIncomingTrackingProjectiles()
	for _,p in pairs(incProj)
	do
		if ( mode == 'attack' and p.is_dodgeable and p.is_attack == false and GetUnitToLocationDistance(bot, p.location) <= range )
		or ( mode == 'retreat' and bot:GetHealth() > 0.20*bot:GetMaxHealth() and p.is_attack == false and GetUnitToLocationDistance(bot, p.location) <= range )	
		or ( mode == 'retreat' and bot:GetHealth() < 0.20*bot:GetMaxHealth() and J.IsValidHero(p.caster) and p.is_attack == true and GetUnitToLocationDistance(bot, p.location) <= range )	
		then
			return true;
		end
	end
	return false;
end

return X;