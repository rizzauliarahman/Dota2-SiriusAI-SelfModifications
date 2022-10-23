--  英雄阵容搭配和克制库
--  电脑可选英雄在推荐列表中建议增加权重，针对阵容同理

local allowsHeroData = require(GetScriptDirectory() .. "/AuxiliaryScript/GetAllowHeroData")
local bnUtil = require(GetScriptDirectory() .. "/AuxiliaryScript/BotNameUtility");
local Role = require( GetScriptDirectory()..'/FunLib/jmz_role' )
local apHeroList = {}
local banList = {}
local interestingList = {}
local interestingSuccession = 1

local X = {}

if xpcall(function(loadDir) require( loadDir ) end, function(err) print('使用内置英雄数据库') end, 'game/英雄匹配数据')
then
	allowsHeroData = require( 'game/英雄匹配数据' )
end

X["allows_hero"] = allowsHeroData.hero

--当前英雄池
--'npc_dota_hero_abaddon',亚巴顿
--'npc_dota_hero_ancient_apparition',远古冰魄*
--'npc_dota_hero_axe',斧王
--'npc_dota_hero_abyssal_underlord',孽主
--'npc_dota_hero_brewmaster'酒仙*
--'npc_dota_hero_batrider',蝙蝠骑士*
--'npc_dota_hero_centaur',半人马战行者
--'npc_dota_hero_chen',陈*
--'npc_dota_hero_dark_seer',黑暗贤者*
--'npc_dota_hero_dark_willow',邪影芳灵*
--'npc_dota_hero_disruptor',干扰者
--'npc_dota_hero_doom_bringer',末日使者*
--'npc_dota_hero_earth_spirit',大地之灵*
--'npc_dota_hero_elder_titan',上古巨神*
--'npc_dota_hero_earthshaker',撼地者*
--'npc_dota_hero_ember_spirit',灰烬之灵*
--'npc_dota_hero_enchantress',魅惑魔女*
--'npc_dota_hero_enigma',谜团*
--'npc_dota_hero_faceless_void',虚空假面*
--'npc_dota_hero_furion',先知
--'npc_dota_hero_grimstroke',天涯墨客
--'npc_dota_hero_gyrocopter',矮人直升机*
--'npc_dota_hero_invoker',祈求者*
--'npc_dota_hero_juggernaut'主宰*
--'npc_dota_hero_keeper_of_the_light',光之守卫*
--'npc_dota_hero_legion_commander',军团指挥官
--'npc_dota_hero_leshrac',拉席克*
--'npc_dota_hero_life_stealer',噬魂鬼*
--'npc_dota_hero_magnataur',马格纳斯*
--'npc_dota_hero_mars',马尔斯*
--'npc_dota_hero_mirana',米拉娜*
--'npc_dota_hero_monkey_king',齐天大圣*
--'npc_dota_hero_naga_siren',娜迦海妖
--'npc_dota_hero_night_stalker',暗夜魔王
--'npc_dota_hero_obsidian_destroyer',殁境神蚀者*
--'npc_dota_hero_omniknight',全能骑士*
--'npc_dota_hero_pangolier',石鳞剑士*
--'npc_dota_hero_puck',帕克*
--'npc_dota_hero_queenofpain',痛苦女王*
--'npc_dota_hero_rubick',拉比克*
--'npc_dota_hero_shadow_demon',暗影恶魔*
--'npc_dota_hero_slardar',斯拉达*
--'npc_dota_hero_slark',斯拉克*
--'npc_dota_hero_snapfire',电炎绝手*
--'npc_dota_hero_spectre',幽鬼*
--'npc_dota_hero_storm_spirit',风暴之灵*
--'npc_dota_hero_terrorblade',恐怖利刃*
--'npc_dota_hero_treant',树精卫士*
--'npc_dota_hero_tusk',巨牙海民*
--'npc_dota_hero_tinker',修补匠*
--'npc_dota_hero_tidehunter',潮汐猎人*
--'npc_dota_hero_tiny',小小*
--'npc_dota_hero_undying',不朽尸王*
--'npc_dota_hero_ursa',熊战士*
--'npc_dota_hero_void_spirit',虚无之灵*
--,npc_dota_hero_venomancer',剧毒术士*
--'npc_dota_hero_vengefulspirit',复仇之魂
--'npc_dota_hero_weaver',编织者*
--'npc_dota_hero_winter_wyvern',寒冬飞龙
--'npc_dota_hero_wisp',艾欧*
--'npc_dota_hero_windrunner',风行
--'npc_dota_hero_visage',维萨吉*
--'npc_dota_hero_spirit_breaker',白牛*
--'npc_dota_hero_rattletrap',发条*
--'npc_dota_hero_morphling',水人*
--'npc_dota_hero_pudge',屠夫
--'npc_dota_hero_shredder',伐木机
--'npc_dota_hero_nyx_assassin',司夜*
--'npc_dota_hero_phoenix',凤凰*
--'npc_dota_hero_alchemist',炼金*
--'npc_dota_hero_lycan',狼人*
--'npc_dota_hero_troll_warlord',巨魔
--'npc_dota_hero_beastmaster',兽王*
--'npc_dota_hero_broodmother',蜘蛛*
--'npc_dota_hero_hoodwink',林海飞霞*
----原脚本
--'npc_dota_hero_antimage',敌法师
--'npc_dota_hero_arc_warden',天穹守望者
--'npc_dota_hero_bane',祸乱之源
--'npc_dota_hero_bloodseeker',血魔
--'npc_dota_hero_bounty_hunter',赏金猎人
--'npc_dota_hero_bristleback',钢背兽
--'npc_dota_hero_chaos_knight',混沌骑士
--'npc_dota_hero_clinkz',克林克兹
--'npc_dota_hero_crystal_maiden',水晶室女
--'npc_dota_hero_dazzle',戴泽
--'npc_dota_hero_death_prophet'死亡先知
--'npc_dota_hero_dragon_knight',龙骑士
--'npc_dota_hero_drow_ranger',卓尔游侠
--'npc_dota_hero_huskar',哈斯卡
--'npc_dota_hero_jakiro',杰奇洛
--'npc_dota_hero_kunkka',昆卡
--'npc_dota_hero_lich',巫妖
--'npc_dota_hero_lina',莉娜
--'npc_dota_hero_lion',莱恩
--'npc_dota_hero_luna',露娜
--'npc_dota_hero_medusa',美杜莎
--'npc_dota_hero_necrolyte',瘟疫法师
--'npc_dota_hero_nevermore',影魔
--'npc_dota_hero_ogre_magi',食人魔魔法师
--'npc_dota_hero_oracle',神谕者
--'npc_dota_hero_phantom_assassin',幻影刺客
--'npc_dota_hero_phantom_lancer',幻影长矛手
--'npc_dota_hero_pugna',帕格纳
--'npc_dota_hero_razor',剃刀
--'npc_dota_hero_riki',力丸
--'npc_dota_hero_sand_king',沙王
--'npc_dota_hero_shadow_shaman',暗影萨满
--'npc_dota_hero_silencer',沉默术士
--'npc_dota_hero_skeleton_king',冥魂大帝
--'npc_dota_hero_skywrath_mage',天怒法师
--'npc_dota_hero_sniper',狙击手
--'npc_dota_hero_sven',斯温
--'npc_dota_hero_templar_assassin',圣堂刺客
--'npc_dota_hero_viper',冥界亚龙
--'npc_dota_hero_warlock',术士
--'npc_dota_hero_witch_doctor',巫医
--'npc_dota_hero_zuus',宙斯
--待添加英雄
--npc_dota_hero_lone_druid德鲁伊
--npc_dota_hero_meepo米波
--待修复的英雄
--噬魂鬼、幽鬼、邪影芳灵

X["test_hero"] = {
    --'npc_dota_hero_omniknight'
    --'npc_dota_hero_abaddon',
}

X["onlyCM_hero"] = {
    --'npc_dota_hero_abaddon',
    --'npc_dota_hero_vengefulspirit',
    --'npc_dota_hero_shadow_demon',
    --'npc_dota_hero_tidehunter',
    --'npc_dota_hero_disruptor',
    --'npc_dota_hero_axe',
    --'npc_dota_hero_leshrac',*
    --'npc_dota_hero_batrider',
    --'npc_dota_hero_dazzle',
    --'npc_dota_hero_grimstroke',
    --'npc_dota_hero_puck',*
    --'npc_dota_hero_centaur',
    --'npc_dota_hero_faceless_void',*
    --'npc_dota_hero_obsidian_destroyer',*
    --'npc_dota_hero_queenofpain',*
    --'npc_dota_hero_slardar',*
    --'npc_dota_hero_omniknight',*
    --'npc_dota_hero_rubick',*
    --'npc_dota_hero_tiny',*
    --'npc_dota_hero_earthshaker',*
    --'npc_dota_hero_dark_willow',*
    --'npc_dota_hero_undying',
    --'npc_dota_hero_snapfire',*
    --'npc_dota_hero_void_spirit',*
    --'npc_dota_hero_storm_spirit',*
    --'npc_dota_hero_magnataur',
    --'npc_dota_hero_treant',
    --'npc_dota_hero_ursa',*
    --'npc_dota_hero_mars',
    --'npc_dota_hero_abyssal_underlord',
    --'npc_dota_hero_ancient_apparition',
    --'npc_dota_hero_bane',
    --'npc_dota_hero_bounty_hunter',
    --'npc_dota_hero_invoker',
    --'npc_dota_hero_gyrocopter',
    --'npc_dota_hero_pangolier',
    --'npc_dota_hero_juggernaut'
    --'npc_dota_hero_enigma',
    --'npc_dota_hero_winter_wyvern',
    --'npc_dota_hero_night_stalker',
    'npc_dota_hero_chen',
    --'npc_dota_hero_dark_seer',
    --'npc_dota_hero_doom_bringer',*
    --'npc_dota_hero_earth_spirit',
    --'npc_dota_hero_elder_titan',*
    --'npc_dota_hero_ember_spirit',
    --'npc_dota_hero_enchantress',
    --'npc_dota_hero_furion',
    --'npc_dota_hero_keeper_of_the_light',
    --'npc_dota_hero_legion_commander',
    --'npc_dota_hero_life_stealer',*
    --'npc_dota_hero_mirana',*
    --'npc_dota_hero_wisp',*
    --'npc_dota_hero_slark',
    --'npc_dota_hero_monkey_king',*
    --'npc_dota_hero_terrorblade',
    --'npc_dota_hero_tusk',
    --'npc_dota_hero_weaver',
    --'npc_dota_hero_naga_siren',
    --'npc_dota_hero_spectre',*
    --'npc_dota_hero_venomancer',
    --'npc_dota_hero_tinker',*
    --'npc_dota_hero_visage',*
    --'npc_dota_hero_spirit_breaker',*
    --'npc_dota_hero_rattletrap',
    --'npc_dota_hero_morphling',
    --'npc_dota_hero_pudge',
    --'npc_dota_hero_shredder',
    --'npc_dota_hero_nyx_assassin',*
    --'npc_dota_hero_phoenix',*
    --'npc_dota_hero_alchemist',
    --'npc_dota_hero_lycan',
    --'npc_dota_hero_troll_warlord',
    --'npc_dota_hero_beastmaster',
    --'npc_dota_hero_broodmother',
    --'npc_dota_hero_hoodwink',
}

X["definingHero"] = {
    "npc_dota_hero_antimage",
	"npc_dota_hero_bane",
	"npc_dota_hero_bounty_hunter",
	"npc_dota_hero_bristleback",
	"npc_dota_hero_chaos_knight",
	"npc_dota_hero_dazzle",
	"npc_dota_hero_lion",
	"npc_dota_hero_medusa",
	"npc_dota_hero_riki",
	"npc_dota_hero_sand_king",
	"npc_dota_hero_sniper",
	"npc_dota_hero_viper",
}

function X.CounterWeightList(hero) --获取推荐阵容列表
	if X["allows_hero"][hero] == nil then return nil end;
    local heroCounter = X["allows_hero"][hero]['restrained'];
    local counterList = {};
    if heroCounter == nil then return nil end;
    for _,value in pairs(heroCounter) do
        counterList[value['hero']] = value['weight'];
        --for w = value['weight'], 0, -1 do
        --    table.insert(counterList,value['hero']);
        --end
	end
	return counterList;
end

function X.RestraintWeightList(hero) --获取针对阵容列表
	if X["allows_hero"][hero] == nil then return nil end;
    local heroCounter = X["allows_hero"][hero]['restraint'];
    local counterList = {};
    if heroCounter == nil then return nil end;
    for _,value in pairs(heroCounter) do
        counterList[value['hero']] = value['weight'];
	end
	return counterList;
end

function X.ProposalWeightList(hero) --获取被针对阵容列表
	if X["allows_hero"][hero] == nil then return nil end;
    local heroProposal = X["allows_hero"][hero]['proposal'];
    local proposalList = {};
    if heroProposal == nil then return nil end;
    for _,value in pairs(heroProposal) do
        proposalList[value['hero']] = value['weight'];
        --if weight then
        --    for w = value['weight'], 0, -1 do
        --        table.insert(proposalList,value['hero']);
        --    end
        --else
        --    table.insert(proposalList,value['hero']);
        --end
	end
	return proposalList;
end

function X.ScreeningHeroList(list,hero)--排除已选英雄 全部已选列表 待选英雄
    if next(list) ~= nil then
        for _,value in pairs(list) do
            if value == hero then
                return false;
            end
        end
        return true;
    else
        return false;
    end
end

function X.OptionalHeroList()--可选英雄列表
    local heroList = {};
    for key,i in pairs(X['allows_hero']) do
        if i['bot'] then
            table.insert(heroList,key);
        end
    end
    return heroList;
end

function X.SelectHero(hero)--判断英雄是否可选
    local heroList = X.OptionalHeroList();
    for _,i in pairs(heroList) do
        if i == hero and IsCMBannedHero(hero) then
            return true
        end
    end
    return false;
end

function X.BreakUpList(list)--打散数组
	local _result = {}
    local _index = 1
    while #list ~= 0 do
        local ran = math.random(0,#list)
        if list[ran] ~= nil then
            _result[_index] = list[ran]
            table.remove(list,ran)
            _index = _index + 1
        end
    end
    return _result
end

function X.RemoveRepeat(a)--去重
    local b = {}
    for k,v in ipairs(a) do
        if(#b == 0) then
            b[1]=v;
        else
            local index = 0
            for i=1,#b do
                if(v == b[i]) then
                    break
                end
                index = index + 1
            end
            if(index == #b) then
                b[#b + 1] = v;
            end
        end
    end
    return b
end

--随机获取列表中的英雄
function RandomHero(herolist)
    local hero = herolist[RandomInt(1, #herolist)];
	while ( IsCMPickedHero(GetTeam(), hero) or IsCMPickedHero(GetOpposingTeam(), hero) or IsCMBannedHero(hero) ) 
	do
        hero = herolist[RandomInt(1, #herolist)];
    end
	return hero;
end

function X.AllLibraryHeroList()
    local HeroSelect = {}
    local HeroBan = {}
    local Herolist = {}

    for key,value in pairs(X['allows_hero']) do
        table.insert(Herolist,key);
        for k,v in pairs(X.CounterWeightList(key)) do
            table.insert(Herolist,k);
        end
        for k,v in pairs(X.ProposalWeightList(key)) do
            table.insert(Herolist,k);
        end
    end
    Herolist = X.RemoveRepeat(Herolist);
    --Herolist中现在拥有所有库中记载的英雄
    --for _,value in pairs(Herolist) do
    --    if IsCMBannedHero(value) then
    --        table.insert(HeroBan,value);
    --    end
    --    if IsCMPickedHero(GetTeam(), value) then
    --        table.insert(HeroSelect,value);
    --    end
    --end
    return {
        ['Herolist'] = Herolist,
        --['HeroSelect'] = HeroSelect,
        --['HeroBan'] = HeroBan,
    }
end

function IsHumanPlayerExist()
	local Players = GetTeamPlayers(GetTeam())
    for _,id in pairs(Players) do
        if not IsPlayerBot(id) then
			return true;
        end
    end
	return false;
end

function IsBanBychat( sHero )

	for i = 1,#banList
	do
		if banList[i] ~= nil
		   and string.find(sHero, banList[i])
		then
			return true;
		end	
	end
	
	return false;
end

function GetNotRepeatHero(nTable)
    --仅限CM选择英雄
    if next(X['onlyCM_hero']) ~= nil then
        local testheroList = {};
        for i, v in ipairs(nTable) do
            if X.ScreeningHeroList(X['onlyCM_hero'],v) then
                table.insert(testheroList,v);
            end
        end
        if next(testheroList) ~= nil then
            nTable = testheroList;
        end
    end

    --锦囊限制英雄
    if Role.GetKeyLV() <= 1 then
        if next(X['definingHero']) ~= nil then
            local definingHeroList = {};
            for i, v in ipairs(nTable) do
                if X.ScreeningHeroList(X['definingHero'],v) then
                    table.insert(definingHeroList,v);
                end
            end
            if next(definingHeroList) ~= nil then
                nTable = definingHeroList;
            end
        end
    end

	local sHero = nTable[1];
	local maxCount = #nTable ;
	local rand = 0;
    local BeRepeated = false;
    
	
	for count = 1, maxCount
	do
		rand = RandomInt(1, #nTable);
		sHero = nTable[rand];
		BeRepeated = false;
		for id = 0, 20
		do
			if ( IsTeamPlayer(id) and GetSelectedHeroName(id) == sHero )
				or ( IsCMBannedHero(sHero) )
				or ( IsBanBychat(sHero) )
			then
				BeRepeated = true;
				table.remove(nTable,rand);
				break;
			end
		end
		if not BeRepeated then break; end
	end
	return sHero;		
end

--以下为测试内容
function X.TypeWeight(ourHero,hero)--类型权重考量
    --local tIntelligence = 5 - #ourHero;
    local tIntelligence = 0;
    --print('-------- 数组总量 ------');
    --print(tIntelligence);
    --print('-------- 遍历列表 ------');
    --if next(ourHero) ~= nil and next(X['allows_hero'][hero]) ~= nil then
    --    for _key,value in pairs(ourHero) do
    --        --print(value);
    --        --print(value);
    --        if value ~= '' and X['allows_hero'][value]['type'] == X['allows_hero'][hero]['type'] then
    --            tIntelligence = tIntelligence - 1;
    --        end
    --    end
    --else
    --    tIntelligence = 0;
    --end
    --print('--------  结束  ------');
    --print(tIntelligence);
    return tIntelligence;
end

function X.TeamToObtain()--获取全阵营已选英雄
    local heroTeam = nil;
	local ourIds = GetTeamPlayers(GetTeam());
	local enemyIds = GetTeamPlayers(GetOpposingTeam());
	local botSelectHero = nil;
    local apHeroList = {};

    local ourHero = {};
    local enemyHero = {};
    local screeningList = {};

    local against = {};
    local targeted = {};

    local retext = '我们可以克制对方的 ';

    for i,id in pairs(ourIds) --找出我方已选英雄
	do
		if GetSelectedHeroName(id) ~= "" or GetSelectedHeroName(id) ~= nil
		then
			if GetTeam() == TEAM_RADIANT then
				apHeroList[GetSelectedHeroName(id)] = TEAM_RADIANT;
			else
				apHeroList[GetSelectedHeroName(id)] = TEAM_DIRE;
			end
		end
	end

	for i,id in pairs(enemyIds) --找出对方已选英雄
	do
		if GetSelectedHeroName(id) ~= "" or GetSelectedHeroName(id) ~= nil
		then
			if GetTeam() == TEAM_RADIANT then
				apHeroList[GetSelectedHeroName(id)] = TEAM_DIRE;
			else
				apHeroList[GetSelectedHeroName(id)] = TEAM_RADIANT;
			end
		end
    end

    for key,value in pairs(apHeroList) do
        if value == GetTeam() then
            table.insert(ourHero,key);
        else
            table.insert(enemyHero,key);
        end
    end

    for _key,value in pairs(enemyHero) do
        local priorityList = X.ProposalWeightList(value);
        if priorityList ~= nil then
            for _hero,i in pairs(priorityList) do
                for j,_ourHero in pairs(ourHero) do
                    if _ourHero == _hero and not X.ScreeningHeroList(against,_hero) then
                        table.insert(against, X["allows_hero"][value]['hero_name']);
                    end
                end
            end
        end
    end

    for _key,value in pairs(ourHero) do
        local enemyList = X.ProposalWeightList(value);
        if enemyList ~= nil then
            for _hero,i in pairs(enemyList) do
                for j,_ourHero in pairs(enemyHero) do
                    if _ourHero == _hero and not X.ScreeningHeroList(targeted,_ourHero) then
                        table.insert(targeted, X["allows_hero"][_ourHero]['hero_name']);
                    end
                end
            end
        end
    end

    
    retext = retext.. table.concat(against,", ");
    retext = retext.. ' 但是会被对方 ';
    retext = retext.. table.concat(targeted,", ");
    retext = retext.. ' 克制';
    
    return retext;
end

--其他文件索引
function X.GetDota2Team()
    return bnUtil.GetDota2Team();
end

--主函数
function X.IntelligentBannedHeroListAnalysis(apHeroList)
    local ourHero = {};
    local enemyHero = {};
    local tempHeroList = {};
    local tempBeAimedHeroList = {};
    local screeningList = {};

    if next(apHeroList) ~= nil then
        --列出已上阵列表
        for key,value in pairs(apHeroList) do
            if value == GetTeam() then
                table.insert(ourHero,key);
            else
                table.insert(enemyHero,key);
            end
            if key ~= '' then
                table.insert(screeningList,key);
            end
        end
        if next(screeningList) == nil then
            --没有成功获取到上阵列表，可能真的是空的
            local selectHero = X.AllLibraryHeroList()['Herolist'];
            return RandomHero(selectHero);
        end
    else
        --没有任何上阵英雄，发出全列表
        local selectHero = X.AllLibraryHeroList()['Herolist'];
        return RandomHero(selectHero);
    end
    --此阶段有问题
    --[[
    if next(ourHero) ~= nil then
        for _key,value in pairs(ourHero) do
            local priorityList = X.ProposalWeightList(value);
            if priorityList ~= nil then
                for _hero,_weight in pairs(priorityList) do
                    if X.ScreeningHeroList(screeningList,_hero) and X.SelectHero(_hero) then
                        table.insert(tempHeroList,_hero);
                    end
                end
            end
        end
    end
    ]]
    if next(enemyHero) ~= nil then
        for _key,value in pairs(enemyHero) do
            local priorityList = X.CounterWeightList(value);
            if priorityList ~= nil then
                for _hero,_weight in pairs(priorityList) do
                    if X.ScreeningHeroList(screeningList,_hero) and X.SelectHero(_hero) then
                        table.insert(tempHeroList,_hero);
                    end
                end
            end
        end
    end

    if next(tempHeroList) ~= nil then
        for k,i in pairs(tempHeroList) do
            if IsCMPickedHero(GetTeam(), i) or IsCMPickedHero(GetOpposingTeam(), i) or IsCMBannedHero(i) then
                table.remove(tempHeroList,k);
            end
        end
    end

    local banhero = ''

    if next(tempHeroList) ~= nil then
        banhero = RandomHero(tempHeroList);
    else
        banhero = RandomHero(X.AllLibraryHeroList()['Herolist']);
    end

    return banhero

end

function X.getApHero()
    local heroTeam = nil;
	local ourIds = GetTeamPlayers(GetTeam());
	local enemyIds = GetTeamPlayers(GetOpposingTeam());
    local botSelectHero = nil;
    --精英模式
    if X.interestingMode == nil  then
        local randomMode = RandomInt(1,100)
        if randomMode == 53 then
            X.interestingMode = '物理克星';
            interestingList = {
                'npc_dota_hero_legion_commander',
                'npc_dota_hero_silencer',
                'npc_dota_hero_winter_wyvern',
                'npc_dota_hero_bounty_hunter',
                'npc_dota_hero_oracle',
            };
        elseif randomMode == 44 then
            X.interestingMode = '法师';
            interestingList = {
                'npc_dota_hero_arc_warden',
                'npc_dota_hero_ogre_magi',
                'npc_dota_hero_skywrath_mage',
                'npc_dota_hero_phantom_lancer',
                'npc_dota_hero_witch_doctor',
            };
        elseif randomMode == 2 then
            X.interestingMode = '固定1组';
            interestingList = {
                'npc_dota_hero_legion_commander',
                'npc_dota_hero_silencer',
                'npc_dota_hero_bounty_hunter',
                'npc_dota_hero_zuus',
                'npc_dota_hero_clinkz',
            };
        elseif randomMode == 11 then
            X.interestingMode = '物理';
            interestingList = {
                'npc_dota_hero_axe',
                'npc_dota_hero_viper',
                'npc_dota_hero_legion_commander',
                'npc_dota_hero_night_stalker',
                'npc_dota_hero_undying',
            };
        elseif randomMode == 84 then
            X.interestingMode = '冲脸';
            interestingList = {
                'npc_dota_hero_huskar',
                'npc_dota_hero_night_stalker',
                'npc_dota_hero_legion_commander',
                'npc_dota_hero_bristleback',
                'npc_dota_hero_magnataur',
            };
        elseif randomMode == 64 then
            X.interestingMode = '漩涡';
            interestingList = {
                'npc_dota_hero_warlock',
                'npc_dota_hero_bristleback',
                'npc_dota_hero_sand_king',
                'npc_dota_hero_witch_doctor',
                'npc_dota_hero_death_prophet',
            };
        elseif randomMode == 28 then
            X.interestingMode = '摄取';
            interestingList = {
                'npc_dota_hero_pudge',
                'npc_dota_hero_legion_commander',
                'npc_dota_hero_zuus',
                'npc_dota_hero_silencer',
                'npc_dota_hero_slark',
            };
        elseif randomMode == 155 or randomMode == 174 or randomMode == 114 then
            X.interestingMode = '闪电';
            local lightning = {
                {
                    'npc_dota_hero_razor',
                    'npc_dota_hero_razor',
                    'npc_dota_hero_razor',
                    'npc_dota_hero_razor',
                    'npc_dota_hero_razor',
                },
                {
                    'npc_dota_hero_disruptor',
                    'npc_dota_hero_disruptor',
                    'npc_dota_hero_disruptor',
                    'npc_dota_hero_disruptor',
                    'npc_dota_hero_disruptor',
                }
            }
            interestingList = lightning[RandomInt(1,2)]
        elseif randomMode == 131 then
            X.interestingMode = '石头也疯狂';
            interestingList = {
                'npc_dota_hero_tiny',
                'npc_dota_hero_tiny',
                'npc_dota_hero_tiny',
                'npc_dota_hero_tiny',
                'npc_dota_hero_tiny',
            };
        else
            X.interestingMode = false;
        end

        if IsHumanPlayerExist() then
            X.interestingMode = false;
        end
    end

	if GetTeam() == TEAM_RADIANT 
	then
		heroTeam = TEAM_RADIANT;
	elseif GetTeam() == TEAM_DIRE
	then
		heroTeam = TEAM_DIRE;
    end

    for i,id in pairs(ourIds) --找出我方已选英雄
    do
        if GetSelectedHeroName(id) ~= "" or GetSelectedHeroName(id) ~= nil
        then
            if GetTeam() == TEAM_RADIANT then
                apHeroList[GetSelectedHeroName(id)] = TEAM_RADIANT;
            else
                apHeroList[GetSelectedHeroName(id)] = TEAM_DIRE;
            end
        end
    end

    for i,id in pairs(enemyIds) --找出对方已选英雄
    do
        if GetSelectedHeroName(id) ~= "" or GetSelectedHeroName(id) ~= nil
        then
            if GetTeam() == TEAM_RADIANT then
                apHeroList[GetSelectedHeroName(id)] = TEAM_DIRE;
            else
                apHeroList[GetSelectedHeroName(id)] = TEAM_RADIANT;
            end
        end
    end

    botSelectHero = X.IntelligentHeroListAnalysis(apHeroList); --智能库去筛选合适的英雄队列

    local botHero;

    if X.interestingMode ~= nil and X.interestingMode then
        botHero = interestingList[interestingSuccession];
        interestingSuccession = interestingSuccession + 1;
        apHeroList[botHero] = heroTeam;
    else
        if next(botSelectHero) ~= nil then
            --print('采用匹配库生成目标英雄串');
            botHero = GetNotRepeatHero(botSelectHero);
            apHeroList[botHero] = heroTeam;
        else
            --print('采用英雄库生成目标英雄串');
            botHero = GetNotRepeatHero(X.OptionalHeroList()); --智能筛选都筛不出能选的，只好在全英雄可选中随便挑一个能用的了
            apHeroList[botHero] = heroTeam;
        end
    end

    return botHero
end

function X.IntelligentHeroListAnalysis(apHeroList)
    --英雄列表分析
    --我方列表ourHero
    --敌方列表enemyHero
    
    local ourHero = {};
    local enemyHero = {};
    local tempHeroList = {};
    local tempBeAimedHeroList = {};
    local screeningList = {};
    if next(apHeroList) ~= nil then
        --列出已上阵列表
        for key,value in pairs(apHeroList) do
            if value == GetTeam() then
                table.insert(ourHero,key);
            else
                table.insert(enemyHero,key);
            end
            --print(key);
            if key ~= '' then
                table.insert(screeningList,key);
            end
        end
        if next(screeningList) == nil then
            --没有成功获取到上阵列表，可能真的是空的
            local selectHero = X.OptionalHeroList();
            return selectHero;
        end
    else
        --没有任何上阵英雄，发出全列表
        local selectHero = X.OptionalHeroList();
        return selectHero;
    end

    --优先选择需要测试的英雄
    if next(X['test_hero']) ~= nil then
        local testheroList = {};
        for i, v in ipairs(X['test_hero']) do
            if X.ScreeningHeroList(screeningList,v) then
                table.insert(testheroList,v);
            end
        end
        if next(testheroList) ~= nil then
            return testheroList;
        end
    end

    if next(ourHero) ~= nil then
        --将我方推荐阵容筛选为待选临时列表
        for _key,value in pairs(ourHero) do
            local priorityList = X.CounterWeightList(value);
            if priorityList ~= nil then
                for _hero,_weight in pairs(priorityList) do
                    if X.ScreeningHeroList(screeningList,_hero) and X.SelectHero(_hero) then
                        --print(_hero);
                        local typeWeight = X.TypeWeight(ourHero,_hero);
                        if tempHeroList[_hero] ~= nil then
                            tempHeroList[_hero] = tempHeroList[_hero] + _weight + typeWeight;
                        else
                            tempHeroList[_hero] = _weight + typeWeight;
                        end
                        --考虑cm模式Ban人取消绝对值
                        --if tempHeroList[_hero] < 0 then
                        --    --if tempHeroList[_hero] < -2; then
                        --    --    tempHeroList[_hero] = nil;
                        --    --else
                        --        tempHeroList[_hero] = 0;
                        --    --end
                        --end
                    end
                end
            end
        end
        if next(enemyHero) ~= nil then --如果敌方还未选英雄，则不进一步操作
        --将我方克制敌方英雄加入临时列表 （取消逻辑）
        --for _key,value in pairs(ourHero) do
        --    local priorityList = X.RestraintWeightList(value);
        --    if priorityList ~= nil then
        --        for _hero,_weight in pairs(priorityList) do
        --            for _,_ehero in pairs(enemyHero) do --遍历敌方列表
        --                if _ehero == _hero then --如果在我方克制列表中发现可以克制地方的英雄
        --                    if X.ScreeningHeroList(screeningList,_hero) and X.SelectHero(_hero) then
        --                        if tempHeroList[_hero] ~= nil then
        --                            tempHeroList[_hero] = tempHeroList[_hero] + _weight;
        --                        else
        --                            tempHeroList[_hero] = _weight;
        --                        end
        --                    end
        --                end
        --            end
        --        end
        --    end
        --end
        --将敌方的克制英雄加入待选临时列表
        for _key,value in pairs(enemyHero) do
            local priorityList = X.ProposalWeightList(value);
            if priorityList ~= nil then
                for _hero,_weight in pairs(priorityList) do
                    if X.ScreeningHeroList(screeningList,_hero) and X.SelectHero(_hero) then
                        --print(_hero);
                        if tempHeroList[_hero] ~= nil then
                            tempHeroList[_hero] = tempHeroList[_hero] + _weight;
                        else
                            tempHeroList[_hero] = _weight;
                        end
                    end
                end
            end
        end
        --将敌方已选克制临时列表中的英雄删除
        for _key,value in pairs(tempHeroList) do
            local enemyList = X.ProposalWeightList(value);
            if enemyList ~= nil then
                for _hero,_weight in pairs(enemyList) do
                    if _hero == value then
                        --print(_hero);
                        if tempHeroList[_hero] ~= nil then
                            tempHeroList[_hero] = tempHeroList[_hero] - _weight;
                            --考虑cm模式Ban人取消绝对值
                            --if tempHeroList[_hero] < 0 then
                            --    tempHeroList[_hero] = 0;
                            --end
                        end
                    end
                end
            end
        end
        end
        --此时tempHeroList中的英雄为我方已选英雄的最佳拍档或敌方的克制英雄并且不被对方针对(包含权重)
        --转换权重为列表
        if next(tempHeroList) ~= nil then
            local conclusionHeroList = {};
            for _hero,_weight in pairs(tempHeroList) do
                for i = 1, _weight do
                    table.insert(conclusionHeroList,_hero);
                end
            end
            conclusionHeroList = X.BreakUpList(conclusionHeroList);--乱序
            return conclusionHeroList;
        else
            --过分了，发出全列表
            local selectHero = X.OptionalHeroList();
            for k,i in pairs(selectHero) do
                if not X.ScreeningHeroList(screeningList,i) then
                    table.remove(selectHero,k);
                end
            end
            return selectHero;
        end
    else --
        if next(enemyHero) ~= nil then
            --将敌方的克制英雄加入待选临时列表
            for _key,value in pairs(enemyHero) do
                local priorityList = X.ProposalWeightList(value);
                if priorityList ~= nil then
                    for _,i in pairs(priorityList) do
                        if X.ScreeningHeroList(screeningList,i) and X.SelectHero(i) then
                            --print(i);
                            table.insert(tempHeroList,i);
                        end
                    end
                end
            end
            --将敌方已选克制临时列表中的英雄删除
            for _key,value in pairs(tempHeroList) do
                local enemyList = X.ProposalWeightList(value);
                if enemyList ~= nil then
                    for _,i in pairs(enemyList) do
                        if value == i then
                            --print(i);
                            table.remove(tempHeroList,_key);
                            table.insert(tempBeAimedHeroList,i);--将移除的英雄加入次要选择库，当无英雄可选时，优先选择对我方有利的英雄，忽视是否被敌方克制
                        end
                    end
                end
            end
            --此时tempHeroList中的英雄为敌方的克制英雄并且不被对方针对(包含权重)
            if next(tempHeroList) ~= nil then
                local conclusionHeroList = {};
                for _hero,_weight in pairs(tempHeroList) do
                    for i = 1, _weight do
                        table.insert(conclusionHeroList,_hero);
                    end
                end
                conclusionHeroList = X.BreakUpList(conclusionHeroList); --乱序
                return conclusionHeroList;
            else
                --过分了，发出全列表
                local selectHero = X.OptionalHeroList();
                for k,i in pairs(selectHero) do
                    if not X.ScreeningHeroList(screeningList,i) then
                        table.remove(selectHero,k);
                    end
                end
                return selectHero;
            end
        else --双方均未选择英雄，则发出全列表
            local selectHero = X.OptionalHeroList();
            return selectHero;
        end
    end
end

return X
-- alcedo@alcedo.site 