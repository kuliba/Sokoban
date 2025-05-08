//
//  Resources.swift
//  Sokoban
//
//  Created by Valentin Ozerov on 06.05.2025.
//

final class Resources: ResourcesProtocol, Sendable {
    static let shared = Resources()

    private let isolatedMembers: IsolatedMembers

    private actor IsolatedMembers {
        private var collections: [Collection]?
        
        func getCollections() -> [Collection]? { collections }
        
        func loadCollections() async -> [Collection] {
            let out = Array<Collection>()
            
            // Читаем файлы
            print("load files")
            
            collections = out
            return out
        }
    }
        
    private init() {
        isolatedMembers = IsolatedMembers()
    }
    
    var collections: [Collection] {
        get async {
            if let collections = await isolatedMembers.getCollections() {
                return collections
            } else {
                return await isolatedMembers.loadCollections()
            }
        }
    }
}
