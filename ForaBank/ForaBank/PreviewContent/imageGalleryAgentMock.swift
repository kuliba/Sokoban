//
//  imageGalleryAgentMock.swift
//  ForaBank
//
//  Created by Mikhail on 30.06.2022.
//

import Foundation

class ImageGalleryAgentMock: ImageGalleryAgentProtocol {
    
    var isGalleryAvailable: Bool = true
    
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        return completion(false)
    }
    
}
