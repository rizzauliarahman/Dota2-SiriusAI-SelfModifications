-----------------
--英雄：帕吉
--技能：腐烂
--键位：W
--类型：无目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('pudge_rot')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange, abilityAhg;

nKeepMana = 400 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--是否拥有蓝杖
abilityAhg = J.IsItemAvailable("item_ultimate_scepter"); 

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("item_aether_lens");
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end
    
--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
	bot:Action_ClearActions(false)
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
	   or ability:IsTrained() 
	   or ability:IsHidden() == false
	then 
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
    
    local nCastPoint = ability:GetCastPoint();
	local manaCost   = ability:GetManaCost();
	local nRadius    = ability:GetSpecialValueInt('rot_radius');
	
	
	if ( J.IsPushing(bot) or J.IsDefending(bot) ) and bot:GetHealth() > 0.65*bot:GetMaxHealth() 
	then
		local creeps = bot:GetNearbyLaneCreeps(nRadius, true);
		if #creeps >= 4 and ability:GetToggleState() == false then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if J.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if J.IsValidHero(target) 
			and J.CanCastOnNonMagicImmune(target) 
			and bot:IsFacingLocation(target:GetLocation(),15) 
		then
			if J.IsInRange(bot, target, nRadius)	
				and ability:GetToggleState() == false 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			elseif J.IsInRange(bot, target, nRadius) == false 
				and ability:GetToggleState() == true 	
			then	
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	else
		local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
		if (( J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) ) or #enemies == 0 )
			and ability:GetToggleState() == true
		then 
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

return X;