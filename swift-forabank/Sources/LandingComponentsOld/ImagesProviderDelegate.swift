//
//  ImageProviderDelegate.swift
//  
//
//  Created by Dmitry Martynov on 25.07.2023.
//

import Combine
import SwiftUI

public protocol ImageProviderDelegate {
    
    var resultImages: CurrentValueSubject<[String : Image], Never> { get }
    func requestImages(list: ImageRequest)
}

public enum ImageRequest {
    
    case md5Hash([String])
    case url([String])
}
