-----------------
--英雄：寒冬飞龙
--技能：碎裂冲击
--键位：W
--类型：指向目标
--作者：Krizalium
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('winter_wyvern_splinter_blast')
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
function X.Release(castTarget)
    if castTarget ~= nil then
        X.Compensation() 
        bot:ActionQueue_UseAbilityOnEntity( ability, castTarget ) --使用技能
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

	-- Get some of its values
	local nCastRange = ability:GetCastRange();
	local nDamage = ability:GetAbilityDamage();
	local nRadius = ability:GetSpecialValueInt( "split_radius" );
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and J.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				local tableNearbyEnemyHeroes = npcEnemy:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
				local tableNearbyEnemyCreeps = npcEnemy:GetNearbyLaneCreeps( nRadius, false );
				for _, h in pairs(tableNearbyEnemyHeroes) 
				do
					if h:GetUnitName() ~= npcEnemy:GetUnitName() and J.CanCastOnNonMagicImmune(h) 
					then
						return BOT_ACTION_DESIRE_HIGH, h;
					end
				end
				for _, c in pairs(tableNearbyEnemyCreeps) 
				do
					if J.CanCastOnNonMagicImmune(c)
					then
						return BOT_ACTION_DESIRE_HIGH, c;
					end
				end
			end
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if J.IsDefending(bot) or J.IsPushing(bot) and bot:GetMana()/bot:GetMaxMana() > 0.65
	then
		local tableNearbyEnemyCreeps = bot:GetNearbyLaneCreeps( nCastRange, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 4 and tableNearbyEnemyCreeps[2] ~= nil
		then
			return BOT_ACTION_DESIRE_MODERATE, tableNearbyEnemyCreeps[2];
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange+200)
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			local tableNearbyEnemyCreeps = npcTarget:GetNearbyLaneCreeps( nRadius, false );
			for _,h in pairs(tableNearbyEnemyHeroes) 
			do
				if h:GetUnitName() ~= npcTarget:GetUnitName() and J.CanCastOnNonMagicImmune(h)
				then
					return BOT_ACTION_DESIRE_HIGH, h;
				end
			end
			for _,c in pairs(tableNearbyEnemyCreeps) 
			do
				if J.CanCastOnNonMagicImmune(c)
				then
					return BOT_ACTION_DESIRE_HIGH, c;
				end
			end
		end
	end

	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;