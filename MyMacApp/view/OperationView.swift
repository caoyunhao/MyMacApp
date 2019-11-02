//
//  OperationView.swift
//  MyMacApp
//
//  Created by Yunhao on 2019/5/30.
//  Copyright © 2019 Yunhao. All rights reserved.
//

import Cocoa
import CoreGraphics

class OperationView: NSView {
    
    @IBOutlet weak var musicDetailView: MusicDetailView!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    @IBAction
    func snapshot (_ sender: AnyObject) {
        for screen in NSScreen.screens {
            DLog(screen.frame)
//            DLog(screen.backingScaleFactor)
            save(screen: screen)
        }
        
        SnipManager.shared.startCapture()
    }
    
    func save(screen: NSScreen) {
        let cgImage = shot(ofScreen: screen)!
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)

        var path = NSTemporaryDirectory()
        let name = "\(NSDate.timeIntervalSinceReferenceDate).png"
        path.append(name)
        
        DLog(path)
        
        let pathToDesktop = "/Users/caoyunhao/Desktop/\(NSDate.timeIntervalSinceReferenceDate).png"
        
        let data = bitmapRep.representation(using: .png, properties: [:])
        
        try! data?.write(to: URL(fileURLWithPath: path))

        do{
            try FileManager.default.copyItem(atPath: path, toPath: pathToDesktop)
            DLog("Success to copy file.")
        }catch let e {
            DLog("Failed. \(e)")
        }
    }
}

fileprivate func shot(ofScreen screen: NSScreen) -> CGImage? {
    return CGWindowListCreateImage(screen.frame.screenRect, .optionOnScreenOnly, kCGNullWindowID, .bestResolution)
}

fileprivate extension CGRect {
    var screenRect: CGRect {
        var mainRect = NSScreen.main!.frame;
        for screen in NSScreen.screens {
            if (screen.frame.origin.x == 0 && screen.frame.origin.y == 0) {
                mainRect = screen.frame;
            }
        }
        return CGRect(x: self.origin.x, y: mainRect.size.height - self.size.height - self.origin.y, width: self.size.width, height: self.size.height)
    }
    
    var zeroed: CGRect {
        return self.offsetBy(dx: -self.origin.x, dy: -self.origin.y)
    }
}
