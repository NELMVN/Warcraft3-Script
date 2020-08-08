library CreepRespawn /* v1.0.0.2
*************************************************************************************
*
*   An RPG Creep Respawn.
*
*************************************************************************************
*
*   */ needs /*
*
*       ___________________________________
*
*       Required:
*
*       */ Table                                    /*      hiveworkshop.com/threads/snippet-new-table.188084/
*       */ TimerUtils                               /*      wc3c.net/showthread.php?t=101322
*       */ Alloc                                    /*      github.com/nestharus/JASS/blob/master/jass/Systems/Alloc/Table/script.j
*
*       ___________________________________
*
*       Optional:
*
*       */ optional RegisterPlayerUnitEvent         /*      hiveworkshop.com/threads/snippet-registerevent-pack.250266/
*       */ optional UnitDex                         /*      hiveworkshop.com/threads/system-unitdex-unit-indexer.248209/
*
************************************************************************************
*
*   SETTINGS
*
*/
    globals
        /*
        *    Player
        */
        private constant   player PLAYER                 = Player(PLAYER_NEUTRAL_AGGRESSIVE)
        
        /*
        *    Special effect for revived creep.
        */
        private constant   string REVIVE_EFFECT          = "Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl"

        /*
        *    Revive duration
        */
        private constant     real CREEP_REGULAR_DURATION = 5
        private constant     real CREEP_BOSS_DURATION    = 10
        
        /*
        *   Boss Type
        *
        *   Note: You must set the Unit's classification at Object Editor
        *         based on CREEP_TYPE_BOSS.
        */
        private constant unittype CREEP_TYPE_BOSS        = UNIT_TYPE_ANCIENT

        /*
        *    Maximum number of creeps.
        *
        *   Note: You do not need to change this value unless you know what
        *   are you doing.
        */
        private constant  integer CREEP_MAX_COUNT        = 0x2000
    endglobals
/*
***********************************************************************************/

    globals
        private TableArray CreepTable
        private integer Count = 0
    endglobals

    private struct System extends array
        implement Alloc

        private integer type
        private unit unit
        private integer key

        private static method onRevive takes nothing returns nothing
            local timer Timer = GetExpiredTimer()
            local thistype this = GetTimerData(Timer)

            local unit Creep = CreateUnit(PLAYER,                           /*
            */     this.type,                                               /*
            */     CreepTable[this.key].real[0],                            /*
            */     CreepTable[this.key].real[1],                            /*
            */     CreepTable[this.key].real[2]                             /*
            */ )
            
            static if LIBRARY_UnitDex then
                local integer Index = GetUnitId(Creep)

                /*
                *    Copy the old unit's information to new indexed unit.
                */
                set CreepTable[Index].real[0] = CreepTable[this.key].real[0]
                set CreepTable[Index].real[1] = CreepTable[this.key].real[1]
                set CreepTable[Index].real[2] = CreepTable[this.key].real[2]
                set CreepTable[Index].boolean[3] = true

                /*
                *    Flush old unit.
                */
                call CreepTable[this.key].flush()
            else
                /*
                *    Set the new unit's index based on dead unit's index
                */
                call SetUnitUserData(Creep, this.key)
            endif

            /*
            *    Revive Effect
            */
            call DestroyEffect(AddSpecialEffect(REVIVE_EFFECT, GetUnitX(Creep), GetUnitY(Creep)))

            /*
            *    Remove corpse
            */
            if this.unit != null then
                call RemoveUnit(this.unit)
                set this.unit = null
            endif

            /*
            *    Remove Timer
            */
            call ReleaseTimer(Timer)

            /*
            *    Remove memory leaks
            */
            set Creep = null
            set Timer = null
            set this.type = 0
            set this.key = 0
            
            /*
            *    Deindex
            */
            call this.deallocate()
        endmethod
        
    static if LIBRARY_RegisterAnyPlayerUnitEvent then
        private static method onDeath takes nothing returns nothing
    else
        private static method onDeath takes nothing returns boolean
    endif
            local thistype this
            local real Duration = 0
            local unit u = GetTriggerUnit()
            local integer k = GetUnitUserData(u)

            /*
            *    Check if this unit is registered on this system else it
            *   won't respawn.
            */
            if CreepTable[k].boolean[3] then
                set this = thistype.allocate()

                set this.unit = u
                set this.type = GetUnitTypeId(this.unit)
                set this.key = k

                if IsUnitType(this.unit, CREEP_TYPE_BOSS) then
                    set Duration = CREEP_BOSS_DURATION
                else
                    set Duration = CREEP_REGULAR_DURATION
                endif

                call TimerStart(NewTimerEx(this), Duration, false, function thistype.onRevive)
            debug else
                debug call BJDebugMsg(GetUnitName(u) + " >> false ")
            endif

            set u = null

            static if not LIBRARY_RegisterAnyPlayerUnitEvent then
                return false
            endif
        endmethod

        private static method enumGroup takes nothing returns boolean
            local unit Enum = GetFilterUnit()

            /*
            *    Indexing
            */
            static if LIBRARY_UnitDex then
                set Count = GetUnitId(Enum)
            else
                set Count = Count + 1
                call SetUnitUserData(Enum, Count)
            endif

            /*
            *    Store a data to CreepTable
            */
            set CreepTable[Count].real[0] = GetUnitX(Enum)
            set CreepTable[Count].real[1] = GetUnitY(Enum)
            set CreepTable[Count].real[2] = GetUnitFacing(Enum)
            set CreepTable[Count].boolean[3] = true

            /*
            *    Remove memory leak
            */
            set Enum = null
            return false
        endmethod

        private static method registerMode takes nothing returns nothing
            local group Iterator = CreateGroup()

            /*
            *    Enumerate all of Player Creep's units
            */
            call GroupEnumUnitsOfPlayer(Iterator, PLAYER, Filter(function thistype.enumGroup))

            /*
            *    Remove memory leaks
            */
            call DestroyGroup(Iterator)
            call DestroyTimer(GetExpiredTimer())
            set Iterator = null
        endmethod

        private static method onInit takes nothing returns nothing
            /*
            *    Init Death Event
            */
            static if LIBRARY_RegisterAnyPlayerUnitEvent then
                call RegisterPlayerUnitEvent(PLAYER, EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            else
                local trigger trg = CreateTrigger()

                call TriggerRegisterPlayerUnitEvent(trg, PLAYER, EVENT_PLAYER_UNIT_DEATH, null )
                call TriggerAddCondition(trg, Condition(function thistype.onDeath))

                set trg = null
            endif

            /*
            *    Init CreepTable
            */
            set CreepTable = TableArray[CREEP_MAX_COUNT]

            /*
            *    Init Register Mode
            */
            call TimerStart(CreateTimer(), 0, false, function thistype.registerMode)
        endmethod
    endstruct
endlibrary
