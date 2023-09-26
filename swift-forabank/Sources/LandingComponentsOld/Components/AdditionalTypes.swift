//
//  File.swift
//  
//
//  Created by Dmitry Martynov on 04.08.2023.
//

import SwiftUI

enum ImageState {
    case placeholder(String)
    case image(Image)
    
    var imageKey: String? {
        
        switch self {
            case let .placeholder(imageKey): return imageKey
            default: return nil
        }
    }
    
}

protocol Action {}
