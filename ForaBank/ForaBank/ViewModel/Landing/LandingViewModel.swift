//
//  LandingViewModel.swift
//  Vortex
//
//  Created by Andryusina Nataly on 11.09.2023.
//

import Foundation
import LandingMapping
import CodableLanding

final class LandingViewModel {
    
    typealias Payload = (serial: String, abroadType: AbroadType)
    typealias Process = (Payload) -> Void
    
    private let abroadType: AbroadType
    
    private let process: Process
    
    init(
        abroadType: AbroadType,
        process: @escaping Process
    ) {
        self.abroadType = abroadType
        self.process = process
    }
}


