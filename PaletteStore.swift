//
//  PaletteStore.swift
//  EmojiArt
//
//  Created by Atu on 2022/4/10.
//

import SwiftUI

struct Paltte: Identifiable, Codable,Hashable {
    var name: String
    var emojis: String
    var id: Int
}


class PaletteStore: ObservableObject {
    let name: String
    
    @Published var palettes = [Paltte]() {
        didSet {
            storeInUserDefaults()
        }
    }
    
    private var userDefaultsKey: String {
        return "PaletteStore:" + name
    }
    
    private func storeInUserDefaults() {
        UserDefaults.standard.set(try? JSONEncoder().encode(palettes), forKey: userDefaultsKey)
//        UserDefaults.standard.set(palettes.map {[$0.name,$0.emojis,String($0.id)]}, forKey: userDefaultsKey)
    }
    
    private func restoreFromUserDefaults() {
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultsKey),
        let decodedPalettes = try? JSONDecoder().decode(Array<Paltte>.self, from: jsonData) {
            palettes = decodedPalettes
        }
//        if let palettesAsPropertyList = UserDefaults.standard.array(forKey: userDefaultsKey) as? [[String]] {
//
//        }
    }
    
    init(named name: String) {
        self.name = name
        restoreFromUserDefaults()
        if palettes.isEmpty {
            insertPalette(named: "Vehicles", emojis: "⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️")
            insertPalette(named: "Sport", emojis: "⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️")
            insertPalette(named: "Music", emojis: "⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️")
            insertPalette(named: "Vehicles", emojis: "⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️")
            insertPalette(named: "Flora", emojis: "⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️")
            insertPalette(named: "Weather", emojis: "⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️")
            insertPalette(named: "Faces", emojis: "⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️⚾️")
        }
    }
    
    
    func palette(at index: Int) -> Paltte {
        let safeIndex = min(max(index, 0), palettes.count - 1)
        return palettes[safeIndex]
    }
    
    @discardableResult
    func removePalette(at index: Int) -> Int {
        if palettes.count > 1,palettes.indices.contains(index) {
            palettes.remove(at: index)
        }
        return index % palettes.count
    }
    
    func insertPalette(named name: String,emojis: String? = nil,at index: Int = 0) {
        let unique = (palettes.max(by: {$0.id < $1.id })?.id ?? 0) + 1
        let palette = Paltte(name: name, emojis: emojis ?? "", id: unique)
        let safeIndex = min(max(index, 0), palettes.count)
        palettes.insert(palette, at: safeIndex)
    }
    
    
}
