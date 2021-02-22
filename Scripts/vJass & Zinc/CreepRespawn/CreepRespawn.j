scope CreepRespawn /* v2.0.0.0
*************************************************************************************
*
*    Efficient Creep Respawning System. It is used for RPG Maps.
*
*************************************************************************************
*
*    Required:
*
*       CTL                         https://github.com/nestharus/JASS/blob/master/jass/Systems/ConstantTimerLoop32/script.j
*       NewTable                    https://www.hiveworkshop.com/threads/snippet-new-table.188084/
*
*    --------------------------
*
*    Optional:
*
*       RegisterPlayerUnitEvent     https://www.hiveworkshop.com/threads/snippet-registerevent-pack.250266/
*
************************************************************************************/

    globals
        // Owner
        private constant player  CREEP_OWNER     = Player(PLAYER_NEUTRAL_AGGRESSIVE)

        // Duration
        private constant integer REVIVE_DURATION = 10

        // Revive Effect
        private constant string  REVIVE_EFFECT   = "Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl"

        // Remove corpse to reduce fps drops.
        private constant boolean NO_CORPSE       = true 
    endglobals

    private struct sys extends array
        private static constant integer CREEP_MAX_COUNT = 0x2000
        private static TableArray tbArray
        private static integer CreepCount = 0

        private unit Creep
        private real Duration

        // Declare local var before looping
        implement CTL
            local integer CreepIndex

        // Start looping
        implement CTLExpire
            // Check if Duration reached 0
            if this.Duration <= 0 then
                // Get Creep Index
                set CreepIndex = GetUnitUserData(this.Creep)

                // Spawn
                call SetUnitUserData(CreateUnit(CREEP_OWNER, GetUnitTypeId(this.Creep), tbArray[CreepIndex].real[0], tbArray[CreepIndex].real[1], tbArray[CreepIndex].real[2]), CreepIndex)
                call DestroyEffect(AddSpecialEffect(REVIVE_EFFECT, tbArray[CreepIndex].real[0], tbArray[CreepIndex].real[1]))

                static if NO_CORPSE then
                    call RemoveUnit(this.Creep)
                endif

                // Recycle
                set this.Creep = null
                set this.Duration = 0

                // Deallocate
                call destroy()
            else
                set this.Duration = this.Duration - .031250000
                debug call BJDebugMsg("[Index: " + I2S(this) + "] [Duration: " + R2S(this.Duration) + "]")
            endif
        implement CTLEnd

        // Dying Event
        static if LIBRARY_RegisterAnyPlayerUnitEvent then
            private static method onDeath takes nothing returns nothing
        else
            private static method onDeath takes nothing returns boolean
        endif
            local thistype this
            local unit u = GetTriggerUnit()
            local integer Index = GetUnitUserData(u)

            // Check if dying unit is revivable.
            if tbArray[Index].boolean[3] then
                set this = thistype.create()

                set this.Duration = REVIVE_DURATION
                set this.Creep = u
            debug else
                debug call BJDebugMsg("[" + GetUnitName(Creep) + "] is not revivable.")
            endif

            static if not LIBRARY_RegisterAnyPlayerUnitEvent then
                return false
            endif
        endmethod

        // Registration
        private static method onRegister takes nothing returns nothing
            local unit Creep = GetFilterUnit()
            local integer Index = 0

            // Register except unit with locust.
            if GetUnitAbilityLevel(Creep, 'Aloc') == 0 then
                // Set Index
                set thistype.CreepCount = thistype.CreepCount + 1
                set Index = thistype.CreepCount
                call SetUnitUserData(Creep, Index)

                // Save X, Y, and Facing values.
                set tbArray[Index].real[0] = GetUnitX(Creep)
                set tbArray[Index].real[1] = GetUnitY(Creep)
                set tbArray[Index].real[2] = GetUnitFacing(Creep)
                set tbArray[Index].boolean[3] = true

                debug call BJDebugMsg("[" + I2S(Index) + "] [" + GetUnitName(Creep) + "] [" + R2S(tbArray[Index].real[0]) + "] [" + R2S(tbArray[Index].real[1]) + "] [" + R2S(tbArray[Index].real[2]) + "] is registered.")
            debug else
                debug call BJDebugMsg("[" + GetUnitName(Creep) + "] has locust ability.")
            endif

            set Creep = null
        endmethod

        private static method registerMode takes nothing returns nothing
            local group Iterator = CreateGroup()

            // Get all CREEP_OWNER units.
            call GroupEnumUnitsOfPlayer(Iterator, CREEP_OWNER, Filter(function thistype.onRegister))

            // Remove memory leaks.
            call DestroyGroup(Iterator)
            call DestroyTimer(GetExpiredTimer())
            set Iterator = null
        endmethod

        // Init
        private static method onInit takes nothing returns nothing
            // Init onDeath Event
            static if LIBRARY_RegisterAnyPlayerUnitEvent then
                call RegisterPlayerUnitEvent(CREEP_OWNER, EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            else
                local trigger trg = CreateTrigger()

                call TriggerRegisterPlayerUnitEvent(trg, CREEP_OWNER, EVENT_PLAYER_UNIT_DEATH, null )
                call TriggerAddCondition(trg, Condition(function thistype.onDeath))

                set trg = null
            endif

            // Init TableArray
            set tbArray = TableArray[thistype.CREEP_MAX_COUNT]

            // Register
            call TimerStart(CreateTimer(), 0, false, function thistype.registerMode)
        endmethod
    endstruct
endscope
