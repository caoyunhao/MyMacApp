//
//  MusicTableView.swift
//  MyMacApp
//
//  Created by Yunhao on 2019/5/24.
//  Copyright © 2019 Yunhao. All rights reserved.
//

import Cocoa

struct FileItem {
    var path: String
    var size: String = "null"
    var name: String
    var prop: [FileAttributeKey: Any]
    
    init?(fileId: String) {
        guard let path = URL(fileURLWithPath: fileId).standardized.absoluteString.removingPercentEncoding else {
            return nil
        }
        self.init(path: path)
    }
    
    init?(path: String) {
        guard let prop = try? FileManager.default.attributesOfFileSystem(forPath: path) else {
            DLog("invalid path \(path)")
            return nil
        }
        
        self.name = NSString(string: path).lastPathComponent
        self.size = "\(String(describing: prop[FileAttributeKey.size]))bytes"
        self.path = path
        self.prop = prop
    }
}

class MusicListView: NSTableView {
    
    fileprivate var fileItems: [FileItem] = [
        
    ]

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.registerForDraggedTypes([.fileURL, ])
        delegate = self
        dataSource = self
    
        // Drawing code here.
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        if let types = sender.draggingPasteboard.types {
            if types.contains(.fileURL) {
                return NSDragOperation.copy
            }
        }

        return NSDragOperation.generic
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        DLog("prepareForDragOperation sender.numberOfValidItemsForDrop=\(sender.numberOfValidItemsForDrop)")
        
        var has = true
        sender.draggingPasteboard.pasteboardItems?.forEach({ (item) in
            if let fileId = item.propertyList(forType: .fileURL) as? String {
                let url = URL(fileURLWithPath: fileId as! String).standardized
                print(url)
                if let attributes = try? FileManager.default.attributesOfItem(atPath: url.absoluteString) {
                    print("File size: \(attributes[FileAttributeKey.size])")
                    print("File creation date: \(attributes[FileAttributeKey.creationDate])")
                    print("File type: \(attributes[FileAttributeKey.type])")
                }

                print(extractMP3Meta(url: url))
                
                if let i = FileItem(fileId: fileId) {
                    fileItems.append(i)
                    has = true
                }
            }
        })
        
        if has {
            self.reloadData()
        }
        
        return true
    }
}

extension MusicListView: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var cellIdentifier = "1111"
        let fileItem = fileItems[row]
        if tableColumn == tableView.tableColumns[0] {
            cellIdentifier = "filename"
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = fileItem.name
                return cell
            }
        } else if tableColumn == tableView.tableColumns[1] {
            cellIdentifier = "filesize"
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = fileItem.size
                return cell
            }
        } else if tableColumn == tableView.tableColumns[2] {
            cellIdentifier = "filefullpath"
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = fileItem.path
                return cell
            }
        }
        
        let cell = NSTableCellView();
        
        cell.textField?.stringValue = "null"
        
        return cell
    }
    
    func tableView(_ tableView: NSTableView, shouldShowCellExpansionFor tableColumn: NSTableColumn?, row: Int) -> Bool {
        return true
    }
}


extension MusicListView: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        DLog("numberOfRows is \(fileItems.count)")
        return fileItems.count
    }
}
