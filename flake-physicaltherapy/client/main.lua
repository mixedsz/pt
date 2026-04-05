local cooldownNotification = false -- Cooldown to prevent spam notifications
local processingPayment = false -- Flag to prevent multiple payment requests
local tempLocation = nil -- Temporary variable to store location during payment processing
local lastTherapyTime = 0 -- Track when the player last used therapy

-- Track current therapy state
local currentTherapy = {
    active = false,
    location = nil,
    currentStep = 1
}

-- Notify player when therapy starts (removed as we'll combine this with step notification)

-- Disable player controls during animation
local function disableControls()
    DisableControlAction(0, 24, true) -- Attack
    DisableControlAction(0, 25, true) -- Aim
    DisableControlAction(0, 21, true) -- Sprint
    DisableControlAction(0, 22, true) -- Jump
    DisableControlAction(0, 23, true) -- Enter vehicle
    DisableControlAction(0, 44, true) -- Cover
    DisableControlAction(0, 37, true) -- Select weapon
    DisableControlAction(0, 289, true) -- Inventory (F2)
    DisableControlAction(0, 73, true) -- Cancel (X)
end

-- Draw a marker for the step
-- Draw a marker for the step, show it when the player is within a smaller range
local function drawMarker(coords)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    -- Ensure coords is a vector3 for distance calculation
    local coordsVec3 = type(coords) == "vector4" and vector3(coords.x, coords.y, coords.z) or coords
    local dist = #(playerCoords - coordsVec3)

    -- Show marker when player is within a smaller range (2-4 units)
    if dist <= 4.0 then -- Changed from 10.0 to 4.0
        DrawMarker(
            22, -- Type 22: Vertical Cylinder
            coords.x, coords.y, coords.z, -- Marker at the step coordinates
            0.0, 0.0, 0.0,
            0.0, 180.0, 0.0,
            0.7, 0.7, 0.7, -- Scale
            0, 0, 255, 180, -- Color (Blue with transparency)
            false, true, 2, nil, nil, false
        )
    end
end

-- Therapy process (player interacts with each step)
local function startTherapy(location)
    -- Force hide any existing TextUI before starting therapy
    exports.ox_lib:hideTextUI()
    Citizen.Wait(300)

    -- Set up the current therapy tracking
    currentTherapy.active = true
    currentTherapy.location = location
    currentTherapy.currentStep = 1

    for index, step in ipairs(location.steps) do
        -- Update current step tracker
        currentTherapy.currentStep = index

        -- Use the step coords directly (works with both vec3 and vec4)
        local stepCoords = step.coords
        local playerPed = PlayerPedId()
        local text = 'Click [E] to start ' .. (step.progress.label or "Interact")
        local showingUI = false
        local complete = false

        -- Notify current step with therapy started message for first step
        if index == 1 then
            exports.ox_lib:notify({
                type = 'inform',
                title = string.format("Step %d: %s", index, step.progress.label),
                description = 'Therapy started! Follow the steps and interact with each point.',
                duration = 5000,
                position = 'top'
            })
        else
            exports.ox_lib:notify({
                type = 'inform',
                title = string.format("Step %d: %s", index, step.progress.label),
                description = 'Continue to the next station.',
                duration = 3500,
                position = 'top'
            })
        end

        -- Hide any existing TextUI first to ensure clean state
        exports.ox_lib:hideTextUI()
        Citizen.Wait(200)

        -- Don't show TextUI here - let the distance check in the loop handle it
        showingUI = false

        Citizen.Wait(1500)

        while not complete do
            local playerCoords = GetEntityCoords(playerPed)
            -- Ensure stepCoords is a vector3 for distance calculation
            local stepCoordsVec3 = type(stepCoords) == "vector4" and vector3(stepCoords.x, stepCoords.y, stepCoords.z) or stepCoords
            local dist = #(playerCoords - stepCoordsVec3)

            -- Only show "Click E" when player is right on top of the step
            if dist <= Config.Distance then
                -- Show "Click E to start" only when very close
                if not showingUI or showingUI ~= "click" then
                    -- Clear any existing TextUI first
                    exports.ox_lib:hideTextUI()
                    Citizen.Wait(100)
                    -- Show the Click [E] text
                    exports.ox_lib:showTextUI(text, { position = "right-center" })
                    showingUI = "click"
                    -- Debug notification to confirm the right text is being shown
                    --[[ Uncomment for debugging
                    exports.ox_lib:notify({
                        type = 'inform',
                        title = "Debug",
                        description = "Showing: " .. text,
                        duration = 1000,
                        position = 'top'
                    })
                    --]]
                end

                if IsControlJustReleased(0, 38) then -- [E]
                    exports.ox_lib:hideTextUI()
                    showingUI = false

                    local anim = step.progress.anim
                    FreezeEntityPosition(playerPed, true)
                    RequestAnimDict(anim.dict)
                    while not HasAnimDictLoaded(anim.dict) do
                        Citizen.Wait(10)
                    end

                    TaskPlayAnim(playerPed, anim.dict, anim.clip, 8.0, 8.0, step.progress.duration, anim.flag, 0, false, false, false)

                    -- Show TextUI during the animation to indicate progress
                    exports.ox_lib:showTextUI('Performing ' .. step.progress.label, { position = "right-center" })

                    local endTime = GetGameTimer() + step.progress.duration
                    while GetGameTimer() < endTime do
                        disableControls()
                        Citizen.Wait(0)
                    end

                    exports.ox_lib:hideTextUI()
                    ClearPedTasks(playerPed)
                    FreezeEntityPosition(playerPed, false)

                    -- Make sure TextUI is hidden before completing step
                    exports.ox_lib:hideTextUI()
                    showingUI = false
                    complete = true

                    -- Almost done message
                    if index == #location.steps - 1 then
                        exports.ox_lib:notify({
                            type = 'info',
                            title = "Almost Done!",
                            description = "You're almost done! One last push!",
                            duration = 4000,
                            position = 'top'
                        })
                    end
                end
            elseif dist > Config.Distance and dist <= 4.0 then
                -- Show "Approach to" when within marker range but not close enough to interact
                if not showingUI or showingUI ~= "approach" then
                    exports.ox_lib:hideTextUI()
                    Citizen.Wait(100)
                    exports.ox_lib:showTextUI('Approach to start ' .. step.progress.label, { position = "right-center" })
                    showingUI = "approach"
                end
            elseif showingUI then
                showingUI = false
                exports.ox_lib:hideTextUI()
            end

            Citizen.Wait(0)
        end
    end

    -- Final success message
    exports.ox_lib:notify({
        type = 'success',
        title = 'Therapy Complete!',
        description = 'Crutch has been removed successfully.',
        position = 'top'
    })

    -- Get the correct server ID
    local serverId = GetPlayerServerId(PlayerId()) -- Get the server ID of the local player

    -- Call the export to remove crutch
    local success = pcall(function()
        exports.wasabi_crutch:RemoveCrutch(serverId)
    end)

    if not success then
        exports.ox_lib:notify({
            type = 'error',
            title = 'Error',
            description = 'Error removing crutch. Please contact staff.',
            duration = 3000,
            position = 'top'
        })
    end

    -- Reset therapy state
    currentTherapy.active = false
    currentTherapy.location = nil
    currentTherapy.currentStep = 1

    -- Set the last therapy time to start the cooldown
    lastTherapyTime = GetGameTimer()
end

-- Spawn the therapy ped (NPC)
local function spawnTherapyPed(location)
    RequestModel(location.ped.model)
    while not HasModelLoaded(location.ped.model) do
        Citizen.Wait(100)
    end

    local ped = CreatePed(4, location.ped.model, location.ped.coords.x, location.ped.coords.y, location.ped.coords.z - 1.0, location.ped.coords.w, false, true)

    -- Make ped completely passive and invincible
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true) -- Prevents ped from reacting to events like being hit
    SetPedCanRagdoll(ped, false)
    SetPedCanBeTargetted(ped, false)
    SetEntityCanBeDamaged(ped, false)
    SetPedResetFlag(ped, 249, true) -- Don't attack player
    SetPedConfigFlag(ped, 185, true) -- Disable melee combat
    SetPedConfigFlag(ped, 208, true) -- Don't react to player
    SetPedConfigFlag(ped, 118, true) -- Disable all combat

    -- Freeze and set task
    FreezeEntityPosition(ped, true)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)
    return ped
end

-- Register client event for money check result
RegisterNetEvent('physical:moneyResult')
AddEventHandler('physical:moneyResult', function(success, message)
    processingPayment = false

    if success then
        -- If payment was successful, notify and start therapy
        exports.ox_lib:notify({
            type = 'success',
            title = 'Payment Successful',
            description = message,
            duration = 3000,
            position = 'top'
        })

        -- Get the location that was stored in the temporary variable
        if tempLocation then
            -- Reset therapy state before starting new therapy
            currentTherapy.active = false
            currentTherapy.location = nil
            currentTherapy.currentStep = 1

            -- Start the therapy process
            startTherapy(tempLocation)
            tempLocation = nil -- Clear the temporary variable
        else
            exports.ox_lib:notify({
                type = 'error',
                title = 'Error',
                description = 'Location data lost. Please try again.',
                duration = 3000,
                position = 'top'
            })
        end
    else
        -- If payment failed, just show the error message
        exports.ox_lib:notify({
            type = 'error',
            title = 'Payment Failed',
            description = message,
            duration = 3000,
            position = 'top'
        })

        -- Reset therapy state on failure
        currentTherapy.active = false
        currentTherapy.location = nil
        currentTherapy.currentStep = 1
    end
end)



-- Draw marker only for the current step
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local isNearAnyLocation = false
        local shouldDrawMarker = false
        local markerCoords = nil

        -- First check if player is near any therapy location (optimization)
        for _, location in pairs(Config.TherapyLocations) do
            -- Handle both vec3 and vec4 for location coords
            local locationCoordsVec3 = type(location.coords) == "vector4" and
                vector3(location.coords.x, location.coords.y, location.coords.z) or location.coords
            local distToLocation = #(playerCoords - locationCoordsVec3)

            -- If player is within 15.0 units of any location, consider them "near"
            if distToLocation <= 15.0 then
                isNearAnyLocation = true
                break
            end
        end

        -- Only proceed if player is near any therapy location
        if isNearAnyLocation then
            -- If therapy is active, only draw the current step marker
            if currentTherapy.active and currentTherapy.location then
                local steps = currentTherapy.location.steps
                if currentTherapy.currentStep <= #steps then
                    -- Draw marker for current step only
                    markerCoords = steps[currentTherapy.currentStep].coords
                    shouldDrawMarker = true
                end
            else
                -- If no therapy is active, we don't need to draw any markers
                -- The ped itself is enough to indicate the interaction point
            end

            -- Draw the current step marker if needed
            if shouldDrawMarker and markerCoords then
                drawMarker(markerCoords)
            end

            Citizen.Wait(0) -- Update every frame when near
        else
            Citizen.Wait(1000) -- Check less frequently when far away
        end
    end
end)

-- Create blips for therapy locations
Citizen.CreateThread(function()
    for name, location in pairs(Config.TherapyLocations) do
        if location.showBlip then
            local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
            SetBlipSprite(blip, 489) -- Medical blip sprite
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 2) -- Green
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Physical Therapy")
            EndTextCommandSetBlipName(blip)
        end
    end
end)

-- Main interaction logic for therapy
Citizen.CreateThread(function()
    for _, location in pairs(Config.TherapyLocations) do
        spawnTherapyPed(location)

        local text = 'Click [E] to start Physical Therapy ($' .. location.cost .. ')'
        local showingUI = false

        while true do
            local playerCoords = GetEntityCoords(PlayerPedId())
            -- Handle both vec3 and vec4 for location coords
            local locationCoordsVec3 = type(location.coords) == "vector4" and
                vector3(location.coords.x, location.coords.y, location.coords.z) or location.coords
            local distance = #(playerCoords - locationCoordsVec3)

            -- Always show TextUI when player is within range, regardless of targeting system
            -- Using Config.Distance (2.0) for consistency
            if distance <= Config.Distance then
                if not showingUI then
                    showingUI = true
                    -- Hide any existing TextUI first to ensure clean state
                    exports.ox_lib:hideTextUI()
                    Citizen.Wait(100)
                    exports.ox_lib:showTextUI(text, { position = "right-center" })
                end

                if IsControlJustReleased(0, 38) and not processingPayment then
                    -- Check cooldown first
                    local currentTime = GetGameTimer()
                    local timeSinceLastTherapy = (currentTime - lastTherapyTime) / 1000 -- Convert to seconds

                    if timeSinceLastTherapy < Config.Cooldown then
                        -- Player is still in cooldown
                        local remainingTime = math.ceil(Config.Cooldown - timeSinceLastTherapy)
                        local minutes = math.floor(remainingTime / 60)
                        local seconds = remainingTime % 60

                        exports.ox_lib:notify({
                            type = 'error',
                            title = 'Cooldown Active',
                            description = string.format('You must wait %d minutes and %d seconds before using therapy again.', minutes, seconds),
                            duration = 3000,
                            position = 'top'
                        })
                    else
                        local hasCrutch = exports.wasabi_crutch:IsCrutchActive()

                        if hasCrutch then
                            -- Check if player has enough money before starting therapy
                            processingPayment = true
                            tempLocation = location -- Store location in a temporary variable

                            -- Trigger server event to check money
                            TriggerServerEvent('physical:checkMoney', location.cost)

                            -- Show processing notification
                            exports.ox_lib:notify({
                                type = 'inform',
                                title = 'Processing',
                                description = 'Processing payment...',
                                duration = 2000,
                                position = 'top'
                            })
                        else
                            exports.ox_lib:notify({
                                type = 'error',
                                title = 'Not Needed',
                                description = 'You don\'t need physical therapy right now!',
                                position = 'top'
                            })
                        end
                    end
                end
            elseif showingUI then
                showingUI = false
                exports.ox_lib:hideTextUI()
            end

            Citizen.Wait(0)
        end
    end
end)
