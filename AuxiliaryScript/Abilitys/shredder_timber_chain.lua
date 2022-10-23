-----------------
--英雄：伐木机
--技能：伐木锯链
--键位：W
--类型：指向地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('shredder_timber_chain')
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
        if castTarget['castType'] == "tree" then
            bot:ActionQueue_UseAbilityOnLocation( ability, GetTreeLocation(castTarget['castTree']) ) --使用技能
        else
            bot:ActionQueue_UseAbilityOnLocation( ability, castTarget['castTree'] ) --使用技能
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
		return BOT_ACTION_DESIRE_NONE, {
            ['castType'] = 'loc',
            ['castTree'] = 0,
        }; --没欲望
	end
    
	-- Get some of its values
	local nRadius = ability:GetSpecialValueInt( "chain_radius" );
	local nSpeed = ability:GetSpecialValueInt( "speed" );
	local nCastRange = GetProperCastRange(false, bot, ability:GetCastRange());
	local nDamage = ability:GetSpecialValueInt("damage");

	if J.IsStuck(bot)
	then
		return BOT_ACTION_DESIRE_HIGH, {
            ['castType'] = 'loc',
            ['castTree'] = J.Site.GetXUnitsTowardsLocation( bot,GetAncient(GetTeam()):GetLocation(), nCastRange ),
        };
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot) and bot:DistanceFromFountain() > 1000
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 then
			local BRTree = GetBestRetreatTree(bot, nCastRange);
			if BRTree ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, {
                    ['castType'] = 'loc',
                    ['castTree'] = BRTree,
                };
			end
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if ( J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange) and
			not AreTreesBetween( npcTarget:GetLocation(),nRadius ) ) 
		then
			
			local BTree = GetBestTree(bot, npcTarget, nCastRange, nRadius);
			if BTree ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, {
                    ['castType'] = 'tree',
                    ['castTree'] = BTree,
                };
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, {
        ['castType'] = 'loc',
        ['castTree'] = 0,
    };
	
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

function AreTreesBetween(loc,r)
	local trees=bot:GetNearbyTrees(GetUnitToLocationDistance(bot,loc));
	--check if there are trees between us
	for _,tree in pairs(trees) do
		local x=GetTreeLocation(tree);
		local y=bot:GetLocation();
		local z=loc;
		
		if x~=y then
			local a=1;
			local b=1;
			local c=0;
		
			if x.x-y.x ==0 then
				b=0;
				c=-x.x;
			else
				a=-(x.y-y.y)/(x.x-y.x);
				c=-(x.y + x.x*a);
			end
		
			local d = math.abs((a*z.x+b*z.y+c)/math.sqrt(a*a+b*b));
			if d<=r and GetUnitToLocationDistance(bot,loc) > J.Site.GetDistance(x,loc)+50 then
				return true;
			end
		end
	end
	return false;
end

function GetBestTree(bot, enemy, nCastRange, hitRadios)
   
	--find a tree behind enemy
	local bestTree=nil;
	local mindis=10000;

	local trees=bot:GetNearbyTrees(nCastRange);
	
	for _,tree in pairs(trees) do
		local x=GetTreeLocation(tree);
		local y=bot:GetLocation();
		local z=enemy:GetLocation();
		
		if x~=y then
			local a=1;
			local b=1;
			local c=0;
		
			if x.x-y.x ==0 then
				b=0;
				c=-x.x;
			else
				a=-(x.y-y.y)/(x.x-y.x);
				c=-(x.y + x.x*a);
			end
		
			local d = math.abs((a*z.x+b*z.y+c)/math.sqrt(a*a+b*b));
			if d<=hitRadios and mindis>GetUnitToLocationDistance(enemy,x) and (GetUnitToLocationDistance(enemy,x)<=GetUnitToLocationDistance(bot,x)) then
				bestTree=tree;
				mindis=GetUnitToLocationDistance(enemy,x);
			end
		end
	end
	
	return bestTree;

end

function GetBestRetreatTree(bot, nCastRange)
	local trees=bot:GetNearbyTrees(nCastRange);
	
	local dest=VectorTowards(bot:GetLocation(),Fountain(GetTeam()),1000);
	
	local BestTree=nil;
	local maxdis=0;
	
	for _,tree in pairs(trees) do
		local loc=GetTreeLocation(tree);
		
		if (not AreTreesBetween(loc,100)) and 
			GetUnitToLocationDistance(bot,loc)>maxdis and 
			GetUnitToLocationDistance(bot,loc)<nCastRange and 
			J.Site.GetDistance(loc,dest)<880 
		then
			maxdis=GetUnitToLocationDistance(bot,loc);
			BestTree=loc;
		end
	end
	
	if BestTree~=nil and maxdis>250 then
		return BestTree;
	end
	
	return nil;
end

function VectorTowards(s,t,d)
	local f=t-s;
	f=f / J.Site.GetDistance(f,Vector(0,0));
	return s+(f*d);
end

function Fountain(team)
	if team==TEAM_RADIANT then
		return Vector(-7093,-6542);
	end
	return Vector(7015,6534);
end

return X;