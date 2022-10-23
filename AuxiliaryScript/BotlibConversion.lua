--英雄技能及装备处理

local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func') --引入jmz_func文件

local BotsInit = require( "game/botsinit" );

local sAbilityList = J.Skill.GetAbilityList(bot)--获取技能列表
--可用技能列表，其实不用检查的
local abilityNameList = {
    'dazzle_poison_touch',
    'dazzle_shadow_wave',
    'dazzle_shallow_grave',
    'disruptor_glimpse',
    'disruptor_kinetic_field',
    'disruptor_static_storm',
    'disruptor_thunder_strike',
    'omniknight_guardian_angel',
    'omniknight_purification',
    'omniknight_repel',
    'shadow_demon_demonic_purge',
    'shadow_demon_disruption',
    'shadow_demon_shadow_poison_release',
    'shadow_demon_shadow_poison',
    'shadow_demon_soul_catcher',
    'slardar_amplify_damage',
    'slardar_slithereen_crush',
    'slardar_sprint',
    'queenofpain_blink',
    'queenofpain_scream_of_pain',
    'queenofpain_shadow_strike',
    'queenofpain_sonic_wave',
    'abaddon_aphotic_shield',
    'abaddon_death_coil',
    'axe_battle_hunger',
    'axe_berserkers_call',
    'axe_culling_blade',
    'batrider_sticky_napalm',
    'batrider_flamebreak',
    'batrider_flaming_lasso',
    'batrider_firefly',
    'faceless_void_chronosphere',
    'faceless_void_time_dilation',
    'faceless_void_time_walk',
    'rubick_fade_bolt',
    'rubick_spell_steal',
    'rubick_telekinesis_land',
    'rubick_telekinesis',
    'centaur_double_edge',
    'centaur_hoof_stomp',
    'centaur_return',
    'centaur_stampede',
    'tidehunter_anchor_smash',
    'tidehunter_gush',
    'tidehunter_ravage',
    'leshrac_pulse_nova',
    'leshrac_lightning_storm',
    'leshrac_diabolic_edict',
    'leshrac_split_earth',
    'grimstroke_dark_artistry',
    'grimstroke_ink_creature',
    'grimstroke_scepter',
    'grimstroke_spirit_walk',
    'grimstroke_soul_chain',
    'vengefulspirit_magic_missile',
    'vengefulspirit_nether_swap',
    'vengefulspirit_wave_of_terror',
    'obsidian_destroyer_arcane_orb',
    'obsidian_destroyer_astral_imprisonment',
    'obsidian_destroyer_equilibrium',
    'obsidian_destroyer_sanity_eclipse',
    'puck_dream_coil',
    'puck_ethereal_jaunt',
    'puck_illusory_orb',
    'puck_phase_shift',
    'puck_waning_rift',
    'jakiro_dual_breath',
    'jakiro_ice_path',
    'jakiro_liquid_fire',
    'jakiro_macropyre',
    'kunkka_x_marks_the_spot',
    'kunkka_torrent',
    'kunkka_tidebringer',
    'kunkka_return',
    'kunkka_ghostship',
    'crystal_maiden_frostbite',
    'crystal_maiden_crystal_nova',
    'crystal_maiden_freezing_field',
    'bloodseeker_rupture',
    'bloodseeker_blood_bath',
    'bloodseeker_bloodrage',
    'antimage_mana_void',
    'antimage_counterspell',
    'antimage_blink',
    'sven_gods_strength',
    'sven_storm_bolt',
    'sven_warcry',
    'arc_warden_flux',
    'arc_warden_magnetic_field',
    'arc_warden_scepter',
    'arc_warden_spark_wraith',
    'arc_warden_tempest_double',
    'dragon_knight_breathe_fire',
    'dragon_knight_dragon_tail',
    'dragon_knight_elder_dragon_form',
    'drow_ranger_frost_arrows',
    'drow_ranger_trueshot',
    'drow_ranger_wave_of_silence',
    'tiny_toss',
    'tiny_avalanche',
    'tiny_craggy_exterior',
    'tiny_toss_tree',
    'tiny_tree_channel',
    'earthshaker_enchant_totem',
    'earthshaker_echo_slam',
    'earthshaker_fissure',
    'razor_eye_of_the_storm',
    'razor_plasma_field',
    'razor_static_link',
    'silencer_curse_of_the_silent',
    'silencer_glaives_of_wisdom',
    'silencer_global_silence',
    'silencer_last_word',
    'undying_tombstone',
    'undying_soul_rip',
    'undying_flesh_golem',
    'undying_decay',
    'riki_tricks_of_the_trade',
    'riki_smoke_screen',
    'riki_blink_strike',
    'phantom_assassin_stifling_dagger',
    'phantom_assassin_phantom_strike',
    'phantom_assassin_blur',
    'dark_willow_terrorize',
    'dark_willow_shadow_realm',
    'dark_willow_cursed_crown',
    'dark_willow_bramble_maze',
    'dark_willow_bedlam',
    'lich_frost_nova',
    'lich_frost_shield',
    'lich_sinister_gaze',
    'lich_chain_frost',
    'snapfire_scatterblast',
    'snapfire_mortimer_kisses',
    'snapfire_firesnap_cookie',
    'snapfire_lil_shredder',
    'void_spirit_aether_remnant',
    'void_spirit_astral_step',
    'void_spirit_dissimilate',
    'void_spirit_resonant_pulse',
    'storm_spirit_ball_lightning',
    'storm_spirit_electric_vortex',
    'storm_spirit_static_remnant',
    'magnataur_empower',
    'magnataur_reverse_polarity',
    'magnataur_shockwave',
    'magnataur_skewer',
    'treant_living_armor',
    'treant_natures_grasp',
    'treant_leech_seed',
    'treant_overgrowth',
    'treant_eyes_in_the_forest',
    'ursa_earthshock',
    'ursa_enrage',
    'ursa_overpower',
    'mars_spear',
    'mars_gods_rebuke',
    'mars_arena_of_blood',
    'abyssal_underlord_dark_rift',
    'abyssal_underlord_pit_of_malice',
    'abyssal_underlord_firestorm',
    'gyrocopter_homing_missile',
    'gyrocopter_rocket_barrage',
    'gyrocopter_call_down',
    'gyrocopter_flak_cannon',
    'juggernaut_blade_fury',
    'juggernaut_healing_ward',
    'juggernaut_omni_slash',
    'pangolier_gyroshell',
    'pangolier_shield_crash',
    'pangolier_swashbuckle',
    'night_stalker_void',
    'night_stalker_darkness',
    'night_stalker_crippling_fear',
    'enigma_malefice',
    'enigma_midnight_pulse',
    'enigma_demonic_conversion',
    'enigma_black_hole',
    'winter_wyvern_cold_embrace',
    'winter_wyvern_splinter_blast',
    'winter_wyvern_arctic_burn',
    'winter_wyvern_winters_curse',
    'chen_divine_favor',
    'chen_hand_of_god',
    'chen_holy_persuasion',
    'chen_penitence',
    'dark_seer_ion_shell',
    'dark_seer_surge',
    'dark_seer_vacuum',
    'dark_seer_wall_of_replica',
    'doom_bringer_devour',
    'doom_bringer_infernal_blade',
    'doom_bringer_doom',
    'doom_bringer_scorched_earth',
    'earth_spirit_boulder_smash',
    'earth_spirit_geomagnetic_grip',
    'earth_spirit_magnetize',
    'earth_spirit_rolling_boulder',
    'earth_spirit_stone_caller',
    'elder_titan_ancestral_spirit',
    'elder_titan_earth_splitter',
    'elder_titan_echo_stomp',
    'ember_spirit_activate_fire_remnant',
    'ember_spirit_fire_remnant',
    'ember_spirit_flame_guard',
    'ember_spirit_searing_chains',
    'ember_spirit_sleight_of_fist',
    'enchantress_bunny_hop',
    'enchantress_enchant',
    'enchantress_impetus',
    'enchantress_natures_attendants',
    'furion_force_of_nature',
    'furion_sprout',
    'furion_teleportation',
    'furion_wrath_of_nature',
    'keeper_of_the_light_blinding_light',
    'keeper_of_the_light_chakra_magic',
    'keeper_of_the_light_illuminate',
    'keeper_of_the_light_spirit_form_illuminate',
    'keeper_of_the_light_will_o_wisp',
    'legion_commander_duel',
    'legion_commander_overwhelming_odds',
    'legion_commander_press_the_attack',
    'life_stealer_consume',
    'life_stealer_infest',
    'life_stealer_open_wounds',
    'life_stealer_rage',
    'mirana_arrow',
    'mirana_invis',
    'mirana_leap',
    'mirana_starfall',
    'wisp_overcharge',
    'wisp_relocate',
    'wisp_spirits_in',
    'wisp_spirits',
    'wisp_tether',
    'slark_pounce',
    'slark_shadow_dance',
    'slark_dark_pact',
    'monkey_king_boundless_strike',
    'monkey_king_mischief',
    'monkey_king_primal_spring',
    'monkey_king_tree_dance',
    'monkey_king_untransform',
    'monkey_king_wukongs_command',
    'weaver_time_lapse',
    'weaver_the_swarm',
    'weaver_shukuchi',
    'tusk_walrus_punch',
    'tusk_walrus_kick',
    'tusk_tag_team',
    'tusk_snowball',
    'tusk_ice_shards',
    'terrorblade_sunder',
    'terrorblade_reflection',
    'terrorblade_metamorphosis',
    'terrorblade_conjure_image',
    'naga_siren_ensnare',
    'naga_siren_mirror_image',
    'naga_siren_song_of_the_siren',
    'naga_siren_song_of_the_siren_cancel',
    'venomancer_venomous_gale',
    'venomancer_poison_nova',
    'venomancer_plague_ward',
    'spectre_spectral_dagger',
    'spectre_reality',
    'spectre_haunt',
    'brewmaster_cinder_brew',
    'brewmaster_drunken_brawler',
    'brewmaster_primal_split',
    'brewmaster_thunder_clap',
    'tinker_heat_seeking_missile',
    'tinker_laser',
    'tinker_march_of_the_machines',
    'tinker_rearm',
    'windrunner_focusfire',
    'windrunner_powershot',
    'windrunner_shackleshot',
    'windrunner_windrun',
    'visage_grave_chill',
    'visage_soul_assumption',
    'visage_summon_familiars',
    'spirit_breaker_bulldoze',
    'spirit_breaker_charge_of_darkness',
    'spirit_breaker_nether_strike',
    'rattletrap_battery_assault',
    'rattletrap_hookshot',
    'rattletrap_overclocking',
    'rattletrap_power_cogs',
    'rattletrap_rocket_flare',
    'pudge_dismember',
    'pudge_meat_hook',
    'pudge_rot',
    'shredder_chakram',
    'shredder_chakram_2',
    'shredder_return_chakram',
    'shredder_return_chakram_2',
    'shredder_timber_chain',
    'shredder_whirling_death',
    'nyx_assassin_burrow',
    'nyx_assassin_impale',
    'nyx_assassin_mana_burn',
    'nyx_assassin_spiked_carapace',
    'nyx_assassin_unburrow',
    'nyx_assassin_vendetta',
    'phoenix_fire_spirits',
    'phoenix_icarus_dive',
    'phoenix_icarus_dive_stop',
    'phoenix_launch_fire_spirit',
    'phoenix_sun_ray',
    'phoenix_sun_ray_stop',
    'phoenix_sun_ray_toggle_move',
    'phoenix_ability',
    'alchemist_acid_spray',
    'alchemist_chemical_rage',
    'alchemist_unstable_concoction',
    'alchemist_unstable_concoction_throw',
    'lycan_howl',
    'lycan_shapeshift',
    'lycan_summon_wolves',
    'lycan_wolf_bite',
    'troll_warlord_battle_trance',
    'troll_warlord_berserkers_rage',
    'troll_warlord_whirling_axes_melee',
    'troll_warlord_whirling_axes_ranged',
    'beastmaster_call_of_the_wild_boar',
    'beastmaster_call_of_the_wild_hawk',
    'beastmaster_primal_roar',
    'beastmaster_wild_axes',
    'broodmother_insatiable_hunger',
    'broodmother_spawn_spiderlings',
    'broodmother_spin_web',
    'hoodwink_acorn_shot',
    'hoodwink_bushwhack',
    'hoodwink_scurry',
    'hoodwink_sharpshooter',
    'grimstroke_ink_over',
    'shredder_flamethrower',
    'naga_siren_rip_tide',
}

--将英雄技能初始入变量
local abilityQ = sAbilityList[1]
local abilityW = sAbilityList[2]
local abilityE = sAbilityList[3]
local abilityD = sAbilityList[4]
local abilityF = sAbilityList[5]
local abilityR = sAbilityList[6]

local abilityExtra1 = sAbilityList[7]
local abilityExtra2 = sAbilityList[8]
local abilityExtra3 = sAbilityList[9]

--初始化技能欲望与点变量
local castDesire = {
    ['Q'] = 0,
    ['W'] = 0,
    ['E'] = 0,
    ['D'] = 0,
    ['F'] = 0,
    ['R'] = 0,
    ['R'] = 0,
    ['E1'] = 0,
    ['E2'] = 0,
    ['E3'] = 0,
}

local castTarget = {
    ['Q'] = nil,
    ['W'] = nil,
    ['E'] = nil,
    ['D'] = nil,
    ['F'] = nil,
    ['R'] = nil,
    ['E1'] = nil,
    ['E2'] = nil,
    ['E3'] = nil,
}

local castName = {
    ['Q'] = nil,
    ['W'] = nil,
    ['E'] = nil,
    ['D'] = nil,
    ['F'] = nil,
    ['R'] = nil,
    ['E1'] = nil,
    ['E2'] = nil,
    ['E3'] = nil,
}

--尝试加载技能数据
function SearchAbilityList(list, hero)
    if next(list) ~= nil then
        for _,value in pairs(list) do
            if value == hero then
                return true;
            end
		end
	end
	
    return false;
end

local Consider = {}

if SearchAbilityList(abilityNameList,abilityQ) and xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityQ) then
    Consider['Q'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityQ )
    castName['Q'] = abilityQ
else
    Consider['Q'] = nil
end
if SearchAbilityList(abilityNameList,abilityW) and xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityW) then
    Consider['W'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityW )
    castName['W'] = abilityW
else
    Consider['W'] = nil
end
if SearchAbilityList(abilityNameList,abilityE) and xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityE) then
    Consider['E'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityE )
    castName['E'] = abilityE
else
    Consider['E'] = nil
end
if SearchAbilityList(abilityNameList,abilityR) and xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityR) then
    Consider['R'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityR )
    castName['R'] = abilityR
else
    Consider['R'] = nil
    castName['R'] = nil
end
if SearchAbilityList(abilityNameList,abilityD) and xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityD) and abilityD ~= 'rubick_empty1' then
    Consider['D'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityD )
    castName['D'] = abilityD
else
    Consider['D'] = nil
    castName['D'] = nil
end
if SearchAbilityList(abilityNameList,abilityF) and xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityF) and abilityF ~= 'rubick_empty2' then
    Consider['F'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityF )
    castName['F'] = abilityF
else
    Consider['F'] = nil
    castName['F'] = nil
end
if SearchAbilityList(abilityNameList,abilityExtra1) and xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityExtra1) then
    Consider['E1'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityExtra1 )
    castName['E1'] = abilityExtra1
else
    Consider['E1'] = nil
    castName['E1'] = nil
end
if SearchAbilityList(abilityNameList,abilityExtra2) and xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityExtra2) then
    Consider['E2'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityExtra2 )
    castName['E2'] = abilityExtra2
else
    Consider['E2'] = nil
    castName['E2'] = nil
end
if SearchAbilityList(abilityNameList,abilityExtra3) and xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityExtra3) then
    Consider['E3'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityExtra3 )
    castName['E3'] = abilityExtra3
else
    Consider['E3'] = nil
    castName['E3'] = nil
end

if BotsInit["ABATiYanMa"] ~= nil then
    if SearchAbilityList(abilityNameList,abilityQ) and xpcall(function(loadAbility) require( 'game/AI锦囊/技能模组/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityQ) then
        Consider['Q'] = require( 'game/AI锦囊/技能模组/'..abilityQ )
    end
    if SearchAbilityList(abilityNameList,abilityW) and xpcall(function(loadAbility) require( 'game/AI锦囊/技能模组/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityW) then
        Consider['W'] = require( 'game/AI锦囊/技能模组/'..abilityW )
    end
    if SearchAbilityList(abilityNameList,abilityE) and xpcall(function(loadAbility) require( 'game/AI锦囊/技能模组/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityE) then
        Consider['E'] = require( 'game/AI锦囊/技能模组/'..abilityE )
    end
    if SearchAbilityList(abilityNameList,abilityR) and xpcall(function(loadAbility) require( 'game/AI锦囊/技能模组/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityR) then
        Consider['R'] = require( 'game/AI锦囊/技能模组/'..abilityR )
    end
    if SearchAbilityList(abilityNameList,abilityD) and xpcall(function(loadAbility) require( 'game/AI锦囊/技能模组/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityD) then
        Consider['D'] = require( 'game/AI锦囊/技能模组/'..abilityD )
    end
    if SearchAbilityList(abilityNameList,abilityF) and xpcall(function(loadAbility) require( 'game/AI锦囊/技能模组/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityF) then
        Consider['F'] = require( 'game/AI锦囊/技能模组/'..abilityF )
    end
    if SearchAbilityList(abilityNameList,abilityExtra1) and xpcall(function(loadAbility) require( 'game/AI锦囊/技能模组/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityExtra1) then
        Consider['E1'] = require( 'game/AI锦囊/技能模组/'..abilityExtra1 )
    end
    if SearchAbilityList(abilityNameList,abilityExtra2) and xpcall(function(loadAbility) require( 'game/AI锦囊/技能模组/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityExtra2) then
        Consider['E2'] = require( 'game/AI锦囊/技能模组/'..abilityExtra2 )
    end
    if SearchAbilityList(abilityNameList,abilityExtra3) and xpcall(function(loadAbility) require( 'game/AI锦囊/技能模组/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityExtra3) then
        Consider['E3'] = require( 'game/AI锦囊/技能模组/'..abilityExtra3 )
    end
end

-- order技能检查顺序 {q,w,e,r}
function X.Skills(order)

    if (bot:GetUnitName() == 'npc_dota_hero_rubick')
    then
        sAbilityList = J.Skill.GetAbilityList(bot)
        abilityQ = sAbilityList[1]
        abilityD = sAbilityList[4]
        abilityF = sAbilityList[5]
        if abilityQ ~= castName['Q'] or abilityD ~= castName['D'] or abilityF ~= castName['F'] then
            if SearchAbilityList(abilityNameList,abilityQ) and xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityQ) then
                Consider['Q'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityQ )
                castName['Q'] = abilityQ
            else
                Consider['Q'] = nil
                castName['Q'] = nil
            end
            if SearchAbilityList(abilityNameList,abilityD) and xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityD) and abilityD ~= 'rubick_empty1' then
                Consider['D'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityD )
                castName['D'] = abilityD
            else
                Consider['D'] = nil
                castName['D'] = nil
            end
            if SearchAbilityList(abilityNameList,abilityF) and xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityF) and abilityF ~= 'rubick_empty2' then
                Consider['F'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityF )
                castName['F'] = abilityF
            else
                Consider['F'] = nil
                castName['F'] = nil
            end
        end
    end

    for ability,desire in pairs(Consider) do
        if desire ~= nil
        then
            castDesire[ability], castTarget[ability] = desire.Consider()
        end
    end

    for _,abilityorder in pairs(order) do
        if castDesire[abilityorder] ~= nil
           and castDesire[abilityorder] > 0 
           and Consider[abilityorder] ~= nil
        then
            local cast = castTarget[abilityorder]
            local release = Consider[abilityorder].Release(cast, castDesire)
            if release == false then
                return false;
            else
                return true;
            end
        end
    end

    return false;
end

--技能组合           s技能组  n欲望信息 b联合行动
function SkillsCombo(skill, consider, joint)
    local ComboConsider = nil

    if joint then

        local nArreysTeam = GetTeamMember(GetTeam());  
        local nArreysAbility = {};--所有队友（包括自己）的技能数据
        local nskillList = {};--技能组合数据

        for i,Arrey in pairs(nArreysTeam)
        do
            local heroId = Arrey:GetPlayerID()
            local heroName = GetSelectedHeroName(heroId)
            local heroAbility = J.Skill.GetAbilityList(Arrey)

            nArreysAbility[i] = {
                ['hero'] = Arrey,
                ['player'] = heroId,
                ['name'] = heroName,
                ['abilitys'] = heroAbility,
                ['bot'] = IsPlayerBot(heroId),
            }
        end

        for _,ability in pairs(skill)
        do
            local multiple = string.find(ability, ':')
            local jointHero = string.sub(ability, 1, multiple - 1)
            local jointability = string.sub(ability, multiple + 1)
            local jointabilitys = nil
            local jointbot = nil

            for _,arreyAbility in pairs(nArreysAbility)
            do
                if arreyAbility['name'] == jointHero and arreyAbility['bot'] then
                    jointabilitys = arreyAbility['abilitys']
                    jointbot = arreyAbility['hero']
                end
            end

            if jointabilitys ~= nil then
                if jointability == 'Q' then
                    jointability = jointabilitys[1]
                elseif jointability == 'W' then
                    jointability = jointabilitys[2]
                elseif jointability == 'E' then
                    jointability = jointabilitys[3]
                elseif jointability == 'D' then
                    jointability = jointabilitys[4]
                elseif jointability == 'F' then
                    jointability = jointabilitys[5]
                elseif jointability == 'R' then
                    jointability = jointabilitys[6]
                end
            end
            --jointability此时为技能名
            if jointbot ~= nil then
                nskillList[ability] = {
                    ['ability'] = jointability,--释放的技能
                    ['bot'] = jointbot--由谁来释放
                }
            end

        end
        
        --此时nskillList中包含组合释放的技能、技能释放人和技能释放顺序，如果技能释放人为玩家控制，则跳过该技能
        
        if xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, consider) then
            ComboConsider = require(GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..consider)
        else
            ComboConsider = nil
        end

        if ComboConsider ~= nil then
            --欲望和释放怎么写啊%￥&*……￥
        end


    end

end

--装备组处理
function X.Combination(tGroupedDataList, tDefaultGroupedData,chineseConversion)
    if chineseConversion == nil then chineseConversion = false end

    --获取随机一组数据
    if #tGroupedDataList > 0 then
        tGroupedDataList = tGroupedDataList[RandomInt(1,#tGroupedDataList)]

        --检查数据是否缺失，如果缺失则使用默认数据
        for item,datalist in pairs(tGroupedDataList) do
            if datalist == nil or #datalist == 0 then
                tGroupedDataList[item] = tDefaultGroupedData[item]
            end
        end

    else
        tGroupedDataList = tDefaultGroupedData
    end
    --处理天赋树
    tGroupedDataList['Talent'] = J.Skill.GetTalentBuild(tGroupedDataList['Talent'])
    --处理中文转换
    if chineseConversion then
        for i,Buy in pairs(tGroupedDataList['Buy']) do
            tGroupedDataList['Buy'][i] = J.Chat.GetRawItemName(Buy)
        end
        for i,Sell in pairs(tGroupedDataList['Sell']) do
            tGroupedDataList['Sell'][i] = J.Chat.GetRawItemName(Sell)
        end
    end
    --返回数据
    return tGroupedDataList['Ability'], tGroupedDataList['Talent'], tGroupedDataList['Buy'], tGroupedDataList['Sell']
end

function errc(err)
    return true;
end

return X