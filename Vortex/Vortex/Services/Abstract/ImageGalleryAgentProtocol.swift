//
//  ImageGalleryAgentProtocol.swift
//  ForaBank
//
//  Created by Mikhail on 30.06.2022.
//

import Foundation

protocol ImageGalleryAgentProtocol {
    
    var isGalleryAvailable: Bool { get }
    
    func requestPermissions(completion: @escaping (Bool) -> Void )
}
