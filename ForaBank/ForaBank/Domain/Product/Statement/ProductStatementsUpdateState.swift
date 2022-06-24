//
//  ProductStatementsUpdateState.swift
//  ForaBank
//
//  Created by Max Gribov on 08.06.2022.
//

import Foundation

enum ProductStatementsUpdateState {
    
    case idle
    case downloading(Period.Direction)
    case failed
    
    var isDownloadActive: Bool {
        
        switch self {
        case .downloading: return true
        default: return false
        }
    }
}
