library CreepRespawn initializer onInit /* v3.0.2
*************************************************************************************
*
*    A simple Creep Respawn System tailored for RPG maps. It does not requires
*    SetUnitUserData and GetUnitUserData. As a result, it is compatible with any
*    existing unit indexer.
*
*************************************************************************************
*
*   */ requires /*
*
*       */ CTL /*                      https://github.com/nestharus/JASS/blob/master/jass/Systems/ConstantTimerLoop32/script.j
*
*
*   */ optional /*
*
*       */ RegisterPlayerUnitEvent /*  https://www.hiveworkshop.com/threads/snippet-registerevent-pack.250266/
*
*
*************************************************************************************
*
*    NOTE: If you’re using an older version of Warcraft 3, change the values of 
*          trn.red, trn.green, trn.blue, and trn.alphaMax to 255. The drawback is 
*          that you can't save and load the RGB color of the creep.
*/

//! textmacro CREEP_RESPAWN_TRANSPARENCY
    set trn.red = BlzGetUnitIntegerField(I[creepIndex], UNIT_IF_TINTING_COLOR_RED)
    set trn.green = BlzGetUnitIntegerField(I[creepIndex], UNIT_IF_TINTING_COLOR_GREEN)
    set trn.blue = BlzGetUnitIntegerField(I[creepIndex], UNIT_IF_TINTING_COLOR_BLUE)
    set trn.alphaMax = BlzGetUnitIntegerField(I[creepIndex], UNIT_IF_TINTING_COLOR_ALPHA)
//! endtextmacro

/************************************************************************************
*
*   Configurations
*
************************************************************************************/
    globals
        // Owner
        private constant player     CREEP_OWNER                         = Player(PLAYER_NEUTRAL_AGGRESSIVE)

        // Revive Special Effect
        private constant string     REVIVE_EFFECT                       = "Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl"

        // Mini Boss and Boss Detector
        private constant integer    CREEP_BOSS_DETECTOR                 = 'A000'
        private constant integer    CREEP_MINI_BOSS_DETECTOR            = 'A001'

        // Creep Revival Durations
        private constant real       CREEP_DEFAULT_RESPAWN_DURATION      = 10
        private constant real       CREEP_BOSS_RESPAWN_DURATION         = 30
        private constant real       CREEP_MINI_BOSS_RESPAWN_DURATION    = 15

        // Fade In
        private constant boolean    ALLOW_FADE_IN                       = true
        private constant integer    ALPHA_INCREMENT                     = 5

/************************************************************************************
*
*   API
*   ---------
*
*   function AddCreepRespawn takes unit whichCreep returns integer
*       - Include a unit to the Creep Respawn System. The function returns the Creep 
*         Index associated with that unit.
*
*   function AddCreepRespawnEx takes unit whichCreep, real duration returns integer
*       - Include a unit to the Creep Respawn System with a custom duration. The
*         function returns the Creep Index associated with that unit.
*
*   function SetCreepRespawn takes unit whichCreep, boolean enable returns boolean
*       - Toggleable creep respawning. The function returns whether it succeeded or
*         failed.
*
*************************************************************************************
*
*   Ignore these below.
*
************************************************************************************/
        private integer             CREEP_INDEXED_COUNT              = 0
        private real array          X // X Coord
        private real array          Y // Y Coord
        private real array          F // Unit Facing
        private integer array       U // Unit Type Id
        private real array          D // Duration
        private unit array          I // Creep
        private boolean array       B // Enable Revival
    endglobals

    private function getCreepDuration takes unit whichCreep returns real
        if GetUnitAbilityLevel(whichCreep, CREEP_BOSS_DETECTOR) > 0 then
            return CREEP_BOSS_RESPAWN_DURATION
        elseif GetUnitAbilityLevel(whichCreep, CREEP_MINI_BOSS_DETECTOR) > 0 then
            return CREEP_MINI_BOSS_RESPAWN_DURATION
        else
            return CREEP_DEFAULT_RESPAWN_DURATION
        endif
    endfunction

    private function storeCreepData takes unit whichCreep, real duration returns integer
        if GetOwningPlayer(whichCreep) == CREEP_OWNER then
            set CREEP_INDEXED_COUNT = CREEP_INDEXED_COUNT + 1
            set X[CREEP_INDEXED_COUNT] = GetUnitX(whichCreep)
            set Y[CREEP_INDEXED_COUNT] = GetUnitY(whichCreep)
            set F[CREEP_INDEXED_COUNT] = GetUnitFacing(whichCreep)
            set U[CREEP_INDEXED_COUNT] = GetUnitTypeId(whichCreep)
            set D[CREEP_INDEXED_COUNT] = duration
            set I[CREEP_INDEXED_COUNT] = whichCreep
            set B[CREEP_INDEXED_COUNT] = true

            call SetUnitUseFood(whichCreep, false)

            static if DEBUG_MODE then
                debug call AddSpecialEffect("buildings\\other\\CircleOfPower\\CircleOfPower.mdl", X[CREEP_INDEXED_COUNT], Y[CREEP_INDEXED_COUNT])
            endif

            return CREEP_INDEXED_COUNT
        endif
        return 0
    endfunction

    private function findCreepDataIndex takes unit whichCreep returns integer
        local integer count = 0

        loop
            exitwhen count == CREEP_INDEXED_COUNT
            set count = count + 1

            if I[count] == whichCreep then
                return count
            endif
        endloop

        return 0
    endfunction

    function AddCreepRespawn takes unit whichCreep returns integer
        return storeCreepData(whichCreep, getCreepDuration(whichCreep))
    endfunction

    function AddCreepRespawnEx takes unit whichCreep, real duration returns integer
        return storeCreepData(whichCreep, duration)
    endfunction

    function SetCreepRespawn takes unit whichCreep, boolean enable returns boolean
        local integer creepIndex

        if GetOwningPlayer(whichCreep) == CREEP_OWNER then
            set creepIndex = findCreepDataIndex(whichCreep)

            if creepIndex > 0 then
                set B[creepIndex] = enable
                return true
            endif
        endif
        return false
    endfunction

    static if ALLOW_FADE_IN then
        private struct transparent extends array
            integer red
            integer blue
            integer green
            integer alpha
            integer alphaMax
            unit unit

            implement CTLExpire
                if this.alpha >= this.alphaMax then
                    call SetUnitVertexColor(this.unit, this.red, this.green, this.blue, this.alphaMax)

                    set this.red = 0
                    set this.blue = 0
                    set this.green = 0
                    set this.alpha = 0
                    set this.alphaMax = 0
                    set this.unit = null

                    call this.destroy()
                else
                    set this.alpha = this.alpha + ALPHA_INCREMENT
                    call SetUnitVertexColor(this.unit, this.red, this.green, this.blue, this.alpha)
                endif
            implement CTLEnd
        endstruct
    endif

    private struct creepRevival extends array
        real duration
        integer creepData
        integer uId

        implement CTL
            local real x
            local real y
            local real f
            local integer creepIndex

            static if ALLOW_FADE_IN then
                local transparent trn
            endif

        implement CTLExpire
            set creepIndex = this.creepData

            if B[creepIndex] then
                if this.duration <= 0 then
                    // Retrieve the X and Y coordinates as well as the unit’s facing direction.
                    set x = X[creepIndex]
                    set y = Y[creepIndex]
                    set f = F[creepIndex]

                    if IsUnitType(I[creepIndex], UNIT_TYPE_HERO) then
                        // Revive the Creep Hero
                        call ReviveHero(I[creepIndex], x, y, false)
                        call DestroyEffect(AddSpecialEffectTarget(REVIVE_EFFECT, I[creepIndex], "origin"))
                    else
                        // Substitute the new unit with the old unit.
                        set I[creepIndex] = CreateUnit(CREEP_OWNER, this.uId, x, y, f)
                        call DestroyEffect(AddSpecialEffectTarget(REVIVE_EFFECT, I[creepIndex], "origin"))
                    endif

                    static if ALLOW_FADE_IN then
                        set trn = transparent.create()
                        set trn.unit = I[creepIndex]
                        set trn.alpha = 0
                        //! runtextmacro CREEP_RESPAWN_TRANSPARENCY()

                        call SetUnitVertexColor(trn.unit, trn.red, trn.green, trn.blue, trn.alpha)
                    endif

                    // Data cleanup
                    set this.duration = 0
                    set this.creepData = 0
                    set this.uId = 0
                    call destroy()
                else
                    set this.duration = this.duration - 0.031250000
                endif
            else
                // Creep is no longer revivable.
                set this.duration = 0
                set this.creepData = 0
                set this.uId = 0
                call destroy()
            endif
        implement CTLEnd
    endstruct

    static if LIBRARY_RegisterPlayerUnitEvent then
        private function onDeath takes nothing returns nothing
    else
        private function onDeath_ takes nothing returns boolean
    endif
        local unit Creep = GetTriggerUnit()
        local integer creepId
        local creepRevival this

        if GetOwningPlayer(Creep) == CREEP_OWNER then
            set creepId = findCreepDataIndex(Creep)

            if creepId > 0 then
                set this = creepRevival.create()
                set this.duration = D[creepId]
                set this.uId = U[creepId]
                set this.creepData = creepId
            endif
        endif

        set Creep = null

        static if not LIBRARY_RegisterPlayerUnitEvent then
            return false
        endif
    endfunction

    private function registerCreepData takes nothing returns nothing
        call AddCreepRespawn(GetFilterUnit())
    endfunction

    private function initRegisterCreepData takes nothing returns nothing
        // Register all created creeps
        call GroupEnumUnitsOfPlayer(bj_lastCreatedGroup, CREEP_OWNER, Filter(function registerCreepData))
    endfunction

    private function onInit takes nothing returns nothing
        static if LIBRARY_RegisterPlayerUnitEvent then
            call RegisterPlayerUnitEvent(CREEP_OWNER, EVENT_PLAYER_UNIT_DEATH, function onDeath)
        else
            local trigger trg = CreateTrigger()
            call TriggerRegisterPlayerUnitEvent(trg, CREEP_OWNER, EVENT_PLAYER_UNIT_DEATH, null)
            call TriggerAddCondition(trg, Filter(function onDeath_))
        endif

        call initRegisterCreepData()
    endfunction
endlibrary
