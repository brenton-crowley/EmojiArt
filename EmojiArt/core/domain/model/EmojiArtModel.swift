//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by Brent on 8/7/2022.
//

import Foundation

// Resume at: https://youtu.be/eNS5EzgK3lY?t=2207

struct EmojiArtModel {
    
    var background = Background.blank
    var emojis: [Emoji] = []
    
    struct Emoji: Identifiable, Hashable {
        
        let text: String
        var x: Int // offset from the centre
        var y: Int // offset from the centre
        var size: Int
        let id: Int
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }

    init() { }
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String, as location: (x: Int, y: Int), size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: location.x, y: location.y, size: size, id: uniqueEmojiId))
    }
}
