function SaveLoad_InitialSetup takes nothing returns nothing
    local integer i = 0
    local integer j = 0

    loop
        set udg_SaveLoad_Compress[i + 48] = j
        set udg_SaveLoad_Uncompress[i] = i + 48
        set j = j + 1
        set i = i + 1
        exitwhen i >= 10
    endloop
    set i = 0
    loop
        set udg_SaveLoad_Compress[i + 97] = j
        set udg_SaveLoad_Compress[i + 65] = j + 26
        set udg_SaveLoad_Uncompress[i + 10] = i + 97
        set udg_SaveLoad_Uncompress[i + 26 + 10] = i + 65
        set j = j + 1
        set i = i + 1
        exitwhen i >= 26
    endloop
endfunction

function SaveLoad_Id2CId takes integer n returns integer
    local integer i = n / (256 * 256 * 256)
    local integer r
    set n = n - i * (256 * 256 * 256)
    set r = udg_SaveLoad_Compress[i]
    set i = n / (256 * 256)
    set n = n - i * (256 * 256)
    set r = r * 64 + udg_SaveLoad_Compress[i]
    set i = n / 256
    set r = r * 64 + udg_SaveLoad_Compress[i]
    return r * 64 + udg_SaveLoad_Compress[n - i * 256]
endfunction

function SaveLoad_CId2Id takes integer n returns integer
    local integer i = n / (64 * 64 * 64)
    local integer r
    set n = n - i * (64 * 64 * 64)
    set r = udg_SaveLoad_Uncompress[i]
    set i = n / (64 * 64)
    set n = n - i * (64 * 64)
    set r = r * 256 + udg_SaveLoad_Uncompress[i]
    set i = n / 64
    set r = r * 256 + udg_SaveLoad_Uncompress[i]
    return r * 256 + udg_SaveLoad_Uncompress[n - i * 64]
endfunction

function SaveLoad_Unit2Integer takes unit u returns integer
    local integer i = 0
    local integer n = GetUnitTypeId(u)
    if udg_SaveLoad_Initialized == false then
        set udg_SaveLoad_Initialized = true
        call SaveLoad_InitialSetup()
    endif
    loop
        set i = i + 1
        exitwhen i > udg_SaveLoad_Heroes_LastIndex
        if udg_SaveLoad_Heroes[i] == n then
            return i
        endif
    endloop
    return SaveLoad_Id2CId(n)
endfunction
function SaveLoad_Integer2Unit takes integer i returns integer
    if udg_SaveLoad_Initialized == false then
        set udg_SaveLoad_Initialized = true
        call SaveLoad_InitialSetup()
    endif
    if i <= udg_SaveLoad_Heroes_LastIndex then
        return udg_SaveLoad_Heroes[i]
    endif
    return SaveLoad_CId2Id(i)
endfunction

function SaveLoad_Item2Integer takes item t returns integer
    local integer i = 0
    local integer n = GetItemTypeId(t)
    if udg_SaveLoad_Initialized == false then
        set udg_SaveLoad_Initialized = true
        call SaveLoad_InitialSetup()
    endif
    loop
        set i = i + 1
        exitwhen i > udg_SaveLoad_Items_LastIndex
        if udg_SaveLoad_Items[i] == n then
            return i
        endif
    endloop
    return SaveLoad_Id2CId(n)
endfunction
function SaveLoad_Integer2Item takes integer i returns integer
    if udg_SaveLoad_Initialized == false then
        set udg_SaveLoad_Initialized = true
        call SaveLoad_InitialSetup()
    endif
    if i <= udg_SaveLoad_Items_LastIndex then
        return udg_SaveLoad_Items[i]
    endif
    return SaveLoad_CId2Id(i)
endfunction

function SaveLoad_Ability2Integer takes integer a returns integer
    local integer i = 0
    if udg_SaveLoad_Initialized == false then
        set udg_SaveLoad_Initialized = true
        call SaveLoad_InitialSetup()
    endif
    loop
        set i = i + 1
        exitwhen i > udg_SaveLoad_Abilities_LastIndex
        if udg_SaveLoad_Abilities[i] == a then
            return i
        endif
    endloop
    return SaveLoad_Id2CId(a)
endfunction
function SaveLoad_Integer2Ability takes integer i returns integer
    if udg_SaveLoad_Initialized == false then
        set udg_SaveLoad_Initialized = true
        call SaveLoad_InitialSetup()
    endif
    if i <= udg_SaveLoad_Abilities_LastIndex then
        return udg_SaveLoad_Abilities[i]
    endif
    return SaveLoad_CId2Id(i)
endfunction

function SaveLoad_Color takes string s returns string
    local integer i = StringLength(s)
    local string c
    local string r = ""

    loop
        set i = i - 1
        set c = SubString(s,i,i + 1)
        if c == "0" or c == "1" or c == "2" or c == "3" or c == "4" or c == "5" or c == "6" or c == "7" or c == "8" or c == "9" then
            set r = "|cffffcc00" + c + "|r" + r
        elseif c == "-" then
            set r = "|cffdddddd-|r" + r
        else
            set r = c + r
        endif
        exitwhen i <= 0
    endloop
    return r
endfunction

function SaveLoad_EncodeChar takes string n returns integer
    local integer i = 0
    local string s1 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local string s2 = "abcdefghijklmnopqrstuvwxyz"
    local string s3 = "0123456789"

    loop
        if SubString(s1,i,i + 1) == n then
            return i
        endif
        if SubString(s2,i,i + 1) == n then
            return i
        endif
        set i = i + 1
        exitwhen i >= 26
    endloop
    set i = 0
    loop
        if SubString(s3,i,i + 1) == n then
            return i
        endif
        set i = i + 1
        exitwhen i >= 10
    endloop
    return 0
endfunction

function SaveLoad_EncodeVerify takes string buffer returns integer
    local integer i = 0
    local integer j = 0
    local string name = GetPlayerName(GetTriggerPlayer())
    if udg_SaveLoad_UsePlayername == true then
        loop
            set j = j + SaveLoad_EncodeChar(SubString(name,i,i + 1))
            set i = i + 1
            exitwhen i >= StringLength(name)
        endloop
    endif
    set i = 0
    loop
        set j = j + SaveLoad_EncodeChar(SubString(buffer,i,i + 1))
        set i = i + 1
        exitwhen i >= StringLength(buffer)
    endloop
    return j
endfunction

function SaveLoad_EncodeValues takes nothing returns string
    local integer i
    local integer j
    local integer k
    local integer l
    local integer m
    local integer CodeLength = StringLength(udg_SaveLoad_Alphabet)
    local integer array a
    local string buffer = ""
    local string c = ""
    local integer skip = 0
    local integer CONST = 1000000
    local string abc = "0123456789"

    set i = 0
    loop
        set i = i + 1
        exitwhen i > udg_SaveCount
        set buffer = buffer + I2S(udg_Save[i]) + "-"
    endloop
    set buffer = buffer + I2S(SaveLoad_EncodeVerify(buffer))
    if udg_Save[1] == 0 then
        set buffer = "-" + buffer
    endif

    set i = 0
    loop
        set a[i] = 0
        set i = i + 1
        exitwhen i >= 100
    endloop

    set m = 0
    set i = 0
    loop
        set j = 0
        loop
            set a[j] = a[j] * 11
            set j = j + 1
            exitwhen j > m
        endloop

        set l = 0
        set c = SubString(buffer,i,i + 1)
        loop
            exitwhen SubString(abc,l,l + 1) == c
            set l = l + 1
            exitwhen l > 9
        endloop
        set a[0] = a[0] + l

        set j = 0
        loop
            set k = a[j] / CONST
            set a[j] = a[j] - k * CONST
            set a[j + 1] = a[j + 1] + k
            set j = j + 1
            exitwhen j > m
        endloop
        if k > 0 then
            set m = m + 1
        endif
        set i = i + 1
        exitwhen i >= StringLength(buffer)
    endloop

    set buffer = ""
    loop
        exitwhen m < 0
        set j = m
        loop
            exitwhen j <= 0
            set k = a[j] / CodeLength
            set a[j - 1] = a[j - 1] + (a[j] - k * CodeLength) * CONST
            set a[j] = k
            set j = j - 1
        endloop
        set k = a[j] / CodeLength
        set i = a[j] - k * CodeLength
        set buffer = buffer + SubString(udg_SaveLoad_Alphabet,i,i + 1)
        set a[j] = k
        if a[m] == 0 then
            set m = m - 1
        endif
    endloop

    set i = StringLength(buffer)
    set skip = 0
    set c = ""
    loop
        set i = i - 1
        set c = c + SubString(buffer,i,i + 1)
        set skip = skip + 1
        if skip == 4 and i > 0 then
            set c = c + "-"
            set skip = 0
        endif
        exitwhen i <= 0
    endloop
    return c
endfunction

function SaveLoad_DecodeValues takes string s returns boolean
    local integer i
    local integer j
    local integer k
    local integer l
    local integer SaveCode = 0
    local integer m
    local integer array a
    local string buffer = ""
    local integer CodeLength = StringLength(udg_SaveLoad_Alphabet)
    local integer skip = -1
    local integer CONST = 1000000
    local string abc = "0123456789-"
    local string c

    set i = 0
    loop
        set a[i] = 0
        set i = i + 1
        exitwhen i >= 100
    endloop

    set m = 0

    set i = 0
    loop
        set j = 0
        loop
            set a[j] = a[j] * CodeLength
            set j = j + 1
            exitwhen j > m
        endloop

        set skip = skip + 1
        if skip == 4 then
            set skip = 0
            set i = i + 1
        endif

        set l = CodeLength
        set c = SubString(s,i,i + 1)
        loop
            set l = l - 1
            exitwhen l < 1
            exitwhen SubString(udg_SaveLoad_Alphabet,l,l + 1) == c
        endloop
        set a[0] = a[0] + l

        set j = 0
        loop
            set k = a[j] / CONST
            set a[j] = a[j] - k * CONST
            set a[j + 1] = a[j + 1] + k
            set j = j + 1
            exitwhen j > m
        endloop
        if k > 0 then
            set m = m + 1
        endif
        set i = i + 1
        exitwhen i >= StringLength(s)
    endloop

    loop
        exitwhen m < 0
        set j = m
        loop
            exitwhen j <= 0
            set k = a[j] / 11
            set a[j - 1] = a[j - 1] + (a[j] - k * 11) * CONST
            set a[j] = k
            set j = j - 1
        endloop
        set k = a[j] / 11
        set i = a[j] - k * 11
        set buffer = SubString(abc,i,i + 1) + buffer
        set a[j] = k
        if a[m] == 0 then
            set m = m - 1
        endif
    endloop

    set i = 0
    set j = 0
    loop
        loop
            exitwhen i >= StringLength(buffer)
            exitwhen i > 0 and SubString(buffer,i,i + 1) == "-" and SubString(buffer,i - 1,i) != "-"
            set i = i + 1
        endloop
        if i < StringLength(buffer) then
            set k = i
        endif
        set SaveCode = SaveCode + 1
        set udg_Save[SaveCode] = S2I(SubString(buffer,j,i))
        set j = i + 1
        set i = i + 1
        exitwhen i >= StringLength(buffer)
    endloop

    set j = SaveLoad_EncodeVerify(SubString(buffer,0,k))
    set udg_SaveCount = SaveCode - 1
    if j == udg_Save[SaveCode] then
        return true
    endif
    return false
endfunction

function SaveLoad_Encode takes nothing returns string
    if udg_SaveLoad_CaseSensitive == false then
        set udg_SaveLoad_Alphabet = StringCase(udg_SaveLoad_Alphabet,true)
    endif
    return SaveLoad_Color(SaveLoad_EncodeValues())
endfunction

function SaveLoad_Decode takes string s returns boolean
    if udg_SaveLoad_CaseSensitive == false then
        set udg_SaveLoad_Alphabet = StringCase(udg_SaveLoad_Alphabet,true)
        set s = StringCase(s,true)
    endif
    if SaveLoad_DecodeValues(s) then
        call DisplayTextToPlayer(GetTriggerPlayer(),0,0,"Decoding sucessful")
        return true
    endif
    call DisplayTextToPlayer(GetTriggerPlayer(),0,0,"Decoding failed")
    return false
endfunction
