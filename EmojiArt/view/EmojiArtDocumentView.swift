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
                Color.white.overlay(
                    OptionalImage(uiImage: document.backgroundImage)
                        .scaleEffect(zoomScale)
                        .position(convertFromEmojiCoordinates((0, 0), in: geo))
                )
                .gesture(doubleTapToZoom(in: geo.size))
                if document.bgFetchStatus == .fetching {
                    ProgressView()
                        .scaleEffect(2)
                } else {
                    ForEach(document.emojis) { emoji in
                        Text(emoji.text)
                            .font(.system(size: fontSize(for: emoji)))
                            .scaleEffect(zoomScale)
                            .position(position(for: emoji, in: geo))
                    }                    
                }
            }
            .clipped()
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                return drop(providers: providers, at: location, in: geo)
            }
        }
        .gesture(panGesture().simultaneously(with: zoomGesture()))
    }
    
    private func doubleTapToZoom(in size:CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    private func drop(providers:[NSItemProvider], at location: CGPoint, in geo: GeometryProxy) -> Bool {
        
        var found = providers.loadObjects(ofType: URL.self) { url in
            document.setBackground(.url(url.imageURL))
        }
        
        guard !found else { return found }
        
        found = providers.loadObjects(ofType: UIImage.self) { image in
            if let data = image.jpegData(compressionQuality: 1.0) {
                document.setBackground(.imageData(data))
            }
        }
        
        guard !found else { return found }
        
        found = providers.loadObjects(ofType: String.self) { string in
            
            if let emoji = string.first, emoji.isEmoji {
                
                document.addEmoji(String(emoji),
                                  at: convertToEmojiCoordinates(location,
                                                                in: geo),
                                  size: defaultEmojiSize / zoomScale
                )
            }
        }
        return found
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    @State private var steadyStatePanOffset: CGSize = CGSize.zero
    @GestureState private var gesturePanOffset: CGSize = CGSize.zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset, body: { latestDragGestureValue, gesturePanOffset, _ in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            })
            .onEnded { finalDragGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
            }
    }
    
    @State private var steadyStateZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    
    private var zoomScale: CGFloat { steadyStateZoomScale * gestureZoomScale }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale, body: { latestGestureScale, gestureZoomScale, _ in
                gestureZoomScale = latestGestureScale
            })
            .onEnded { gestureScaleAtEnd in
                steadyStateZoomScale *= gestureScaleAtEnd
            }
        
        // what state is changing while we're pinching?
    }
    
    private func zoomToFit(_ image:UIImage?, in size: CGSize) {
        
        guard let image = image,
                image.size.width > 0,
                image.size.height > 0,
                size.width > 0,
                size.height > 0 else { return }

        let hZoom = size.width / image.size.width
        let vZoom = size.height / image.size.height
        
        steadyStatePanOffset = .zero
        steadyStateZoomScale = min(hZoom, vZoom)
    }
    
    private func position(for emoji: EmojiArtModel.Emoji, in geo: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates((emoji.x, emoji.y), in: geo)
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geo: GeometryProxy) -> (x: Int, y: Int) {
        let center = geo.frame(in: .local).center
        let location = CGPoint(
            x: (location.x - panOffset.width - center.x) / zoomScale,
            y: (location.y - panOffset.height - center.y) / zoomScale
        )
        
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geo: GeometryProxy) -> CGPoint {
        
        let center = geo.frame(in: .local).center   
        
        return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
            y: center.y + CGFloat(location.y) * zoomScale + panOffset.height
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
