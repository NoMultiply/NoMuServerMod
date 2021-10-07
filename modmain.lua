GLOBAL.setmetatable(
        env,
        {
            __index = function(t, k)
                return GLOBAL.rawget(GLOBAL, k)
            end
        }
)

if GetModConfigData("super_reskin") then
    local reskin_fx_info = {
        abigail = { offset = 1.3, scale = 1.3 },
        arrowsign_post = { offset = 0.9, scale = 1.2 },
        beebox = { scale = 1.4 },
        bernie_big = { offset = 1.2, scale = 1.8 },
        birdcage = { offset = 1.2, scale = 1.8 },
        bugnet = { offset = 0.4 },
        campfire = { scale = 1.2 },
        cane = { offset = 0.4 },
        coldfirepit = { scale = 1.2 },
        cookpot = { offset = 0.5, scale = 1.4 },
        critter_dragonling = { offset = 0.8 },
        critter_glomling = { offset = 0.8 },
        dragonflyfurnace = { offset = 0.6, scale = 1.8 },
        endtable = { offset = 0.2, scale = 1.3 },
        featherfan = { scale = 1.3 },
        featherhat = { scale = 1.1 },
        fence = { offset = 0.1, scale = 1.2 },
        fence_gate = { offset = 0.2, scale = 1.3 },
        firepit = { scale = 1.2 },
        firestaff = { offset = 0.4 },
        firesuppressor = { offset = 0.5, scale = 1.5 },
        goldenshovel = { offset = 0.2 },
        grass_umbrella = { offset = 0.4 },
        greenstaff = { offset = 0.4 },
        hambat = { offset = 0.2 },
        icebox = { offset = 0.3, scale = 1.3 },
        icestaff = { offset = 0.4 },
        lightning_rod = { offset = 0.8, scale = 1.3 },
        mast = { offset = 4, scale = 2 },
        meatrack = { offset = 1, scale = 1.7 },
        mushroom_light = { offset = 1.2, scale = 1.4 },
        mushroom_light2 = { offset = 1.2, scale = 1.8 },
        nightsword = { offset = 0.2 },
        opalstaff = { offset = 0.4 },
        orangestaff = { offset = 0.4 },
        pighouse = { offset = 1.5, scale = 2.2 },
        rabbithouse = { offset = 1.5, scale = 2.2 },
        rainometer = { offset = 0.9, scale = 1.6 },
        researchlab2 = { offset = 0.5, scale = 1.4 },
        researchlab3 = { offset = 0.5, scale = 1.4 },
        researchlab4 = { offset = 0.5, scale = 1.4 },
        ruins_bat = { offset = 0.4, scale = 1.2 },
        saltbox = { offset = 0.3, scale = 1.3 },
        shovel = { offset = 0.2 },
        spear = { offset = 0.4 },
        spear_wathgrithr = { offset = 0.4 },
        tent = { offset = 0.4, scale = 2.0 },
        treasurechest = { offset = 0.1, scale = 1.1 },
        umbrella = { offset = 0.4 },
        wardrobe = { offset = 0.5, scale = 1.4 },
        winterometer = { offset = 0.8, scale = 1.3 },
        yellowstaff = { offset = 0.4 },
    }

    local function spellCB(tool, target, pos)
        local fx_prefab = "explode_reskin"
        local skin_fx = SKIN_FX_PREFAB[tool:GetSkinName()]
        if skin_fx ~= nil and skin_fx[1] ~= nil then
            fx_prefab = skin_fx[1]
        end

        local fx = SpawnPrefab(fx_prefab)

        target = target or tool.components.inventoryitem.owner --if no target, then get the owner of the tool. Self target for beards

        local fx_info = reskin_fx_info[target.prefab] or {}

        local scale_override = fx_info.scale or 1
        fx.Transform:SetScale(scale_override, scale_override, scale_override)

        local fx_pos_x, fx_pos_y, fx_pos_z = target.Transform:GetWorldPosition()
        fx_pos_y = fx_pos_y + (fx_info.offset or 0)
        fx.Transform:SetPosition(fx_pos_x, fx_pos_y, fx_pos_z)

        tool:DoTaskInTime(0, function()

            local prefab_to_skin = target.prefab
            local is_beard = false
            if target.components.beard ~= nil and target.components.beard.is_skinnable then
                prefab_to_skin = target.prefab .. "_beard"
                is_beard = true
            end

            if target:IsValid() and tool:IsValid() then
                local curr_skin = is_beard and target.components.beard.skinname or target.skinname
                local search_for_skin = tool._cached_reskinname[prefab_to_skin] ~= nil --also check if it's owned
                local new_creator = tool.parent.userid;
                local someone_has_cache = false
                if tool._cached_reskinname[prefab_to_skin] ~= nil then
                    for _, player in pairs(AllPlayers) do
                        if TheInventory:CheckClientOwnership(player.userid, tool._cached_reskinname[prefab_to_skin]) then
                            someone_has_cache = true;
                            new_creator = player.userid;
                            break
                        end
                    end
                end
                if curr_skin == tool._cached_reskinname[prefab_to_skin] or (search_for_skin and not someone_has_cache) then
                    --TheInventory:CheckClientOwnership(tool.parent.userid, tool._cached_reskinname[prefab_to_skin])) then
                    local new_reskinname = nil
                    if PREFAB_SKINS[prefab_to_skin] ~= nil then
                        for _, item_type in pairs(PREFAB_SKINS[prefab_to_skin]) do
                            if search_for_skin then
                                if tool._cached_reskinname[prefab_to_skin] == item_type then
                                    search_for_skin = false
                                end
                            else
                                local someone_has = false
                                for _, player in pairs(AllPlayers) do
                                    if TheInventory:CheckClientOwnership(player.userid, item_type) then
                                        new_creator = player.userid;
                                        someone_has = true
                                        break
                                    end
                                end
                                --if TheInventory:CheckClientOwnership(tool.parent.userid, item_type) then
                                if someone_has then
                                    print("!!! find", new_creator, 'has', item_type)
                                    new_reskinname = item_type
                                    break
                                end
                            end
                        end
                    end
                    tool._cached_reskinname[prefab_to_skin] = new_reskinname
                end

                if is_beard then
                    target.components.beard:SetSkin(tool._cached_reskinname[prefab_to_skin])
                else
                    --TheSim:ReskinEntity(target.GUID, target.skinname, tool._cached_reskinname[prefab_to_skin], nil, tool.parent.userid)
                    TheSim:ReskinEntity(target.GUID, target.skinname, tool._cached_reskinname[prefab_to_skin], nil, new_creator)

                    --Todo(Peter): make this better one day if we do more skins applied to multiple prefabs in the future
                    if target.prefab == "wormhole" then
                        local other = target.components.teleporter.targetTeleporter
                        if other ~= nil then
                            --TheSim:ReskinEntity(other.GUID, other.skinname, tool._cached_reskinname[prefab_to_skin], nil, tool.parent.userid)
                            TheSim:ReskinEntity(other.GUID, other.skinname, tool._cached_reskinname[prefab_to_skin], nil, new_creator)
                        end
                    end
                end
            end
        end)
    end

    local function can_cast_fn(doer, target, pos)

        local prefab_to_skin = target.prefab
        local is_beard = false

        if table.contains(DST_CHARACTERLIST, prefab_to_skin) then
            --We found a player, check if it's us
            if doer.userid == target.userid and target.components.beard ~= nil and target.components.beard.is_skinnable then
                prefab_to_skin = target.prefab .. "_beard"
                is_beard = true
            else
                return false
            end
        end

        if PREFAB_SKINS[prefab_to_skin] ~= nil then
            for _, item_type in pairs(PREFAB_SKINS[prefab_to_skin]) do
                for _, player in pairs(AllPlayers) do
                    if TheInventory:CheckClientOwnership(player.userid, item_type) then
                        return true;
                    end
                end
                --if TheInventory:CheckClientOwnership(doer.userid, item_type) then
                --    return true
                --end
            end
        end

        --Is there a skin to turn off?
        local curr_skin = is_beard and target.components.beard.skinname or target.skinname
        if curr_skin ~= nil then
            return true
        end

        return false
    end

    local function tool_fn(inst)
        if GLOBAL.TheWorld.ismastersim then
            inst.components.spellcaster:SetSpellFn(spellCB)
            inst.components.spellcaster:SetCanCastFn(can_cast_fn)
        end
    end

    AddPrefabPostInit("reskin_tool", tool_fn)
end

local infinite_items = {
    { 'orangestaff', '懒人魔杖' },
    { 'golden_farm_hoe', '黄金园艺锄' },
    { 'goldenshovel', '黄金铲子' },
    { 'panflute', '排箫' },
    { 'glasscutter', '玻璃刀' },
}
for _, item in ipairs(infinite_items) do
    if GetModConfigData("infinite_" .. item[1]) then
        local function item_fn(inst)
            if GLOBAL.TheWorld.ismastersim then
                local old_finiteuses = inst.components.finiteuses
                if old_finiteuses ~= nil then
                    inst.components.finiteuses = setmetatable({}, {
                        __index = function(k, v)
                            if type(old_finiteuses[v]) == 'function' then
                                return function(...)
                                end
                            end
                            if type(old_finiteuses[v]) == 'number' then
                                return 1
                            end
                        end
                    })
                end
            end
        end
        AddPrefabPostInit(item[1], item_fn)
    end
end

local extra_things = {
    { 'orangestaff', '懒人魔杖' },
    { 'golden_farm_hoe', '黄金园艺锄' },
    { 'goldenshovel', '黄金铲子' },
    { 'reskin_tool', '清洁扫把' },
}

if GetModConfigData("spawn_tips") or GetModConfigData("extra_things") then
    AddComponentPostInit("playerspawner", function(OnPlayerSpawn, inst)
        inst:ListenForEvent("ms_playerjoined", function(self, player)
            if not (player and player.components) then
                return
            end
            player:DoTaskInTime(3, function(target)
                if GetModConfigData("spawn_tips") then
                    if target.components and target.components.talker then
                        local welcome_tips = target:GetDisplayName() .. '，欢迎来到挂机刷礼物豪华档！\n右键点击自己可以跳跃去其他岛玩耍，\n想海钓或想要宠物可以找管理员，\n任何搞破坏的行为（炸船，烧家等）将永久封禁。\n上缴基础材料（树枝、草、燧石等）可以在管理这换好东西。';
                        target.components.talker:Say(welcome_tips, 10)
                    end
                end
                if GetModConfigData("extra_things") then
                    for _, item_name in ipairs(extra_things) do
                        if not player.components.inventory:IsFull() and not player.components.inventory:Has(item_name[1], 1) then
                            local item = GLOBAL.SpawnPrefab(item_name[1])
                            local eslot = item.components.equippable.equipslot
                            local olditem = player.components.inventory.equipslots[eslot]
                            if olditem ~= nil and olditem.prefab == item_name[1] then
                                item:Remove()
                            else
                                player.components.inventory:GiveItem(item)
                            end
                        end
                    end
                end
            end)
        end)
    end)
end