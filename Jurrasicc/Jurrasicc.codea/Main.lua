-- Main.lua

function setup()
    -- Core systems
    player      = PlayerProfile()
    dinos       = DinoManager()
    admin       = AdminConsole()
    viewer      = DinoViewer()
    hatchery    = Hatchery()
    market      = DinoMarket()
    income      = PassiveIncome()
    resetButton = ResetButton()
    saveSystem  = SaveSystem()
    mutationLab = MutationLab()
    
    -- Cinematics and Battle
    cinematics  = Cinematics()
    battle      = Battle()
    
    -- Load saved data
    saveSystem:load()
end

function draw()
    background(40, 40, 50)
    
    -- 1) Update cinematic first
    cinematics:update()
    if cinematics:isPlaying() then
        cinematics:draw()
        return
    end
    
    -- 2) Then battle
    battle:update()
    if battle:isActive() then
        battle:draw()
        return
    end
    
    -- 3) Finally, your normal HUD and UI
    player:drawHUD()
    admin:drawGear()
    admin:drawConsole()
    resetButton:draw()
    viewer:draw()
    hatchery:draw()
    market:draw()
    income:update()
    mutationLab:draw()
end

function touched(touch)
    -- Debug: tap top-left to trigger Seraphic pulse on first dino
    if touch.state == BEGAN and touch.x < 80 and touch.y > HEIGHT-80 then
        if not cinematics:isPlaying() then
            cinematics:triggerSeraphicPulse(dinos.dinos[1])
            return
        end
    end
    
    -- Block input during cinematic or active battle
    if cinematics:isPlaying() or battle:isActive() then
        return
    end
    
    -- Forward to battle, then UI
    battle:touched(touch)
    if battle.selecting or battle:isActive() then return end
    
    admin:touched(touch)
    viewer:touched(touch)
    market:touched(touch)
    resetButton:touched(touch)
    mutationLab:touched(touch)
end

function keyboard(key)
    -- Only admin console listens to keyboard
    admin:keyboard(key)
end
