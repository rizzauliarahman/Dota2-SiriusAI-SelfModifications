-----------------
--英雄：林海飞霞
--技能：爆栗出击
--键位：Q
--类型：指向目标/地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('hoodwink_acorn_shot')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 300 --魔法储量
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
		if castTarget['tType'] == 'unit' then
			bot:ActionQueue_UseAbilityOnEntity(ability, castTarget['qTarget']);
		else 
			bot:ActionQueue_UseAbilityOnLocation(ability, castTarget['qTarget']);
		end	
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
	
	if  CanBeCast(ability) == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastPoint = ability:GetCastPoint();
	local manaCost   = ability:GetManaCost();
	local nRadius    = ability:GetSpecialValueInt('bounce_range');
	local nBounce    = ability:GetSpecialValueInt('bounce_count');
	local nCastRange    = GetProperCastRange(false, bot, ability:GetCastRange());
	
	if ( J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) )
	then
		local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		for i=1,#enemies do
			if J.IsValidHero(enemies[i]) 
				and J.CanCastOnNonMagicImmune(enemies[i]) 
				and J.IsDisabled(enemies[i]) == false
			then
				return BOT_ACTION_DESIRE_MODERATE, {
					['qTarget'] = enemies[1]:GetLocation(),
					['tType'] = 'point',
				};
			end
		end
	end

	if ( J.IsPushing(bot) or J.IsDefending(bot) ) and  CanSpamSpell(manaCost) 
	then
		local creeps = bot:GetNearbyLaneCreeps(nCastRange, true);
		if #creeps >= nBounce and J.CanCastOnNonMagicImmune(creeps[1]) then
			return BOT_ACTION_DESIRE_MODERATE, {
				['qTarget'] = creeps[1]:GetLocation(),
				['tType'] = 'point',
			};
		end
	end

	if J.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if J.IsValidHero(target) 
			and J.CanCastOnNonMagicImmune(target) 
			and J.IsInRange(bot, target, nCastRange) 
			and J.IsDisabled(target) == false
		then
			local enemies = target:GetNearbyHeroes(0.75*nRadius, false, BOT_MODE_NONE);
			if #enemies > 1 then
				return BOT_ACTION_DESIRE_MODERATE, {
					['qTarget'] = target:GetLocation(),
					['tType'] = 'point',
				};
			end
			local creeps = target:GetNearbyLaneCreeps(0.75*nRadius, false);
			if #creeps > 0 then
				return BOT_ACTION_DESIRE_MODERATE, {
					['qTarget'] = target:GetLocation(),
					['tType'] = 'point',
				};	
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function GetProperCastRange(bIgnore, hUnit, abilityCR)
	local attackRng = hUnit:GetAttackRange();
	if bIgnore then
		return abilityCR;
	elseif abilityCR <= attackRng then
		return attackRng + 200;
	elseif abilityCR + 200 <= 1600 then
		return abilityCR + 200;
	elseif abilityCR > 1600 then
		return 1600;
	else
		return abilityCR;
	end
end

function CanBeCast(ability)
	return ability:IsTrained() and ability:IsFullyCastable() and ability:IsHidden() == false;
end

function CanSpamSpell(manaCost)
	local initialRatio = 1.0;
	if manaCost < 100 then
		initialRatio = 0.6;
	end
	return ( bot:GetMana() - manaCost ) / bot:GetMaxMana() >= ( initialRatio - bot:GetLevel()/(2*25) );
end

return X;