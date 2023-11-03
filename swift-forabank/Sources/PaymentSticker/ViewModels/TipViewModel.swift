//
//  TipViewModel.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation
import SwiftUI

public struct TipViewModel {
    
    let imageName: String
    let text: String
    
    public init(
        imageName: String,
        text: String
    ) {
        self.imageName = imageName
        self.text = text
    }
}
