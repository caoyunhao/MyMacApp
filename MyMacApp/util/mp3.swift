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
}

func extractMP3Meta(path: String) -> MusicMeta? {
    return extractMP3Meta(avUrlAsset: AVURLAsset(url: URL(fileURLWithPath: path)))
}

func extractMP3Meta(url: URL) -> MusicMeta? {
    return extractMP3Meta(avUrlAsset: AVURLAsset(url: url))
}

func extractMP3Meta(avUrlAsset: AVURLAsset) -> MusicMeta? {
    // let avURLAsset = AVURLAsset(url: URL.init(fileURLWithPath: singlePath))
    var meta = MusicMeta()
    
    var has = false
    for i in avUrlAsset.availableMetadataFormats {
        
        for metaDataItem in avUrlAsset.metadata(forFormat: i) {
            //歌曲名
            print("metaDataItem: \(metaDataItem)")
            if let key = metaDataItem.commonKey {
                switch key {
                case .commonKeyTitle:
                    meta.title = metaDataItem.value as? String
                    has = true
                case .commonKeyAlbumName:
                    meta.ablum = metaDataItem.value as? String
                    has = true
                case .commonKeyArtwork:
                    meta.imageData = metaDataItem.value as? Data// 这里是个坑坑T T
                    has = true
                case AVMetadataKey.commonKeyArtist:
                    if let authors = metaDataItem.value {
                        meta.authors = [authors] as? [String]
                        has = true
                    }
                case AVMetadataKey.id3MetadataKeyLyricist:
                    if let value = metaDataItem.value as? String {
                        meta.lyricist = value
                        has = true
                    }
                case AVMetadataKey.id3MetadataKeyEncodedBy:
                    if let value = metaDataItem.value as? String {
                        meta.encodedBy = value
                        has = true
                    }
                case AVMetadataKey.id3MetadataKeyMusicCDIdentifier:
                    if let value = metaDataItem.value as? String {
                        meta.encodedBy = value
                        has = true
                    }
                default:
                    break
                }
            }
        }
    }
    
    return has ? meta : nil
}
