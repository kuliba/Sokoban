//
//  ProductsLandingEvent.swift
//
//
//  Created by Дмитрий Савушкин on 11.03.2025.
//

import Foundation

public enum ProductsLandingEvent<Landing> {
    
    case dismissInformer
    case load
    case loadResult(Result<Landing, LoadFailure>)
}
