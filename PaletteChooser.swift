//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by Atu on 2022/6/11.
//

import SwiftUI

struct PaletteChooser: View {
    var emojiFontSize: CGFloat = 40
    var emojiFont: Font{.system(size: emojiFontSize)}
    
    @EnvironmentObject var strore: PaletteStore
    
    @State private var chosenPaletteIndex = 0
    
    var body: some View {
        HStack {
            paletteControlButton
            body(for: strore.palette(at: chosenPaletteIndex))
        }
        .clipped()
    }
    
    var paletteControlButton: some View {
        Button {
            withAnimation {
                chosenPaletteIndex = (chosenPaletteIndex + 1) % strore.palettes.count
            }
        
        } label: {
            Image(systemName: "paintpalette")
        }
        .font(emojiFont)
        .contextMenu {
            contextMenu
        }
    }
    
    @ViewBuilder
    var contextMenu: some View {
        AnimatedActionButton(title: "Edit", systemImage: "pencil"){
//            editing = true
            paletteToEditor = strore.palette(at: chosenPaletteIndex)
        }
        AnimatedActionButton(title: "New", systemImage: "plus"){
            strore.insertPalette(named: "New",emojis: "",at: chosenPaletteIndex)
//            editing = true
            paletteToEditor = strore.palette(at: chosenPaletteIndex)
        }
        AnimatedActionButton(title: "Delete", systemImage: "minus.circle"){
            chosenPaletteIndex = strore.removePalette(at: chosenPaletteIndex)
        }
        AnimatedActionButton(title: "Manager", systemImage: "sliver.vertical.3"){
            managing  = true
        }
        gotoMenu
    }
    
    
    var gotoMenu: some View {
        Menu {
            ForEach(strore.palettes,id: \.self) { palette in
                AnimatedActionButton(title: palette.name){
                    if let index = strore.palettes.firstIndex(where: {$0.id == palette.id}){
                        chosenPaletteIndex = index
                    }
                }
            }
        } label: {
            Label("Go To", systemImage: "text.insert")
        }
    }
    
    func body(for palette:   Paltte) -> some View {
        HStack {
            Text(palette.name)
            ScrollingEmojisView(emojis: palette.emojis)
                .font(emojiFont)
        }
        .id(palette.id)
        .transition(rollTransition)
        .popover(item: $paletteToEditor){ palette in
            PaletteEditor(palette: $strore.palettes[chosenPaletteIndex])
        }
        .sheet(isPresented: $managing) {
            PaletteManager()
        }
//        .popover(isPresented: $editing){
//            PaletteEditor(palette: $strore.palettes[chosenPaletteIndex])
//        }
  
    }
    
    
    @State private var managing = false
    @State private var paletteToEditor: Paltte?

    
    var rollTransition: AnyTransition {
        AnyTransition.asymmetric(insertion: .offset(x: 0,y: emojiFontSize), removal: .offset(x: 0,y: -emojiFontSize))
    }
}

struct ScrollingEmojisView: View{
    let emojis: String
    
    var body: some View {
        ScrollView(.horizontal){
            HStack{
                ForEach(emojis.map {String($0)},id: \.self) { emoji in
                    Text(emoji)
                        .onDrag {NSItemProvider(object: emoji as NSString)}
                }
            }
        }
    }
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser()
    }
}
