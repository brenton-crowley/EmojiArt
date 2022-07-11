//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Brent on 8/7/2022.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    
    let document = EmojiArtDocument()
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
        }
    }
}
