#Requires AutoHotkey v2.0

saveFile := A_ScriptDir "\hotkey_quick_note__saved_text.dat"
persistentText := ""
cursorPosition := 0
scrollLine := 0
global myGui := ""
global isVisible := false
global guiExists := false

#n::ToggleGui()
OnExit(SaveNoteToFile)

if FileExist(saveFile) {
    fh := FileOpen(saveFile, "r", "UTF-8")
    if fh {
        persistentText := fh.Read()
        fh.Close()
    }
}

ToggleGui() {
    global persistentText, cursorPosition, scrollLine, myGui, isVisible, guiExists

    if !guiExists {
        myGui := Gui("+Resize", "Быстрая заметка")
        myGui.SetFont("s12", "Roboto")
        myGui.AddEdit("vNoteEdit Multi WantTab WantReturn VScroll")
        myGui.OnEvent("Close", HideGui)
        myGui.OnEvent("Escape", HideGui)

        HotIfWinActive("ahk_id " myGui.Hwnd)
        Hotkey("!c", CopyAllAndClose, "On")
        Hotkey("!v", PasteFromClipboard, "On")
        Hotkey("!d", DeleteText, "On")
        Hotkey("^Enter", DoCtrlEnter, "On")
        Hotkey("+Enter", DoShiftEnter, "On")
        Hotkey("^y", DeleteCurrentLineSmart, "On") ; ← Ctrl+Y: удаление строки
        HotIfWinActive()

        guiExists := true
        ctrl := myGui["NoteEdit"]
        ctrl.Value := persistentText ; загружаем текст только при создании GUI
    }

    ctrl := myGui["NoteEdit"]
    if !isVisible {
        screenWidth := A_ScreenWidth
        screenHeight := A_ScreenHeight
        winWidth := Round(screenWidth * 0.6)
        winHeight := Round(screenHeight * 0.8)
        winX := (screenWidth - winWidth) // 2
        winY := (screenHeight - winHeight) // 2
        myGui.Show("x" winX " y" winY " w" winWidth " h" winHeight)

        padTop := 9
        padLeft := 9
        padBottom := 9
        padRight := 0
        editW := winWidth - padLeft - padRight
        editH := winHeight - padTop - padBottom
        ctrl.Move(padLeft, padTop, editW, editH)

        ; Увеличение межстрочного интервала
        SendMessage(0x00C3, 0, 24, ctrl.Hwnd)

        ctrl.Focus()
        SendMessage(0x00B1, 0, 0, ctrl.Hwnd)
        SendMessage(0x00B6, 0, scrollLine, ctrl.Hwnd)

        if (cursorPosition >= 0 && cursorPosition <= StrLen(ctrl.Value)) {
            SendMessage(0x00B1, cursorPosition, cursorPosition, ctrl.Hwnd)
            SendMessage(0x00B7, 0, 0, ctrl.Hwnd)
        }

        isVisible := true
        SetTimer(WatchFocus, 200)
    } else {
        HideGui()
    }
}

HideGui(*) {
    global cursorPosition, scrollLine, myGui, isVisible
    if !myGui
        return

    ctrl := myGui["NoteEdit"]
    persistentText := ctrl.Value ; обновляем текст в памяти без записи в файл
    cursorPosition := StrLen(ctrl.Value)

    result := SendMessage(0x00B0, 0, 0, ctrl.Hwnd)
    start := result & 0xFFFF
    if (start < cursorPosition)
        cursorPosition := start

    scrollLine := SendMessage(0x00CE, 0, 0, ctrl.Hwnd)
    myGui.Hide()
    isVisible := false
    SetTimer(WatchFocus, 0)
}

SaveNoteToFile(*) {
    global persistentText, saveFile
    file := FileOpen(saveFile, "w", "UTF-8")
    if file {
        file.Write(persistentText)
        file.Close()
    }
}

WatchFocus(*) {
    global myGui, isVisible
    if isVisible && WinActive("ahk_id " myGui.Hwnd) = 0 {
        HideGui()
    }
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
    text := StrReplace(A_Clipboard, "`r`n", "`n") ; CRLF → LF
    myGui["NoteEdit"].Value := text
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

; --- удаление строки по Ctrl+Y ---
DeleteCurrentLineSmart(*) {
    global myGui
    ctrl := myGui["NoteEdit"]

    ; Получаем текущую позицию курсора
    cursorPos := SendMessage(0x00B0, 0, 0, ctrl.Hwnd) & 0xFFFF

    ; Сохраняем позицию относительно начала строки
    Send("{Home}")
    Sleep(20)
    startPos := GetCursorPosInEdit(ctrl)

    ; Зажимаем Shift и нажимаем End → выделяем всю строку
    Send("+{End}")
    Sleep(20)

    ; Удаляем выделенный текст
    Send("{Del}")

    ; Восстанавливаем позицию курсора внутри строки
    Send("{Home}")
    Sleep(20)

    charsToRight := cursorPos - startPos
    Loop charsToRight {
        Send("{Right}")
    }

    ; --- Проверка: пустая ли строка? ---
    text := ctrl.Value
    newCursorPos := GetCursorPosInEdit(ctrl)

    ; Найдём начало строки (вручную без InStrRev)
    lineStart := 0
    Loop newCursorPos {
        pos := newCursorPos - A_Index + 1
        if (SubStr(text, pos, 1) = "`n") {
            lineStart := pos + 1 ; после символа перевода строки
            break
        }
    }

    ; Найдём конец строки
    lineEnd := InStr(text, "`n", false, newCursorPos)
    if !lineEnd
        lineEnd := StrLen(text) + 1

    ; Извлекаем содержимое строки
    lineContent := SubStr(text, lineStart, newCursorPos - lineStart + 1)
    lineContent .= SubStr(text, newCursorPos + 1, lineEnd - newCursorPos - 1)

    ; Если строка пустая (только пробелы или вообще ничего), то удаляем символ справа
    if (StrReplace(lineContent, " ", "") = "")
        Send("{Del}")
}