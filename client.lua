--[[ SEAT SHUFFLE ]]--
--[[ BY NOVA STUDIO ]]--

local actionkey=21 --Lshift (or whatever your sprint key is bound to)
local allowshuffle = false
local playerped=nil
local currentvehicle=nil

--Retrieve variables
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)
		--constantly maintain the current status 
		playerped=PlayerPedId()
		--constantly receive player vehicle
		currentvehicle=GetVehiclePedIsIn(playerped, false)
	end
end)


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)
		if IsPedInAnyVehicle(playerped, false) and allowshuffle == false then
			--if for some reason they try to reshuffle the cards
			SetPedConfigFlag(playerped, 184, true)
			if GetIsTaskActive(playerped, 165) then
				--Seat player is in 
				seat=0
				if GetPedInVehicleSeat(currentvehicle, -1) == playerped then
					seat=-1
				end
				--if the passenger does not close the door, close it manually
				--when GetVehicleDoorAngleRatio(currentvehicle,1) > 0.0 and seat == 0 then
					--SetVehicleDoorShut(currentVehicle,1,false)
				--end
				--move the pedal back into the seat as soon as the animation starts
				SetPedIntoVehicle(playerped, currentvehicle, seat)
			end
		elseif IsPedInAnyVehicle(playerped, false) and allowshuffle == true then
			SetPedConfigFlag(playerped, 184, false)
		end
	end
end)


RegisterNetEvent("SeatShuffle")
AddEventHandler("SeatShuffle", function()
	if IsPedInAnyVehicle(playerped, false) then
		--Take a seat
		seat=0
		if GetPedInVehicleSeat(currentvehicle, -1) == playerped then
			seat=-1
		end
		--if you are a driver
		if GetPedInVehicleSeat(currentvehicle,-1) == playerped then
			TaskShuffleToNextVehicleSeat(playerped,currentvehicle)
		end
		--if you are a passenger
		--Adding a lock until they are actually sitting in their new seat
		allowshuffle=true
		while GetPedInVehicleSeat(currentvehicle,seat) == playerped do
			Citizen.Wait(0)
		end
		allowshuffle=false
	else
		allowshuffle=false
		CancelEvent('SeatShuffle')
	end
end)


local elapsed=0
--Thread for determining the duration of the keystroke
Citizen.CreateThread(function()
  while true do
	Citizen.Wait(0)
	elapsed=0
	while IsControlPressed(0,actionkey) and GetIsTaskActive(playerped, 165) do
		Citizen.Wait(100)
		elapsed=elapsed+0.1
	end
  end
end)



Citizen.CreateThread(function()
  while true do
  --when the control is pressed, the animation is started
	if IsControlJustPressed(1, actionkey) then -- Lshift
	   TriggerEvent("SeatShuffle")
    end
	--when you release the control in the middle of the animation and then reset it
	if IsControlJustReleased(1, actionkey) and allowshuffle == true then 
		--Setting the threshold value for how long the ksy button should be pressed
		threshhold=0.8
		--If they are in the passenger seat, the threshold is increased by 1 second, as there is a slight delay when they move from the passenger side.
		--if GetPedInVehicleSeat(currentVehicle, 0) == playerped then
			--Threshold value=threshold value+0.55
		--end
		--if the animation is running and the button is pressed long enough, the animation is canceled
	   if GetIsTaskActive(playerped, 165) and elapsed < threshhold then
			allowshuffle=false
	   end
    end
    Citizen.Wait(0)
  end
end)

RegisterCommand("shuff", function(source, args, raw) -- Change command here
    TriggerEvent("SeatShuffle")
end, false) --Wrong, anyone can do it