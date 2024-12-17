//
//  ServerCommandMediaParameter.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.09.2023.
//

import Foundation

public struct ServerCommandMediaParameter {
    
    let fileName: String
    let data: Data
    let mimeType: String
    
    public init(
        fileName: String, 
        data: Data, 
        mimeType: String
    ) {
        self.fileName = fileName
        self.data = data
        self.mimeType = mimeType
    }
}
