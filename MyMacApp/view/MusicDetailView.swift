//
//  MusicDetailView.swift
//  MyMacApp
//
//  Created by Yunhao on 2019/5/26.
//  Copyright © 2019 Yunhao. All rights reserved.
//

import Cocoa

class MusicDetailView: NSView {
    @IBOutlet weak var filePathTextField: NSTextField!
    @IBOutlet weak var musicTitleTextField: NSTextField!
    @IBOutlet weak var musicAuthorTextField: NSTextField!
    @IBOutlet weak var musicAlbumTextField: NSTextField!
    @IBOutlet weak var musicAlbumImageView: NSImageView!
    @IBOutlet weak var musicLyricistTextView: NSTextView!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
