//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Brent on 11/7/2022.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    
    @ObservedObject var document: EmojiArtDocument
    
    let defaultEmojiSize:CGFloat = 40.0
    
    var body: some View {
        VStack (spacing: 0) {
            documentBody
            palette
        }
    }
    
    var documentBody: some View {
        
        GeometryReader { geo in
            ZStack {
                Color.orange
                ForEach(document.emojis) { emoji in
                    Text(emoji.text)
                        .font(.system(size: fontSize(for: emoji)))
                        .position(position(for: emoji, in: geo))
                }
            }
            .onDrop(of: [.plainText], isTargeted: nil) { providers, location in
                return drop(providers: providers, at: location, in: geo)
            }
        }
    }
    
    private func drop(providers:[NSItemProvider], at location: CGPoint, in geo: GeometryProxy) -> Bool {
        return providers.loadObjects(ofType: String.self) { string in
            
            if let emoji = string.first, emoji.isEmoji {
                
                document.addEmoji(String(emoji),
                                  at: convertToEmojiCoordinates(location,
                                                                in: geo),
                                  size: defaultEmojiSize
                )
            }
            
        }
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geo: GeometryProxy) -> (x: Int, y: Int) {
        let center = geo.frame(in: .local).center
        let location = CGPoint(
            x: location.x - center.x,
            y: location.y - center.y
        )
        
        return (Int(location.x), Int(location.y))
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    private func position(for emoji: EmojiArtModel.Emoji, in geo: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates((emoji.x, emoji.y), in: geo)
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geo: GeometryProxy) -> CGPoint {
        
        let center = geo.frame(in: .local).center   
        
        return CGPoint(
            x: center.x + CGFloat(location.x),
            y: center.y + CGFloat(location.y)
        )
    }
    
    var palette: some View {
        ScrollingEmojisView(emojis: testEmojis)
            .font(.system(size: defaultEmojiSize))
    }
    
    let testEmojis = "⚠️😎💻❓♣️🥹🧠🚨🏃‍♀️🔬🛠📚🎯👍❤️🐶🐱🐭🐹🐰🦋🐝🦄🦑🌵🎄🌳"
    
}

struct ScrollingEmojisView:View {
    
    let emojis: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag { NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
    
}




struct EmojiArtDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
