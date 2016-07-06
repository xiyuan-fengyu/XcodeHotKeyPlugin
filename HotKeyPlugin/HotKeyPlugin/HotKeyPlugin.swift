//
//  HotKeyPlugin.swift
//
//  Created by xiyuan_fengyu on 16/6/22.
//  Copyright © 2016年 xiyuan. All rights reserved.
//

import AppKit

var sharedPlugin: HotKeyPlugin?

class HotKeyPlugin: NSObject {

    var bundle: NSBundle
    lazy var center = NSNotificationCenter.defaultCenter()

    // MARK: - Initialization

    class func pluginDidLoad(bundle: NSBundle) {
        let allowedLoaders = bundle.objectForInfoDictionaryKey("me.delisa.XcodePluginBase.AllowedLoaders") as! Array<String>
        if allowedLoaders.contains(NSBundle.mainBundle().bundleIdentifier ?? "") {
            sharedPlugin = HotKeyPlugin(bundle: bundle)
        }
    }

    init(bundle: NSBundle) {
        self.bundle = bundle

        super.init()
        // NSApp may be nil if the plugin is loaded from the xcodebuild command line tool
        if (NSApp != nil && NSApp.mainMenu == nil) {
            center.addObserver(self, selector: #selector(self.applicationDidFinishLaunching), name: NSApplicationDidFinishLaunchingNotification, object: nil)
        } else {
            initializeAndLog()
        }
    }

    private func initializeAndLog() {
        let name = bundle.objectForInfoDictionaryKey("CFBundleName")
        let version = bundle.objectForInfoDictionaryKey("CFBundleShortVersionString")
        let status = initialize() ? "loaded successfully" : "failed to load"
        NSLog("🔌 Plugin \(name) \(version) \(status)")
    }

    func applicationDidFinishLaunching() {
        center.removeObserver(self, name: NSApplicationDidFinishLaunchingNotification, object: nil)
        initializeAndLog()
    }

    // MARK: - Implementation

    func initialize() -> Bool {
        loadHotKeySetting()
        
        guard let mainMenu = NSApp.mainMenu else { return false }
        guard let item = mainMenu.itemWithTitle("Edit") else { return false }
        guard let submenu = item.submenu else { return false }

        let deleteLineMI = NSMenuItem(title:"Delete Line", action:#selector(self.deleteLine), keyEquivalent: "")
        bindHotKey(deleteLineMI, hotKey: hkDeleteLine)
        
        let selectLineMI = NSMenuItem(title:"Select Line", action:#selector(self.selectLine), keyEquivalent: "")
        bindHotKey(selectLineMI, hotKey: hkSelectLine)

//        let moveToBeginingOfLineMI = NSMenuItem(title:"Move To Begining Of Line", action:#selector(self.moveToBeginingOfLine), keyEquivalent: "")
//        bindHotKey(moveToBeginingOfLineMI, hotKey: hkMoveToBeginingOfLine)

        submenu.addItem(NSMenuItem.separatorItem())
        submenu.addItem(deleteLineMI)
        submenu.addItem(selectLineMI)
//        submenu.addItem(moveToBeginingOfLineMI)

        return true
    }
    
    func bindHotKey(menuItem: NSMenuItem, hotKey: HotKey) {
        menuItem.keyEquivalent = hotKey.keyEquivalent
        if hotKey.keyEquivalentModifierMask != 0 {
            menuItem.keyEquivalentModifierMask = hotKey.keyEquivalentModifierMask
        }
        menuItem.target = self
    }
    
    private var hkDeleteLine: HotKey!
    private var hkSelectLine: HotKey!
    private var hkMoveToBeginingOfLine: HotKey!
    
    func loadHotKeySetting() {
        //获取删除一行的快捷键设置
        if let temp = bundle.objectForInfoDictionaryKey("HotKey_DeleteLine") {
            hkDeleteLine = HotKey(keyStr: temp as! String, defaultKeyEquivalent: "d", defaultMask: KeyMask.CommandKeyMask)
        }
        else {
            hkDeleteLine = HotKey(keyStr: "", defaultKeyEquivalent: "d", defaultMask: KeyMask.CommandKeyMask)
        }
        
        //获取选中一行的快捷键设置
        if let temp = bundle.objectForInfoDictionaryKey("HotKey_SelectLine") {
            hkSelectLine = HotKey(keyStr: temp as! String, defaultKeyEquivalent: "l", defaultMask: KeyMask.CommandKeyMask)
        }
        else {
            hkSelectLine = HotKey(keyStr: "", defaultKeyEquivalent: "l", defaultMask: KeyMask.CommandKeyMask)
        }

        //将光标移动到行首（忽略空白）
//        if let temp = bundle.objectForInfoDictionaryKey("HotKey_MoveToBeginingOfLine") {
//            hkMoveToBeginingOfLine = HotKey(keyStr: temp as! String, defaultKeyEquivalent: Key.Home, defaultMask: 0)
//        }
//        else {
//            hkMoveToBeginingOfLine = HotKey(keyStr: "", defaultKeyEquivalent: Key.Home, defaultMask: 0)
//        }
        
    }
    
    func deleteLine() {
        if let firstResponder = NSApp.keyWindow?.firstResponder {
            if firstResponder.isKindOfClass(NSClassFromString("DVTSourceTextView")!) && firstResponder.isKindOfClass(NSTextView.self) {
                let textView = firstResponder as! NSTextView
                
                if let text = textView.string {
                    let range = textView.selectedRange()
                    var lineRange = text.lineRangeForRange(text.startIndex.advancedBy(max(0, range.location - 1))..<text.startIndex.advancedBy(range.location))
                    var selectLineNum: Int = 0
                    
//                    print("range:\(range.location)..<\(range.location + range.length)")
                    
                    if range.location <= text.startIndex.distanceTo(lineRange.endIndex) {
                        selectLineNum = 1
//                        print(lineRange)
                    }
                    
                    while (text.startIndex.distanceTo(lineRange.endIndex) < range.location + range.length) {
                        selectLineNum += 1
                        lineRange = text.lineRangeForRange(lineRange.endIndex..<lineRange.endIndex)
//                        print(lineRange)
                    }
                    
                    print("selectLineNum: \(selectLineNum)")
                    
                    for _ in 0..<selectLineNum {
                        //删除一行(注意：这里不要直接对textView的string内容做修改，否则无法回退或重做，且光标位置为错误)
                        textView.moveToBeginningOfLine(nil)
                        textView.deleteToEndOfLine(nil)
                        textView.deleteForward(nil)
                    }
                }
                
            }
        }
    }
    
    private let blankCharacters = Character(" ")
    private let changeLineCharacters = Character("\n")
    
    func selectLine() {
        if let firstResponder = NSApp.keyWindow?.firstResponder {
            if firstResponder.isKindOfClass(NSClassFromString("DVTSourceTextView")!) && firstResponder.isKindOfClass(NSTextView.self) {
                let textView = firstResponder as! NSTextView
                
                let text = NSString(string: textView.string!)
                let curSelection = textView.selectedRange()
                let curLineSelection = text.lineRangeForRange(curSelection)
                let line = text.substringWithRange(curLineSelection)
                
                var notBlankStartIndex: Int?
                var notBlankEndIndex: Int?
                for i in line.characters.indices {
                    let c = line.characters[i]
                    if c != blankCharacters {
                        if notBlankStartIndex == nil {
                            notBlankStartIndex = line.startIndex.distanceTo(i)
                        }
                        else if c == changeLineCharacters && notBlankEndIndex == nil {
                            notBlankEndIndex = line.startIndex.distanceTo(i)
                            break
                        }
                        
                    }
                }
                
                if notBlankEndIndex != nil {
                    let lineNotBlankRange = NSMakeRange(curLineSelection.location + notBlankStartIndex!, notBlankEndIndex! - notBlankStartIndex!)
                    textView.setSelectedRange(lineNotBlankRange)
                }

            }
        }
    }
    
//    func moveToBeginingOfLine() {
//        if let firstResponder = NSApp.keyWindow?.firstResponder {
//            if firstResponder.isKindOfClass(NSClassFromString("DVTSourceTextView")!) && firstResponder.isKindOfClass(NSTextView.self) {
//                let textView = firstResponder as! NSTextView
//                
//                let text = NSString(string: textView.string!)
//                let curSelection = textView.selectedRange()
//                let curLineSelection = text.lineRangeForRange(curSelection)
//                let line = text.substringWithRange(curLineSelection)
//                
//                var notBlankStartIndex: Int?
//                for i in line.characters.indices {
//                    let c = line.characters[i]
//                    if c != blankCharacters {
//                        notBlankStartIndex = line.startIndex.distanceTo(i)
//                        break
//                    }
//                }
//                
//                if notBlankStartIndex != nil {
//                    let lineNotBlankRange = NSMakeRange(curLineSelection.location + notBlankStartIndex!, 0)
//                    textView.setSelectedRange(lineNotBlankRange)
//                }
//                
//            }
//        }
//    }
    
}

