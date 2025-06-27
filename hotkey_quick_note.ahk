#Requires AutoHotkey v2.0

persistentText := ""          ; сохраняемый текст
cursorPosition := 0           ; сохранённая позиция курсора
scrollLine := 0               ; сохранённая вертикальная прокрутка
global myGui := ""
global isVisible := false     ; флаг отображения окна
global guiExists := false

#n::ToggleGui()

ToggleGui() {
    global persistentText, cursorPosition, scrollLine, myGui, isVisible, guiExists

    static winX := 0, winY := 0, winWidth := 0, winHeight := 0

    if !guiExists {
        screenWidth := A_ScreenWidth
        screenHeight := A_ScreenHeight

        winWidth := Round(screenWidth * 0.6)
        winHeight := Round(screenHeight * 0.8)
        winX := (screenWidth - winWidth) // 2
        winY := (screenHeight - winHeight) // 2

        myGui := Gui("+Resize", "Быстрая заметка")
        myGui.SetFont("s12", "Segoe UI")
        myGui.AddEdit("vNoteEdit w" winWidth " h" winHeight " Multi WantTab")
        myGui.OnEvent("Close", HideGui)
        myGui.OnEvent("Escape", HideGui)

        guiExists := true
    }

    ctrl := myGui["NoteEdit"]

    if !isVisible {
        ctrl.Value := persistentText
        myGui.Show("x" winX " y" winY)
        ctrl.Focus()

        ; Восстановить прокрутку
        SendMessage(0x00B1, 0, 0, ctrl.Hwnd) ; временно убираем выделение
        SendMessage(0x00B6, 0, scrollLine, ctrl.Hwnd) ; EM_LINESCROLL — прокрутка на scrollLine строк

        ; Восстановить курсор
        if (cursorPosition >= 0 && cursorPosition <= StrLen(ctrl.Value)) {
            SendMessage(0x00B1, cursorPosition, cursorPosition, ctrl.Hwnd)
            SendMessage(0x00B7, 0, 0, ctrl.Hwnd) ; EM_SCROLLCARET — показать курсор
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
    cursorPosition := GetCursorPosInEdit(ctrl)
    scrollLine := SendMessage(0x00CE, 0, 0, ctrl.Hwnd) ; EM_GETFIRSTVISIBLELINE
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
    result := SendMessage(0x00B0, 0, 0, ctrl.Hwnd)  ; EM_GETSEL
    start := result & 0xFFFF
    return start
}

SetCursorPosInEdit(ctrl, pos) {
    SendMessage(0x00B1, pos, pos, ctrl.Hwnd)  ; EM_SETSEL
    SendMessage(0x00B7, 0, 0, ctrl.Hwnd)      ; EM_SCROLLCARET
}
