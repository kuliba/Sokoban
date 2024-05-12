//
//  PrepaymentPickerEffect.swift
//  
//
//  Created by Igor Malyarov on 12.05.2024.
//

#warning("move to `Domain`")
enum PrepaymentPickerEffect<OperatorID> {
    
    case paginate(OperatorID, PageSize)
}

extension PrepaymentPickerEffect {
    
    typealias PageSize = Int
}

extension PrepaymentPickerEffect: Equatable where OperatorID: Equatable {}
