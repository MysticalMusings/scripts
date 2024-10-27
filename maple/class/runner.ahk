#Requires AutoHotkey v2.0
#Include "action.ahk"

class ClassRunner {
    __New(delays, actions) {
        this.delays := delays
        this.actions := actions
    }

    Start() {
        loop {
            for action in this.actions {
                if WinActive("ahk_exe MapleStory.exe")
                    action.Run(this.delays)
            }
            try {
                WinSetTitle "main", "i).*macro.*"
            } catch Error as e {
            }
            Sleep 100
        }
    }

    static CreateFromIni(file) {
        pairs := []
        loop parse IniRead(file, "delays"), "`n" {
            parts := StrSplit(A_LoopField, "=", , 2)
            pairs.Push(parts[1], parts[2])
        }
        delays := Map(pairs*)

        actions := []
        loop parse IniRead(file, "actions"), "`n" {
            parts := StrSplit(A_LoopField, "=", , 2)
            sequence := parts[1]
            params := []
            for param in StrSplit(parts[2], ",", " ")
                params.Push(param)
            actions.Push(Rotation(sequence, params*))
        }

        return ClassRunner(delays, actions)
    }
}
