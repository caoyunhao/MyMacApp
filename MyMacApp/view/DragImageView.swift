//
//  DragImageView.swift
//  MyMacApp
//
//  Created by Yunhao on 2019/6/13.
//  Copyright © 2019 Yunhao. All rights reserved.
//

import Cocoa

class DragImageView: NSImageView {
    
    var fileName: String?
    
    private let dragThreshold: CGFloat = 3.0
    private var dragOriginOffset = CGPoint.zero
    private var imagePixelSize = CGSize.zero
    
    class SnapshotItem {
        let baseImage: NSImage
        let pixelSize: CGSize
        let drawingScale: CGFloat
        
        init(baseImage: NSImage, pixelSize: CGSize, drawingScale: CGFloat) {
            self.baseImage = baseImage
            self.pixelSize = pixelSize
            self.drawingScale = drawingScale
        }
        
        var outputImage: NSImage {
            return NSImage(size: pixelSize, flipped: false) { (rect) -> Bool in
                self.baseImage.draw(in: rect)
                let transform = NSAffineTransform()
                transform.scale(by: self.drawingScale)
                transform.concat()
                return true
            }
        }
        
        var jpegRepresentation: Data? {
            guard let tiffData = outputImage.tiffRepresentation else { return nil }
            let bitmapImageRep = NSBitmapImageRep(data: tiffData)
            return bitmapImageRep?.representation(using: .jpeg, properties: [:])
        }
    }
    
    var snapshotItem: SnapshotItem? {
        guard let image = image else { return nil }
        let drawingScale = imagePixelSize.width / overlay.frame.width
        return SnapshotItem(baseImage: image, pixelSize: imagePixelSize, drawingScale: drawingScale)
    }
    
    var draggingImage: NSImage {
        let targetRect = overlay.frame
        let image = NSImage(size: targetRect.size)
        if let imageRep = bitmapImageRepForCachingDisplay(in: targetRect) {
            cacheDisplay(in: targetRect, to: imageRep)
            image.addRepresentation(imageRep)
        }
        return image
    }
    
    override var image: NSImage? {
        set {
            super.image = newValue
            if let imageRep = newValue?.representations.first {
                imagePixelSize = CGSize(width: imageRep.pixelsWide, height: imageRep.pixelsHigh)
            }
//            isLoading = false
            needsLayout = true
        }
        get {
            return super.image
        }
    }
    
    /// directory URL used for accepting file promises
    private lazy var destinationURL: URL = {
        let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Drops")
        try? FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
        return destinationURL
    }()
    
    private var overlay: NSView!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.registerForDraggedTypes(NSFilePromiseReceiver.readableDraggedTypes.map { NSPasteboard.PasteboardType($0) })
        self.registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
        // Drawing code here.
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        unregisterDraggedTypes()
        overlay = NSView()
        addSubview(overlay)
    }
    
    override func layout() {
        super.layout()
        let imageSize = image?.size ?? .zero
        overlay.frame = rectForDrawingImage(with: imageSize, scaling: imageScaling)
    }
    
    private func rectForDrawingImage(with imageSize: CGSize, scaling: NSImageScaling?) -> CGRect {
        var drawingRect = CGRect(origin: .zero, size: imageSize)
        let containerRect = bounds
        guard let scaling = scaling, imageSize.width > 0 && imageSize.height > 0 else {
            return drawingRect
        }
        
        func scaledSizeToFitFrame() -> CGSize {
            var scaledSize = CGSize.zero
            let horizontalScale = containerRect.width / imageSize.width
            let verticalScale = containerRect.height / imageSize.height
            let minimumScale = min(horizontalScale, verticalScale)
            scaledSize.width = imageSize.width * minimumScale
            scaledSize.height = imageSize.height * minimumScale
            return scaledSize
        }
        
        switch scaling {
        case .scaleProportionallyDown:
            if imageSize.width > containerRect.width || imageSize.height > containerRect.height {
                drawingRect.size = scaledSizeToFitFrame()
            }
        case .scaleAxesIndependently:
            drawingRect.size = containerRect.size
        case .scaleProportionallyUpOrDown:
            if imageSize.width > 0.0 && imageSize.height > 0.0 {
                drawingRect.size = scaledSizeToFitFrame()
            }
        case .scaleNone:
            break
        @unknown default:
            break
        }
        
        drawingRect.origin.x = containerRect.minX + (containerRect.width - drawingRect.width) * 0.5
        drawingRect.origin.y = containerRect.minY + (containerRect.height - drawingRect.height) * 0.5
        
        return drawingRect
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = self.convert(event.locationInWindow, to: nil)
        window?.trackEvents(matching: [.leftMouseUp, .leftMouseDragged], timeout: NSEvent.foreverDuration, mode: .eventTracking, handler: { (event, stop) in
            guard let event = event else { return }
            
            if event.type == .leftMouseUp {
                stop.pointee = true
            } else {
                let movedLocation = convert(event.locationInWindow, from: nil)
                if abs(movedLocation.x - location.x) > dragThreshold || abs(movedLocation.y - location.y) > dragThreshold {
                    stop.pointee = true
                    let provider = NSFilePromiseProvider(fileType: kUTTypeJPEG as String, delegate: self)
                    provider.userInfo = snapshotItem
                    let draggingItem = NSDraggingItem(pasteboardWriter: provider)
                    draggingItem.setDraggingFrame(overlay.frame, contents: draggingImage)
                    beginDraggingSession(with: [draggingItem], event: event, source: self)
                }
            }
        })
    }
    
    /// updates the canvas with a given image file
    private func handleFile(at url: URL) {
        let image = NSImage(contentsOf: url)
        OperationQueue.main.addOperation {
            self.handleImage(image)
        }
    }
    
    /// updates the canvas with a given image
    private func handleImage(_ image: NSImage?) {
        self.image = image
//        placeholderLabel.isHidden = (image != nil)
//        imageLabel.stringValue = imageCanvas.imageDescription
    }
    
    // MARK: - NSDraggingDestination
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return sender.draggingSourceOperationMask.intersection([.copy])
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let supportedClasses = [
            NSFilePromiseReceiver.self,
            NSURL.self
        ]
        
        let searchOptions: [NSPasteboard.ReadingOptionKey: Any] = [
            .urlReadingFileURLsOnly: true,
            .urlReadingContentsConformToTypes: [ kUTTypeImage ]
        ]
        /// - Tag: HandleFilePromises
        sender.enumerateDraggingItems(options: [], for: nil, classes: supportedClasses, searchOptions: searchOptions) { (draggingItem, _, _) in
            switch draggingItem.item {
            case let filePromiseReceiver as NSFilePromiseReceiver:
//                self.prepareForUpdate()
                filePromiseReceiver.receivePromisedFiles(atDestination: self.destinationURL, options: [:],operationQueue: OperationQueue.main) {
                    (fileURL, error) in
                    if let error = error {
                        DLog(error)
                    } else {
                        self.handleFile(at: fileURL)
                    }
                }
            case let fileURL as URL:
                self.handleFile(at: fileURL)
            default: break
            }
        }
        
        return true
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isHighlighted = false
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        isHighlighted = false
    }
}

extension DragImageView: NSDraggingSource {
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return (context == .outsideApplication) ? [.copy] : []
    }
}

extension DragImageView: NSFilePromiseProviderDelegate {
    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, fileNameForType fileType: String) -> String {
        guard let filename = fileName, filename.count == 0 else {
            return "unnamed.png"
        }

        return filename
    }
    
    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, writePromiseTo url: URL, completionHandler: @escaping (Error?) -> Void) {
        do {
            if let snapshot = filePromiseProvider.userInfo as? DragImageView.SnapshotItem {
                try snapshot.jpegRepresentation?.write(to: url)
            }
            completionHandler(nil)
        } catch let error {
            completionHandler(error)
        }
    }
}
