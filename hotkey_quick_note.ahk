#Requires AutoHotkey v2.0

persistentText := ""
cursorPosition := 0
scrollLine := 0
global myGui := ""
global isVisible := false
global guiExists := false

#n::ToggleGui()

ToggleGui() {
    global myGui, isVisible
    
    if !myGui {
        CreateGui()
    }

    if !isVisible {
        RestoreGui()
    } else {
        BringToFrontOrHide()
    }
}

CreateGui() {
    global myGui, guiExists, persistentText, cursorPosition, scrollLine
    myGui := Gui("+Resize", "Hotkey quick note")
    myGui.SetFont("s12", "Roboto")
    myGui.AddEdit("vNoteEdit Multi WantTab WantReturn VScroll")
    myGui.OnEvent("Close", HideGui)
    myGui.OnEvent("Escape", HideGui)
    
    HotIfWinActive("ahk_id " myGui.Hwnd)
    Hotkey("!c", CopyAllAndClose, "On")
    Hotkey("!+v", PasteFromClipboard, "On")
    Hotkey("!d", DeleteText, "On")
    Hotkey("^Enter", DoCtrlEnter, "On")
    Hotkey("+Enter", DoShiftEnter, "On")
    Hotkey("^y", DeleteCurrentLineSmart, "On")
    HotIfWinActive()
    
    guiExists := true
    ctrl := myGui["NoteEdit"]
    ctrl.Value := persistentText ; загружаем текст только при создании GUI
    
    SetTimer(WatchFocus, 200)
}

RestoreGui() {
    global myGui, isVisible, cursorPosition, scrollLine
    ctrl := myGui["NoteEdit"]
    
    screenWidth := A_ScreenWidth
    screenHeight := A_ScreenHeight
    winWidth := Round(screenWidth * 0.6)
    winHeight := Round(screenHeight * 0.8)
    winX := (screenWidth - winWidth) // 2
    winY := (screenHeight - winHeight) // 2 - 15
    
    myGui.Show("x" winX " y" winY " w" winWidth " h" winHeight)
    padTop := 9
    padLeft := 9
    padBottom := 9
    padRight := 0
    editW := winWidth - padLeft - padRight
    editH := winHeight - padTop - padBottom
    ctrl.Move(padLeft, padTop, editW, editH)
    
    SendMessage(0x00C3, 0, 24, ctrl.Hwnd)
    ctrl.Focus()
    SendMessage(0x00B1, 0, 0, ctrl.Hwnd)
    SendMessage(0x00B6, 0, scrollLine, ctrl.Hwnd)
    
    realLength := SendMessage(0x000E, 0, 0, ctrl.Hwnd)
    if (cursorPosition < 0 || cursorPosition > realLength)
        cursorPosition := realLength
    SetCursorPosInEdit(ctrl, cursorPosition)
    
    isVisible := true
}

BringToFrontOrHide() {
    global myGui
    WinExistID := WinExist("ahk_id " myGui.Hwnd)
    If (WinExistID && !WinActive("ahk_id " myGui.Hwnd)) {
        WinActivate
    } Else {
        HideGui()
    }
}

WatchFocus() {
    global myGui, isVisible
    static focusLostTime := 0
    
    if !isVisible
        return
    
    if WinActive("ahk_id " myGui.Hwnd) {
        focusLostTime := 0
    } else {
        if !focusLostTime {
            focusLostTime := A_TickCount
        } else if (A_TickCount - focusLostTime > 50000) {  ; через 50 секунд после потери фокуса свернуть прогу
            HideGui()
        }
    }
}

HideGui(*) {
    global cursorPosition, scrollLine, myGui, isVisible
    if !myGui
        return
    
    ctrl := myGui["NoteEdit"]
    persistentText := ctrl.Value ; обновляем текст в памяти без записи в файл
    cursorPosition := GetCursorPosInEdit(ctrl) ; точное сохранение позиции
    scrollLine := SendMessage(0x00CE, 0, 0, ctrl.Hwnd)
    myGui.Hide()
    isVisible := false
}

GetCursorPosInEdit(ctrl) {
    result := SendMessage(0x00B0, 0, 0, ctrl.Hwnd)
    start := result & 0xFFFF
    return start
}

SetCursorPosInEdit(ctrl, pos) {
    SendMessage(0x00B1, pos, pos, ctrl.Hwnd)
    SendMessage(0x00B7, 0, 0, ctrl.Hwnd)
}

CopyAllAndClose(*) {
    global myGui
    text := StrReplace(myGui["NoteEdit"].Value, "`n", "`r`n") ; LF → CRLF
    A_Clipboard := text
    HideGui()
}

PasteFromClipboard(*) {
    global myGui
    ctrl := myGui["NoteEdit"]
    text := StrReplace(A_Clipboard, "`r`n", "`n") ; CRLF → LF
    ctrl.Value := text
    realLength := SendMessage(0x000E, 0, 0, ctrl.Hwnd)
    SetCursorPosInEdit(ctrl, realLength) ; установка курсора в конец
}

DeleteText(*) {
    global myGui
    myGui["NoteEdit"].Value := ""
}

DoCtrlEnter(*) {
    Send("{Home}")
    Sleep(30)
    Send("{Enter}")
    Sleep(30)
    Send("{Up}")
}

DoShiftEnter(*) {
    Send("{End}")
    Sleep(30)
    Send("{Enter}")
}

; === Функция удаления строки через эмуляцию Home + Shift+End + Del ===
DeleteCurrentLineSmart(*) {
    global myGui
    ctrl := myGui["NoteEdit"]
    ; Сохраняем позицию курсора
    cursorPos := GetCursorPosInEdit(ctrl)
    ; Выделяем всю строку под курсором
    Send("{Home}")
    Sleep(20)
    Send("+{End}")
    Sleep(20)
    ; Удаляем выделение
    Send("{Del}")
    ; Восстанавливаем курсор
    Send("{Home}")
    Sleep(20)
    charsToRight := cursorPos
    Loop charsToRight {
        Send("{Right}")
    }
    ; Проверяем, не является ли строка пустой
    text := ctrl.Value
    newCursorPos := GetCursorPosInEdit(ctrl)
    lineStart := 0
    Loop newCursorPos {
        pos := newCursorPos - A_Index + 1
        if (SubStr(text, pos, 1) = "`n") {
            lineStart := pos + 1
            break
        }
    }
    lineEnd := InStr(text, "`n", false, newCursorPos)
    if !lineEnd
        lineEnd := StrLen(text) + 1
    lineContent := SubStr(text, lineStart, newCursorPos - lineStart)
    lineContent .= SubStr(text, newCursorPos + 1, lineEnd - newCursorPos - 1)
    if (StrReplace(lineContent, " ", "") = "")
        Send("{Del}")
}