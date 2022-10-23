-----------------
--英雄：修补匠
--技能：再装填
--键位：R
--类型：无目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('tinker_rearm')
local abilityFB = bot:GetAbilityByName('tinker_laser')
local abilitySC = bot:GetAbilityByName('tinker_heat_seeking_missile')
local abilityTS = bot:GetAbilityByName('tinker_march_of_the_machines')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList;

nKeepMana = 180 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
    local channleTime = ability:GetSpecialValueFloat("channel_tooltip");
    X.Compensation()
    bot:Action_ClearActions(true)
	bot:ActionQueue_UseAbility( ability )
    bot:ActionQueue_Delay( channleTime + 0.25 )
    
end

--补偿功能
function X.Compensation()
    local sr=IsItemAvailable("item_soul_ring")
		
    if bot:GetHealth() > 2 * 150 and nMP < 0.90
    then
        bot:Action_UseAbility( sr );
	end
end

--技能释放欲望
function X.Consider()
	-- 确保技能可以使用
    if ability == nil
       or ability:IsNull()
       or bot:HasModifier("modifier_tinker_rearm")
       or not ability:IsFullyCastable()
       or ability:IsInAbilityPhase()
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
    --[[
	if castFBDesire > 0 or castSCDesire > 0 then
		return BOT_ACTION_DESIRE_NONE;
	end
	]]
	local nManaCost = ability:GetManaCost()
	local botMana = bot:GetMana();
	
	if  not TravelOffCD() and bot:DistanceFromFountain() > 1000 then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	if J.IsGoingOnSomeone(bot) and bot:DistanceFromFountain() > 0
	then
		local npcTarget = bot:GetTarget();
		if ( botMana >= nManaCost and J.IsValidHero(npcTarget) and not abilityFB:IsCooldownReady() and not abilitySC:IsCooldownReady() 
		     and J.IsInRange(npcTarget, bot, 1000)   ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if ( J.IsDefending(bot) ) and abilitySC:GetCooldownTimeRemaining() > 3
	then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	if ( J.IsDefending(bot) or J.IsPushing(bot) ) and bot:DistanceFromFountain() > 0
	then
		if ( botMana >= nManaCost and not abilityTS:IsCooldownReady()  ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
    return BOT_ACTION_DESIRE_NONE;
    
end

function IsItemAvailable(item_name)
    for i = 0, 5 do
        local item = bot:GetItemInSlot(i);
		if (item~=nil) then
			if(item:GetName() == item_name) then
				return item;
			end
		end
    end
    return nil;
end

function TravelOffCD()
	local bot1=IsItemAvailable("item_travel_boots");
	local bot2=IsItemAvailable("item_travel_boots_2");
	local tpscroll=bot:GetItemInSlot(15);
	if ( bot1~=nil or bot2~=nil ) and tpscroll~=nil and tpscroll:IsCooldownReady() == false then
		return false;
	end
	return true;
end

return X;