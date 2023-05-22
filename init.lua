--Nothing to see here

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

function OnWorldInitialized()
    dofile_once("mods/global_poly/files/scripts/poly_pool.lua")
    for k=1,#poly_control_options
    do local enemy = poly_control_options[k]
        local setting_id = ModSettingGetNextValue("global_poly.poly_toggle_" .. enemy.file)
        if setting_id == true then
            EditPolyTable(true, enemy.file, enemy.uniquepath or false)
        else
            EditPolyTable(false, enemy.file, enemy.uniquepath or false)
        end
    end

    --Hack to fix sheep being inserted for some reason???
    if #PolymorphTableGet(false) > 1 then
        PolymorphTableRemoveEntity("data/entities/animals/poly_control_filler/sheep.xml", true, true)
    end
end