---@diagnostic disable
dofile("data/scripts/lib/mod_settings.lua")

function mod_setting_change_callback( mod_id, gui, in_main_menu, setting, old_value, new_value  )
	print( tostring(new_value) )
end

local currentLang = GameTextGetTranslatedOrNot("$current_language")

local poly_list_name = "Polymorph List"
local poly_list_desc = "Click to enable & disable creatures you can chaotic polymorph into \nLeft click to enable, Right click to disable \n \nYou need at least 2 creatures enabled for the mod to work properly."
local poly_enable_all_name = "[Enable All]"
local poly_disable_all_name = "[Disable All]"
local poly_vanilla_all_name = "[Reset to Default]"

local monsterpath = "data/entities/animals/"

--If mode is true then add to table, otherwise we are removing
function EditPolyTable(mode,filename,specialpath)
  local filepath = "data/entities/animals/"
  if specialpath then
    filepath = specialpath
  end

  --Creates a valid filepath with various bits of data
  filepath = table.concat({filepath,filename,".xml"})
  --GamePrint(filepath)
  --[[
  local polytable = PolymorphTableGet(false)
  for k=1,#polytable
  do local v = polytable[k]
    GamePrint("Polymorph table is " .. tostring(v))
  end
  ]]--

  if mode == true then
    PolymorphTableAddEntity(filepath, false, true)
    --GamePrint("Added")
  else
    PolymorphTableRemoveEntity(filepath, true, true)
    GamePrint(filepath)
    GamePrint("Removed")
  end
end


local mod_id = "global_poly"
mod_settings_version = 1

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
                  for k=1,#poly_control_options
                  do local enemy = poly_control_options[k]
                    ModSettingSetNextValue("global_poly.poly_toggle_" .. enemy.file, true, false)
                    --PolymorphTableAddEntity((enemy.uniquepath or monsterpath) .. enemy.file .. ".xml", false, true)
                    EditPolyTable(true,enemy.file,enemy.uniquepath or false)
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
                  for k=1,#poly_control_options
                  do local enemy = poly_control_options[k]
                    ModSettingSetNextValue("global_poly.poly_toggle_" .. enemy.file, false, false)
                    --PolymorphTableRemoveEntity((enemy.uniquepath or monsterpath) .. enemy.file .. ".xml", true, true)
                    EditPolyTable(false,enemy.file,enemy.uniquepath or false)
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
                  for k=1,#poly_control_options
                  do local enemy = poly_control_options[k]
                    ModSettingSetNextValue("global_poly.poly_toggle_" .. enemy.file, false, false)
                    PolymorphTableRemoveEntity((enemy.uniquepath or monsterpath) .. enemy.file .. ".xml", true, true)
                    EditPolyTable(false,enemy.file,enemy.uniquepath or false)
                  end
                  
                  for k=1,#vanilla_poly_pool
                  do local enemy = vanilla_poly_pool[k]
                    ModSettingSetNextValue("global_poly.poly_toggle_" .. enemy, true, false)
                    PolymorphTableAddEntity(monsterpath .. enemy .. ".xml", false, true)
                    EditPolyTable(false,enemy,enemy.uniquepath or false)
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
                      GuiLayoutBeginHorizontal(gui, 0, 0, false, 6, 6)
                          local count = 0
                          for _, enemy in ipairs(poly_control_options) do
                              if enemy.name:upper():match((ModSettingGetNextValue("global_poly.polyquery") or ""):upper()) then
                                  if count % 14 == 0 then
                                      GuiLayoutEnd(gui)
                                      GuiLayoutBeginHorizontal(gui, 0, 0, false, 6, 6)
                                  end
                                  GuiOptionsAddForNextWidget(gui, 28)
                                  GuiOptionsAddForNextWidget(gui, 8)
                                  GuiOptionsAddForNextWidget(gui, 6)
                                  local path = "data/ui_gfx/animal_icons/"
                                  if ModSettingGetNextValue(("global_poly.poly_toggle_" .. enemy.file) or false) == false then GuiOptionsAddForNextWidget(gui, 26) end
                                  local lmb, rmb = GuiImageButton(gui, im_id + #poly_control_options + count, 0, 0, "", table.concat({path,(enemy.uniquegfx or enemy.file),".png"}))
                                  GuiTooltip(gui, enemy.name, "")
                                  if lmb then
                                    ModSettingSetNextValue("global_poly.poly_toggle_" .. enemy.file, true, false)
                                    --PolymorphTableAddEntity((enemy.uniquepath or monsterpath) .. enemy.file .. ".xml", false, true)
                                    EditPolyTable(true,enemy.file,enemy.uniquepath or false)
                                    --GamePrint("enabled " .. enemy.name)
                                  end
                                  if rmb then
                                    ModSettingSetNextValue("global_poly.poly_toggle_" .. enemy.file, false, false)
                                    --PolymorphTableRemoveEntity((enemy.uniquepath or monsterpath) .. enemy.file .. ".xml", true, true)
                                    EditPolyTable(false,enemy.file,enemy.uniquepath or false)
                                    --GamePrint("disabled " .. enemy.name)
                                  end
                                  count = count + 1
                              end
                          end
                      GuiLayoutEnd(gui)
                  else
                      GuiLayoutBeginHorizontal(gui, 0, 0, false, 5, 5)
                          GuiImage(gui, im_id, 0, 0, "data/ui_gfx/inventory/icon_warning.png", 1, 1, 1)
                          GuiColorSetForNextWidget(gui, 0.9, 0.4, 0.4, 0.9)
                          GuiText(gui, 0, 2, "Please open this menu in-game to edit the chaotic polymorph options!")
                      GuiLayoutEnd(gui)
                  end
                  mod_setting_tooltip(mod_id, gui, in_main_menu, setting)
              end
          },
      },
    },
  }
end

function ModSettingsUpdate( init_scope )
	local old_version = mod_settings_get_version( mod_id )
	mod_settings_update( mod_id, mod_settings, init_scope )

  
end

function ModSettingsGuiCount()
	return mod_settings_gui_count( mod_id, mod_settings )
end

function ModSettingsGui( gui, in_main_menu )
	mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )
end