//
//  ViewController.swift
//  MyMacApp
//
//  Created by Yunhao on 2019/5/23.
//  Copyright © 2019 Yunhao. All rights reserved.
//
import Cocoa
import Carbon

class ViewController: NSViewController {
    
    @IBOutlet weak var fileListView: FileListView!
    @IBOutlet weak var musicDetailView: MusicDetailView!
    
    var hotkey: HotKey! = nil
    var captureHotkey: HotKey! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fileListView.handleSelectedFileItem = { item in
            self.handle(fileItem: item)
        }
        initHotKey()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func handle(fileItem item: FileItem ) {
        DLog("handleSelectedFileItem")
        let asset = MusicAsset(path: item.path, data: nil)
//        musicDetailView.setAsset(musicAsset: asset)
        musicDetailView.musicAsset = asset
    }
    
    func initHotKey() {
//        hotkey = HotKey(key: .escape, modifiers: [])
//        hotkey.keyDownHandler = {
//            SnipManager.shared.endCapture()
//        }
        
        captureHotkey = HotKey(key: .a, modifiers: [.command, .control])
        captureHotkey.keyDownHandler = {
            SnipManager.shared.startCapture()
        }
    }
}

//

