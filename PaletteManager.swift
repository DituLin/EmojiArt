//
//  PaletteManager.swift
//  EmojiArt
//
//  Created by Atu on 2022/6/11.
//

import SwiftUI

struct PaletteManager: View {
    
    @EnvironmentObject var store: PaletteStore
    
    @State private var editMode: EditMode = .inactive
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.palettes) { palette in
                    if let index = store.palettes.index(matching: palette) {
                        NavigationLink(destination: PaletteEditor(palette: $store.palettes[index])) {
                            VStack(alignment: .leading) {
                                Text(palette.name)
                                Text(palette.emojis)
                            }
                            .gesture(editMode == .active ? tap : nil)
                        }
                    }
                }
                .onDelete { indexSet in
                    store.palettes.remove(atOffsets: indexSet)
                }
                .onMove {indexSet, newOffset in
                    store.palettes.move(fromOffsets: indexSet, toOffset: newOffset)
                }
            }
            .navigationTitle("Manage Palettes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem { EditButton()}
                ToolbarItem(placement: .navigationBarLeading) {
                    if presentationMode.wrappedValue.isPresented,
                       UIDevice.current.userInterfaceIdiom != .pad {
                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                
            }
            .environment(\.editMode, $editMode)
           
        }
        
    }
    
     var tap : some Gesture {
         TapGesture().onEnded{}
    }
}

struct PaletteManager_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManager()
            .environmentObject(PaletteStore(named: "Preview"))
    }
}
