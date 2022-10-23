-----------------
--英雄：全能骑士
--技能：洗礼
--键位：Q
--类型：指向目标
--作者：望天的稻草
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('omniknight_purification')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

if bot.lastCheck == nil then bot.lastCheck = -90; end

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
	
	local nCastRange = GetProperCastRange(false, bot, ability:GetCastRange());
	local nCastPoint = ability:GetCastPoint();
	local manaCost   = ability:GetManaCost();
	local nRadius    = ability:GetSpecialValueInt( "radius" );
	local nDamage    = ability:GetSpecialValueInt( "heal" );
	
	if J.IsRetreating(bot) and bot:HasModifier('modifier_omniknight_repel') == false and J.CanCastOnNonMagicImmune(bot) 
	then
		local enemies = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE);
		if #enemies > 0 and bot:GetHealth() <= (0.2+(#enemies*0.1))*bot:GetMaxHealth() then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
	end

	if DotaTime() >= bot.lastCheck + 2.0 then 
		local weakest = nil;
		local minHP = 100000;
		local allies = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE);
		if #allies > 0 then
			for i=1,#allies do
				if J.CanCastOnNonMagicImmune(allies[i])
				   and allies[i]:WasRecentlyDamagedByAnyHero(2.0) and allies[i]:GetAttackTarget() == nil
				   and allies[i]:GetHealth() <= minHP
     			   and allies[i]:GetHealth() <= 0.55*allies[i]:GetMaxHealth() 
				then
					weakest = allies[i];
					minHP = allies[i]:GetHealth();
				end
			end
		end
		if weakest ~= nil then
			return BOT_ACTION_DESIRE_HIGH, weakest;
		end
		bot.lastCheck = DotaTime();
	end
	
	if J.IsGoingOnSomeone(bot) and bot:GetHealth() + nDamage <= bot:GetMaxHealth()
	then
		local target = bot:GetTarget();
		if J.IsValidHero(target) and J.CanCastOnNonMagicImmune(target) and J.IsInRange(target, bot, nRadius) 
		then
			return BOT_ACTION_DESIRE_HIGH, bot;
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

return X;