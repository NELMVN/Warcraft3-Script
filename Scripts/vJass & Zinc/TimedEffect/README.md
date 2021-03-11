## Example:

```vb
scope SpawnEffects initializer main
    private function main takes nothing returns nothing
        // Remove fog
        call Cheat("iseedeadpeople")
        call SetCameraPosition(0, 0)

        // Spawn Spellbreakers
        call TimedEffect.Apply(AddSpecialEffect("units\\human\\BloodElfSpellThief\\BloodElfSpellThief.mdl", 100, 0), 5)
        call TimedEffect.Apply(AddSpecialEffect("units\\human\\BloodElfSpellThief\\BloodElfSpellThief.mdl", 200, 0), 10)
        call TimedEffect.Apply(AddSpecialEffect("units\\human\\BloodElfSpellThief\\BloodElfSpellThief.mdl", 300, 0), 15)
        call TimedEffect.Apply(AddSpecialEffect("units\\human\\BloodElfSpellThief\\BloodElfSpellThief.mdl", 400, 0), 20)
        call TimedEffect.Apply(AddSpecialEffect("units\\human\\BloodElfSpellThief\\BloodElfSpellThief.mdl", 500, 0), 25)
        call TimedEffect.Apply(AddSpecialEffect("units\\human\\BloodElfSpellThief\\BloodElfSpellThief.mdl", 600, 0), 30)
    endfunction
endscope
```
