------------------------------------------------------------------------
   --- AllTheThings Inter Works and Data [Thanks to Crieve\Dylan] ---
------------------------------------------------------------------------
	local vPT_AppTitle = "|CFFFFFF00"..strsub(GetAddOnMetadata("ProgressTracker", "Title"),2).."|r v"..GetAddOnMetadata("ProgressTracker", "Version")
	local vPT_Revision = "01112021_114000" --Ignore, its for my Debugging Purpose :)
------------------------------------------------------------------------
-- Initializing Variables
------------------------------------------------------------------------
	local vPT_Realm = GetRealmName()							-- Get The Realm Name
	local vPT_Player = UnitName("player")						-- Get Player Name
	local vPT_Level = UnitLevel("player")						-- Get Level of Player
	local vPT_Class, vPT_EngClass, _ = UnitClass("player")		-- Get Player Class 
	local _, _, _, vPT_HexColor = GetClassColor(vPT_EngClass)	-- Get Player Class Color
	local vPT_Race, _, _ = UnitRace("player")					-- Get Player Race
	local vPT_ATTModes = { "Uniq", "Comp", "Acct Uniq", "Acct Comp", "Debug Uniq", "Debug Comp", }
	local vPT_ATTSMode = { "Uniq", "Comp", "AccUniq", "AccComp", "DebUniq", "DebComp", }
	local vPT_UpdaMode = { "Upd-Uniq", "Upd-Comp", "Upd-AccUniq", "Upd-AccComp", "Upd-DebUniq", "Upd-DebComp", }
	local vPT_ATTData, vPT_StoreDB, vPT_TempDB = {}, {}, {}		-- Database Temp Storage
	local tCmbo
------------------------------------------------------------------------
-- Debugging Only
------------------------------------------------------------------------
	local DEBUG = true
	function PTOutput(str, ...)
		local str = tostring(str)
		local arr = { ... }
		if #arr > 0 then
			for i, v in ipairs(arr) do
				str = str .. ", " .. tostring(v)
			end
		end
		for _,name in pairs(CHAT_FRAMES) do
		   local frame = _G[name]
		   if frame.name == "DEWin" then -- You Need DEWin (ChatFrame) to view debugs
				frame:AddMessage(str)
		   end
		end
	end
------------------------------------------------------------------------
-- Query ATT Database for ProgressTracker
------------------------------------------------------------------------
	local function QueryATTData(arg)
		for i = 1, 3 do
			if _G["vPT_CB"..i]:GetChecked() then ExpRowSel = i break end
		end
		if ExpRowSel == 0 then return end

		vPT_ATTData = { AllTheThings.GetDataCache() }

		wipe(vPT_TempDB)
		PTOutput(vPT_ATTData[1]["text"], vPT_ATTData[1]["total"], vPT_ATTData[1]["progress"])
		vPT_ItemCount.Text:SetText(vPT_ATTData[1]["progress"].." of "..vPT_ATTData[1]["total"].." ("..(string.format("%.2f",(vPT_ATTData[1]["progress"]/vPT_ATTData[1]["total"])*100)).."%)")
		tinsert(vPT_TempDB,vPT_ATTData[1]["g"])

		vPT_Simple[vPT_Class][vPT_ATTSMode[arg]] = { vPT_ATTData[1]["progress"], vPT_ATTData[1]["total"], }
		wipe(vPT_ATTData)
		wipe(vPT_StoreDB)
		for k, v in pairs(vPT_TempDB) do
			for l, w in pairs(v) do
				if l == 22 then break end
				if ExpRowSel == 1 or (l == 1 and (ExpRowSel == 2 or ExpRowSel == 3)) then
					if (DEBUG) then PTOutput( "> "..l, w["text"], #w["g"], (w["visible"] and 1 or 0), w["total"], w["progress"] ) end
					vPT_StoreDB[l] = {
						["iA"] = l,
						["hA"] = w["text"],
						["vA"] = w["visible"] and 1 or 0,
						["nA"] = #w["g"],
						["tA"] = w["total"],
						["pA"] = w["progress"],
					}
				end
				if l == 1 and (ExpRowSel == 2 or ExpRowSel == 3) then
					for i = 1, #w["g"] do
						if (DEBUG) then PTOutput( "=> "..i, w["g"][i]["text"], (w["g"][i]["visible"] and 1 or 0), #w["g"][i]["g"], w["g"][i]["total"], w["g"][i]["progress"] ) end
						vPT_StoreDB[l][i] = {
							["iB"] = i,
							["hB"] = w["g"][i]["text"],
							["vB"] = w["g"][i]["visible"] and 1 or 0,
							["nB"] = #w["g"][i]["g"],
							["tB"] = w["g"][i]["total"],
							["pB"] = w["g"][i]["progress"],
						}
						if ExpRowSel == 3 then
							for j = 1, #w["g"][i]["g"] do
								if (DEBUG) then PTOutput( "==> "..i, j, w["g"][i]["g"][j]["text"]:gsub("|cffff8000",""):gsub("|r",""), (w["g"][i]["g"][j]["isRaid"] and w["g"][i]["g"][j]["isRaid"] or 0), (w["g"][i]["g"][j]["visible"] and 1 or 0), #w["g"][i]["g"][j]["g"], w["g"][i]["g"][j]["total"], w["g"][i]["g"][j]["progress"] ) end
								vPT_StoreDB[l][i][j] = { 
									["iC"] = j,
									["hC"] = w["g"][i]["g"][j]["text"]:gsub("|cffff8000",""):gsub("|r",""),
									["vC"] = w["g"][i]["g"][j]["visible"] and 1 or 0,
									["nC"] = #w["g"][i]["g"][j]["g"],
									["rC"] = w["g"][i]["g"][j]["isRaid"] and w["g"][i]["g"][j]["isRaid"] or 0,
									["tC"] = w["g"][i]["g"][j]["total"],
									["pC"] = w["g"][i]["g"][j]["progress"],
								}
								-- if j == 5 then break end -- Temp for Debug Purpose, so won't flood my screen
							end
						end
					end
				end
			end
		end
		
		vPT_Data[vPT_Realm][vPT_Player][vPT_ATTSMode[arg]] = vPT_StoreDB
		vPT_Data[vPT_Realm][vPT_Player][vPT_UpdaMode[arg]] = time()
		GreyOutOptions()
	end
------------------------------------------------------------------------
-- Checkbox Toggles
------------------------------------------------------------------------
	function vPT_Toggle(arg)
		for i = 1, 3 do
			_G["vPT_CB"..i]:SetChecked(false)
		end
		_G["vPT_CB"..arg]:SetChecked(true)
		vPT_Config["vPT_Toggle"] = arg
	end
------------------------------------------------------------------------
-- Custom DropMenu
------------------------------------------------------------------------
	local function vPT_CustomDropdown(opts)
		local dropdown_name = "$parent_" .. opts["name"] .. "_dropdown"
		local menu_items = opts["items"] or {}
		local title_text = opts["title"] or ""
		local dropdown_width = 295
		local default_val = opts["defaultVal"] or ""
		local change_func = opts["changeFunc"] or function (dropdown_val) end
		local dropdown = CreateFrame("Frame", dropdown_name, opts["parent"], "UIDropDownMenuTemplate")
		local dd_title = dropdown:CreateFontString(dropdown, "OVERLAY", "GameFontNormal")
			dd_title:SetPoint("TOPLEFT", 20, 15)
		UIDropDownMenu_SetWidth(dropdown, dropdown_width)
		UIDropDownMenu_SetText(dropdown, default_val)
		dd_title:SetText(title_text)
		UIDropDownMenu_Initialize(dropdown, function(self, level, _)
			local info = UIDropDownMenu_CreateInfo()
			for key, val in pairs(menu_items) do
				info.text = val;
				info.checked = false
				info.menuList= key
				info.hasArrow = false
				info.func = function(b)
					UIDropDownMenu_SetSelectedValue(dropdown, b.value, b.value)
					UIDropDownMenu_SetText(dropdown, b.value)
					b.checked = true
					change_func(dropdown, b.value)
				end
				UIDropDownMenu_AddButton(info)
			end
		end)
		return dropdown
	end
------------------------------------------------------------------------
-- Create a Drop Down Menu with All Your Character Names
------------------------------------------------------------------------
	local function CreateCharDropdown()
		wipe(vPT_StoreDB)
		for k, v in pairs(vPT_Profile) do
			for l, w in pairs(v) do
				tinsert(vPT_StoreDB,k.." - "..l)
			end
		end
		local opts = {
			["name"]		= "Realm_Char",
			["parent"]		= vPT_MF,
			["title"]		= "List of Chars (Pick One As Main)",
			["items"]		= vPT_StoreDB,
			["defaultVal"]	= vPT_Config["vPT_TheMain"], 
			["changeFunc"]	= function(dropdown_frame, dropdown_val)
				vPT_Config["vPT_TheMain"] = dropdown_val
				GreyOutOptions()
			end
		}
		CharDD = vPT_CustomDropdown(opts)
		CharDD:SetPoint("TOPLEFT", vPT_MF, -8, -150)
		GreyOutOptions()
	end
------------------------------------------------------------------------
-- For Above
------------------------------------------------------------------------
	function GreyOutOptions()
		tCmbo = vPT_Realm.." - "..vPT_Player
		for i = 1, #vPT_ATTModes do
			if vPT_Config["vPT_TheMain"] == tCmbo or i < 3 then
				_G["vPT_ModeT"..i]:SetText("|cFFFFFFFF"..vPT_ATTModes[i].."|r")
				_G["vPT_ModeButton"..i]:Enable()
			else
				_G["vPT_ModeT"..i]:SetText("|cFF808080"..vPT_ATTModes[i].."|r")
				_G["vPT_ModeButton"..i]:Disable()
			end
			local tDate = vPT_Data[vPT_Realm][vPT_Player][vPT_UpdaMode[i]]
			_G["vPT_ModeL"..i]:SetText("|cFFFFFF00"..(tDate ~= nil and date("%m/%d/%y %H:%M", tDate) or "").."|r")
		end
	end
------------------------------------------------------------------------
-- Create Frame
------------------------------------------------------------------------
	local BDropA = {
		edgeFile = "Interface\\ToolTips\\UI-Tooltip-Border",
		bgFile = "Interface\\BlackMarket\\BlackMarketBackground-Tile",
		tileEdge = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	local BDropB = {
		edgeFile = "Interface\\ToolTips\\UI-Tooltip-Border",
		bgFile = "Interface\\BankFrame\\Bank-Background",
		tileEdge = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	local BDropC = {
		edgeFile = "Interface\\ToolTips\\UI-Tooltip-Border",
		bgFile = "Interface\\ToolTips\\UI-Tooltip-Background-Azerite",
		tileEdge = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	local vPT_MF = CreateFrame("Frame","vPT_MF",UIParent,BackdropTemplateMixin and "BackdropTemplate")
		vPT_MF:SetBackdrop(BDropA)
		vPT_MF:SetSize(330,340)
		vPT_MF:ClearAllPoints()
		vPT_MF:SetPoint("CENTER", UIParent)
		vPT_MF:EnableMouse(true)
		vPT_MF:SetMovable(true)
		vPT_MF:RegisterForDrag("LeftButton")
		vPT_MF:SetScript("OnDragStart", function() vPT_MF:StartMoving() end)
		vPT_MF:SetScript("OnDragStop", function() vPT_MF:StopMovingOrSizing() end)
		vPT_MF:SetClampedToScreen(true)
		vPT_MF:Hide()
		
	local vPT_Title = CreateFrame("Frame","vPT_Title",vPT_MF,BackdropTemplateMixin and "BackdropTemplate")
		vPT_Title:SetBackdrop(BDropB)
		vPT_Title:SetSize(vPT_MF:GetWidth()-5,25)
		vPT_Title:ClearAllPoints()
		vPT_Title:SetPoint("TOP", vPT_MF, 0, -3)
			vPT_Title.Text = vPT_Title:CreateFontString("T")
			vPT_Title.Text:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
			vPT_Title.Text:SetPoint("CENTER", vPT_Title, 0, -1)
			vPT_Title.Text:SetText("|cffFFFF00Progress Tracker: `|cffB4B4FFALL THE THINGS|r`|r")
			local vPT_TitleX = CreateFrame("Button", "vPT_TitleX", vPT_Title, "UIPanelCloseButton")
				vPT_TitleX:SetSize(26,26)
				vPT_TitleX:SetPoint("RIGHT", vPT_Title, 0, 0)
				vPT_TitleX:SetScript("OnClick", function() vPT_MF:Hide() end)
	
	local vPT_TitleMode = CreateFrame("Frame","vPT_TitleMode",vPT_MF,BackdropTemplateMixin and "BackdropTemplate")
		vPT_TitleMode:SetSize(vPT_MF:GetWidth()-5,24)
		vPT_TitleMode:ClearAllPoints()
		vPT_TitleMode:SetPoint("TOP", vPT_MF, 0, -23)
			vPT_TitleMode.Text = vPT_TitleMode:CreateFontString("T")
			vPT_TitleMode.Text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
			vPT_TitleMode.Text:SetPoint("CENTER", vPT_TitleMode, 0, 0)
			vPT_TitleMode.Text:SetText("---")
	
	local vPT_ItemCount = CreateFrame("Frame","vPT_ItemCount",vPT_MF,BackdropTemplateMixin and "BackdropTemplate")
		vPT_ItemCount:SetSize(vPT_MF:GetWidth()-5,24)
		vPT_ItemCount:ClearAllPoints()
		vPT_ItemCount:SetPoint("TOP", vPT_MF, 0, -43)
			vPT_ItemCount.Text = vPT_ItemCount:CreateFontString("T")
			vPT_ItemCount.Text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
			vPT_ItemCount.Text:SetPoint("CENTER", vPT_ItemCount, 0, 0)
			vPT_ItemCount.Text:SetText("---")

	local vPT_OptA = CreateFrame("CheckButton","vPT_CB1",vPT_MF,"ChatConfigCheckButtonTemplate")
		vPT_OptA:SetChecked(false)
		vPT_OptA:SetPoint("TOPLEFT", vPT_MF, 5, -65)
		vPT_OptA:SetScript("OnClick", function() vPT_Toggle(1) end)
			vPT_OptA.Text = vPT_OptA:CreateFontString("T")
			vPT_OptA.Text:SetFont("Fonts\\FRIZQT__.TTF", 10)
			vPT_OptA.Text:SetPoint("LEFT", vPT_OptA, 25, 0)
			vPT_OptA.Text:SetText("Click To List: All The Things Main List")
	local vPT_OptB = CreateFrame("CheckButton","vPT_CB2",vPT_MF,"ChatConfigCheckButtonTemplate")
		vPT_OptB:SetChecked(false)
		vPT_OptB:SetPoint("TOPLEFT", vPT_MF, 5, -85)
		vPT_OptB:SetScript("OnClick", function() vPT_Toggle(2) end)
			vPT_OptB.Text = vPT_OptB:CreateFontString("T")
			vPT_OptB.Text:SetFont("Fonts\\FRIZQT__.TTF", 10)
			vPT_OptB.Text:SetPoint("LEFT", vPT_OptB, 25, 0)
			vPT_OptB.Text:SetText("Click To List: Dungeons & Raids Expansion List")
	local vPT_OptC = CreateFrame("CheckButton","vPT_CB3",vPT_MF,"ChatConfigCheckButtonTemplate")
		vPT_OptC:SetChecked(true)
		vPT_OptC:SetPoint("TOPLEFT", vPT_MF, 5, -105)
		vPT_OptC:SetScript("OnClick", function() vPT_Toggle(3) end)
			vPT_OptC.Text = vPT_OptC:CreateFontString("T")
			vPT_OptC.Text:SetFont("Fonts\\FRIZQT__.TTF", 10)
			vPT_OptC.Text:SetPoint("LEFT", vPT_OptC, 25, 0)
			vPT_OptC.Text:SetText("Click To List: Dungeons & Raids and Sub [Default]")

			HeiPos = -178
			for i = 1, #vPT_ATTModes do
				local vPT_ModeList = CreateFrame("Frame","vPT_ModeList"..i,vPT_MF,BackdropTemplateMixin and "BackdropTemplate")
					vPT_ModeList:SetSize(vPT_MF:GetWidth()-5,27)
					vPT_ModeList:ClearAllPoints()
					vPT_ModeList:SetPoint("TOPLEFT", vPT_MF, 0, HeiPos)

					vPT_ModeList.Mode = vPT_ModeList:CreateTexture("vPT_ModeM"..i, "OVERLAY")
					vPT_ModeList.Mode:SetSize(16,16)
					vPT_ModeList.Mode:SetPoint("LEFT", vPT_ModeList, 7, -1)
					vPT_ModeList.Mode:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")

					local vPT_ModeButton = CreateFrame("Button","vPT_ModeButton"..i,vPT_ModeList,"UIPanelButtonTemplate")
						vPT_ModeButton:SetSize(50,22)
						vPT_ModeButton:SetPoint("LEFT", vPT_ModeList, 23, 0)
						vPT_ModeButton:SetText("Pull")
						vPT_ModeButton:SetScript("OnClick", function() QueryATTData(i) end)
						
					vPT_ModeList.Text = vPT_ModeList:CreateFontString("vPT_ModeT"..i)
					vPT_ModeList.Text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
					vPT_ModeList.Text:SetPoint("LEFT", vPT_ModeList, 78, -1)
					vPT_ModeList.Text:SetText(vPT_ATTModes[i])
					
					vPT_ModeList.Last = vPT_ModeList:CreateFontString("vPT_ModeL"..i)
					vPT_ModeList.Last:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
					vPT_ModeList.Last:SetPoint("LEFT", vPT_ModeList, 200, -1)
					vPT_ModeList.Last:SetText("")
				HeiPos = HeiPos - 25
			end

------------------------------------------------------------------------
-- Nothing here, right?
------------------------------------------------------------------------
function DoNothing(f)
	print("Did I Forget Something Here on "..f.." ?")
	--I mean, it's obvious isn't it?
end
------------------------------------------------------------------------
-- Character Data(s)
------------------------------------------------------------------------
local function SaveVarData()
	if vPT_Config == nil then vPT_Config = {} end
	if vPT_Config["vPT_Toggle"] ~= nil then vPT_Toggle(vPT_Config["vPT_Toggle"]) else vPT_Config["vPT_Toggle"] = 3 end

	if vPT_Simple == nil then vPT_Simple = {} end
	if vPT_Simple[vPT_Class] == nil then vPT_Simple[vPT_Class] = {} end

	if vPT_Data == nil then vPT_Data = {} end
	if vPT_Data[vPT_Realm] == nil then vPT_Data[vPT_Realm] = {} end
	if vPT_Data[vPT_Realm][vPT_Player] == nil then vPT_Data[vPT_Realm][vPT_Player] = {} end
	
	if vPT_Profile == nil then vPT_Profile = {} end
	if vPT_Profile[vPT_Realm] == nil then vPT_Profile[vPT_Realm] = {} end
	if vPT_Profile[vPT_Realm][vPT_Player] == nil then vPT_Profile[vPT_Realm][vPT_Player] = {} end
	
	vPT_Profile[vPT_Realm][vPT_Player]["Class"] = vPT_Class
	vPT_Profile[vPT_Realm][vPT_Player]["Color"] = string.upper(string.sub(vPT_HexColor,3))
	vPT_Profile[vPT_Realm][vPT_Player]["Faction"] = select(2,UnitFactionGroup("player"))
	vPT_Profile[vPT_Realm][vPT_Player]["Race"] = vPT_Race
	vPT_Profile[vPT_Realm][vPT_Player]["Level"] = vPT_Level
end
------------------------------------------------------------------------
-- Fire Up Events
------------------------------------------------------------------------
	local vPT_OnUpdate = CreateFrame("Frame")
	vPT_OnUpdate:RegisterEvent("ADDON_LOADED")
	vPT_OnUpdate:SetScript("OnEvent", function(self, event, ...)
		if event == "ADDON_LOADED" then
			SaveVarData()
			vPT_OnUpdate:RegisterEvent("PLAYER_LOGIN")
		end
		if event == "PLAYER_LOGIN" then
			CreateCharDropdown()
			SLASH_ProgressTracker1 = '/pt'
			SLASH_ProgressTracker2 = '/progtrack'
			SLASH_ProgressTracker3 = '/progresstracker'
			SlashCmdList["ProgressTracker"] = function(arg)
				if vPT_MF:IsVisible() then vPT_MF:Hide() else vPT_MF:Show() end
			end
			vPT_OnUpdate:UnregisterEvent("ADDON_LOADED")
			if vPT_Profile[vPT_Realm][vPT_Player]["iLvl"] == nil then vPT_Profile[vPT_Realm][vPT_Player]["iLvl"] = ("%.2f"):format(GetAverageItemLevel()) end
			DEFAULT_CHAT_FRAME:AddMessage("Loaded: "..vPT_AppTitle)
	
			vPT_OnUpdate:UnregisterEvent("PLAYER_LOGIN")
		end
		if event == "PLAYER_LOGOUT" then
			--Do Nothing
		end
	end)
------------------------------------------------------------------------
-- Watching ATT Update Mode Method
------------------------------------------------------------------------
	function vPT_ATTModeChange()
		vPT_TitleMode.Text:SetText("|cffCCCC66".._G["AllTheThings"]["Settings"]:GetModeString().."|r")
		
		local tDE = _G["AllTheThingsSettings"]["General"]["DebugMode"] -- User On Debug Mode?
		local tUC = _G["AllTheThingsSettings"]["General"]["Completionist"] -- User On Unique or Comp Mode?
		local tAC = _G["AllTheThingsSettings"]["General"]["AccountMode"] -- User On Account Mode?

		-- _G["AllTheThings"]["Settings"]:ToggleCompletionistMode()		-- Turn on Uniq
		-- _G["AllTheThings"]["Settings"]:ToggleAccountMode()			-- Turn off Account
		-- _G["AllTheThings"]["Settings"]:ToggleDebugMode()				-- Turn off Debug
		
		if not tUC and not tAC and not tDE then arg = 1 end			-- Unique
		if tUC and not tAC and not tDE then arg = 2 end				-- Completionist
		if not tUC and tAC and not tDE then arg = 3 end				-- Account Unique
		if tUC and tAC and not tDE then arg = 4 end					-- Account Completionist
		if not tUC and (tAC or not tAC) and tDE then arg = 5 end	-- Debug Unique
		if tUC and (tAC or not tAC) and tDE then arg = 6 end		-- Debug Completionist

		for i = 1, #vPT_ATTSMode do
			_G["vPT_ModeM"..i]:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
		end
		_G["vPT_ModeM"..arg]:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
	end
	
	_G["AllTheThings"]["Settings"]:HookScript("OnUpdate",vPT_ATTModeChange)