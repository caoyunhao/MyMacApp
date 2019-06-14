//
//  SplitView.swift
//  MyMacApp
//
//  Created by Yunhao on 2019/5/26.
//  Copyright © 2019 Yunhao. All rights reserved.
//

import Cocoa

class SplitView: NSSplitView {
    
    var isFirstDraw = true

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if (isFirstDraw) {
            isFirstDraw = false
            firstDraw()
        }
        
        DLog("SplitView draw")
        
        // Drawing code here.
    }
    
    func firstDraw() {
        DLog("first draw")
        self.setPosition(300, ofDividerAt: 0)
    }
}
