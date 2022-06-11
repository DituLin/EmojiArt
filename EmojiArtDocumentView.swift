//
//  ContentView.swift
//  EmojiArt
//
//  Created by Atu on 2022/4/3.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    
    let defaultEmojiFontSize: CGFloat = 40
    
    @ObservedObject var document: EmojiArtDocument
    
    var body: some View {
        VStack(spacing: 0){
            documentBody
            PaletteChooser(emojiFontSize: defaultEmojiFontSize)
        }
    }
    
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay(
                    OptionalImage(uiImage: document.backgroundImage)
                        .scaleEffect(zoomScale)
                        .position(convertFromEmojiCoordinates((0,0), in: geometry))
                )
                .gesture(doubleTapToZoom(in: geometry.size))
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView().scaleEffect(2)
                }else {
                    ForEach(document.emojis) { emoji in
                        Text(emoji.text)
                            .font(.system(size: fontSize(for: emoji)))
                            .scaleEffect(zoomScale)
                            .position(position(for: emoji,in: geometry))
                    }
                }
                
            }
            .clipped()
            .onDrop(of: [.plainText,.url,.image], isTargeted: nil){ providers, location in
                 drop(providers: providers,at: location,in: geometry)
            }
            .gesture(panGesture().simultaneously(with: zoomGesture()))
            .alert(item: $alertToShow) { alertToShow in
                alertToShow.alert()
            }
            .onChange(of: document.backgroundImageFetchStatus) { status in
                switch status {
                case .failed(let url):
                    showBackgroundImageFetchFailedAlert(url)
                default:
                    break
                }
            }
        }
        
    }
    
    @State private var alertToShow: IdentifiableAlert?
    
    private func showBackgroundImageFetchFailedAlert(_ url: URL) {
        alertToShow = IdentifiableAlert(id: "fetch failed: " + url.absoluteString,alert: {
                Alert(
                    title: Text("Background iamge fetch"),
                    message: Text("Couldn't load image from \(url)"),
                    dismissButton: .default(Text("OK"))
                )
        })
    }
    
    private func drop(providers: [NSItemProvider],at location: CGPoint,in geometry: GeometryProxy) -> Bool{
        var found = providers.loadObjects(ofType: URL.self) { url in
            document.setBackground(EmojiArtModel.Background.url(url.imageURL))
        }
        
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0){
                    document.setBackground(.imageData(data))
                }
            }
        }
        
        
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    document.addEmoji(String(emoji),
                                      at: convertFromEmojiCoordinates(location,in: geometry),
                                      size: defaultEmojiFontSize * zoomScale)
                }
            }
        }
        
        return found
    }
    
    
    private func position(for emoji: EmojiArtModel.Emoji,in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates((emoji.x,emoji.y), in: geometry)
    }
    
    private func convertFromEmojiCoordinates(_ location: CGPoint,in geometry: GeometryProxy) -> (x: Int,y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x - steadyStatePanOffset.width - center.x) * zoomScale,
            y: (location.y - steadyStatePanOffset.height - center.y) * zoomScale
        )
        return (Int(location.x),Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int,y: Int),in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale,
            y: center.y + CGFloat(location.y) * zoomScale
        )
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    
    
    @GestureState private var gesturePanOffset: CGSize = CGSize.zero
    @State private var steadyStatePanOffset: CGSize = CGSize.zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) {latesDragGestureValue, gesturePanOffset, _ in
                gesturePanOffset = latesDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
            }
    }
    
    
    @State private var steadyStateZoomScale: CGFloat = 1
    
    @GestureState private var gestureZoomScale: CGFloat = 1
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latesGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latesGestureScale
            }
            .onEnded { gestureScaleAtEnd in
                steadyStateZoomScale *= gestureScaleAtEnd
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
                
            }
    }
    
    private func zoomToFit(_ image: UIImage?,in size: CGSize) {
        if let image = image, image.size.width > 0,image.size.height > 0, size.width > 0,size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePanOffset = .zero
            steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
//    var palette: some View {
//        ScrollingEmojisView(emojis: testestemojis)
//            .font(.system(size: defaultEmojiFontSize))
//    }
//
//    let testestemojis = "⚽️🚄🚗🏉🛼"
}


//struct ScrollingEmojisView: View {
//    let emojis: String
//
//    var body: some View {
//
//        ScrollView(.horizontal){
//            HStack {
//                ForEach(emojis.map{ String($0) },id: \.self){ emoji in
//                    Text(emoji)
//                        .onDrag {
//                            NSItemProvider(object: emoji as NSString)
//
//                        }
//                }
//            }
//        }
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
