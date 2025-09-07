SaveSystem = class()

function SaveSystem:save()
    local data = {
        coins = player.coins,
        food = player.food,
        dna = player.dna,
        dinos = dinos.dinos
    }
    saveProjectData("playerSave", json.encode(data))
end

function SaveSystem:load()
    local raw = readProjectData("playerSave")
    if raw then
        local data = json.decode(raw)
        player.coins = data.coins or 0
        player.food = data.food or 0
        player.dna = data.dna or 0
        dinos.dinos = data.dinos or {}
    end
end
