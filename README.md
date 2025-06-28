# Hotkey Quick Note
**A micro app for instant note creation with minimal effort.**

It is invoked by a hotkey, appears in the center of the screen, and allows you to immediately start typing and editing text. Press Alt+C to copy the text to the clipboard and automatically minimize the window to the system tray — then you can continue with your tasks. Convenient!

When focus is lost, the program minimizes to the tray automatically.

There are several hotkeys for convenience. Here's the full list:

- Win+N — open / restore the program (no need to manually minimize it; it will do so itself).
- Alt+C — copy all existing text to the clipboard and minimize to the tray.
- Alt+D — delete all text (clear the editing area).
- Alt+V — replace the current text with the contents of the clipboard (deletes current text and pastes from clipboard).
- Ctrl+Y — delete the current line. Works with minor glitches but still fine enough. I didn’t have enough patience to debug this perfectly.
- Ctrl+Enter — insert a new line above the current line.
- Shift+Enter — insert a new line below the current line.


The app is convenient and written in AutoHotkey v2. It can be run as a script if you have AutoHotkey installed — that’s how I use it. You can also compile it into an EXE file and run that; it will work exactly the same way.

Download AutoHotkey: https://github.com/AutoHotkey/AutoHotkey

Guys, this program was written for personal use. The code isn't perfect and there are some small bugs, but it works well enough for me. I currently launch it manually because when starting from a shortcut, the window size displays incorrectly and I haven’t been able to fix it. If you can, please do so and send me the fix.

**RUSSIAN**

**Микро приложение для мгновенного создания заметки минимальными усилиями.**

Вызывается хоткеем, появляется посередине экрана и позволяет тут же вводить и редактировать текст посередине экрана, а затем по Alt-C копирует его в буфер и автоматически сворачивается в трей. И вы можете дальше делать свои дела. Удобно !

При потере фокуса программа сворачивается в трей.

Есть несколько хоткеев для удобства. Вот полный список:

- Win-N  -  открыть \ свернуть программу, но сворачивать не нужно, она сама сворачивается.
- Alt-C  -  скопировать весь имеющийся текст в буфер и свернуться в трей.
- Alt-D  -  удалить весь текст (очистить область редактирования)
- Alt-V  -  замещение текста содержимым буфера. То есть удаляет весь текст и вставляет из буфера
- Ctrl-Y  -  удаляет текущую строку. Работает с мелкими глюками, но и так нормально. не хватило терпения отладить это до идеального состояния
- Ctrl-Enter  -  вставляет строку над текущей строкой
- Shift-Enter  -  вставляет строку под текущей строкой

Прога удобная. Написана на AutoHotkey v2. Можно запускать в виде скрипта, если у вас установлен сам AutoHotkey. Я так и делаю. Можно сгенерить exe-файл и запускать его. Работать будет точно так же.

Скачать AutoHotkey   https://github.com/AutoHotkey/AutoHotkey

Ребята, программа написана для себя. Код не идеальный, есть мелкие глюки, но меня устраивает. Я пока запускаю вручную, потому что при запуске с иконки некорректно отображается размер окна. Я не смог это исправить. Если можете - исправьте и присылайте.
