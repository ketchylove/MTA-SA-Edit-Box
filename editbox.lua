---
--- Created by KetchyLove.
--- DateTime: 25.01.2025 01:19

local allEditboxs = {}
local nowEditing = false
local id = 1
local backState = 100
selectedIndex = 1
local starter = getTickCount()
function dxDrawEditbox(text, x, y, w, h, scale, font, alignX, alignY, color, wordBreak)
    local text = text or 'Bilinmiyor'
    local scale = scale or 1
    local font = font or 'default'
    local alignX = alignX or 'left'
    local alignY = alignY or 'top'
    table.insert(allEditboxs,
        { id = id, text = text, x = x, y = y, w = w, h = h, scale = scale, font = font, alignX = alignX, alignY = alignY, color =
        color, wordBreak = wordBreak, allSelect = false })
    selectedIndex = utf8.len(text)
    id = id + 1
end

local editboxRenderHandler = function()
    now = getTickCount()
    for index, value in pairs(allEditboxs) do
        if value then
            local alpha = interpolateBetween(0, 0, 0, 200, 0, 0, (now - starter) / 1000, 'SineCurve')
            local textWidth, textHeight = dxGetTextSize(value.text, value.w, value.scale, value.font, value.wordBreak)
            local deftextWidth, deftextHeight = dxGetTextSize('S', value.w, value.scale, value.font, value.wordBreak)
            local first, second = utf8.sub(value.text, 1, selectedIndex), utf8.sub(value.text, selectedIndex + 1)
            local firstWidth = dxGetTextWidth(first, value.scale, value.font)
            dxDrawText(value.text, value.x + 10, value.y + (value.h / 4), value.x + value.w - 10, value.y + value.h,
                value.color, value.scale, value.font, value.alignX, value.alignY, false, value.wordBreak, true)
            if (utf8.len(value.text) > 0 and isInBox(value.x, value.y, textWidth, textHeight, 'text') or isInBox(value.x, value.y, value.w, value.h, 'text')) then
                if isClicked('mouse1') then
                    nowEditing = allEditboxs[index]
                    selectedIndex = utf8.len(value.text)
                    guiSetInputEnabled(true)
                    if value.firstClick == false then
                        value.firstClick = true
                        if value.clearOnClick then
                            value.text = ''
                        end
                    end
                end
            end
            if nowEditing == allEditboxs[index] then
                dxDrawRectangle(value.x + firstWidth + 9, value.y + (value.h / 4) + 3, 1,
                    (utf8.len(value.text) > 0 and textHeight - 6 or deftextHeight - 6), tocolor(200, 200, 200, alpha),
                    true)
                if 0 < getTickCount() then
                    if getKeyState("backspace") then
                        backState = backState - 1
                    else
                        backState = 100
                    end
                    if getKeyState("backspace") and (getTickCount() - starter) > backState then
                        if nowEditing.text ~= '' then
                            if nowEditing.allSelect then
                                nowEditing.text = ''
                                nowEditing.allSelect = false
                            else
                                nowEditing.text = utf8.sub(first, 1, -2) .. second
                                selectedIndex = selectedIndex - 1
                                playSound(':srp_auth/assets/key.mp3')
                            end
                        end
                        starter = getTickCount()
                    end
                end
                if nowEditing.allSelect then
                    dxDrawRectangle(value.x + 10, value.y + (value.h / 4), textWidth, textHeight,
                        tocolor(63, 127, 217, 100), true)
                end
                if getKeyState('lctrl') and isClicked('a') then
                    nowEditing.allSelect = true
                end
                if getKeyState('lctrl') and isClicked('x') then
                    if nowEditing.allSelect then
                        setClipboard(nowEditing.text)
                        nowEditing.text = ''
                    end
                end
                if isClicked('arrow_l') then
                    selectedIndex = math.max(selectedIndex - 1, 0)
                    if nowEditing.allSelect then
                        nowEditing.allSelect = false
                    end
                end
                if isClicked('arrow_r') then
                    selectedIndex = math.min(selectedIndex + 1, #value.text)
                    if nowEditing.allSelect then
                        nowEditing.allSelect = false
                    end
                end
            end
        end
    end
end
function cleanupAllEditboxs()
    nowEditing = false
    backState = 100
    selectedIndex = 1
    for name, _ in pairs(allEditboxs) do
        allEditboxs[name] = false
    end
    guiSetInputEnabled(false)
end

addEventHandler('onClientRender', root, editboxRenderHandler)
addEventHandler('onClientCharacter', root, function(character)
    if nowEditing then
        if nowEditing.allSelect then
            nowEditing.text = ''
            nowEditing.allSelect = false
        end
        if selectedIndex then
            nowEditing.text = utf8.sub(nowEditing.text, 1, selectedIndex) ..
            character .. utf8.sub(nowEditing.text, selectedIndex + 1)
            selectedIndex = selectedIndex + 1
            w, h = dxGetTextSize(nowEditing.text, 0, 5, "default-bold")
            playSound(':srp_auth/assets/key.mp3')
        end
    end
end)

addEventHandler("onClientPaste", root, function(text)
    if nowEditing then
        if nowEditing.allSelect then
            nowEditing.text = text
            nowEditing.allSelect = false
        end
    end
end)
function getEditboxText(name)
    if allEditboxs[name] then
        return allEditboxs[name].text
    else
        return 'N/A'
    end
end

function deleteEditbox(name)
    if allEditboxs[name] then
        allEditboxs[name] = false
        return true
    else
        return false
    end
end

function getEditbox(name)
    return allEditboxs[name]
end
---