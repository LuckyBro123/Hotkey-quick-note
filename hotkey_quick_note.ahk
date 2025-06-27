#Requires AutoHotkey v2.0

persistentText := ""
cursorPosition := 0
scrollLine := 0

global myGui := ""
global isVisible := false
global guiExists := false

#n::ToggleGui()

ToggleGui() {
    global persistentText, cursorPosition, scrollLine, myGui, isVisible, guiExists

    if !guiExists {
        myGui := Gui("+Resize", "Быстрая заметка")
        myGui.SetFont("s12", "Roboto")
        myGui.AddEdit("vNoteEdit Multi WantTab WantReturn VScroll")

        myGui.OnEvent("Close", HideGui)
        myGui.OnEvent("Escape", HideGui)

        HotIfWinActive("ahk_id " myGui.Hwnd)
        Hotkey("!c", CopyAll, "On")
        Hotkey("!v", PasteFromClipboard, "On")
        Hotkey("!d", DeleteAll, "On")
        HotIfWinActive()

        guiExists := true
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
        SendMessage(0x00C3, 0, 24, ctrl.Hwnd) ; EM_SETRECTNP с высотой строки

        ctrl.Value := persistentText
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
    global persistentText, cursorPosition, scrollLine, myGui, isVisible
    if !myGui
        return

    ctrl := myGui["NoteEdit"]
    persistentText := ctrl.Value

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

WatchFocus() {
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

CopyAll(*) {
    global myGui
    A_Clipboard := myGui["NoteEdit"].Value
    HideGui()
}

PasteFromClipboard(*) {
    global myGui
    myGui["NoteEdit"].Value := A_Clipboard
}

DeleteAll(*) {
    global myGui
    myGui["NoteEdit"].Value := ""
}

; === Ctrl+Enter: Home → Enter → Up ===
^Enter::
{
    Send("{Home}")
    Sleep(30)
    Send("{Enter}")
    Sleep(30)
    Send("{Up}")
}

; === Shift+Enter: Down → Home → Enter ===
+Enter::
{
    Send("{End}")
    Sleep(30)
    Send("{Enter}")
}
