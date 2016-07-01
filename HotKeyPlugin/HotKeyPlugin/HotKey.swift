//
//  HotKey.swift
//  HotKeyPlugin
//
//  Created by 123456 on 16/6/22.
//  Copyright © 2016年 xiyuan. All rights reserved.
//

import AppKit

class Key {
    static let ﻿UpArrow = String(Character(UnicodeScalar(0xF700)))
    static let DownArrow = String(Character(UnicodeScalar(0xF701)))
    static let LeftArrow = String(Character(UnicodeScalar(0xF702)))
    static let RightArrow = String(Character(UnicodeScalar(0xF703)))
    static let F1 = String(Character(UnicodeScalar(0xF704)))
    static let F2 = String(Character(UnicodeScalar(0xF705)))
    static let F3 = String(Character(UnicodeScalar(0xF706)))
    static let F4 = String(Character(UnicodeScalar(0xF707)))
    static let F5 = String(Character(UnicodeScalar(0xF708)))
    static let F6 = String(Character(UnicodeScalar(0xF709)))
    static let F7 = String(Character(UnicodeScalar(0xF70A)))
    static let F8 = String(Character(UnicodeScalar(0xF70B)))
    static let F9 = String(Character(UnicodeScalar(0xF70C)))
    static let F10 = String(Character(UnicodeScalar(0xF70D)))
    static let F11 = String(Character(UnicodeScalar(0xF70E)))
    static let F12 = String(Character(UnicodeScalar(0xF70F)))
    static let Insert = String(Character(UnicodeScalar(0xF727)))
    static let Delete = String(Character(UnicodeScalar(0xF728)))
    static let Home = String(Character(UnicodeScalar(0xF729)))
    static let Begin = String(Character(UnicodeScalar(0xF72A)))
    static let End = String(Character(UnicodeScalar(0xF72B)))
    static let PageUp = String(Character(UnicodeScalar(0xF72C)))
    static let PageDown = String(Character(UnicodeScalar(0xF72D)))
    static let PrintScreen = String(Character(UnicodeScalar(0xF72E)))
    static let ScrollLock = String(Character(UnicodeScalar(0xF72F)))
    static let Pause = String(Character(UnicodeScalar(0xF730)))
    static let SysReq = String(Character(UnicodeScalar(0xF731)))
    static let Break = String(Character(UnicodeScalar(0xF732)))
    static let Reset = String(Character(UnicodeScalar(0xF733)))
    static let Stop = String(Character(UnicodeScalar(0xF734)))
    static let Menu = String(Character(UnicodeScalar(0xF735)))
    static let User = String(Character(UnicodeScalar(0xF736)))
    static let System = String(Character(UnicodeScalar(0xF737)))
    static let Print = String(Character(UnicodeScalar(0xF738)))
    static let ClearLine = String(Character(UnicodeScalar(0xF739)))
    static let ClearDisplay = String(Character(UnicodeScalar(0xF73A)))
    static let InsertLine = String(Character(UnicodeScalar(0xF73B)))
    static let DeleteLine = String(Character(UnicodeScalar(0xF73C)))
    static let InsertChar = String(Character(UnicodeScalar(0xF73D)))
    static let DeleteChar = String(Character(UnicodeScalar(0xF73E)))
    static let Prev = String(Character(UnicodeScalar(0xF73F)))
    static let Next = String(Character(UnicodeScalar(0xF740)))
    static let Select = String(Character(UnicodeScalar(0xF741)))
    static let Execute = String(Character(UnicodeScalar(0xF742)))
    static let Undo = String(Character(UnicodeScalar(0xF743)))
    static let Redo = String(Character(UnicodeScalar(0xF744)))
    static let Find = String(Character(UnicodeScalar(0xF745)))
    static let Help = String(Character(UnicodeScalar(0xF746)))
    static let ModeSwitch = String(Character(UnicodeScalar(0xF747)))
}

class KeyMask {
    static let ShiftKeyMask = 1 << 17
    static let ControlKeyMask = 1 << 18
    static let AlternateKeyMask = 1 << 19
    static let CommandKeyMask = 1 << 20
}

class HotKey {
    private let keyMap = [
        "﻿UpArrow": Key.﻿UpArrow,
        "DownArrow": Key.DownArrow,
        "LeftArrow": Key.LeftArrow,
        "RightArrow": Key.RightArrow,
        "F1": Key.F1,
        "F2": Key.F2,
        "F3": Key.F3,
        "F4": Key.F4,
        "F5": Key.F5,
        "F6": Key.F6,
        "F7": Key.F7,
        "F8": Key.F8,
        "F9": Key.F9,
        "F10": Key.F10,
        "F11": Key.F11,
        "F12": Key.F12,
        "Insert": Key.Insert,
        "Delete": Key.Delete,
        "Home": Key.Home,
        "Begin": Key.Begin,
        "End": Key.End,
        "PageUp": Key.PageUp,
        "PageDown": Key.PageDown,
        "PrintScreen": Key.PrintScreen,
        "ScrollLock": Key.ScrollLock,
        "Pause": Key.Pause,
        "SysReq": Key.SysReq,
        "Break": Key.Break,
        "Reset": Key.Reset,
        "Stop": Key.Stop,
        "Menu": Key.Menu,
        "User": Key.User,
        "System": Key.System,
        "Print": Key.Print,
        "ClearLine": Key.ClearLine,
        "ClearDisplay": Key.ClearDisplay,
        "InsertLine": Key.InsertLine,
        "DeleteLine": Key.DeleteLine,
        "InsertChar": Key.InsertChar,
        "DeleteChar": Key.DeleteChar,
        "Prev": Key.Prev,
        "Next": Key.Next,
        "Select": Key.Select,
        "Execute": Key.Execute,
        "Undo": Key.Undo,
        "Redo": Key.Redo,
        "Find": Key.Find,
        "Help": Key.Help,
        "ModeSwitch": Key.ModeSwitch
    ]
    
    private let keyMaskMap = [
        "shift": KeyMask.ShiftKeyMask,
        "ctrl": KeyMask.ControlKeyMask,
        "alt": KeyMask.AlternateKeyMask,
        "command": KeyMask.CommandKeyMask
        ]
    
    private let keyStr: String!
    private let keyStrSplit: [String]!
    private var _keyEquivalent: String = ""
    private var _keyEquivalentModifierMask: Int = 0
    
    var keyEquivalent: String {
        get {
            return _keyEquivalent
        }
    }
    
    var keyEquivalentModifierMask: Int {
        get {
            return _keyEquivalentModifierMask
        }
    }
    
    init(keyStr: String, defaultKeyEquivalent: String, defaultMask: Int) {
        self.keyStr = keyStr.stringByReplacingOccurrencesOfString(" ", withString: "")
        self.keyStrSplit = self.keyStr.characters.split(Character("+")).map{String($0)}
        for s in self.keyStrSplit {
            if let temp = keyMaskMap[s] {
                _keyEquivalentModifierMask += temp
            }
            else if _keyEquivalent == "" {
                if s.characters.count == 1 {
                    _keyEquivalent = s
                }
                else if let key = keyMap[s] {
                    _keyEquivalent = key
                }
            }
        }
        
        if _keyEquivalent == "" {
            _keyEquivalent = defaultKeyEquivalent
        }
        
        if _keyEquivalentModifierMask == 0 {
            _keyEquivalentModifierMask = defaultMask
        }
    }
    
}