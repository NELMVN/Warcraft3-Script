<p align="center">Hiding Save Game Button and Load Game Button in 1.31+ patch.</p>

---

This script hides Save Game Button and Load Game Button.

```javascript
scope NoSaveGame initializer render
    private function renderMainMenu takes nothing returns nothing
        local framehandle EscMenuOptionsPanel = BlzGetFrameByName("EscMenuOptionsPanel", 0)

        call BlzFrameSetVisible(BlzGetFrameByName("SaveGameButton", 0), false)
        call BlzFrameSetVisible(BlzGetFrameByName("LoadGameButton", 0), false)

        set EscMenuOptionsPanel = null
    endfunction

    private function render takes nothing returns nothing
        // Re-rendering Main Menu
        call TimerStart(CreateTimer(), 0, false, function renderMainMenu)
    endfunction
endscope
```

---

This script hides Save Game Button, Load Game Button, Help Button, and Tips Button.

```javascript
scope NoSaveGame initializer render
    private function renderMainMenu takes nothing returns nothing
        local framehandle EscMenuOptionsPanel = BlzGetFrameByName("EscMenuOptionsPanel", 0)
        local framehandle OptionButton = BlzGetFrameByName("OptionsButton", 0)
        local framehandle EndGameButton = BlzGetFrameByName("EndGameButton", 0)

        call BlzFrameSetVisible(BlzGetFrameByName("SaveGameButton", 0), false)
        call BlzFrameSetVisible(BlzGetFrameByName("LoadGameButton", 0), false)
        call BlzFrameSetVisible(BlzGetFrameByName("HelpButton", 0), false)
        call BlzFrameSetVisible(BlzGetFrameByName("TipsButton", 0), false)

        // Re-adjust the button's XY
        call BlzFrameClearAllPoints(OptionButton)
        call BlzFrameClearAllPoints(EndGameButton)

        call BlzFrameSetPoint(OptionButton, FRAMEPOINT_TOP, EscMenuOptionsPanel, FRAMEPOINT_TOP, 0, -0.067)
        call BlzFrameSetPoint(EndGameButton, FRAMEPOINT_TOP, OptionButton, FRAMEPOINT_TOP, 0, -0.037)

        set EscMenuOptionsPanel = null
    endfunction

    private function render takes nothing returns nothing
        // Re-rendering Main Menu
        call TimerStart(CreateTimer(), 0, false, function renderMainMenu)
    endfunction
endscope
```
