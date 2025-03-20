//
//  CloseAccountPayload.swift
//  Vortex
//
//  Created by Andryusina Nataly on 19.03.2025.
//

struct CloseAccountPayload {
    
    let flag: ProcessingFlag
    let payload: Payload
    
    struct Payload {
        
        let balance: Double
        let currency: Currency
        let productDataID: Int
        let transferData: CloseProductTransferData
    }
}

