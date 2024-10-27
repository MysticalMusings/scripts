#Requires AutoHotkey v2.0
#Include "class\runner.ahk"


Start() {
    IB := InputBox("选择职业（英文缩写）")
    if IB.Result = "Cancel"
        return
    file := "class/" IB.Value ".ini"
    runner := ClassRunner.CreateFromIni(file)
    runner.Start()
    ResetTimer()
}

ResetTimer() {
    SetTimer(Notify, 0)
    SetTimer(Notify, 1200000)
}

Notify() {
    MsgBox "Rune"
}

SetTitleMatchMode "RegEx"
#q:: Start()
#w:: ResetTimer()
#s:: Pause -1