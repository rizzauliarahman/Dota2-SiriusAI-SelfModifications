-----------------
--英雄：剧毒术士
--技能：共鸣脉冲
--键位：R
--类型：无目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('venomancer_poison_nova')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 160 --魔法储量
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
function X.Release()
	X.Compensation() 
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
	then
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
	
	-- Get some of its values
	local nRadius = ability:GetSpecialValueInt( "radius" );
	local nCastRange = 0;
	local nDamage = ability:GetAbilityDamage();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and J.CanCastOnNonMagicImmune(npcEnemy) )
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	if J.IsInTeamFight(bot, 1200) 
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius - 200, true, BOT_MODE_NONE  );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if  J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget)
		then
			local EnemyHeroes = bot:GetNearbyHeroes( nRadius - 150, true, BOT_MODE_NONE );
			if ( J.IsInRange(npcTarget, bot, nRadius - 200) and EnemyHeroes ~= nil and #EnemyHeroes >= 2 ) or ( EnemyHeroes ~= nil and #EnemyHeroes >= 3 )
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;
	
end

return X;