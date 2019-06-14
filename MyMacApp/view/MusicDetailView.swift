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
    
    var musicAsset: MusicAsset {
        set {
            let musicAsset = newValue
            filePathTextField.stringValue = musicAsset.path
            
            let meta = extractMP3Meta(path: musicAsset.path)
            
            musicTitleTextField.stringValue = meta?.title ?? ""
            musicAuthorTextField.stringValue = meta?.authorString ?? ""
            musicAlbumTextField.stringValue = meta?.ablum ?? ""
            musicLyricistTextView.string = meta?.lyricist ?? ""
            
            if let data = meta?.imageData {
                musicAlbumImageView.image = NSImage(data: data)
            } else {
                musicAlbumImageView.image = nil
            }
        }
        get {
            return MusicAsset(path: filePathTextField.stringValue, data: nil)
        }
    }
    
    var musicMeta: MusicMeta {
        
        var meta = MusicMeta();
        meta.title = musicTitleTextField.stringValue
        meta.authorString = musicAuthorTextField.stringValue
        meta.ablum = musicAlbumTextField.stringValue
        meta.lyricist = musicLyricistTextView.string
        
        return meta
    }
    
    func save() {
        
    }
}
