//
//  CameraAgentMock.swift
//  ForaBank
//
//  Created by Mikhail on 30.06.2022.
//

import Foundation

class CameraAgentMock: CameraAgentProtocol {
    
    var isCameraAvailable: Bool = true
    
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        return completion(false)
    }
    
}
