#Requires AutoHotkey v2.0

persistentText := ""      ; Сохраняемый текст
global myGui := ""        ; Глобальное окно
global isVisible := false ; Состояние окна

#n::
{
    global persistentText, myGui, isVisible
    static guiExists := false

    if !guiExists {
        screenWidth := A_ScreenWidth
        screenHeight := A_ScreenHeight

        winWidth := Round(screenWidth * 0.6)
        winHeight := Round(screenHeight * 0.8)
        winX := (screenWidth - winWidth) // 2
        winY := (screenHeight - winHeight) // 2

        myGui := Gui("+AlwaysOnTop +Resize", "Быстрая заметка")
        myGui.SetFont("s12", "Segoe UI")
        myGui.AddEdit("vNoteEdit w" winWidth " h" winHeight " Multi WantTab", persistentText)
        myGui.OnEvent("Close", (*) => (
            persistentText := myGui["NoteEdit"].Value,
            myGui.Hide(),
            isVisible := false
        ))

        guiExists := true
        myGui.Show("x" winX " y" winY)  ; ✅ исправлено
        isVisible := true
    } else if isVisible {
        persistentText := myGui["NoteEdit"].Value
        myGui.Hide()
        isVisible := false
    } else {
        myGui["NoteEdit"].Value := persistentText
        myGui.Show()
        myGui["NoteEdit"].Focus()
        isVisible := true
    }
    return
}
