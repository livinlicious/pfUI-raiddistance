pfUI:RegisterModule("RaidDistance", "vanilla:tbc", function ()
  -- Default configuration values
  pfUI:UpdateConfig("RaidDistance", nil, "updateFrequency", 0.5)

  -- Raid defaults
  pfUI:UpdateConfig("RaidDistance", nil, "raid_enabled", 1)
  pfUI:UpdateConfig("RaidDistance", nil, "raid_fontSize", 10)
  pfUI:UpdateConfig("RaidDistance", nil, "raid_xOffset", 0)
  pfUI:UpdateConfig("RaidDistance", nil, "raid_yOffset", 0)
  pfUI:UpdateConfig("RaidDistance", nil, "raid_alignment", "CENTER")

  -- Party defaults
  pfUI:UpdateConfig("RaidDistance", nil, "party_enabled", 1)
  pfUI:UpdateConfig("RaidDistance", nil, "party_fontSize", 10)
  pfUI:UpdateConfig("RaidDistance", nil, "party_xOffset", 0)
  pfUI:UpdateConfig("RaidDistance", nil, "party_yOffset", 0)
  pfUI:UpdateConfig("RaidDistance", nil, "party_alignment", "CENTER")

  -- Target defaults
  pfUI:UpdateConfig("RaidDistance", nil, "target_enabled", 1)
  pfUI:UpdateConfig("RaidDistance", nil, "target_fontSize", 10)
  pfUI:UpdateConfig("RaidDistance", nil, "target_xOffset", 0)
  pfUI:UpdateConfig("RaidDistance", nil, "target_yOffset", 0)
  pfUI:UpdateConfig("RaidDistance", nil, "target_alignment", "CENTER")

  -- Storage for our distance text frames
  local distanceFrames = {}
  local frameCounter = 0

  -- Create GUI configuration
  if pfUI.gui.CreateGUIEntry then
    pfUI.gui.CreateGUIEntry(T["Thirdparty"], T["Raid Distance"], function()
      pfUI.gui.CreateConfig(nil, T["Update Frequency (seconds)"], C.RaidDistance, "updateFrequency", "text")
      
      -- Raid Settings
      pfUI.gui.CreateConfig(nil, T["Raid: Enable"], C.RaidDistance, "raid_enabled", "checkbox")
      pfUI.gui.CreateConfig(nil, T["Raid: Font Size"], C.RaidDistance, "raid_fontSize", "text")
      pfUI.gui.CreateConfig(nil, T["Raid: X Offset"], C.RaidDistance, "raid_xOffset", "text")
      pfUI.gui.CreateConfig(nil, T["Raid: Y Offset"], C.RaidDistance, "raid_yOffset", "text")
      pfUI.gui.CreateConfig(nil, T["Raid: Text Alignment"], C.RaidDistance, "raid_alignment", "dropdown", 
        { ["LEFT"] = "Left", ["CENTER"] = "Center", ["RIGHT"] = "Right" })

      -- Party Settings
      pfUI.gui.CreateConfig(nil, T["Party: Enable"], C.RaidDistance, "party_enabled", "checkbox")
      pfUI.gui.CreateConfig(nil, T["Party: Font Size"], C.RaidDistance, "party_fontSize", "text")
      pfUI.gui.CreateConfig(nil, T["Party: X Offset"], C.RaidDistance, "party_xOffset", "text")
      pfUI.gui.CreateConfig(nil, T["Party: Y Offset"], C.RaidDistance, "party_yOffset", "text")
      pfUI.gui.CreateConfig(nil, T["Party: Text Alignment"], C.RaidDistance, "party_alignment", "dropdown", 
        { ["LEFT"] = "Left", ["CENTER"] = "Center", ["RIGHT"] = "Right" })

      -- Target Settings
      pfUI.gui.CreateConfig(nil, T["Target: Enable"], C.RaidDistance, "target_enabled", "checkbox")
      pfUI.gui.CreateConfig(nil, T["Target: Font Size"], C.RaidDistance, "target_fontSize", "text")
      pfUI.gui.CreateConfig(nil, T["Target: X Offset"], C.RaidDistance, "target_xOffset", "text")
      pfUI.gui.CreateConfig(nil, T["Target: Y Offset"], C.RaidDistance, "target_yOffset", "text")
      pfUI.gui.CreateConfig(nil, T["Target: Text Alignment"], C.RaidDistance, "target_alignment", "dropdown", 
        { ["LEFT"] = "Left", ["CENTER"] = "Center", ["RIGHT"] = "Right" })
    end)
  else
    pfUI.gui.tabs.thirdparty.tabs.RaidDistance = pfUI.gui.tabs.thirdparty.tabs:CreateTabChild("RaidDistance", true)
    pfUI.gui.tabs.thirdparty.tabs.RaidDistance:SetScript("OnShow", function()
      if not this.setup then
        local CreateConfig = pfUI.gui.CreateConfig
        this.setup = true
        CreateConfig(this, T["Update Frequency (seconds)"], C.RaidDistance, "updateFrequency", "text")

        CreateConfig(this, T["Raid: Enable"], C.RaidDistance, "raid_enabled", "checkbox")
        CreateConfig(this, T["Raid: Font Size"], C.RaidDistance, "raid_fontSize", "text")
        CreateConfig(this, T["Raid: X Offset"], C.RaidDistance, "raid_xOffset", "text")
        CreateConfig(this, T["Raid: Y Offset"], C.RaidDistance, "raid_yOffset", "text")
        CreateConfig(this, T["Raid: Text Alignment"], C.RaidDistance, "raid_alignment", "dropdown", 
          { ["LEFT"] = "Left", ["CENTER"] = "Center", ["RIGHT"] = "Right" })
        
        CreateConfig(this, T["Party: Enable"], C.RaidDistance, "party_enabled", "checkbox")
        CreateConfig(this, T["Party: Font Size"], C.RaidDistance, "party_fontSize", "text")
        CreateConfig(this, T["Party: X Offset"], C.RaidDistance, "party_xOffset", "text")
        CreateConfig(this, T["Party: Y Offset"], C.RaidDistance, "party_yOffset", "text")
        CreateConfig(this, T["Party: Text Alignment"], C.RaidDistance, "party_alignment", "dropdown", 
          { ["LEFT"] = "Left", ["CENTER"] = "Center", ["RIGHT"] = "Right" })

        CreateConfig(this, T["Target: Enable"], C.RaidDistance, "target_enabled", "checkbox")
        CreateConfig(this, T["Target: Font Size"], C.RaidDistance, "target_fontSize", "text")
        CreateConfig(this, T["Target: X Offset"], C.RaidDistance, "target_xOffset", "text")
        CreateConfig(this, T["Target: Y Offset"], C.RaidDistance, "target_yOffset", "text")
        CreateConfig(this, T["Target: Text Alignment"], C.RaidDistance, "target_alignment", "dropdown", 
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

  local function UpdateUnitFrameDistance(frame, unit, type)
    if not frame or not unit or not UnitExists(unit) then return end

    local enabled = tonumber(C.RaidDistance[type .. "_enabled"]) or 1
    if enabled ~= 1 then
      if distanceFrames[frame] then
        if distanceFrames[frame].text then distanceFrames[frame].text:Hide() end
      end
      return
    end

    if UnitIsUnit(unit, "player") then
      if distanceFrames[frame] then
        if distanceFrames[frame].text then distanceFrames[frame].text:Hide() end
      end
      return
    end

    local distance = GetDistance(unit)
    local hasLOS = GetLineOfSight(unit)

    if not distanceFrames[frame] then
      -- Use a holder frame to ensure text sits above healthbars (especially for party frames)
      local holder = CreateFrame("Frame", nil, frame)
      holder:SetAllPoints(frame)
      holder:SetFrameLevel(frame:GetFrameLevel() + 50)
      
      local fs = holder:CreateFontString(nil, "OVERLAY")
      distanceFrames[frame] = { holder = holder, text = fs }
      
      local font = pfUI.font_default or "Fonts\\FRIZQT__.TTF"
      fs:SetFont(font, tonumber(C.RaidDistance[type .. "_fontSize"]) or 10, "OUTLINE")
    end

    -- Ensure holder level matches current frame
    if distanceFrames[frame].holder then
      distanceFrames[frame].holder:SetFrameLevel(frame:GetFrameLevel() + 50)
    end

    local distanceText = distanceFrames[frame].text
    local font = pfUI.font_default or "Fonts\\FRIZQT__.TTF"
    distanceText:SetFont(font, tonumber(C.RaidDistance[type .. "_fontSize"]) or 10, "OUTLINE")

    -- Use the same method as pfUI unitframes for text alignment
    distanceText:ClearAllPoints()
    local xOffset = tonumber(C.RaidDistance[type .. "_xOffset"]) or 0
    local yOffset = tonumber(C.RaidDistance[type .. "_yOffset"]) or 0
    local alignment = C.RaidDistance[type .. "_alignment"] or "CENTER"
    
    -- Set justification FIRST
    distanceText:SetJustifyH(alignment)
    
    -- Then set anchor points with proper frame regions
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

    if hasLOS and (not distance or tonumber(distance) <= 40) then
      distanceText:SetTextColor(1, 1, 1, 1)
    else
      distanceText:SetTextColor(1, 0, 0, 1)
    end
  end

  local function UpdateAllRaidFrames()
    if not pfUI or not pfUI.uf then return end

    -- Update Raid Frames
    if pfUI.uf.raid then
      local maxraid = tonumber(pfUI_config.unitframes.maxraid) or 40
      for i = 1, maxraid do
        local frame = pfUI.uf.raid[i]
        if frame and frame.id and tonumber(frame.id) and tonumber(frame.id) > 0 then
          local unit = "raid" .. frame.id
          if UnitExists(unit) then
            UpdateUnitFrameDistance(frame, unit, "raid")
          end
        end
      end
    end

    -- Update Party Frames
    if not UnitInRaid("player") and pfUI.uf.frames then
      for _, frame in pairs(pfUI.uf.frames) do
        if frame and frame.label then
          if frame.label == "party" and frame.id and frame.id ~= "" then
            local unit = frame.label .. frame.id
            if UnitExists(unit) then
              UpdateUnitFrameDistance(frame, unit, "party")
            end
          end
        end
      end
    end

    -- Update Target Frame
    if pfUI.uf.target and UnitExists("target") then
      UpdateUnitFrameDistance(pfUI.uf.target, "target", "target")
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