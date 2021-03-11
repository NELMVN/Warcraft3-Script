library TimedEffect /* v2.0.0.1 | Copyright © github.com/nelmvn
*************************************************************************************
*
*    */ uses /*
*
*        */ CTL    /*  https://github.com/nestharus/JASS/blob/master/jass/Systems/ConstantTimerLoop32/script.j
*
*************************************************************************************
*
*    struct TimedEffect extends array
*       static method Apply takes effect whichEffect, real Duration returns effect
*
************************************************************************************/

    struct TimedEffect extends array
        private effect effect
        private real real

        implement CTLExpire
            if .real <= 0 then
                call DestroyEffect(.effect)

                set .effect = null
                set .real = 0
                call destroy()
            else
                set .real = .real - .031250000
            endif
        implement CTLEnd

        static method Apply takes effect whichEffect, real Duration returns effect
            local thistype this = thistype.create()
            set .effect = whichEffect
            set .real = Duration
            return whichEffect
        endmethod
    endstruct
endlibrary
