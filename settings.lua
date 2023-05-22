dofile("data/scripts/lib/mod_settings.lua")
--dofile_once("mods/global_poly/files/scripts/poly_pool.lua")

---@diagnostic disable-next-line: lowercase-global
function mod_setting_change_callback(mod_id, gui, in_main_menu, setting, old_value, new_value)
    print(tostring(new_value))
end

local currentLang = GameTextGetTranslatedOrNot("$current_language")
-- Could be handled with a table indexed by key/language: translations[currentLang].poly_list_name or translations["poly_list_name"][currentLang] or something /shrug -copi
local poly_list_name = "Polymorph List"
local poly_list_desc = "Click to enable & disable creatures you can chaotic polymorph into \nLeft click to enable, Right click to disable"
local poly_enable_all_name = "[Enable All]"
local poly_disable_all_name = "[Disable All]"
local poly_vanilla_all_name = "[Reset to Default]"
local poly_random_all_name = "[Randomise Pool]"

local monsterpath = "data/entities/animals/"

--If mode is true then add to table, otherwise we are removing
function EditPolyTable(mode,filename,specialpath)
  local filepath = "data/entities/animals/"
  if specialpath then
    filepath = specialpath
  end

  --Creates a valid filepath with various bits of data
  local newfilepath = table.concat({filepath,filename,".xml"})

  if mode == true then
    PolymorphTableAddEntity(newfilepath, false, true)
    ModSettingSetNextValue("global_poly.poly_toggle_" .. filename, true, false)
    if #PolymorphTableGet(false) < 3 then
      PolymorphTableRemoveEntity("data/entities/animals/poly_control_filler/sheep.xml", true, true)
    end
  else
    if #PolymorphTableGet(false) < 2 then
      PolymorphTableAddEntity("data/entities/animals/poly_control_filler/sheep.xml", false, true)
    end
    PolymorphTableRemoveEntity(newfilepath, true, true)
    ModSettingSetNextValue("global_poly.poly_toggle_" .. filename, false, false)
  end
end

if DebugGetIsDevBuild() and 1 == 2 then --If mod is loaded using debug build, then print using debug data  |  can change 1 == 2 to 1 == 1 to enable
  function EditPolyTable(mode,filename,specialpath)
    local filepath = "data/entities/animals/"
    if specialpath then
      filepath = specialpath
    end
  
    --Creates a valid filepath with various bits of data
    local newfilepath = table.concat({filepath,filename,".xml"})
  
    --[[
    ]]--
    local polytable = PolymorphTableGet(false)
    for k=1,#polytable
    do local v = polytable[k]
      print("Polymorph table is " .. tostring(v))
    end
  
    if mode == true then
      PolymorphTableAddEntity(newfilepath, false, true)
      ModSettingSetNextValue("global_poly.poly_toggle_" .. filename, true, false)
      print(table.concat({"ADDED: ",newfilepath}))
      if #PolymorphTableGet(false) < 3 then
        PolymorphTableRemoveEntity("data/entities/animals/poly_control_filler/sheep.xml", true, true)
        print("Removing emergency sheep, good work out there soldier!")
      end
    else
      if #PolymorphTableGet(false) < 2 then
        PolymorphTableAddEntity("data/entities/animals/poly_control_filler/sheep.xml", false, true)
        print("Adding emergency sheep as poly storage to prevent table reset!!")
      end
      PolymorphTableRemoveEntity(newfilepath, true, true)
      ModSettingSetNextValue("global_poly.poly_toggle_" .. filename, false, false)
      print(table.concat({"REMOVED: ",newfilepath}))
    end
  end
end

function ResetPolyTable(poly_table_disable,poly_table_enable)
  for k=1,#poly_table_disable
  do local enemy = poly_table_disable[k]
    EditPolyTable(false, enemy.file, enemy.uniquepath or false)
  end

  for k=1,#poly_table_enable
  do local enemy = poly_table_enable[k]
    EditPolyTable(true, enemy, false)
  end
end

function PolyControlSetup(main_menu_check,poly_1,poly_2)
  if HasFlagPersistent( "poly_control_firsttime_setup" ) == false and not main_menu_check then
    ResetPolyTable(poly_control_options,vanilla_poly_pool)
    AddFlagPersistent( "poly_control_firsttime_setup" )
  end
end

local mod_id = "global_poly"
---@diagnostic disable-next-line: lowercase-global
mod_settings_version = 1

---@diagnostic disable-next-line: lowercase-global
mod_settings = {
    {
        id = "warning",
        ui_name = "",
        ui_fn = function(mod_id, gui, in_main_menu, im_id, setting)
            if in_main_menu then
                GuiLayoutBeginHorizontal(gui, 0, 0, false, 5, 5)
                GuiImage(gui, im_id, 0, 0, "data/ui_gfx/inventory/icon_warning.png", 1, 1, 1)
                GuiColorSetForNextWidget(gui, 0.9, 0.4, 0.4, 0.9)
                GuiText(gui, 0, 2, "Poly Control is only functional on the beta branch of Noita! \n \n \nYou can enable the beta branch by right clicking Noita on steam \nGoing to properties \nclick on the Betas tab \nThen opt into NoitaBeta")
                GuiLayoutEnd(gui)
            end
        end
    },
}


if GameIsBetaBuild() then
    ---@diagnostic disable-next-line: lowercase-global
    mod_settings =
    {
        {
            id = "poly_enable_all",
            ui_name = "",
            ui_fn = function(mod_id, gui, in_main_menu, im_id, setting)
                if not in_main_menu then
                    GuiColorSetForNextWidget(gui, 0.9, 0.9, 0.9, 0.8)
                    local lmb = GuiButton(gui, im_id, mod_setting_group_x_offset, 0, poly_enable_all_name)
                    if lmb then
                        for k = 1, #poly_control_options
                        do
                            local enemy = poly_control_options[k]
                            --PolymorphTableAddEntity((enemy.uniquepath or monsterpath) .. enemy.file .. ".xml", false, true)
                            EditPolyTable(true, enemy.file, enemy.uniquepath or false)
                        end
                    end
                end
            end
        },
        {
            id = "poly_disable_all",
            ui_name = "",
            ui_fn = function(mod_id, gui, in_main_menu, im_id, setting)
                if not in_main_menu then
                    GuiColorSetForNextWidget(gui, 0.9, 0.9, 0.9, 0.8)
                    local lmb = GuiButton(gui, im_id, mod_setting_group_x_offset, 0, poly_disable_all_name)
                    if lmb then
                        for k = 1, #poly_control_options
                        do
                            local enemy = poly_control_options[k]
                            --PolymorphTableRemoveEntity((enemy.uniquepath or monsterpath) .. enemy.file .. ".xml", true, true)
                            EditPolyTable(false, enemy.file, enemy.uniquepath or false)
                        end
                    end
                end
            end
        },
        {
            id = "poly_vanilla_all",
            ui_name = "",
            ui_fn = function(mod_id, gui, in_main_menu, im_id, setting)
                if not in_main_menu then
                    GuiColorSetForNextWidget(gui, 0.9, 0.9, 0.9, 0.8)
                    local lmb = GuiButton(gui, im_id, mod_setting_group_x_offset, 0, poly_vanilla_all_name)
                    if lmb then
                        ResetPolyTable(poly_control_options,vanilla_poly_pool)
                    end
                end
            end
        },
        {
            id = "poly_random_all",
            ui_name = "",
            ui_fn = function(mod_id, gui, in_main_menu, im_id, setting)
                if not in_main_menu then
                    GuiColorSetForNextWidget(gui, 0.9, 0.9, 0.9, 0.8)
                    local lmb = GuiButton(gui, im_id, mod_setting_group_x_offset, 0, poly_random_all_name)
                    if lmb then
                        for k=1,#poly_control_options
                        do local enemy = poly_control_options[k]
                            if math.random(1,3) == 1 then
                                EditPolyTable(true, enemy.file, enemy.uniquepath or false)
                            else
                                EditPolyTable(false, enemy.file, enemy.uniquepath or false)
                            end
                        end
                    end
                end
            end
        },
        {
            category_id = "poly_toggler",
            ui_name = poly_list_name,
            ui_description = poly_list_desc,
            settings =
            {
                {
                    id = "poly_search",
                    ui_name = "",
                    ui_fn = function(mod_id, gui, in_main_menu, im_id, setting)
                        if not in_main_menu then
                            GuiLayoutBeginHorizontal(gui, mod_setting_group_x_offset, 0, false, 0, 6)
                            GuiColorSetForNextWidget(gui, 1.0, 1.0, 1.0, 0.5)
                            GuiText(gui, 0, 0, "Search: ")
                            local query = tostring(ModSettingGetNextValue("global_poly.polyquery") or "")
                            local query_new = GuiTextInput(gui, im_id, 0, 0, query, 200, 100, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 ")
                            if query ~= query_new then
                                ModSettingSetNextValue("global_poly.polyquery", query_new, false)
                            end
                            GuiLayoutEnd(gui)
                        end
                    end
                },
                {
                    id = "poly_menu",
                    ui_name = "",
                    ui_fn = function(mod_id, gui, in_main_menu, im_id, setting)
                        if not in_main_menu then
                            dofile_once("mods/global_poly/files/scripts/poly_pool.lua")
                            PolyControlSetup(in_main_menu,poly_control_options,vanilla_poly_pool)
                            GuiIdPushString(gui, "global_poly_menu")
                            GuiLayoutBeginHorizontal(gui, 0, 0, false, 6, 6)
                            local count = 0
                            for i=1, #poly_control_options do
                                local enemy = poly_control_options[i]
                                if enemy.name:upper():match(tostring(ModSettingGetNextValue("global_poly.polyquery") or ""):upper()) then
                                    local setting_id = "global_poly.poly_toggle_" .. enemy.file
                                    local old_value = (ModSettingGetNextValue(setting_id) or false)
                                    if count % 14 == 0 then
                                        GuiLayoutEnd(gui)
                                        GuiLayoutBeginHorizontal(gui, 0, 0, false, 6, 6)
                                    end
                                    GuiOptionsAddForNextWidget(gui, 28)
                                    GuiOptionsAddForNextWidget(gui, 4)
                                    GuiOptionsAddForNextWidget(gui, 6)
                                    if not old_value then GuiOptionsAddForNextWidget(gui, 26) end
                                    local path = "data/ui_gfx/animal_icons/"
                                    local lmb, rmb = GuiImageButton(gui, count, 0, 0, "", table.concat({ path, (enemy.uniquegfx or enemy.file), ".png" }))
                                    GuiTooltip(gui, enemy.name, "")
                                    if lmb then
                                        GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos())
                                        ModSettingSetNextValue(setting_id, true, false)
                                        --Conga: I know you want it to toggle here and reset on default down there, but I feel like this system works better honestly
                                        --Less user-error risk for accidental double-clicks and more intuitive overall
                                        --"why does right click randomly disable some stuff but enable others?!?!?!?! Your mod is broken! pls fix!!!" - Quote from user titled 'readn't mc noreaderson' who didn't read how to use the mod
                                        --
                                        --Check ResetPolyTable function for how poly table reset works
                                        --Essentially, it removes everything from the poly list
                                        --Then it re-adds everything from the vanilla_poly_pool list
                                        --
                                        --ModSettingSetNextValue(setting_id, not old_value, false)
                                        EditPolyTable(true, enemy.file, enemy.uniquepath or false)
                                    end
                                    if rmb then
                                        GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos())
                                        ModSettingSetNextValue(setting_id, false, false)    -- Copi: Please make this reset to the default value, I cant figure out how you handled that
                                        EditPolyTable(false, enemy.file, enemy.uniquepath or false)
                                    end
                                    count = count + 1
                                end
                            end
                            GuiLayoutEnd(gui)
                            GuiIdPop(gui)
                        else    -- In main menu warning
                            GuiLayoutBeginHorizontal(gui, 0, 0, false, 5, 5)
                            GuiImage(gui, im_id, 0, 0, "data/ui_gfx/inventory/icon_warning.png", 1, 1, 1)
                            GuiColorSetForNextWidget(gui, 0.9, 0.4, 0.4, 0.9)
                            GuiText(gui, 0, 2, "Please open this menu in-game to edit the chaotic polymorph options!")
                            GuiLayoutEnd(gui)
                        end
                    end
                },
            },
        },
    }
end

function ModSettingsUpdate(init_scope)
    ---@diagnostic disable-next-line: undefined-global
    local old_version = mod_settings_get_version(mod_id)
    ---@diagnostic disable-next-line: undefined-global
    mod_settings_update(mod_id, mod_settings, init_scope)
end

function ModSettingsGuiCount()
    ---@diagnostic disable-next-line: undefined-global
    return mod_settings_gui_count(mod_id, mod_settings)
end

function ModSettingsGui(gui, in_main_menu)
    ---@diagnostic disable-next-line: undefined-global
    mod_settings_gui(mod_id, mod_settings, gui, in_main_menu)
end
