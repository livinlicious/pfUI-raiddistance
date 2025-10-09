pfUI:RegisterModule("RaidDistance", "vanilla:tbc", function ()
  -- Default configuration values
  pfUI:UpdateConfig("RaidDistance", nil, "updateFrequency", 0.5)
  pfUI:UpdateConfig("RaidDistance", nil, "fontSize", 10)
  pfUI:UpdateConfig("RaidDistance", nil, "enabled", 1)
  pfUI:UpdateConfig("RaidDistance", nil, "xOffset", 0)
  pfUI:UpdateConfig("RaidDistance", nil, "yOffset", 0)
  pfUI:UpdateConfig("RaidDistance", nil, "alignment", "CENTER")

  -- Storage for our distance text frames
  local distanceFrames = {}
  local frameCounter = 0

  -- Create GUI configuration
  if pfUI.gui.CreateGUIEntry then
    pfUI.gui.CreateGUIEntry(T["Thirdparty"], T["Raid Distance"], function()
      pfUI.gui.CreateConfig(nil, T["Enable Raid Distance"], C.RaidDistance, "enabled", "checkbox")
      pfUI.gui.CreateConfig(nil, T["Update Frequency (seconds)"], C.RaidDistance, "updateFrequency", "text")
      pfUI.gui.CreateConfig(nil, T["Font Size"], C.RaidDistance, "fontSize", "text")
      pfUI.gui.CreateConfig(nil, T["X Offset"], C.RaidDistance, "xOffset", "text")
      pfUI.gui.CreateConfig(nil, T["Y Offset"], C.RaidDistance, "yOffset", "text")
      pfUI.gui.CreateConfig(nil, T["Text Alignment"], C.RaidDistance, "alignment", "dropdown", 
        { ["LEFT"] = "Left", ["CENTER"] = "Center", ["RIGHT"] = "Right" })
    end)
  else
    pfUI.gui.tabs.thirdparty.tabs.RaidDistance = pfUI.gui.tabs.thirdparty.tabs:CreateTabChild("RaidDistance", true)
    pfUI.gui.tabs.thirdparty.tabs.RaidDistance:SetScript("OnShow", function()
      if not this.setup then
        local CreateConfig = pfUI.gui.CreateConfig
        this.setup = true
        CreateConfig(this, T["Enable Raid Distance"], C.RaidDistance, "enabled", "checkbox")
        CreateConfig(this, T["Update Frequency (seconds)"], C.RaidDistance, "updateFrequency", "text")
        CreateConfig(this, T["Font Size"], C.RaidDistance, "fontSize", "text")
        CreateConfig(this, T["X Offset"], C.RaidDistance, "xOffset", "text")
        CreateConfig(this, T["Y Offset"], C.RaidDistance, "yOffset", "text")
        CreateConfig(this, T["Text Alignment"], C.RaidDistance, "alignment", "dropdown", 
          { ["LEFT"] = "Left", ["CENTER"] = "Center", ["RIGHT"] = "Right" })
      end
    end)
  end

  local function GetDistance(unit)
    if not UnitExists(unit) then return nil end
    local success, distance = pcall(UnitXP, "distanceBetween", "player", unit)
    if success then return distance end
    return nil
  end

  local function GetLineOfSight(unit)
    if not UnitExists(unit) then return true end
    local success, los = pcall(UnitXP, "inSight", "player", unit)
    if success then return los end
    return true
  end

  local function UpdateUnitFrameDistance(frame, unit)
    if not frame or not unit or not UnitExists(unit) then return end

    if tonumber(C.RaidDistance.enabled) ~= 1 then
      if distanceFrames[frame] then
        distanceFrames[frame]:Hide()
      end
      return
    end

    if UnitIsUnit(unit, "player") then
      if distanceFrames[frame] then
        distanceFrames[frame]:Hide()
      end
      return
    end

    local distance = GetDistance(unit)
    local hasLOS = GetLineOfSight(unit)

    if not distanceFrames[frame] then
      distanceFrames[frame] = frame:CreateFontString(nil, "OVERLAY")
      local font = pfUI.font_default or "Fonts\\FRIZQT__.TTF"
      distanceFrames[frame]:SetFont(font, tonumber(C.RaidDistance.fontSize) or 10, "OUTLINE")
    end

    local distanceText = distanceFrames[frame]
    local font = pfUI.font_default or "Fonts\\FRIZQT__.TTF"
    distanceText:SetFont(font, tonumber(C.RaidDistance.fontSize) or 10, "OUTLINE")

    -- FIXED: Use the same method as pfUI unitframes for text alignment
    distanceText:ClearAllPoints()
    local xOffset = tonumber(C.RaidDistance.xOffset) or 0
    local yOffset = tonumber(C.RaidDistance.yOffset) or 0
    local alignment = C.RaidDistance.alignment or "CENTER"
    
    -- Set justification FIRST (like pfUI does)
    distanceText:SetJustifyH(alignment)
    
    -- Then set anchor points with proper frame regions (like pfUI health/power text)
    if alignment == "LEFT" then
      distanceText:SetPoint("TOPLEFT", frame, "TOPLEFT", 2 + xOffset, -1 + yOffset)
      distanceText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2 + xOffset, yOffset)
    elseif alignment == "RIGHT" then
      distanceText:SetPoint("TOPLEFT", frame, "TOPLEFT", 2 + xOffset, -1 + yOffset)
      distanceText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2 + xOffset, yOffset)
    else -- CENTER
      distanceText:SetPoint("TOPLEFT", frame, "TOPLEFT", xOffset, -1 + yOffset)
      distanceText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", xOffset, yOffset)
    end

    if distance and tonumber(distance) and tonumber(distance) > 0 then
      distanceText:SetText(string.format("%.0fyr", tonumber(distance)))
    else
      distanceText:SetText("--")
    end
    distanceText:Show()

    if hasLOS then
      distanceText:SetTextColor(1, 1, 1, 1)
    else
      distanceText:SetTextColor(1, 0, 0, 1)
    end
  end

  local function UpdateAllRaidFrames()
    if tonumber(C.RaidDistance.enabled) ~= 1 then return end
    if not pfUI or not pfUI.uf then return end

    if pfUI.uf.raid then
      local maxraid = tonumber(pfUI_config.unitframes.maxraid) or 40
      for i = 1, maxraid do
        local frame = pfUI.uf.raid[i]
        if frame and frame.id and tonumber(frame.id) and tonumber(frame.id) > 0 then
          local unit = "raid" .. frame.id
          if UnitExists(unit) then
            UpdateUnitFrameDistance(frame, unit)
          end
        end
      end
    end

    if not UnitInRaid("player") and pfUI.uf.frames then
      for _, frame in pairs(pfUI.uf.frames) do
        if frame and frame.label then
          if frame.label == "party" and frame.id and frame.id ~= "" then
            local unit = frame.label .. frame.id
            if UnitExists(unit) then
              UpdateUnitFrameDistance(frame, unit)
            end
          end
        end
      end
    end
  end

  local function OnUpdate()
    frameCounter = frameCounter + 1
    local updateFreq = tonumber(C.RaidDistance.updateFrequency) or 0.5
    local targetFrames = math.max(1, math.floor(updateFreq * 60))

    if frameCounter >= targetFrames then
      UpdateAllRaidFrames()
      frameCounter = 0
    end
  end

  -- Initialize update frame
  local updateFrame = CreateFrame("Frame")
  updateFrame:SetScript("OnUpdate", OnUpdate)

  -- Initial update
  UpdateAllRaidFrames()
end)