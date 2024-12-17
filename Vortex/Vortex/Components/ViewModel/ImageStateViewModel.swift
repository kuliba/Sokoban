//
//  ImageStateViewModel.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 10.01.2023.
//

import Foundation
import SwiftUI

typealias Md5hash = String

enum ImageStateViewModel {
    case placeholder(Md5hash?)
    case image(Image)
    
    var isPlaceholder: Bool {
        switch self {
        case .placeholder: return true
        case .image: return false
        }
    }
}

extension ImageStateViewModel {
    
    static func reduce(images: [String: ImageData],
                              md5hash: String?,
                              imagesDownloadList: inout [String]) -> ImageStateViewModel {
       
        guard let md5hash = md5hash else { return .placeholder(nil) }
        
        if let image = images[md5hash]?.image {
            return .image(image)
            
        } else {
            
            imagesDownloadList.append(md5hash)
            return .placeholder(md5hash)
        }
    }
    
    static func updateImage(imgState: ImageStateViewModel?,
                            images: [String: ImageData]) -> ImageStateViewModel? {
        
        if case let .placeholder(md5hash) = imgState,
           let md5hash = md5hash,
           let image = images[md5hash]?.image {
            
            return .image(image)
        }
        return nil
    }

}
