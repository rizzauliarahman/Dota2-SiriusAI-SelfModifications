-----------------
--英雄：米拉娜
--技能：月神之箭
--键位：W
--类型：指向地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('mirana_arrow')
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
    if castTarget ~= nil then
        X.Compensation()
		bot:Action_UseAbilityOnLocation( ability, castTarget );
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
	local nRadius = ability:GetSpecialValueInt( "arrow_width" );
	local speed = ability:GetSpecialValueInt( "arrow_speed" );
	local nDamage = ability:GetAbilityDamage();
	local nCastRange = ability:GetSpecialValueInt("arrow_range")
	local nCastPoint = ability:GetCastPoint();

	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() and  not IsEnemyCreepBetweenMeAndTarget(bot, npcEnemy, npcEnemy:GetLocation(), nRadius) ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
		end
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if  J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange)
		then
			local distance = GetUnitToUnitDistance(npcTarget, bot)
			local moveCon = npcTarget:GetMovementDirectionStability();
			local pLoc = npcTarget:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
			if moveCon < 1 then
				pLoc = npcTarget:GetLocation();
			end
			if not IsEnemyCreepBetweenMeAndTarget(bot, npcTarget, pLoc, nRadius)  then
				return BOT_ACTION_DESIRE_MODERATE, pLoc;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function IsEnemyCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation();
	local vEnd = vLoc;
	local creeps = hSource:GetNearbyLaneCreeps(1600, true);
	for i,creep in pairs(creeps) do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then
			return true;
		end
	end
	creeps = hTarget:GetNearbyLaneCreeps(1600, false);
	for i,creep in pairs(creeps) do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then
			return true;
		end
	end
	return false;
end

return X;