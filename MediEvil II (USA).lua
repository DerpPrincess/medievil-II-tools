-----------------------------------------------------------------------------------------------------------------------------------
-- File: MediEvil II (USA).lua                                                                                                    -
-- Title: MediEvil II PSX LUA for BizHawk                                                                                         -
-- Author: Allison Mackenzie Johnson (Derp Princess)                                                                              -
-- Version: Current: April 1, 2022 ~~~ Initial September 19, 2020                                                                -
-- License: Creative Commons; CC0; Public Domain. You are free to edit/reuse as you please. Retain original author credit.        -
-----------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------
--                                                   Script Flags                                                                --
-----------------------------------------------------------------------------------------------------------------------------------

--[[ Script Specific ]]
x = 1500; -- Location to draw script horizontally. Default: 1400.
y = 25; --Location to draw script vertically. Default: 25, this is the value each line is separated by.
scriptColors = true; -- Show script with colors on GUI, otherwise all text be white
fontsizeHeaderDivisor = 40; -- For the Game Header: Fontsize is relative to your screen height divided by this number. Default: 60
fontsizeCategoryDivisor = 50; -- For Categories like General, Dan State, Misc, Game Progress, and other. Default: 50
fontsizeDivisor = 60; -- For other Text. Default: 40

--[[ Speedrun/TAS ]]
toggleActorCollisionView = false; -- Shows collision hitbox of actors (Currently doesn't work)
toggleMapVertexView = false; -- Shows collision of maps (Currently doesn't work)
toggleOOBHelper = false; -- Spawns Out of Bounds Rectangles where Exit Triggers are in the void (Currently doesn't work)

--[[ Quirky Things ]]
---------------------- NOTE: To get these to work you will have to freeze values in memory ----------------------------------------

weirdFountainColors = false; -- Modifies the colors of the fountain
weirdFountainBehavior = false; -- Modifies the way the fountain behaves visually, such as looking like a giant vortex
weirdFountainSprite = false; -- Modifies the sprite that spews out of the fountain

-----------------------------------------------------------------------------------------------------------------------------------
--                                                  Global Variables                                                             --
-----------------------------------------------------------------------------------------------------------------------------------

--[[ General Variables ]]
levelArray = {}; -- An array containing all the level names
currentLevel = 0x0EFF0C; -- Current level
currentChunk = 0x0EFF18;

chaliceKCArray = {};
currentChaliceKC = 0x0EFE88; -- Memory Address of Chalice Kill Count

--[[ Daniel's Variables ]]
--Integral to Dan as an entity
danState = 0x0EFEA8; -- Are you Dan or Hand
danCanMove = 0x0EFF20; -- Can Dan Actor move?


-- Integral to Dan as the player
dansHP = 0x0F152C; -- Memory Address of Daniel's Health
dansStoredHP = 0x0F1530; -- Memory Address of Stored Health (From 0 to 3300, see dansMaxHP variable comments)
dansMaxHP = 0x0F1534; -- Memory Address of Life bottles (Every life bottle is 300 extra HP (12C in Hex) up to 11 * 300 = 3300 (CE4 in Hex))
superArmor = 0xF15AC; -- Memory Address of amount of Super Armor you have
dansSpeed = 0x1FFE1C; -- wrong??
dansRealX = 0x1FFE20;
dansRealY = 0x1FFE24;
dansRealZ = 0x1FFE28;

--[[ Inventory Variables ]]
-- General
moneyAddress = 0x0F15B4; -- Memory Address of Money
inventoryID = {};
shieldID = {};
dansWeapon1 = 0x0F1540; -- Memory Address of Daniel's First Slot Weapon
dansWeapon2 = 0x0F1544; -- Memory Address of Daniel's Second Slot Weapon
dansShield = 0x0F1548; -- Memory Address of Daniel's Shield
dansCurrentWeapon = 0x0F153C; -- Memory Address of 00000000 or 01000000

--[[ Explanation of how the below Inventory values work
	FFFF = You do not have it
	FFFE = It is removed from the inventory forever
	0000 = You have it, and it is empty (if it has ammo)
   >0000 = You have it, and it has some ammo (if it has ammo)
--]]

-- Row 1 of Inventory
smallSword = 0x0F155C; --Memory Address of Small Sword
broadSword = 0x0F1560; -- Memory Address of Broad Sword and its %
magicSword = 0x0F1564; -- Memory Address of Magic Sword
caneStick = 0x0F1568; -- Memory Address of Cane Stick
hammer = 0x0F1570; -- Memory Address of Hammer
axe = 0x0F157C; -- Memory Address of Axe
copperShield = 0x0F15A0; -- Memory Address of Copper Shield
silverShield = 0x0F15A4; -- Memory Address of Silver Shield
goldShield = 0x0F15A8; -- Memory Address of Gold Shield


-- Row 2 of Invenotry
pistol = 0x0F156C; -- Memory Address of amount of ammo you have for the pistol
crossbow = 0x0F1574; -- Memory Address of the Crossbow
flamingCrossbow = 0x0F1578; -- Memory Address of the Flaming Crossbow
gatlingGun = 0x0F1580; -- Memory Address of the Gatling Gun
goodLightning = 0x0F1584; -- Memory Address of Good Lightning
lightning = 0x0F1588; -- Memory Address of Lightning
blunderbuss = 0X1590; -- Memory Address of Blunderbuss
bombs = 0x0F1594; -- Memory Address of Bombs

-- Row 3 of Inventory
arm = 0x0F158C; -- Memory Address of Arm
chickenDrumstick = 0x0F1598; -- Memory Address of Chicken Drumstick
torch = 0x0F159C; -- Memory Address of Torch
poster = 0x0F15AC; -- Memory Address of Poster
danHead = 0x0F15BC; -- Memory Address of Head

-- LEVEL SPECIFIC!! They may not exist outside of their appropriate level, keys may have blank names

-- The Museum
cannonBall = 0x0F165C; -- Memory Address of Cannon Ball (The Museum)
museumKey = 0x0F166C; -- Memory Address of Museum Key (The Museum)
dinosaurKey = 0x0F1670; -- Memory Address of Dinosaur Key (The Museum)

-- Kensington
pocketWatch = 0x0F163C; -- Memory Address of Pocket Watch (Kensington)
townHouseKey = 0x0F1640; -- Memory Address of Town House Key (Kensington)
theDepotKey = 0x0F1668; -- Memory Address of The Depot Key (Kensington)

-- Kensington, the Tomb ~~ These exist in Kensington but do not have names
scrollOfSekhmet = 0x0F1630; -- Memory Address of Scroll of Sekhmet
staffOfAnubis = 0x0F1634; -- Memory Address of Staff of Anubis
tabletOfHorus = 0x0F1638; -- Memory Address of Tablet of Horus

-- The Freakshow
snakemanKeys = 0x0F1618; -- Memory Addressed of Snakeman Keys

-- Kew Gardens

-- Whitechapel
griffinShield = 0x0F1600; -- Memory Address of Griffin Shield (Whitechapel)
unicornShield = 0x0F1604; -- Memory Address of Griffin Shield (Whitechapel)
beard = 0x0F160C; -- Memory Address of Beard (Whitechapel)
libraryKey = 0x0F1610; -- Memory Address of Library Key (Whitechapel)
clubMembershipCard = 0x0F1614; -- Memory Address of Club Membership Card (Whitechapel)


lostSoulsInventory = 0x0F15F4;

--[[ Game Progress Variables ]]
projectorArray = {}; -- An array containing whether you've beat levels or not for the level selector (projector)
danHandAbility = 0x0F1694;
danSuperArmor = 0x1010101;
lostSouls = 0x137A50; -- How many lost souls do you have? (Cathedral Spires)


--[[ Miscellaneous Variables ]]
inACutscene = 0x0EEF98;


--[[ Other Variables ]]
-- Timer
timer = 0x0F39D4;

--[[ Boss HP Variables]]
danDankensteinHP = 0x1C9C9E;
ironSluggerHP = 0x1DF78E;

-- Camera Field of View
currentLevelFov = 0;
fovTitleLevel = 0x101A98;
fovTheProfessorsLab = 0x12C044;
fovTheMuseum = 0x129084;
fovTyrannosaurusWrecks = 0x128870;
fovKensington = 0x1288B4;
fovKensingtonTheTomb = 0x1286A4; -- Kensington, the Tomb
fovFreakshow = 0x1288F0;
fovGreenwich = 0x1288D4;
fovGreenwichNavalAcademy = 0x128894; -- Greenwich Naval Academy
fovKewGardens = 0x128B3C;
fovDankenstein = 0x128D90; -- Dankenstein - The Professor's Lab
fovIronSlugger = 0x128D30;
fovWulfrumHall = 0x128A68;
fovTheCount = 0x12883C;
fovWhiteChapel = 0x128BF4;
fovTheSewers = 0x128ABC;
fovTheTimeMachine = 0x128D24; -- The Time Machine - the Museum
fovTimeMachineSewers = 0x1287C4; -- The Time Machine, Sewers
fovTheTimeMachineTheRipper = 0x1286A4; -- The Time Machine, the Ripper
fovCathedralSpires = 0x1287DC;
fovCathedralSpiresTheDescent = 0x1286FC; -- Cathedral Spires, the Descent
fovTheDemon = 0x128BD4; -- Cathedral Spires, The Demon

--[[ Dev Variables ]]
fountainCrevice = 0x0D1AC4; -- The hole below the fountain, value is 98 in hexadecimal by default
fountainSprite = 0x0D1A74; -- The sprite used by the fountain
fountainTransparency = 0x0D1A52; -- Transparency on fountain sprites???
fountainColor = 0x0D1A6C; -- Fountain Color
fountainScale = 0x0D1A70; -- Scale of the sprites used
fountainArchRadius = 0x00000; -- Arching Radius of sprites that emit from the fountain - find address again pls

----------------------------------------------------------------------------------------------------------------------------------
--                                                  Global Functions                                                             --
-----------------------------------------------------------------------------------------------------------------------------------

-- Fills the global variable "levelArray" array; I've intentionally committed a sin of starting arrays with 0 in lua here to match
-- the level ID, this is not an error. Memory Addresses: 0x800EFF0C & 0x800EFF10-> Level ID.
function fillLevelArray()
	levelArray[0] = "Collision Test"; -- Stripped in Retail
	levelArray[1] = "Network Test"; -- Stripped in Retail
	levelArray[2] = "Cathedral Spires";
	levelArray[3] = "The Demon";
	levelArray[4] = "Iron Slugger";
	levelArray[5] = "Dankenstein";
	levelArray[6] = "The Freakshow";
	levelArray[7] = "Greenwich Observatory";
	levelArray[8] = "Kew Gardens";
	levelArray[9] = "Whitechapel";
	levelArray[10] = "The Museum";
	levelArray[11] = "Tyrannosaurus Wrecks";
	levelArray[12] = "Parliament" -- Stripped in Retail
	levelArray[13] = "The Professor's Lab";
	levelArray[14] = "The Sewers";
	levelArray[15] = "The Time Machine";
	levelArray[16] = "The Count";
	levelArray[17] = "Wulfrum Hall";
	levelArray[18] = "Kensington";
	levelArray[19] = "Title Level";
	levelArray[20] = "Art Slot 0" -- Stripped in Retail
	levelArray[21] = "Art Slot 1"; -- Stripped in Retail
	levelArray[22] = "Art Slot 2"; -- Stripped in Retail
	levelArray[23] = "Art Slot 3"; -- Stripped in Retail
	levelArray[24] = "Art Slot 4"; -- Stripped in Retail
	levelArray[25] = "Art Slot 5"; -- Stripped in Retail
	levelArray[26] = "Kensington, the Tomb";
	levelArray[27] = "Greenwich Naval Academy";
	levelArray[28] = "The Time Machine, Sewers";
	levelArray[29] = "The Time Machine, the Ripper";
	levelArray[30] = "Cathedral Spires, the Descent";
end

-- Fills the global variable "chaliceKCArray" array; Once again to match with the level ID I've intentionally started the Array at 0, this is not an error.
function fillChaliceKCArray()
	chaliceKCArray[0] = "No Chalice"; -- Collision Test has no chalice
	chaliceKCArray[1] = "No Chalice"; -- Network Test has no chalice
	chaliceKCArray[2] = "No Chalice"; -- Cathedral Spires has no chalice
	chaliceKCArray[3] = "No Chalice"; -- The Demon has no chalice
	chaliceKCArray[4] = "No Chalice"; -- Iron Slugger has no chalice
	chaliceKCArray[5] = 5; -- You need a kill count of 5 to collect the chalice from Dankenstien
	chaliceKCArray[6] = 55; -- You need to have a kill count of 55 to collect the chalice from The Freakshow
	chaliceKCArray[7] = 55; -- You need a kill count of 55 to collect the chalice from Greenwich Observatory
	chaliceKCArray[8] = 51; -- You need a kill count of 51 to collect the chalice from Kew Gardens
	chaliceKCArray[9] = 18; -- You need a kill count of 18 to collect the chalice from Whitechapel
	chaliceKCArray[10] = 25; -- You need to have a kill count of 25 to collect the chalice from The Museum
	chaliceKCArray[11] = "No Chalice"; -- Tyrannosaurus Wrecks has no chalice
	chaliceKCArray[12] = "No Chalice"; -- Parliament has no chalice
	chaliceKCArray[13] = "No Chalice"; -- The Professor's lab has no chalice
	chaliceKCArray[14] = 11; -- You need a kill count of 11 to collect the chalice from The Sewers
	chaliceKCArray[15] = 1; -- Time Machine, The Ripper simply requires you kill Jack the Ripper
	chaliceKCArray[16] = "No Chalice" -- The Count has no chalice
	chaliceKCArray[17] = 34; -- You need a kill count of 34 to collect the chalice from Wulfrum Hall
	chaliceKCArray[18] = 38; -- You need to have a kill count of 38 to collect the chalice from Kensington
	chaliceKCArray[19] = "No Chalice"; -- Title Level has no chalice
	chaliceKCArray[20] = "No Chalice"; -- Art Slot 0 has no chalice
	chaliceKCArray[21] = "No Chalice"; -- Art Slot 1 has no chalice
	chaliceKCArray[22] = "No Chalice"; -- Art Slot 2 has no chalice
	chaliceKCArray[23] = "No Chalice"; -- Art Slot 3 has no chalice
	chaliceKCArray[24] = "No Chalice"; -- Art Slot 4 has no chalice
	chaliceKCArray[25] = "No Chalice"; -- Art Slot 5 has no chalice
	chaliceKCArray[26] = "No Chalice"; -- Kensington, the Tomb has no chalice
	chaliceKCArray[27] = "No Chalice"; -- Greenwich Naval Academy has no chalice
	chaliceKCArray[28] = "No Chalice"; -- The Time Machine, Sewers has no chalice
	chaliceKCArray[29] = "No Chalice"; -- The Time Machine, the Ripper has no chalice
	chaliceKCArray[30] = "No Chalice"; -- Cathedral Spires, the Descent has no chalice
end

function inventoryItems()
	inventoryID[0] = "Small Sword";
	inventoryID[1] = "Broad Sword";
	inventoryID[2] = "Magic Sword";
	inventoryID[3] = "Cane Stick";
	inventoryID[4] = "Pistol";
	inventoryID[5] = "Hammer";
	inventoryID[6] = "Crossbow";
	inventoryID[7] = "Flaming Crossbow";
	inventoryID[8] = "Axe";
	inventoryID[9] = "Gatling Gun";
	inventoryID[10] = "Good Lightning";
	inventoryID[11] = "Lightning";
	inventoryID[12] = "Arm";
	inventoryID[13] = "Blunderbuss";
	inventoryID[14] = "Bombs";
	inventoryID[15] = "Chicken Drumsticks";
	inventoryID[16] = "Torch";
	inventoryID[17] = "Antidote";
	inventoryID[18] = "No Weapon";
	inventoryID[19] = "Unknown";
	inventoryID[20] = "Unknown";
	inventoryID[21] = "Unknown";
end

function shieldItems()
	shieldID[0] = "Copper Shield";
	shieldID[1] = "Silver Shield";
	shieldID[2] = "Gold Shield";
	shieldID[3] = "No Shield";
	shieldID[-1] = "2H Weapon (Copper Shield)"; -- This is here as a failsafe incase the game poops out so the script doesn't crash if the value drops to this ever
	shieldID[-2] = "2H Weapon (Silver Shield)"; -- On that note, I'll be honest in saying that lua let's you have negative array indexes... who knew cause I didn't
	shieldID[-3] = "2H Weapon (Gold Shield)"; -- before making this script.
end

function determineWeaponHasAmmo(weapon)
	if(memory.read_s8(weapon) == 1) then -- Broad Sword, if enchanted
		return true;
	end
	if(memory.read_s8(weapon) == 4) then -- Pistol
		return true;
	end
	if(memory.read_s8(weapon) == 6) then -- Crossbow
		return true;
	end
	if(memory.read_s8(weapon) == 7) then -- Flaming Crossbow
		return true;
	end
	if(memory.read_s8(weapon) == 9) then -- Gatling Gun
		return true;
	end
	if(memory.read_s8(weapon) == 11) then -- Lightning
		return true;
	end
	if(memory.read_s8(weapon) == 13) then -- Blunderbuss
		return true;
	end
	if(memory.read_s8(weapon) == 14) then -- Bombs
		return true;
	end
	if(memory.read_s8(weapon) == 15) then -- Chicken Drumsticks
		return true;
	end
	if(memory.read_s8(weapon) == 17) then -- Antidote
		return true;
	end
	return false;
end

function determineCurrentWeaponAmmo(weapon)
	if(memory.read_s8(weapon) == 1) then -- Broad Sword, if enchanted
		return memory.read_u32_le(broadSword);
	end
	if(memory.read_s8(weapon) == 4) then -- Pistol
		return memory.read_u32_le(pistol);
	end
	if(memory.read_s8(weapon) == 6) then -- Crossbow
		return memory.read_u32_le(crossbow);
	end
	if(memory.read_s8(weapon) == 7) then -- Flaming Crossbow
		return memory.read_u32_le(flamingCrossbow);
	end
	if(memory.read_s8(weapon) == 9) then -- Gatling Gun
		return memory.read_u32_le(gatlingGun);
	end
	if(memory.read_s8(weapon) == 11) then -- Lightning
		return memory.read_u32_le(lightning);
	end
	if(memory.read_s8(weapon) == 13) then -- Blunderbuss
		return memory.read_u32_le(blunderbuss);
	end
	if(memory.read_s8(weapon) == 14) then -- Bombs
		return memory.read_u32_le(bombs);
	end
	if(memory.read_s8(weapon) == 15) then -- Chicken Drumstick
		return memory.read_u32_le(chickenDrumstick);
	end
	--if(memory.read_s8(weapon) == 17) then -- Antidote
		--return memory.read_u32_le(antidote);
	--end
	return 0;
end

function populateProjector()
	--[[ Explanation of how the progress in this game works
		If there is an asterisk at the end of the level name, it will crash if value is set to 0x01 and chosen on projector. The value the address has is its level progress.

		1 = Level Exists on the Projector
		32 = Level Does Not Exist on the Projector, and is a boss level that has not yet been completed
	--]]
	projectorArray[0] = 0x0E1734; -- The Museum
	projectorArray[1] = 0x0E1744; -- Tyrannosaurus Wrecks
	projectorArray[2] = 0x0E1754; -- Kensington
	projectorArray[3] = 0x0E1764; -- Kensington, the Tomb*
	projectorArray[4] = 0x0E1774; -- The Freakshow
	projectorArray[5] = 0x0E1784; -- Greenwich Observatory
	projectorArray[6] = 00E1794; -- Greenwich Naval Academy*
	projectorArray[7] = 0x0E17A4; -- Kew Gardens
	projectorArray[8] = 0x0E17B4; -- Dankenstein
	projectorArray[9] = 0x0E17C4; -- Iron Slugger
	projectorArray[10] = 0x0E17D4; -- Wulfrum Hall
	projectorArray[11] = 0x0E17E4; -- The Count
	projectorArray[12] = 0x0E17F4; -- Whitechapel
	projectorArray[13] = 0x0E1804; -- The Sewers
	projectorArray[14] = 0x0E1814; -- The Time Machine
	projectorArray[15] = 0x0E1824; -- The Time Machine, Sewers*
	projectorArray[16] = 0x0E1834; -- The Time Machine, the Ripper*
	projectorArray[17] = 0x0E1844; -- Cathedral Spires
	projectorArray[18] = 0x0E1854; -- Cathedral Spires, the Descent*
	projectorArray[19] = 0x0E1864; -- The Demon
end

function determineDanState()
	if(memory.read_u32_le(danState) == 0) then
		return "--Sir Daniel Fortesque--";
	end
	if(memory.read_u32_le(danState) == 1) then
		return "--Headless Dan (Head Stolen)--";
	end
	if(memory.read_u32_le(danState) == 38) then
		return "--Headless Dan--";
	end
	if(memory.read_u32_le(danState) == 39) then
		return "--Dankenstein--";
	end
	if(memory.read_u32_le(danState) == 2490406) then
		return "--Dan Hand--";
	end
	if(memory.read_u32_le(danState) == 65537) then
		return "--Dan's Head--";
	end
	return "--ERROR Dan State Not Found--";
end

function determineGameState()
	if (memory.read_u8(danCanMove) == 0) then -- Dan CAN move
		if(memory.read_u8(inACutscene) == 1) then
			return "Cutscene Playing";
		end
		if(memory.read_u8(inACutscene) == 0) then
			return "";
		end
	end
	if(determineCurrentLevelName() == "Iron Slugger") then -- Dankenstein things
		if (memory.read_u8(danCanMove) == 0) then
			if(memory.read(inACutscene) == 0) then -- Dan CAN move, and you're not in a cutscene
				return "Controlling Headless Dan";
			end
		end
		if (memory.read_u8(danCanMove) == 1) then
			if(memory.read(inACutscene) == 0) then -- Dan CAN'T move, and you're not in a cutscene
				return "Controlling Dankenstein";
			end
			if(memory.read(inACutscene) == 1) then -- Dan CAN'T move, and you're in a cutscene
				return "Cutscene Playing";
			end
		end
	end
	if memory.read_u8(danCanMove) == 1 then -- Dan CANNOT move
		return "Dan Idle";
	end
	if memory.read_u8(danCanMove) == 2 then -- You're on the title screen
		return "Title Screen"
	end
end

function determineCurrentLevelName()
	return levelArray[memory.read_u32_le(currentLevel)];
end

function determineCurrentLevelChunk()
	return memory.read_u32_le(currentChunk);
end

--[[
	Returns colors based on if you've beaten a level or not and it's current status. Only works if script colors is enabled.

	If Value is 0, you probably doesn't have the level unlocked yet.

	Color meanings:
		orange = Generic failsafe
		red = Impossible to Occur scenarios - if you see this naturally without modifying with a hex editor, please report this
		lightgreen = Not Completed
		yellow = Completed without Chalice
		green = Completed with Chalice
--]]
function determineIfCurrentLevelIsCompleted()
	if(determineCurrentLevelName() == "The Museum") then
		if(memory.read_u32_le(projectorArray[0]) == 0) then -- Impossible to Occur
			return "red";
		end
		if(memory.read_u32_le(projectorArray[0]) == 65535) then -- Impossible to Occur
			return "red";
		end
		if(memory.read_u32_le(projectorArray[0]) == 1) then -- Not Complete
			return "lightgreen";
		end
		if(memory.read_u32_le(projectorArray[0]) == 9) then -- Completed without Chalice
			return "yellow";
		end
		if(memory.read_u32_le(projectorArray[0]) == 25) then -- Completed with Chalice
			return "green";
		end
	end
	if(determineCurrentLevelName() == "Tyrannosaurus Wrecks") then
		if(memory.read_u32_le(projectorArray[1]) == 0) then
			return "red";
		end
		if(memory.read_u32_le(projectorArray[1]) == 65535) then
			return "red";
		end
		if(memory.read_u32_le(projectorArray[1]) == 32) then -- After you beat The Museum, you WILL enter Tyrannosaurus Wrecks aka Boss is Undefeated
			return "red";
		end
		if(memory.read_u32_le(projectorArray[1]) == 33) then -- Incomplete
			return "lightgreen";
		end
		if(memory.read_u32_le(projectorArray[1]) == 41) then -- Complete
			return "green";
		end
	end
	if(determineCurrentLevelName() == "Kensington") then
		if(memory.read_u32_le(projectorArray[2]) == 0) then -- You don't have Kensington unlocked, however this would be impossible to see legitimately
			return "red";
		end
		if(memory.read_u32_le(projectorArray[2]) == 1) then -- Incomplete
			return "lightgreen";
		end
		if(memory.read_u32_le(projectorArray[2]) == 9) then -- Complete without Chalice
			return "lightgreen";
		end
		if(memory.read_u32_le(projectorArray[2]) == 25) then -- Complete with Chalice
			return "green";
		end
	end
	if(determineCurrentLevelName() == "Kensington, the Tomb") then
		if(memory.read_u32_le(projectorArray[3]) == 34) then -- You've never entered Kensington, the Tomb, should be impossible to see this
			return "red";
		end
		if(memory.read_u32_le(projectorArray[3]) == 35) then -- Incomplete
			return "lightgreen";
		end
		if(memory.read_u32_le(projectorArray[3]) == 43) then -- Complete
			return "green";
		end
	end
	return "orange";
end

-- void gui.drawText(int x, int y, string message, [luacolor forecolor = nil],
--  [luacolor backcolor = nil], [int? fontsize = nil], [string fontfamily = nil],
--  [string fontstyle = nil], [string horizalign = nil], [string vertalign = nil], [string surfacename = nil]) -----  ternary(scriptColors == true, ternary(showBackgroundColor == true, backgroundColor, "transparent")  "transparent"), 50);
function displayGUI()
	local height = client.screenheight();

	gui.drawText(x, y * 0.5, "MediEvil II - PSX", "pink", "blue", height/fontsizeHeaderDivisor, nil, "bold");
	gui.drawText(x, y * 1, "--General--", ternary(scriptColors == true, "cyan", "white"), "green", height/fontsizeCategoryDivisor); -- ternary(scriptColors == true, "cyan", "white"), nil, 50);
	gui.drawText(x, y * 2, "Level: " .. determineCurrentLevelName() .. " (Chunk: " .. determineCurrentLevelChunk() .. ")", ternary(scriptColors == true, determineIfCurrentLevelIsCompleted(), "white"), nil, height/fontsizeDivisor); -- Display name of level as a String based on level ID
	gui.drawText(x, y * 3, "Chalice Kill Count: " .. memory.read_u32_le(currentChaliceKC) .. " / " .. chaliceKCArray[memory.read_u32_le(currentLevel)], "violet", "transparent", height/fontsizeDivisor);

	gui.drawText(x, y * 5, determineDanState(), ternary(determineDanState() == "--ERROR Dan State Not Found--", ternary(scriptColors == true, "red", "white"), ternary(scriptColors == true, "cyan", "white")), "green", height/fontsizeCategoryDivisor);
	gui.drawText(x + 325, y * 5, determineGameState(), ternary(scriptColors == true, "purple", "white"));
	gui.drawText(x, y * 6, "Health: " .. memory.read_s32_le(dansHP) .. " + (" .. memory.read_u32_le(dansStoredHP) .. " / " .. memory.read_u32_le(dansMaxHP) .. ")" .. ternary(memory.read_u32_le(superArmor) ~= 65535, " | Super Armor: " .. memory.read_u32_le(superArmor), ""));
	gui.drawText(x, y * 7, "Speed: " .. memory.read_u8(dansSpeed), "purple", "transparent", height/fontsizeDivisor); -- Read + Display as unsigned 8 bytes
	gui.drawText(x, y * 8, "Real X Position: " .. memory.read_s16_le(dansRealX)); -- Read + Display as signed 16 bytes
	gui.drawText(x, y * 9, "Real Y Position: " .. memory.read_s16_le(dansRealY)); -- Read + Display as signed 16 bytes
	gui.drawText(x, y * 10, "Real Z Position: " .. memory.read_s16_le(dansRealZ)); -- Read + Display as signed 16 bytes

	gui.drawText(x, y * 12, "--Miscellaneous--", ternary(scriptColors == true, "cyan", "white"), "green", height/fontsizeCategoryDivisor);
	gui.drawText(x, y * 13, "Weapon Slot 1: " .. inventoryID[memory.read_s8(dansWeapon1)]);
	gui.drawText(x + 325, y * 13, ternary(determineWeaponHasAmmo(dansWeapon1) == true, "Ammo: " .. determineCurrentWeaponAmmo(dansWeapon1), ""));
	gui.drawText(x, y * 14, "Weapon Slot 2: " .. inventoryID[memory.read_s8(dansWeapon2)]);
	gui.drawText(x + 325, y * 14, ternary(determineWeaponHasAmmo(dansWeapon2) == true, "Ammo: " .. determineCurrentWeaponAmmo(dansWeapon2), ""));
	gui.drawText(x, y * 15, "Shield Slot: " .. shieldID[memory.read_s8(dansShield)]);
	gui.drawText(x, y * 16, "Money: " .. memory.read_u32_le(moneyAddress));

	gui.drawText(x, y * 18, "--Game Progress--", ternary(scriptColors == true, "cyan", "white"), "green", height/fontsizeCategoryDivisor);
	gui.drawText(x, y * 19, "Has Dan Hand?: " .. ternary(memory.read_s8(danHandAbility) % 2 == 1, "Yes", "No"));
	gui.drawText(x, y * 20, "Has Super Armor?: " .. "???");

	gui.drawText(x, y * 22, "--Other--", ternary(scriptColors == true, "cyan", "white"), "green", height/fontsizeCategoryDivisor);
	gui.drawText(x, y * 23, ternary(memory.read_u32_le(timer) ~= 0, "Current Timer: " .. memory.read_u32_le(timer) .. " seconds", "No Current Timers"));
	gui.drawText(x, y * 24, "Camera Field of View: " .. memory.read_s32_le(currentLevelFov))

	
end

function ternary(cond, T, F)
    if cond then return T else return F end
end

function beatLevel()
	-- https://viper.shadowflareindustries.com/antigsc/index.php?codes&dev=gs&system=psx&game=medievil2

end

function setCanvas()
	gui.use_surface("client");
end

-----------------------------------------------------------------------------------------------------------------------------------
--                                                      Ran Once                                                                 --
-----------------------------------------------------------------------------------------------------------------------------------

setCanvas(); -- Always draw on client canvas
fillLevelArray(); -- Calls function fillLevelArray() to fill levelArray array for GUI use
populateProjector() -- Calls function populateProjector() to fill projectorArray for GUI use
fillChaliceKCArray(); -- Calls function fillChaliceKCArray() to fill the Kill Count requirement of each level's chalice
inventoryItems(); -- Calls function inventoryItems() to fill the inventory array for GUI use
shieldItems(); -- Calls function shieldItems() to fill the shield array for GUI use


-----------------------------------------------------------------------------------------------------------------------------------
--                                                     Ran Occasionally                                                          --
-----------------------------------------------------------------------------------------------------------------------------------

beatLevel();

-----------------------------------------------------------------------------------------------------------------------------------
--                                                    Ran Constantly                                                             --
-----------------------------------------------------------------------------------------------------------------------------------

while true do
	emu.frameadvance(); -- Runs the emulator, pretty important I think ¯\_(ツ)_/¯
	displayGUI(); -- Display GUI every frame
end