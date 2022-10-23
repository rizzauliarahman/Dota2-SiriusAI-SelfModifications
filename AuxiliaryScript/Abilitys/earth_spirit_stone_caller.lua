-----------------
--英雄：大地之灵
--技能：残岩
--键位：D
--类型：指向地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('earth_spirit_stone_caller')
local abilityR = bot:GetAbilityByName('earth_spirit_magnetize')

local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange, stoneCast, stoneCastGap;

stoneCast = -100;
stoneCastGap = 1.0;

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
    if castTarget ~= nil then
        X.Compensation() 
        bot:Action_UseAbilityOnLocation( ability, castTarget );
		stoneCast = DotaTime();
    end
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
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
    end
    
	if DotaTime() < stoneCast + stoneCastGap then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange  = ability:GetCastRange( );
	local nRadius     = abilityR:GetSpecialValueInt('rock_search_radius');
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange - 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if npcEnemy:HasModifier('modifier_earth_spirit_magnetize') 
		then
			local duration = npcEnemy:GetModifierRemainingDuration(npcEnemy:GetModifierByName('modifier_earth_spirit_magnetize'));
			if duration < 1.0 or CanChainMag(npcEnemy, nRadius) then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function CanChainMag(target, radius)
	local enemies = target:GetNearbyHeroes(radius, false, BOT_MODE_NONE);
	for _,enemy in pairs(enemies)
	do
		if not enemy:HasModifier('modifier_earth_spirit_magnetize') then
			return true
		end	
	end
	return false;
end

return X;