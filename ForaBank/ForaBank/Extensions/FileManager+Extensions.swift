//
//  FileManager+Extensions.swift
//  ForaBank
//
//  Created by Max Gribov on 20.01.2022.
//

import Foundation

extension FileManager {
    
    func rootFolderURL(with name: String) throws -> URL {
        
        let folderURL = try url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(name, isDirectory: true)
        try createDirectory(at: folderURL, withIntermediateDirectories: true)
        
        return folderURL
    }
}
