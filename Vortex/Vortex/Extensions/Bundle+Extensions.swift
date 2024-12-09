//
//  Bundle+Extensions.swift
//  Vortex
//
//  Created by Max Gribov on 26.04.2022.
//

import Foundation

extension Bundle {
    
    var releaseVersionNumber: String? {
        
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildVersionNumber: String? {
        
        return infoDictionary?["CFBundleVersion"] as? String
    }
    
    var releaseVersionFull: String {
        let versionNumber = buildVersionNumber ?? ""
        return (releaseVersionNumber ?? "") + (versionNumber.isEmpty ? "" : ".\(versionNumber)")
    }
    
    func url(
        forFilename filename: String,
        withExtension ext: String
    ) throws -> URL {
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext)
        else {
            struct MissingResourceError: Error {
                
                let filename: String
                let ext: String
            }
            
            throw MissingResourceError(filename: filename, ext: ext)
        }

        return url
    }
}
