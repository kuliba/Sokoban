//
//  Image+Extensions.swift
//  ForaBank
//
//  Created by Max Gribov on 26.02.2022.
//

import Foundation
import UIKit
import SwiftUI

extension Image {
    
    init?(data: Data) {
        
        guard let uiImage = UIImage(data: data) else {
            return nil
        }
        
        self.init(uiImage: uiImage)
    }
}
