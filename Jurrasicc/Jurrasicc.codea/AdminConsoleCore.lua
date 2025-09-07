AdminConsole = class()

function AdminConsole:init()
    self.showConsole = false
    self.input = ""
    self.gearPos = vec2(WIDTH - 60, HEIGHT - 60)
    self.active = false
end

function AdminConsole:drawGear()
    sprite(asset.documents.gear, self.gearPos.x, self.gearPos.y, 40, 40)
end

function AdminConsole:drawConsole()
    if self.showConsole then
        fill(30, 30, 30, 220)
        rect(WIDTH/2 - 150, HEIGHT/2 - 50, 300, 100)
        
        fill(255)
        fontSize(16)
        text("Enter Code:", WIDTH/2, HEIGHT/2 + 30)
        text(self.input, WIDTH/2, HEIGHT/2)
        
        if math.floor(ElapsedTime * 2) % 2 == 0 then
            text("|", WIDTH/2 + textSize(self.input)/2 + 5, HEIGHT/2)
        end
    end
end

function AdminConsole:touched(touch)
    if touch.state == BEGAN and vec2(touch.x, touch.y):dist(self.gearPos) < 30 then
        self.showConsole = not self.showConsole
        self.active = self.showConsole
        if self.active then showKeyboard() else hideKeyboard() end
    end
end

function AdminConsole:keyboard(key)
    if not self.active then return end
    
    if key == RETURN then
        self:submitCode(self.input)
        hideKeyboard()
        self.active = false
    elseif key == BACKSPACE then
        self.input = self.input:sub(1, -2)
    else
        self.input = self.input .. key
    end
end

function mutationBoost(mutations)
    local boost = 1
    for _, m in ipairs(mutations) do
        if m == "Mythic" then boost = boost * 1.25
        elseif m == "Apex" then boost = boost * 1.5
        elseif m == "Omega" then boost = boost * 2.5
        elseif m == "Eternal" then boost = boost * 5.0
        elseif m == "Divine" then boost = boost * 5.5
        elseif m == "Seraphic Grace" then boost = boost * 8.0 end
    end
    return boost
end

function table.contains(t, val)
    for _, v in ipairs(t) do
        if v == val then return true end
    end
    return false
end
