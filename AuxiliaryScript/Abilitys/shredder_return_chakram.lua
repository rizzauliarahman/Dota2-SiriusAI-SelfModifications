-----------------
--英雄：伐木机
--技能：收回锯齿飞轮
--键位：R
--类型：无目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('shredder_return_chakram')
local abilityCH = bot:GetAbilityByName('shredder_chakram')

local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList;

nKeepMana = 400 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
    bot:Action_UseAbility( ability )
	bot.ultLoc = Vector(-6376, 6419, 0)
end

--补偿功能
function X.Compensation()
    J.SetQueuePtToINT(bot, true)--临时补充魔法，使用魂戒
end

--技能释放欲望
function X.Consider()
	-- 确保技能可以使用
    if ability == nil
       or bot.ultLoc == 0
	   or ability:IsNull()
       or not ability:IsFullyCastable()
       or ability:IsHidden()
       or DotaTime() < bot.ultTime1 + bot.ultETA1 or StillTraveling(1)
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	local nRadius = abilityCH:GetSpecialValueFloat( "radius" );
	local nDamage = abilityCH:GetSpecialValueInt("pass_damage");
	local nManaCost = abilityCH:GetManaCost();
	
	if bot:GetMana() < 100 or GetUnitToLocationDistance(bot, bot.ultLoc) > 1600 then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	if  J.IsDefending(bot) or J.IsPushing(bot) 
	then
		local nUnits = 0;
		local nLowHPUnits = 0;
		local NearbyUnits = bot:GetNearbyLaneCreeps(1300, true);
		for _,c in pairs(NearbyUnits)
		do 
			if GetUnitToLocationDistance(c, bot.ultLoc) < nRadius  then
				nUnits = nUnits + 1;
			end
			if GetUnitToLocationDistance(c, bot.ultLoc) < nRadius and c:GetHealth() <= nDamage then
				nLowHPUnits = nLowHPUnits + 1;
			end
		end
		if nUnits == 0 or nLowHPUnits >= 1  then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if  bot:GetActiveMode() == BOT_MODE_RETREAT or J.IsGoingOnSomeone(bot) 
	then
		local nUnits = 0;
		local nLowHPUnits = 0;
		local NearbyUnits = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
		for _,c in pairs(NearbyUnits)
		do 
			if GetUnitToLocationDistance(c, bot.ultLoc) < nRadius  then
				nUnits = nUnits + 1;
			end
			if GetUnitToLocationDistance(c, bot.ultLoc) < nRadius and c:GetHealth() <= nDamage / 2 then
				nLowHPUnits = nLowHPUnits + 1;
			end
		end
		if nUnits == 0 or nLowHPUnits >= 1 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local creeps = bot:GetNearbyLaneCreeps(1600, true)
	if #enemies == 0 and #creeps == 0 then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
    return BOT_ACTION_DESIRE_NONE;
    
end

function StillTraveling(cType)
	local proj = GetLinearProjectiles();
	for _,p in pairs(proj)
	do
		if p ~= nil and (( cType == 1 and p.ability:GetName() == "shredder_chakram" ) or (  cType == 2 and p.ability:GetName() == "shredder_chakram_2" ) ) then
			return true; 
		end
	end
	return false;
end

return X;