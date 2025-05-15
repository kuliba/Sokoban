//
//  Resources.swift
//  Sokoban
//
//  Created by Valentin Ozerov on 06.05.2025.
//

import Foundation

@MainActor
final class Resources: NSObject, Sendable, @preconcurrency ResourcesProtocol {
    static let shared = Resources()

    private let isolatedMembers: IsolatedMembers
    private let parser: ParserProtocol

    private enum Constants {
        
        static let `extension` = "slc"
    }
    
    private actor IsolatedMembers {
        private var collections: [Collection]?
        
        func getCollections() -> [Collection]? { collections }
        func setCollection(_ collections: [Collection]) {
            self.collections = collections
        }
    }
    
    private override init() {
        self.isolatedMembers = IsolatedMembers()
        self.parser = Parser()
        super.init()
    }
    
    var collections: [Collection] {
        get async {
            if let collections = await isolatedMembers.getCollections() {
                return collections
            } else {
                return await loadCollections()
            }
        }
    }
    
    private func loadCollections() async -> [Collection] {
        let files = getFileNames()
        let data = files.map { readCollection($0) }.compactMap { $0 }
        let out = data.map { mapDataToCollection(fileName: $0.0, data: $0.1) }.compactMap { $0 }
        
        await isolatedMembers.setCollection(out)
        return out
    }

    private func getFileNames() -> [String] {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!

        do {
            return try fm.contentsOfDirectory(atPath: path)
                .filter { NSString(string: $0).pathExtension == Constants.extension }
                .map { URL(fileURLWithPath: $0).deletingPathExtension().lastPathComponent }
        } catch {
            // failed to read directory – bad permissions, perhaps?
            print(error.localizedDescription)
        }
        
        return []
    }
    
    private func readCollection(_ fileName: String) -> (String, Data)? {
        guard
            let fileURL = Bundle.main.url(forResource: fileName, withExtension: Constants.extension),
            let data = try? Data(contentsOf: fileURL)
        else {
            fatalError("Cannot find original file “\(fileName)” in application bundle’s resources.")
        }

        return (fileName, data)
    }
    
    private func mapDataToCollection(fileName: String, data: Data) -> Collection? {
        parser.parseCollection(name: fileName, data: data)
    }
}
