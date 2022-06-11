//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by Atu on 2022/6/11.
//

import SwiftUI

struct PaletteEditor: View {
    
    @Binding var palette: Paltte
    
    var body: some View {
        Form {
            nameSection
            addEmojisSection
            removeEmojiSection
        }
        .navigationTitle("Editor Palette \(palette.name)")
        .frame(minWidth: 300, minHeight: 350)
    }
    
    
    var nameSection: some View  {
        Section(header: Text("Name")) {
            TextField("Name",text: $palette.name)
        }
    }
    
    @State private var emojisToAdd = ""
    
    var addEmojisSection: some View {
        Section(header: Text("Add Emojis")) {
            TextField("",text: $emojisToAdd)
                .onChange(of: emojisToAdd){ emojis in
                    addEmojis(emojis)
                }
        }
    }
    
    func addEmojis(_ emojis: String) {
        withAnimation {
            palette.emojis = (emojis + palette.emojis)
                .filter { $0.isEmoji}
        }
    }
    
    var removeEmojiSection: some View {
        Section(header: Text("Remove Emoji")) {
            let emojis = palette.emojis.map { String($0)}
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(emojis,id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                palette.emojis.removeAll(where: {String($0) == emoji})
                            }
                        }
                }
            }
        }
    }
    
}

struct PaletteEditor_Previews: PreviewProvider {
    static var previews: some View {
        Text("Fix Me")
    }
}
