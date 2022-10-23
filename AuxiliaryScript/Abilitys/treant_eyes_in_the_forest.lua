-----------------
--英雄：树精卫士
--技能：丛林之眼
--键位：D
--类型：指向单位
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('treant_eyes_in_the_forest')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList;

local castEiFTime = -90;

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
    if castTarget ~= nil then
		X.Compensation()
		castEiFTime = DotaTime();
        bot:Action_UseAbilityOnTree( ability, castTarget ) --使用技能
    end
end

--补偿功能
function X.Compensation()
    J.SetQueuePtToINT(bot, true)--临时补充魔法，使用魂戒
end

--技能释放欲望
function X.Consider()
	-- Make sure it's castable
	if ( not ability:IsFullyCastable() 
		or bot:HasScepter() == false 
		or bot:DistanceFromFountain() < 1000 
		or DotaTime() < castEiFTime + 3.0 ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	

	-- Get some of its values
	local nRadius = ability:GetCastRange();

	local trees = bot:GetNearbyTrees(nRadius + 200);

	if #trees >= 1 then
		for i=1, #trees do
			if ( IsLocationVisible(GetTreeLocation(trees[i])) or IsLocationPassable(GetTreeLocation(trees[i])) ) then
				return BOT_ACTION_DESIRE_HIGH, trees[i];
			end
		end
	end
	
	return 0;
end

return X;