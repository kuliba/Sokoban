//
//  Bundle+Extensions.swift
//  ForaBank
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
}
