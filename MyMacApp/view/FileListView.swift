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
    var size: String
    var name: String
    var attributes: [FileAttributeKey: Any]
    
    init?(fileId: String) {
        guard let path = URL(fileURLWithPath: fileId).standardized.absoluteString.removingPercentEncoding?.replacingOccurrences(of: "file://", with: "") else {
            DLog("invalid fileId \(fileId) for URL")
            return nil
        }
        
        self.init(path: path)
    }
    
    init?(path: String) {
        guard let prop = try? FileManager.default.attributesOfItem(atPath: path) else {
            DLog("invalid path \(path) for file system")
            return nil
        }
        
        self.name = NSString(string: path).lastPathComponent
        self.size = "\(prop[FileAttributeKey.size] ?? "NAN") bytes"
        self.path = path
        self.attributes = prop
    }
}

class FileListView: NSTableView {

    fileprivate var fileItems: [FileItem] = [
        
    ]
    
    // var handleSelectedFileItem: Selector?
    var handleSelectedFileItem: ((FileItem) -> Void)?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.registerForDraggedTypes([.fileURL, ])
        self.delegate = self
        self.dataSource = self
        self.doubleAction = #selector(self.doDoubleAction)
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
                let url = URL(fileURLWithPath: fileId ).standardized
                
                let path = url.absoluteString.removingPercentEncoding!.replacingOccurrences(of: "file://", with: "")
                DLog("path: \(path)")
                
                let attributesOpt = try? FileManager.default.attributesOfItem(atPath: path)
                
//                DLog(attributesOpt)
                
                if let attributes = attributesOpt{
                    DLog("File size: \(attributes[FileAttributeKey.size])")
                    DLog("File creation date: \(attributes[FileAttributeKey.creationDate])")
                    DLog("File type: \(attributes[FileAttributeKey.type])")
                }

//                DLog(extractMP3Meta(url: url))
                
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
    
    @objc
    func doDoubleAction() {
        DLog("do double action")
        self.handleSelectedFileItem?(fileItems[self.selectedRow])
//        if let s = self.handleSelectedFileItem {
//            self.perform(s)
//        }
    }
}

extension FileListView: NSTableViewDelegate {
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


extension FileListView: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        DLog("numberOfRows is \(fileItems.count)")
        return fileItems.count
    }
}
