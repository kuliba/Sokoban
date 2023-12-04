//
//  SberQRFeatureState.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

enum SberQRFeatureState: Equatable {
    
    case loading
    case getSberQRDataResponse(GetSberQRDataResponse)
    case getSberQRDataError(GetSberQRDataError)
}
