DIVISOR = 4

local function reduce_tile_anim_speed(tiles)
    local new_tiles = {}

    for i, tile in ipairs(tiles) do
        if type(tile) == "table" then
            local t = table.copy(tile)

            if t.animation and t.animation.length then
                t.animation = table.copy(t.animation)
                t.animation.length = t.animation.length * DIVISOR
            end

            new_tiles[i] = t
        else
            new_tiles[i] = tile
        end
    end

    return new_tiles
end

local anim_nodes = {
    "glitch_nodes:white_noise",
    "glitch_nodes:white_noise_temp",
    "glitch_nodes:white_noise_ceiling",
    "glitch_nodes:white_noise_nonglow",
    "glitch_nodes:white_noise_movethrough",
    "glitch_nodes:rainbow_noise",
    "glitch_nodes:gateway",
    "glitch_nodes:savezone",
}

for _, name in ipairs(anim_nodes) do
    local def = core.registered_nodes[name]

    if def and def.tiles then
        core.override_item(name, {
            tiles = reduce_tile_anim_speed(def.tiles),
        })
    end
end

local old_particlespawner = core.add_particlespawner

core.add_particlespawner = function(def)
    -- Only target the electron particle
    if def.texture and type(def.texture) == "table" then
        if def.texture.name == "glitch_entities_electron_particle.png" then

            -- Reduce velocity
            if def.vel then
                def.vel = {
                    min = vector.multiply(def.vel.min, 0.25),
                    max = vector.multiply(def.vel.max, 0.25),
                }
            end

            -- Particle lifetime
            if def.exptime then
                def.exptime = {
                    min = def.exptime.min * 0.6,
                    max = def.exptime.max * 0.8,
                }
            end

            -- Reduce burst intensity
            def.amount = math.floor(def.amount * 0.25)

            -- Increase drag for gentler motion
            def.drag = vector.new(2, 2, 2)
        end
    end

    return old_particlespawner(def)
end