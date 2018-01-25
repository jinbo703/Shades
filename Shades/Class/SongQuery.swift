//
//  SongQuery.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import Foundation
import MediaPlayer

struct SongInfo {
    
    var albumTitle: String
    var artistName: String
    var songTitle:  String
    var songUrl:    URL
    var songId   :  NSNumber
}

struct AlbumInfo {
    
    var albumTitle: String
    var songs: [SongInfo]
}

class SongQuery {
    
    func get(songCategory: String) -> [AlbumInfo] {
        
        var albums: [AlbumInfo] = []
        let albumsQuery: MPMediaQuery
        if songCategory == "Artist" {
            albumsQuery = MPMediaQuery.artists()
            
        } else if songCategory == "Album" {
            albumsQuery = MPMediaQuery.albums()
            
        } else {
            albumsQuery = MPMediaQuery.albums()
        }
        
        
        // let albumsQuery: MPMediaQuery = MPMediaQuery.albums()
        let albumItems: [MPMediaItemCollection] = albumsQuery.collections! as [MPMediaItemCollection]
        //  var album: MPMediaItemCollection
        
        for album in albumItems {
            
            let albumItems: [MPMediaItem] = album.items as [MPMediaItem]
            // var song: MPMediaItem
            
            var songs: [SongInfo] = []
            
            var albumTitle: String = ""
            
            for song in albumItems {
                if songCategory == "Artist" {
                    albumTitle = song.value( forProperty: MPMediaItemPropertyArtist ) as! String
                    
                } else if songCategory == "Album" {
                    albumTitle = song.value( forProperty: MPMediaItemPropertyAlbumTitle ) as! String
                    
                    
                } else {
                    albumTitle = song.value( forProperty: MPMediaItemPropertyAlbumTitle ) as! String
                }
                
                let songInfo: SongInfo = SongInfo(
                    albumTitle: song.value( forProperty: MPMediaItemPropertyAlbumTitle ) as! String,
                    artistName: song.value( forProperty: MPMediaItemPropertyArtist ) as! String,
                    songTitle:  song.value( forProperty: MPMediaItemPropertyTitle ) as! String,
                    songUrl:    song.value( forProperty: MPMediaItemPropertyAssetURL ) as! URL,
                    songId:     song.value( forProperty: MPMediaItemPropertyPersistentID ) as! NSNumber
                )
                songs.append( songInfo )
            }
            
            let albumInfo: AlbumInfo = AlbumInfo(
                
                albumTitle: albumTitle,
                songs: songs
            )
            
            albums.append( albumInfo )
        }
        
        return albums
        
    }
    
    func get2(songCategory: String) -> [SongInfo] {
        
        var albums: [SongInfo] = []
        var albumsQuery: MPMediaQuery!
        albumsQuery = MPMediaQuery.songs()

        if albumsQuery == nil {
            return []
        }
        
        albumsQuery.addFilterPredicate(MPMediaPropertyPredicate.init(value: false, forProperty: MPMediaItemPropertyIsCloudItem))
        
        let albumCollect: [MPMediaItemCollection] = albumsQuery.collections! as [MPMediaItemCollection]
        
        for album in albumCollect {

            let albumItems: [MPMediaItem] = album.items as [MPMediaItem]
        
            var songs: [SongInfo] = []
            
            for song in albumItems {
                let isCloud = song.value( forProperty: MPMediaItemPropertyIsCloudItem )
                if isCloud != nil {
                    let b = isCloud as! Bool
                    if b == true {
                        continue
                    }
                }
                var albumTitle = song.value( forProperty: MPMediaItemPropertyAlbumTitle )
                if albumTitle == nil {
                    albumTitle = "UnTitled"
                }
                var artistName = song.value( forProperty: MPMediaItemPropertyArtist )
                if artistName == nil {
                    artistName = "Unnamed"
                }
                var songTitle = song.value( forProperty: MPMediaItemPropertyTitle )
                if songTitle == nil {
                    songTitle = "UnTitled"
                }
                print(artistName ?? "")
                
                let songProperty = song.value( forProperty: MPMediaItemPropertyGenre )
                print(songProperty ?? "")
                
                let songUrl = song.value( forProperty: MPMediaItemPropertyAssetURL )
                if songUrl == nil {
                    continue
                }
                else {
                    let url = songUrl as! URL
                    print(url.absoluteString)
                    if url.absoluteString.contains("ipod-library://item/item.mp3") == false &&
                       url.absoluteString.contains("ipod-library://item/item.wav") == false &&
                       url.absoluteString.contains("ipod-library://item/item.wma") == false {
                        continue
                    }
                }
                
                let songId = song.value( forProperty: MPMediaItemPropertyPersistentID )
                if songId == nil {
                    continue
                }                
                
                let songInfo: SongInfo = SongInfo(
                    albumTitle: albumTitle as! String,
                    artistName: artistName as! String,
                    songTitle:  songTitle as! String,
                    songUrl:    songUrl as! URL,
                    songId:     songId as! NSNumber
                )
                songs.append( songInfo )
            }
        
            for song in songs {
                albums.append(song)
            }
        }
        
        return albums
    }
    
    static func getItem( songId: NSNumber ) -> MPMediaItem {
        
        let property: MPMediaPropertyPredicate = MPMediaPropertyPredicate( value: songId, forProperty: MPMediaItemPropertyPersistentID )
        
        let query: MPMediaQuery = MPMediaQuery()
        query.addFilterPredicate( property )
        
        var items: [MPMediaItem] = query.items! as [MPMediaItem]
        
        return items[items.count - 1]
        
    }
    
}

