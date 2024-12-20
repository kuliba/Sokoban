//
//  PinLoader.swift
//  
//
//  Created by Igor Malyarov on 16.07.2023.
//

public protocol PinLoader {
    
    typealias GetPinResult = Result<String, Error>
    typealias GetPinCompletion = (GetPinResult) -> Void
    
    func getPin(completion: @escaping GetPinCompletion)
}
