ui = {}

function ui:clickHitRect(x, y, buttonX, buttonY, buttonW, buttonH)
    return x > buttonX and x < buttonX + buttonW and y > buttonY and y < buttonY + buttonH
end