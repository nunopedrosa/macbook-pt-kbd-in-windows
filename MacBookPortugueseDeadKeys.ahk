#Requires AutoHotkey v2.0
#SingleInstance Force
#UseHook

; Global variable to track the active dead key state
global PendingAccent := ""

; Unified helper function to catch Left Option or virtualized Right Option (AltGr) in UTM
IsOptionPressed() {
    return GetKeyState("LAlt", "P") || (GetKeyState("LCtrl", "P") && GetKeyState("RAlt", "P"))
}

; Core router that maps characters OR routes straight to the dead key engine if an accent is waiting
SendLayerChar(noneChar, shiftChar, optChar, optShiftChar, rawLetter := "") {
    ; IF AN ACCENT IS WAITING: Redirect basic letter keys to the composition engine
    if (PendingAccent != "" && rawLetter != "") {
        ComposeAccent(rawLetter)
        return
    }

    ; OTHERWISE: Output the correct layout symbol layer
    if IsOptionPressed() {
        if GetKeyState("Shift", "P")
            SendText(optShiftChar)
        else
            SendText(optChar)
    } else {
        if GetKeyState("Shift", "P")
            SendText(shiftChar)
        else
            SendText(noneChar)
    }
}

; Helper specifically for non-letter symbols when a dead key is pending
HandleSymbolOrDeadKey(noneChar, shiftChar, optChar, optShiftChar) {
    if (PendingAccent != "") {
        EmitAccent() ; Flush out the pending accent if a symbol is pressed instead of a vowel
    }
    if IsOptionPressed() {
        if GetKeyState("Shift", "P")
            SendText(optShiftChar)
        else
            SendText(optChar)
    } else {
        if GetKeyState("Shift", "P")
            SendText(shiftChar)
        else
            SendText(noneChar)
    }
}

; =========================================================================
; ROW 1: NUMBER ROW & BOUNDS
; =========================================================================
*SC029::HandleSymbolOrDeadKey("§", "±", "§", "±")  ; Key below Esc
*SC002::HandleSymbolOrDeadKey("1", "!", "", "¡")  ; 1
*SC003::HandleSymbolOrDeadKey("2", "`"", "@", "ﬁ") ; 2
*SC004::HandleSymbolOrDeadKey("3", "#", "€", "ﬂ")  ; 3
*SC005::HandleSymbolOrDeadKey("4", "$", "£", "¢")  ; 4
*SC006::HandleSymbolOrDeadKey("5", "%", "‰", "∞")  ; 5
*SC007::HandleSymbolOrDeadKey("6", "&", "¶", "•")  ; 6
*SC008::HandleSymbolOrDeadKey("7", "/", "÷", "⁄")  ; 7
*SC009::HandleSymbolOrDeadKey("8", "(", "[", "{")  ; 8
*SC00A::HandleSymbolOrDeadKey("9", ")", "]", "}")  ; 9
*SC00B::HandleSymbolOrDeadKey("0", "=", "≠", "≈")  ; 0
*SC00C::HandleSymbolOrDeadKey("'", "?", "§", "¿")  ; ' ? key
*SC00D::HandleSymbolOrDeadKey("+", "*", "±", "◊")  ; + * key (Left of Backspace)

; =========================================================================
; ROW 2: LETTERS & END KEYS
; =========================================================================
*SC010::SendLayerChar("q", "Q", "œ", "Œ", "q")
*SC011::SendLayerChar("w", "W", "∑", "∑", "w")
*SC012::SendLayerChar("e", "E", "æ", "Æ", "e")
*SC013::SendLayerChar("r", "R", "®", "®", "r")
*SC014::SendLayerChar("t", "T", "™", "™", "t")
*SC015::SendLayerChar("y", "Y", "¥", "¥", "y")
*SC016::SendLayerChar("u", "U", "†", "‡", "u")
*SC017::SendLayerChar("i", "I", "ı", "˚", "i")
*SC018::SendLayerChar("o", "O", "ø", "Ø", "o")
*SC019::SendLayerChar("p", "P", "π", "∏", "p")
*SC01A::HandleSymbolOrDeadKey("º", "ª", "°", "˚") ; Right of P
*SC01B:: {                                 ; Right of ºª (Dead Acute / Dead Grave)
    if IsOptionPressed() {
        if GetKeyState("Shift", "P")
            SetPendingAccent("˝")          ; Double Acute
        else
            SetPendingAccent("¨")          ; Diaeresis
    } else {
        if GetKeyState("Shift", "P")
            SetPendingAccent(Chr(96))      ; Grave (`)
        else
            SetPendingAccent("´")          ; Acute (´)
    }
}

; =========================================================================
; ROW 3: LETTERS & END KEYS
; =========================================================================
*SC01E::SendLayerChar("a", "A", "å", "Å", "a")  
*SC01F::SendLayerChar("s", "S", "ß", "ß", "s")
*SC020::SendLayerChar("d", "D", "∂", "∆", "d")
*SC021::SendLayerChar("f", "F", "ƒ", "ƒ", "f")
*SC022::SendLayerChar("g", "G", "˙", "˙", "g")
*SC023::SendLayerChar("h", "H", "ˇ", "ˇ", "h")
*SC024::SendLayerChar("j", "J", "¯", "¯", "j")
*SC025::SendLayerChar("k", "K", "„", "‚", "k")
*SC026::SendLayerChar("l", "L", "‘", "’", "l")
*SC027::SendLayerChar("ç", "Ç", "¸", "˛", "ç")
*SC028:: {                                 ; Right of Ç (Dead Tilde / Dead Circumflex)
    if IsOptionPressed() {
        if GetKeyState("Shift", "P")
            SetPendingAccent("ˆ")          ; Circumflex alternative
        else
            SetPendingAccent("˜")          ; Tilde alternative
    } else {
        if GetKeyState("Shift", "P")
            SetPendingAccent("^")          ; Circumflex (^)
        else
            SetPendingAccent("~")          ; Tilde (~)
    }
}
*SC02B::HandleSymbolOrDeadKey("\", "|", "‹", "›")  ; Key beside Enter

; =========================================================================
; ROW 4: LETTERS & EXTRA ISO KEY
; =========================================================================
*SC056::HandleSymbolOrDeadKey("<", ">", "≤", "≥")  ; ISO key beside Left Shift
*SC02C::SendLayerChar("z", "Z", "Ω", "Ω", "z")
*SC02D::SendLayerChar("x", "X", "«", "»", "x")
*SC02E::SendLayerChar("c", "C", "©", "©", "c")
*SC02F::SendLayerChar("v", "V", "√", "√", "v")
*SC030::SendLayerChar("b", "B", "∫", "∫", "b")
*SC031::SendLayerChar("n", "N", "¬", "¬", "n")
*SC032::SendLayerChar("m", "M", "µ", "µ", "m")
*SC033::HandleSymbolOrDeadKey(",", ";", "“", "”")
*SC034::HandleSymbolOrDeadKey(".", ":", "‘", "·") 
*SC035::HandleSymbolOrDeadKey("-", "_", "—", "–")

; Global escape keys to clear or force-emit accents safely
*Space:: {
    if (PendingAccent != "")
        EmitAccent()
    else
        Send("{Blank} ")
}
*Backspace:: {
    if (PendingAccent != "")
        ClearAccent()
    else
        Send("{Blind}{Backspace}")
}
*Escape:: {
    if (PendingAccent != "")
        ClearAccent()
    else
        Send("{Blind}{Escape}")
}

; =========================================================================
; CORE INTERNALS & DICTIONARY
; =========================================================================

SetPendingAccent(accent) {
    global PendingAccent
    PendingAccent := accent
    SetTimer(FlushPendingAccent, -5000)
}

IsAccentPending() {
    global PendingAccent
    return PendingAccent != ""
}

ComposeAccent(letter) {
    global PendingAccent
    accent := PendingAccent
    PendingAccent := ""
    SetTimer(FlushPendingAccent, 0)

    isUpper := GetKeyState("Shift", "P") != GetKeyState("CapsLock", "T")
    key := StrLower(letter)
    
    resultMap := Map(
        "~|a", "ã", "~|o", "õ", "~|n", "ñ", "˜|a", "ã", "˜|o", "õ",
        "^|a", "â", "^|e", "ê", "^|i", "î", "^|o", "ô", "^|u", "û", "ˆ|a", "â",
        "¨|a", "ä", "¨|e", "ë", "¨|i", "ï", "¨|o", "ö", "¨|u", "ü",
        Chr(96) . "|a", "à", Chr(96) . "|e", "è", Chr(96) . "|i", "ì",
        Chr(96) . "|o", "ò", Chr(96) . "|u", "ù",
        "´|a", "á", "´|e", "é", "´|i", "í", "´|o", "ó", "´|u", "ú"
    )
    mapKey := accent . "|" . key

    if resultMap.Has(mapKey) {
        result := resultMap[mapKey]
        if isUpper
            result := StrUpper(result)
        SendText(result)
    } else {
        if isUpper
            letter := StrUpper(letter)
        SendText(accent . letter)
    }
}

EmitAccent() {
    global PendingAccent
    accent := PendingAccent
    PendingAccent := ""
    SetTimer(FlushPendingAccent, 0)
    SendText(accent)
}

ClearAccent() {
    global PendingAccent
    PendingAccent := ""
    SetTimer(FlushPendingAccent, 0)
}

FlushPendingAccent() {
    global PendingAccent
    if PendingAccent != "" {
        accent := PendingAccent
        PendingAccent := ""
        SendText(accent)
    }
}
