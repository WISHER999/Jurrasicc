DinoManager = class()

function DinoManager:init()
    self.dinos = {}
end

function DinoManager:addBatch()
    for i = 1, 30 do table.insert(self.dinos, "Dino_"..i) end
    for i = 1, 15 do table.insert(self.dinos, "Hybrid_"..i) end
    for i = 1, 5 do table.insert(self.dinos, "Apex_"..i) end
    table.insert(self.dinos, "Omega_1")
end
