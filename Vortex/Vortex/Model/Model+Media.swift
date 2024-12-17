//
//  Model+Media.swift
//  ForaBank
//
//  Created by Mikhail on 30.06.2022.
//

import Foundation

extension ModelAction {
    
    enum Media {
  
        enum CameraPermission {
        
            struct Request: Action {}
            
            struct Response: Action {
                
                let result: Bool
            }
        }
        
        enum GalleryPermission {
        
            struct Request: Action {}
            
            struct Response: Action {
                
                let result: Bool
            }
        }
        
        enum DocumentPermission {
            
            struct Request: Action {}
            
            struct Response: Action {}
            
        }
    }
}

extension Model {
    
    var cameraIsAvailable: Bool { cameraAgent.isCameraAvailable }
    var galleryIsAvailable: Bool { imageGalleryAgent.isGalleryAvailable }
    
    func handleMediaCameraPermissionStatusRequest() {
            
        cameraAgent.requestPermissions { result in
            self.action.send(ModelAction.Media.CameraPermission.Response(result: result))
        }
    }
    
    func handleMediaGalleryPermissionStatusRequest() {
            
        imageGalleryAgent.requestPermissions { result in
            self.action.send(ModelAction.Media.GalleryPermission.Response(result: result))
        }
    }
    
    func handleMediaDocumentPermissionStatusRequest() {
        
            self.action.send(ModelAction.Media.DocumentPermission.Response())
    }
}
