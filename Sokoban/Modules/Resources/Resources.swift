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
        private var files: [File]?
        
        func getFiles() -> [File]? { files }
        
        func loadResources() async -> [File] {
            let out = Array<File>()
            
            // Читаем файлы
            print("load files")
            
            files = out
            return out
        }
    }
        
    private init() {
        isolatedMembers = IsolatedMembers()
    }
    
    var files: [File] {
        get async {
            if let files = await isolatedMembers.getFiles() {
                return files
            } else {
                return await isolatedMembers.loadResources()
            }
        }
    }
}
