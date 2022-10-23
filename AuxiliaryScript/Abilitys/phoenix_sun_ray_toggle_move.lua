-----------------
--英雄：凤凰
--技能：切换移动状态
--键位：D
--类型：无目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('phoenix_sun_ray_toggle_move')
local abilityE = bot:GetAbilityByName('phoenix_sun_ray')

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
	if castTarget == "on" then
		if not ability:GetToggleState() then
			bot:Action_UseAbility( ToggleMovement );
		end
	else
		if ability:GetToggleState() then
			bot:Action_UseAbility( ToggleMovement );
		end
	end
	return;
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
	   or ability:IsHidden()
	   or not bot:HasModifier("modifier_phoenix_sun_ray")
	then 
		return BOT_ACTION_DESIRE_NONE, ''; --没欲望
	end
	
	local nCastRange = abilityE:GetCastRange()
	local nRadius = abilityE:GetSpecialValueInt( "radius" );
	local nCastPoint = abilityE:GetCastPoint();
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, bot ) >= ( nCastRange / 2 ) + 200 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, "on";
		end
	end
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, bot ) < ( nCastRange / 2 ) + 200 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, "off";
		end
	end
    
	return BOT_ACTION_DESIRE_NONE, '';

end

return X;