**Demo Code:**

```c
//! zinc
library Sample

    requires
        GameClock
 
{
    private {
        real SampleTime;
        string SampleFormatTime;
 
        function onInit() {
            trigger trg = CreateTrigger();
            TriggerRegisterTimerEvent(trg, 0.50, true);
            TriggerAddAction(trg, function(){
                ClearTextMessages();
                BJDebugMsg(
                    "|cffffcc00Current Game Time:|r " + R2S(GetElapsedTime()) + "\n" +
                    "|cffffcc00Formatted Game Time:|r " + GetElapsedTimeFormatted() +
                    "\n\n---------------------------\n" +
                    "|cffffcc00Format Time:|r " + R2S(SampleTime) + "   |cffffcc00>>>|r   " + SampleFormatTime
                );
            });
            trg = null;
         
            SampleTime = GetRandomInt(0, 86400);
            SampleFormatTime = FormatTime( SampleTime );
        }
    }
}
//! endzinc
```
