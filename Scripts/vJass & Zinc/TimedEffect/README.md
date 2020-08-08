## Example:

```vb
scope SpawnEffects initializer main
    private function main takes nothing returns nothing
        call TimedEffect.Apply(AddSpecialEffect("units\\human\\BloodElfSpellThief\\BloodElfSpellThief.mdl", 0, 0), 5)
        call TimedEffect.Apply(AddSpecialEffect("units\\human\\BloodElfSpellThief\\BloodElfSpellThief.mdl", 0, 0), 10)
        call TimedEffect.Apply(AddSpecialEffect("units\\human\\BloodElfSpellThief\\BloodElfSpellThief.mdl", 0, 0), 15)
        call TimedEffect.Apply(AddSpecialEffect("units\\human\\BloodElfSpellThief\\BloodElfSpellThief.mdl", 0, 0), 20)
        call TimedEffect.Apply(AddSpecialEffect("units\\human\\BloodElfSpellThief\\BloodElfSpellThief.mdl", 0, 0), 25)
        call TimedEffect.Apply(AddSpecialEffect("units\\human\\BloodElfSpellThief\\BloodElfSpellThief.mdl", 0, 0), 30)
    endfunction
endscope
```
