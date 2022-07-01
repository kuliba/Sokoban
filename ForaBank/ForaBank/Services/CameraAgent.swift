//
//  CameraAgent.swift
//  ForaBank
//
//  Created by Mikhail on 29.06.2022.
//

import UIKit
import AVFoundation

struct CameraAgent: CameraAgentProtocol {
    
    var isCameraAvailable: Bool { UIImagePickerController.isSourceTypeAvailable(.camera) }
    
    func requestPermissions(completion: @escaping (Bool) -> Void ) {
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
            
        case .authorized:
            completion(true)
          
        case .notDetermined:
            
            AVCaptureDevice.requestAccess(for: .video) { granted in
                
                if granted {
                    
                    completion(true)
                    
                } else {
                    
                    completion(false)
                }
            }
        default :
            completion(false)
        }
    }
}
