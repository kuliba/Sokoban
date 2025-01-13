//
//  CheckUncheckImages.swift
//  
//
//  Created by Andryusina Nataly on 14.06.2023.
//

import SwiftUI

public struct CheckUncheckImages: Equatable {

    public let checkedImage: Image
    public let uncheckedImage: Image
    
    public init(checkedImage: Image, uncheckedImage: Image) {
        
        self.checkedImage = checkedImage
        self.uncheckedImage = uncheckedImage
    }
}
