//
//  SberQRFeatureState.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

public enum SberQRFeatureState: Equatable {
    
    case loading
    case getSberQRDataResponse(GetSberQRDataResponse)
    case getSberQRDataError(MappingError)
}
