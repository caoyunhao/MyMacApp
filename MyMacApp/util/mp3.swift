//
//  mp3.swift
//  MyMacApp
//
//  Created by Yunhao on 2019/5/24.
//  Copyright © 2019 Yunhao. All rights reserved.
//

import AVKit

struct MusicAsset {
    var path: String
    var data: Data?
}

struct Music {
    var meta: MusicMeta?
}

struct MusicMeta {
    var title: String?
    var ablum: String?
    var authors: [String]?
    var yearRecorded: String?
    var composer: String?
    var sampleRate: String?
    var audioChannels: String?
    var duration: Double?
    var imageData: Data?
    var lyricist: String?
    var encodedBy: String?
    var cdIdentifier: String?
    
    var authorString: String? {
        get {
            guard let authors = authors,
                authors.count > 0 else {
                    return nil
            }
            
            return authors.joined(separator: ",")
        }
        
        set {
            guard let newValue = newValue, newValue.count > 0 else {
                return
            }
            
            var r: [String] = []
            
            let ss = newValue.split(separator: ",")
            
            for sss in ss {
                r.append(String(sss))
            }
            
            authors = r
        }
    }
}

func extractMP3Meta(path: String) -> MusicMeta? {
    return extractMP3Meta(asset: AVURLAsset(url: URL(fileURLWithPath: path)))
}

func extractMP3Meta(url: URL) -> MusicMeta? {
    return extractMP3Meta(asset: AVURLAsset(url: url))
}

func extractMP3Meta(asset: AVAsset) -> MusicMeta? {
    var resultMeta = MusicMeta()
    var has = false
    
    func add<T>(value: T?, _ function: (T) -> Void) {
        if let value = value {
            function(value)
            has = true
        }
    }
    
    for format in asset.availableMetadataFormats {
        for metaDataItem in asset.metadata(forFormat: format) {
            if let key = metaDataItem.commonKey {
                let value = metaDataItem.value
                switch key {
                case .commonKeyTitle:
                    add(value: value as? String) { (value) in
                        resultMeta.title = value
                    }
                case .commonKeyAlbumName:
                    add(value: value as? String) { (value) in
                        resultMeta.ablum = value
                    }
                case .commonKeyArtwork:
                    add(value: value as? Data) { (value) in
                        resultMeta.imageData = value
                    }
                case AVMetadataKey.commonKeyArtist:
                    add(value: value as? String) { (value) in
                        resultMeta.authorString = value
                    }
                case AVMetadataKey.id3MetadataKeyLyricist:
                    add(value: value as? String) { (value) in
                        resultMeta.lyricist = value
                    }
                case AVMetadataKey.id3MetadataKeyEncodedBy:
                    add(value: value as? String) { (value) in
                        resultMeta.encodedBy = value
                    }
                case AVMetadataKey.id3MetadataKeyMusicCDIdentifier:
                    add(value: value as? String) { (value) in
                        resultMeta.cdIdentifier = value
                    }
                default:
                    break
                }
            }
        }
    }
    
    return has ? resultMeta : nil
}

func id3Metadata(metadataItems items: [AVMetadataItem], musicMeta: MusicMeta) -> [AVMetadataItem] {
    var ret: [AVMetadataItem] = []
    
    for item in items {
        if let key = item.commonKey {
            let newItem = AVMutableMetadataItem()
            
            switch key {
            case .commonKeyTitle:
                if let title = musicMeta.title {
                    newItem.identifier = .commonIdentifierTitle
                    newItem.value = title as NSCopying & NSObjectProtocol
                }
            case AVMetadataKey.commonKeyArtist:
                if let value = musicMeta.authorString {
                    newItem.identifier = .commonIdentifierAuthor
                    newItem.value = value as NSCopying & NSObjectProtocol
                }
            default: break
            }
            if newItem.identifier != nil {
                ret.append(newItem)
            }
        }
    }
    
    return ret;
}

func modifyAssetMetaReturnNew(asset: AVAsset, musicMeta: MusicMeta) -> AVAsset {
    let newAsset = asset.copy() as! AVAsset;
    
    for item in newAsset.metadata(forFormat: AVMetadataFormat.id3Metadata) {
        
        
        
    }
    
    
    
    
    
    
    
    
    return newAsset
}

func exportMP3(asset: AVAsset, outputURL: URL) {
    guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
        DLog("null")
        return
    }
    
    exportSession.outputURL = URL(fileURLWithPath: "/Users/caoyunhao/Desktop/test.mp3")
    exportSession.outputFileType = .mp3
    
    exportSession.metadata = []
    
//    exportSession.audioMix
    
    exportSession.exportAsynchronously {
        DLog("export successfully")
    }
}
