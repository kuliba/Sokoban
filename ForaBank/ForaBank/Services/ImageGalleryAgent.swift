//
//  ImageGalleryAgent.swift
//  ForaBank
//
//  Created by Mikhail on 30.06.2022.
//

import UIKit
import Photos

struct ImageGalleryAgent: ImageGalleryAgentProtocol {
    
    var isGalleryAvailable: Bool { UIImagePickerController.isSourceTypeAvailable(.photoLibrary) }
    
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()

        switch authorizationStatus {
            
        case .authorized:
            completion(true)
            
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { status in
                
                switch status {
                    
                case .authorized:
                    completion(true)
                    
                default:
                    completion(false)
                }
            }
        default:
            completion(false)
        }
    }
}
