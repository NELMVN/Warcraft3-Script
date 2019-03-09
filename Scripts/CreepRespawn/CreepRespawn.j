library CreepRespawn /* v1.0.0.0
*************************************************************************************
*
*   It is used to spawn a creeps and useful for the RPG map.
*
*************************************************************************************
*
*   */ needs /*
*
*       */ Table                           /*      hiveworkshop.com/threads/snippet-new-table.188084/
*       */ TimerUtils                      /*      wc3c.net/showthread.php?t=101322
*       */ RegisterPlayerUnitEvent         /*      hiveworkshop.com/threads/snippet-registerevent-pack.250266/
*       */ AllocT                          /*      github.com/nestharus/JASS/blob/master/jass/Systems/Alloc/Table/script.j
*
************************************************************************************
*
*   SETTINGS
*
*/
    globals
        private constant   player PLAYER          = Player(PLAYER_NEUTRAL_AGGRESSIVE)
        private constant   string REVIVE_EFFECT   = "Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl"

        private constant     real CREEP_REGULAR   = 5
        private constant     real CREEP_BOSS      = 10
        private constant unittype CREEP_TYPE_BOSS = UNIT_TYPE_ANCIENT
    endglobals
/*
***********************************************************************************/

    globals
        private TableArray CreepTable
        private group Iterator = CreateGroup()
    endglobals
    
    private struct System extends array
        implement AllocT
        
        private unit Creep
        private integer key
        private timer Timer
        
        private static method onRevive takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local unit Creep

            call DestroyEffect(AddSpecialEffect(                            /*
            */     REVIVE_EFFECT,                                           /*
            */     CreepTable[this.key].real[0],                            /*
            */     CreepTable[this.key].real[1]                             /*
            */ ))
            
            set Creep = CreateUnit(PLAYER,                                  /*
            */     GetUnitTypeId(this.Creep),                               /*
            */     CreepTable[this.key].real[0],                            /*
            */     CreepTable[this.key].real[1],                            /*
            */     CreepTable[this.key].real[2]                             /*
            */ )
            
            call SetUnitUserData(Creep, this.key)
            call RemoveUnit(this.Creep)
            call ReleaseTimer(this.Timer)

            set Creep = null
            set this.Creep = null
            set this.key = 0
            set this.Timer = null
            
            call this.deallocate()
        endmethod
        
        private static method onDeath takes nothing returns nothing
            local unit Creep = GetTriggerUnit()
            local thistype this
            local real Duration = 0
            
            if GetOwningPlayer(Creep) == PLAYER then
                set this = thistype.allocate()
                
                set this.Creep = Creep
                set this.key = GetUnitUserData(this.Creep)
                set this.Timer = NewTimerEx(this)
                
                if IsUnitType(Creep, CREEP_TYPE_BOSS) then
                    set Duration = CREEP_BOSS
                else
                    set Duration = CREEP_REGULAR
                endif
                
                call TimerStart(this.Timer, Duration, false,                /*
                */     function thistype.onRevive                           /*
                */ )
            endif
            
            set Creep = null
        endmethod
        
        private static method registerMode takes nothing returns nothing
            local unit FoG
            local integer key = 0

            call GroupEnumUnitsInRect(Iterator, bj_mapInitialPlayableArea, null)

            loop
                set FoG = FirstOfGroup(Iterator)
                exitwhen FoG == null
                
                if GetOwningPlayer(FoG) == PLAYER then
                    set key = key + 1
                    
                    set CreepTable[key].real[0] = GetUnitX(FoG)
                    set CreepTable[key].real[1] = GetUnitY(FoG)
                    set CreepTable[key].real[2] = GetUnitFacing(FoG)
                    call SetUnitUserData(FoG, key)
                endif
                
                call GroupRemoveUnit(Iterator, FoG)
            endloop

            debug call DisplayTextToPlayer(GetLocalPlayer(), 0, 0,          /*
            */     "Creep Respawn Indexed: " + I2S(key)                     /*
            */ )
        endmethod
        
        private static method onInit takes nothing returns nothing
            set CreepTable = TableArray[0x2000]
            
            call registerMode()
            call RegisterAnyPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH,        /*
            */     function thistype.onDeath                                /*
            */ )
        endmethod
    endstruct
endlibrary
