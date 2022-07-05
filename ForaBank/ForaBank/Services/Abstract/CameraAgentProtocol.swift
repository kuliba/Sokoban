//
//  CameraAgentProtocol.swift
//  ForaBank
//
//  Created by Mikhail on 29.06.2022.
//

import Foundation

protocol CameraAgentProtocol {
    
    var isCameraAvailable: Bool { get }
    
    func requestPermissions(completion: @escaping (Bool) -> Void )
}
