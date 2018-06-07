--[[
        Created by DooDesch
        http://discord.me/doodesch
]]--

local playerPed = GetPlayerPed(-1)

local entering = false

local thisBus
local busCoords = {}
local storedBusses = {}
local models = {}
models.driver = GetHashKey("s_m_m_lsmetro_01") -- Busdriver Skin

local busModels = {GetHashKey("bus"), GetHashKey("airbus"), GetHashKey("rentalbus"), GetHashKey("tourbus")} -- Available Busses

local routes = {}
table.insert(routes, { -- Route 1
    {x = 308.08102416992, y = -766.60925292969, z = 28.285007476807},
    {x = 112.79048919678, y = -784.93463134766, z = 30.38437461853},
    {x = -173.01126098633, y = -821.38104248047, z = 30.027135848999},
    {x = -201.25819396973, y = -1148.4880371094, z = 22.016857147217},
    {x = 356.78210449219, y = -1064.1846923828, z = 28.387935638428}
})
table.insert(routes, { -- Route 2
    {x = 308.08102416992, y = -766.60925292969, z = 28.285007476807},
    {x = 112.79048919678, y = -784.93463134766, z = 30.38437461853},
    {x = -173.01126098633, y = -821.38104248047, z = 30.027135848999},
    {x = -201.25819396973, y = -1148.4880371094, z = 22.016857147217},
    {x = 356.78210449219, y = -1064.1846923828, z = 28.387935638428}
})
table.insert(routes, { -- Route 3
    {x = 308.08102416992, y = -766.60925292969, z = 28.285007476807},
    {x = 112.79048919678, y = -784.93463134766, z = 30.38437461853},
    {x = -173.01126098633, y = -821.38104248047, z = 30.027135848999},
    {x = -201.25819396973, y = -1148.4880371094, z = 22.016857147217},
    {x = 356.78210449219, y = -1064.1846923828, z = 28.387935638428}
})
table.insert(routes, { -- Route 4
    {x = 308.08102416992, y = -766.60925292969, z = 28.285007476807},
    {x = 112.79048919678, y = -784.93463134766, z = 30.38437461853},
    {x = -173.01126098633, y = -821.38104248047, z = 30.027135848999},
    {x = -201.25819396973, y = -1148.4880371094, z = 22.016857147217},
    {x = 356.78210449219, y = -1064.1846923828, z = 28.387935638428}
})

local Setup = {}
Setup.BussesEnabled = true
Setup.debug = true

Citizen.CreateThread(function()
    if Setup.BussesEnabled then
        if NetworkIsHost() then

            local function _createBus(_bus)
                local vehicle = {}

                vehicle.bus = CreateVehicle(_bus.type, _bus.x, _bus.y, _bus.z, _bus.h, true, true)
                vehicle.driver = CreatePedInsideVehicle(vehicle.bus, 3, models.driver, -1, true, true)
                vehicle.infos = _bus
                vehicle.onRoute = 1
                vehicle.halt = false

                return vehicle
            end

            local busses = {
                {route=1, direction=true, x = 461.7961730957, y = -643.66479492188, z = 27.443323135376, h = 180.0, type=GetHashKey("tourbus")}, -- Defined busses, which route, which direction, where to spawn and so on
                {route=1, direction=false, x = 464.81274414063, y = -616.51867675781, z = 27.49933052063, h = 180.0, type=GetHashKey("tourbus")},
                {route=2, direction=true, x = 461.7961730957, y = -643.66479492188, z = 27.443323135376, h = 180.0, type=GetHashKey("rentalbus")},
                {route=2, direction=false, x = 464.81274414063, y = -616.51867675781, z = 27.49933052063, h = 180.0, type=GetHashKey("rentalbus")},
                {route=3, direction=true, x = 461.7961730957, y = -643.66479492188, z = 27.443323135376, h = 180.0, type=GetHashKey("airbus")},
                {route=3, direction=false, x = 464.81274414063, y = -616.51867675781, z = 27.49933052063, h = 180.0, type=GetHashKey("airbus")},
                {route=4, direction=true, x = 461.7961730957, y = -643.66479492188, z = 27.443323135376, h = 180.0, type=GetHashKey("bus")},
            }

            for i= 1, #(busModels) do
                RequestModel(busModels[i])
                while not HasModelLoaded(busModels[i]) do
                    Citizen.Wait(250)
                end
            end

            print("Loaded busses")

            RequestModel(models.driver)
            while not HasModelLoaded(models.driver) do
                Citizen.Wait(250)
            end

            print("Loaded driver")

            for i=1, #(busses) do
                Citizen.Wait(5000)
                local busCoords = busses[i]
                local thisBus = _createBus(busCoords)

                SetEntityProofs(thisBus.bus, true, true, true, true, true, false, 0, false)
                SetEntityAsMissionEntity(thisBus.bus, true, true)

                if Setup.debug then
                    local blip = AddBlipForEntity(thisBus.bus)
                    SetBlipColour(blip, 9)
                    table.insert(storedBusses, {bus = thisBus, blip = blip})
                else
                    table.insert(storedBusses, {bus = thisBus})
                end
                Citizen.Wait(15000)
            end
        end
    end
end)

function reverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

function hasValue(tab, val)
    for k, v in ipairs(tab) do
        if v == val then
            return true
        end
    end

    return false
end

Citizen.CreateThread(function()
    if Setup.BussesEnabled then
        function halt(vehicle)
            vehicle.bus.halt = true
            SetVehicleHandbrake(vehicle.bus.bus, true)
            ClearPedTasks(vehicle.bus.driver)
            Citizen.Wait(10000)
            vehicle.bus.halt = false
        end

        function nextStop(k, vehicle, stops)
            vehicle.bus.onRoute = tonumber(vehicle.bus.onRoute) + 1
            if stops[vehicle.bus.onRoute] == nil then
                vehicle.bus.onRoute = 1
            end
            storedBusses[k].bus.onRoute = vehicle.bus.onRoute
        end

        function killBus(vehicle)
            print("Killing bus")
            Citizen.Wait(3000)

            SetEntityHealth(vehicle.bus.bus, 0)
            SetEntityHealth(vehicle.bus.driver, 0)
            DeleteEntity(vehicle.bus.bus)
            if vehicle.blip ~= nil then
                Citizen.Wait(500)
                RemoveBlip(vehicle.blip)
                DeleteEntity(vehicle.blip)
            end
        end

        function enterPassenger(vehicle, ped, hash)
            if vehicle ~= nil and ped ~= nil then
                ClearPedTasksImmediately(ped)

                if AreAnyVehicleSeatsFree(vehicle) then
                    local numberOfSeats = GetVehicleModelNumberOfSeats(hash)
                    local seat = nil
                    for i=1, tonumber(numberOfSeats) do
                        if IsVehicleSeatFree(vehicle, i) then
                            seat = i
                            break
                        end
                    end
                    if seat ~= nil then
                        TaskEnterVehicle(ped, vehicle, -1, seat, 2.0, 1, 0)
                    end
                end
            end

            Citizen.Wait(5000)

            entering = false

            -- @TODO : Set a small amount to pay when entered and seat is found
        end
    end
end)

Citizen.CreateThread(function()
    if Setup.BussesEnabled then

        if NetworkIsHost() then
            while true do
                Citizen.Wait(1000)
                if #(storedBusses) > 0 then
                    for k,vehicle in pairs(storedBusses) do

                        Citizen.Wait(25)
                        if not IsEntityDead(vehicle.bus.driver) then

                            local vehicleCoords = GetEntityCoords(vehicle.bus.bus)
                            local destination = routes[vehicle.bus.infos.route]
                            if not vehicle.bus.infos.direction then
                                destination = reverseTable(destination)
                            end
                            destination = destination[vehicle.bus.onRoute]

                            if not vehicle.bus.halt then
                                if GetDistanceBetweenCoords(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, destination.x, destination.y, destination.z, false) < 15  then
                                    nextStop(k, vehicle, routes[vehicle.bus.infos.route])
                                    halt(vehicle)
                                else
                                    TaskVehicleDriveToCoord(vehicle.bus.driver, vehicle.bus.bus, destination.x, destination.y, destination.z, 50*3.6, 180.0, vehicle.bus.infos.type,  2, 1.0, 1)
                                end
                            else
                                SetVehicleHandbrake(vehicle.bus.bus, true)
                            end

                        else
                            killBus(vehicle)
                        end

                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    if Setup.BussesEnabled then
        while true do
            Citizen.Wait(100)
            if IsControlJustPressed(1, 23) then
                if not entering then
                    playerPed = GetPlayerPed(-1)
                    local enteringVehicle = GetVehiclePedIsTryingToEnter(playerPed)
                    if enteringVehicle ~= nil then
                        local hashEnteringVehicle = GetEntityModel(enteringVehicle)
                        if hashEnteringVehicle ~= nil then
                            if hasValue(busModels, hashEnteringVehicle) then
                                entering = true
                                enterPassenger(enteringVehicle, playerPed, hashEnteringVehicle)
                            end
                        end
                    end
                end
            end
        end
    end
end)