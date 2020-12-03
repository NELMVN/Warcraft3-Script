library ItemUtils /* v3.0.0.0 | fugatsu.freeforums.net
************************************************************************************
*
*    Much faster than BJ functions.
*
************************************************************************************
*
*    function IsItemExists takes unit whichUnit, integer whichItemType returns boolean
*       - Find specific item type.
*
*    function IsItemExistsEx takes unit whichUnit, integer whichItemType returns integer
*       - Find specific item type then count how many.
*
*    function IsItemExistsByItem takes unit whichUnit, integer whichItemType returns item
*       - Find specific item type.
*
*    function IsItemClassificationExists takes unit whichUnit, itemtype whichClassification, item exceptThisItem returns boolean
*       - Find specific item classification.
*
*    function RemoveExistingItem takes unit whichUnit, integer whichItemType returns boolean
*       - Similar to RemoveItem(), but it removes specific item type.
*
*    function RemoveExistingItemByCharges takes unit whichUnit, integer whichItemType returns boolean
*       - Similar to RemoveExistingItem(). but it decreases item charges of specific item type.
*
*    function RemoveAllItems takes unit whichUnit returns nothing
*       - Similar to RemoveItem(), but it removes all items.
*
************************************************************************************/

    function IsItemExists takes unit whichUnit, integer whichItemType returns boolean
        local integer Slot   = bj_MAX_INVENTORY
        local item    Object

        loop
            exitwhen Slot == 0
            set Slot   = Slot - 1
            set Object = UnitItemInSlot(whichUnit, Slot)

            if Object != null and GetItemTypeId(Object) == whichItemType then
                set Object = null
                return true
            endif
        endloop

        set Object = null
        return false
    endfunction

    function IsItemExistsEx takes unit whichUnit, integer whichItemType returns integer
        local integer Slot   = bj_MAX_INVENTORY
        local integer Count  = 0
        local item    Object

        loop
            exitwhen Slot == 0
            set Slot   = Slot - 1
            set Object = UnitItemInSlot(whichUnit, Slot)

            if Object != null and GetItemTypeId(Object) == whichItemType then
                set Count = Count + 1
            endif
        endloop

        set Object = null
        return Count
    endfunction

    function IsItemExistsByItem takes unit whichUnit, integer whichItemType returns item
        local integer Slot   = bj_MAX_INVENTORY
        local item    Object

        loop
            exitwhen Slot == 0
            set Slot   = Slot - 1
            set Object = UnitItemInSlot(whichUnit, Slot)

            if Object != null and GetItemTypeId(Object) == whichItemType then
                return Object
            endif
        endloop

        set Object = null
        return null
    endfunction

    function IsItemClassificationExists takes unit whichUnit, itemtype whichItemClassification, item exceptThisItem returns boolean
        local integer Slot   = bj_MAX_INVENTORY
        local item    Object

        loop
            exitwhen Slot == 0
            set Slot   = Slot - 1
            set Object = UnitItemInSlot(whichUnit, Slot)

            if Object != null and Object != exceptThisItem and GetItemType(Object) == whichItemClassification then
                set Object = null
                return true
            endif
        endloop

        set Object = null
        return false
    endfunction

    function RemoveExistingItem takes unit whichUnit, integer whichItemType returns boolean
        local integer Slot   = bj_MAX_INVENTORY
        local item    Object

        loop
            exitwhen Slot == 0
            set Slot   = Slot - 1
            set Object = UnitItemInSlot(whichUnit, Slot)

            if Object != null and GetItemTypeId(Object) == whichItemType then
                call RemoveItem(Object)
                set Object = null
                return true
            endif
        endloop

        set Object = null
        return false
    endfunction

    function RemoveExistingItemByCharges takes unit whichUnit, integer whichItemType returns boolean
        local integer Slot   = bj_MAX_INVENTORY
        local integer Count  = 0
        local item    Object

        loop
            exitwhen Slot == 0
            set Slot   = Slot - 1
            set Object = UnitItemInSlot(whichUnit, Slot)

            if Object != null and GetItemTypeId(Object) == whichItemType then
                set Count = GetItemCharges(Object)

                if Count == 1 then
                    call RemoveItem(Object)
                else
                    call SetItemCharges(Object, Count - 1)
                endif

                set Object = null
                return true
            endif
        endloop

        set Object = null
        return false
    endfunction

    function RemoveAllItems takes unit whichUnit returns nothing
        local integer Slot = bj_MAX_INVENTORY

        loop
            exitwhen Slot == 0
            set Slot = Slot - 1
            call RemoveItem(UnitItemInSlot(whichUnit, Slot))
        endloop
    endfunction
endlibrary
