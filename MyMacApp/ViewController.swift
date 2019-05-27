//
//  ViewController.swift
//  MyMacApp
//
//  Created by Yunhao on 2019/5/23.
//  Copyright © 2019 Yunhao. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
//    @IBOutlet var tableView: NSTableView?
    
    var items: [Music] = []

    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView?.delegate = self
//        tableView?.dataSource = self
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

//

