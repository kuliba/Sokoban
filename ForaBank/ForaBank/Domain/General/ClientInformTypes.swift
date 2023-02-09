//
//  ClientInformTypes.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 09.02.2023.
//

struct ClientInformStatus {
 
    var isShowNotAuthorized: Bool
    var isShowAuthorized: Bool
}

enum ClientInformDataState {

    case result(ClientInformData?)
    case notRecieved
    
    var data: ClientInformData? {
        
        switch self {
        case .result(let data): return data
        default: return nil
        }
    }
    
    var isRecieved: Bool {
        
        switch self {
        case .result: return true
        case .notRecieved: return false
        }
    }
}
