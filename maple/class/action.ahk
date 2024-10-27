#Requires AutoHotkey v2.0

class Action {
    __New(sequence, interval, defaultDelay := 2, rand := false, oneTime := false) {
        this.keys := []
        pos := 1
        while found := RegExMatch(sequence, "\{.+?\}|\w+", &key, pos) {
            this.keys.Push(key[0])
            pos := found + StrLen(key[0])
        }
        this.interval := Number(interval)
        this.defaultDelay := defaultDelay := defaultDelay ? Number(defaultDelay) : 2
        this.rand := rand ? true : false
        this.oneTime := oneTime ? true : false
        this.actionTime := this.keys.Length * this.defaultDelay
        this.lastCastTime := DateAdd(A_Now, -100000, "Seconds")
        this.continue := true
    }

    Run(delays) {
        if this.continue and DateDiff(A_Now, this.lastCastTime, "Seconds") >= this.interval - this.actionTime {
            Sleep Random() * 1000
            for key in this.keys {
                SendInput key
                if delays.Has(key)
                    Sleep delays[key] * 1000 * (this.rand ? Random() : 1)
                else
                    Sleep this.defaultDelay * 1000
                if InStr(key, "down}", false)
                    SendInput StrReplace(key, "down", "up", false)
            }
            this.lastCastTime := A_Now
            if this.oneTime
                this.continue := false
        }
    }
}
