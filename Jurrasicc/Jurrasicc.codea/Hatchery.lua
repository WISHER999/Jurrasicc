Hatchery = class()

function Hatchery:init()
    self.queue = {}
end

function Hatchery:addToQueue(dinoName, hatchTime)
    table.insert(self.queue, {
        name = dinoName,
        start = ElapsedTime,
        duration = hatchTime
    })
end

function Hatchery:update()
    for i = #self.queue, 1, -1 do
        local hatch = self.queue[i]
        if ElapsedTime - hatch.start >= hatch.duration then
            table.insert(dinos.dinos, hatch.name)
            table.remove(self.queue, i)
            saveSystem:save()
        end
    end
end

function Hatchery:draw()
    self:update()
    for i, hatch in ipairs(self.queue) do
        local x = 100
        local y = HEIGHT - i * 60
        local progress = math.min((ElapsedTime - hatch.start) / hatch.duration, 1)
        
        fill(80)
        rect(x, y, WIDTH - 200, 40)
        fill(0, 200, 0)
        rect(x, y, (WIDTH - 200) * progress, 40)
        
        fill(255)
        fontSize(16)
        text(hatch.name.." ("..math.ceil(hatch.duration - (ElapsedTime - hatch.start)).."s)", WIDTH/2, y + 20)
    end
end
