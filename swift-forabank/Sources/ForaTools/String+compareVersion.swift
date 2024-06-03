//
//  String+compareVersion.swift
//
//
//  Created by Igor Malyarov on 02.06.2024.
//

import Foundation

public extension String {
    
    /**
     Compares the version string with another version string.
     
     This method splits the version strings into components (separated by ".") and compares each component numerically.
     If the components are of different lengths, the missing components are treated as 0.
     
     - Parameter version: The version string to compare with.
     - Returns: A `ComparisonResult` indicating the ordering of the two version strings:
     - `.orderedAscending`: The instance version is earlier than the provided version.
     - `.orderedDescending`: The instance version is later than the provided version.
     - `.orderedSame`: Both versions are equal.
     
     # Example:
     ```
     let result = "1.2.3".compareVersion(to: "1.2.4")
     switch result {
     case .orderedAscending:
     print("1.2.3 is earlier than 1.2.4")
     case .orderedDescending:
     print("1.2.3 is later than 1.2.4")
     case .orderedSame:
     print("1.2.3 is the same as 1.2.4")
     }
     ```
     */
    func compareVersion(to version: String) -> ComparisonResult {
        
        let versionArray1 = self.split(separator: ".").map { Int($0) ?? 0 }
        let versionArray2 = version.split(separator: ".").map { Int($0) ?? 0 }
        
        let maxLength = max(versionArray1.count, versionArray2.count)
        let paddedVersionArray1 = versionArray1 + Array(repeating: 0, count: maxLength - versionArray1.count)
        let paddedVersionArray2 = versionArray2 + Array(repeating: 0, count: maxLength - versionArray2.count)
        
        for i in 0..<maxLength {
            if paddedVersionArray1[i] < paddedVersionArray2[i] {
                return .orderedAscending
            } else if paddedVersionArray1[i] > paddedVersionArray2[i] {
                return .orderedDescending
            }
        }
        
        return .orderedSame
    }
}
