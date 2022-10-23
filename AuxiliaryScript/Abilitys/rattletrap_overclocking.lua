-----------------
--英雄：发条技师
--技能：超速运转
--键位：D
--类型：无目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('rattletrap_overclocking')
local abilities = {
	[1] = bot:GetAbilityByName('rattletrap_battery_assault'),
	[2] = bot:GetAbilityByName('rattletrap_power_cogs'),
	[3] = bot:GetAbilityByName('rattletrap_rocket_flare'),
	[4] = bot:GetAbilityByName('rattletrap_hookshot'),
}
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList;

nKeepMana = 240 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
	X.Compensation() 
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
       or bot:HasScepter() == false
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end

    local nCastPoint = ability:GetCastPoint();
	local manaCost   = ability:GetManaCost();
	
	if J.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if J.IsValidHero(target) 
			and J.CanCastOnNonMagicImmune(target)  
			and J.IsInRange(bot, target, 600) == true	
		then
			local n_ability = 0;
			for i=1, 4 do
				if abilities[i] ~= nil 
					and abilities[i]:IsTrained() == true
					and CheckFlag(abilities[i]:GetBehavior(), ABILITY_BEHAVIOR_PASSIVE) == false
					and CheckFlag(abilities[i]:GetBehavior(), ABILITY_BEHAVIOR_HIDDEN) == false
				then
					if abilities[i]:GetCooldownTimeRemaining() > 3 then
						n_ability = n_ability + 1;
					end
				end
			end
			if  n_ability >= 3 then
				return BOT_ACTION_DESIRE_ABSOLUTE;
			end
		end
	end
	
    return BOT_ACTION_DESIRE_NONE;
    
end

function CheckFlag(bitfield, flag)
    return ((bitfield/flag) % 2) >= 1;
end

return X;