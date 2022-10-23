-----------------
--英雄：兽王
--技能：野性呼唤战鹰
--键位：E
--类型：指向地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('beastmaster_call_of_the_wild_hawk')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange, abilityAhg;

nKeepMana = 250 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

local ListRune = {
	RUNE_BOUNTY_1,
	RUNE_BOUNTY_2,
	RUNE_BOUNTY_3,
	RUNE_BOUNTY_4,
	RUNE_POWERUP_1,
	RUNE_POWERUP_2
}


local hawkLocDire = {
	Vector(-3788.000000, -280.000000, 0.000000),
	Vector(-166.000000, -4568.000000, 0.000000),
	GetRuneSpawnLocation(ListRune[1]),
	GetRuneSpawnLocation(ListRune[2]),
	GetRuneSpawnLocation(ListRune[3]),
	GetRuneSpawnLocation(ListRune[4]),
	GetRuneSpawnLocation(ListRune[5]),
	GetRuneSpawnLocation(ListRune[6])
}

local hawkLocRadiant = {
	Vector(-943.000000, 3546.000000, 0.000000),
	Vector(3136.000000, -370.000000, 0.000000),
	GetRuneSpawnLocation(ListRune[1]),
	GetRuneSpawnLocation(ListRune[2]),
	GetRuneSpawnLocation(ListRune[3]),
	GetRuneSpawnLocation(ListRune[4]),
	GetRuneSpawnLocation(ListRune[5]),
	GetRuneSpawnLocation(ListRune[6])
}

--是否拥有蓝杖
abilityAhg = J.IsItemAvailable("item_ultimate_scepter"); 

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("item_aether_lens");
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end

--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
	if castTarget ~= nil then
        X.Compensation()
        bot:ActionQueue_UseAbilityOnLocation( ability, castTarget ) --使用技能
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
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
    
	local roll = RandomInt(1,8);
	if GetTeam() == TEAM_RADIANT then
		return BOT_ACTION_DESIRE_MODERATE, hawkLocRadiant[roll];
	else
		return BOT_ACTION_DESIRE_MODERATE, hawkLocDire[roll];
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


return X;