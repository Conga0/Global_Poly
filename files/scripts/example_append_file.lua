--Example append file for modders

--This table contains every creature in your mod, this will appear in the polymorph toggling UI
--Please input all necessary data mentioned in the steam forum
local all_creatures = {
    {
        file="ant_fire",
        name="Fire Ant",
    },
    {
        file="blob_big",
        name="Big Blob",
    },
    {
        file="blob_huge",
        name="Creepy Blob",
    },
    {
        file="blindgazer",
        name="Blindgazer",
    },
}

--These creatures are enabled by default when the player presses [Reset to Default]
--Note, this assumes the creature is inside the data/entities/animals folder
local enabled_by_default_creatures = {
    "ant_fire",
    "ant_suffocate",
    "blindgazer",
}

--append the all_creatures table to the poly_control_options table
for k=1,#all_creatures
do local v = all_creatures[k]
    table.insert(poly_control_options,v)
end

--append the enabled_by_default_creatures table to the vanilla_poly_pool table
for k=1,#enabled_by_default_creatures
do local v = enabled_by_default_creatures[k]
    table.insert(vanilla_poly_pool,v)
end