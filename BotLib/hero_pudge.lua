local X = {}
local bot = GetBot() --获取当前电脑

local J = require( GetScriptDirectory()..'/FunLib/jmz_func') --引入jmz_func文件
local ConversionMode = dofile( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion') --引入Minion文件
local sTalentList = J.Skill.GetTalentList(bot) --获取当前英雄（当前电脑选择的英雄，一下省略为当前英雄）的天赋列表
local sAbilityList = J.Skill.GetAbilityList(bot) --获取当前英雄的技能列表

--编组技能、天赋、装备
local tGroupedDataList = {}
--默认数据
local tDefaultGroupedData = {
	--天赋树
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {10, 0},
		['t15'] = {10, 0},
		['t10'] = {0, 10},
	},
	--技能
	['Ability'] = { 1,2,1,2,1,6,1,2,2,3,6,3,3,3,6 },
	--装备
	['Buy'] = {
		"两个item_tango",
		"item_enchanted_mango",
		"两个item_branches",
		"item_wind_lace",
		"item_ring_of_protection",
		"item_boots",
		"item_magic_wand",
		"item_tranquil_boots",
		"item_blade_mail",
		"item_blink",
		"item_urn_of_shadows",
		"item_eternal_shroud",
		"item_radiance",
		"item_heart",
		"item_crimson_guard",
		"item_ultimate_scepter2",
		"item_lotus_orb",
		"item_octarine_core",
		"item_overwhelming_blink",
		"item_spirit_vessel",
	},
	--出售
	['Sell'] = {
		"item_shivas_guard",
		"item_magic_wand",
				
		"item_travel_boots",
		"item_tranquil_boots",
	},
}

--根据组数据生成技能、天赋、装备
local nAbilityBuildList, nTalentBuildList;

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = ConversionMode.Combination(tGroupedDataList, tDefaultGroupedData, true)


nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit) 
	then
		if hMinionUnit:IsIllusion() 
		then 
			Minion.IllusionThink(hMinionUnit)	
		end
	end

end

function X.SkillsComplement()

	
	local ability2 = bot:GetAbilityByName('pudge_rot')

	if bot:IsChanneling() then
		if (ability2:IsTrained() or ability2:IsFullyCastable() or ability2:IsHidden() == false)
			and J.IsGoingOnSomeone(bot)
		then
			local nRadius = ability2:GetSpecialValueInt('rot_radius');
			local target = bot:GetTarget();
			if J.IsValidHero(target) 
				and J.CanCastOnNonMagicImmune(target) 
				and bot:IsFacingLocation(target:GetLocation(),15) 
				and J.IsInRange(bot, target, nRadius)	
				and ability2:GetToggleState() == false 
			then
				bot:Action_UseAbility(ability2);		
				return
			end
		end
	end

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	--技能检查顺序
	local order = {'R','Q','W'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X