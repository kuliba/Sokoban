//
//  PrepaymentPickerEffect.swift
//
//
//  Created by Igor Malyarov on 12.05.2024.
//

public enum PrepaymentPickerEffect<OperatorID> {
    
    case paginate(PaginatePayload)
}

extension PrepaymentPickerEffect {
    
    public struct PaginatePayload {
        
        public let operatorID: OperatorID?
        public let pageSize: PageSize
        public let searchText: String
        
        public init(
            operatorID: OperatorID?,
            pageSize: PageSize,
            searchText: String
        ) {
            self.operatorID = operatorID
            self.pageSize = pageSize
            self.searchText = searchText
        }
        
        public typealias PageSize = Int
    }
}

extension PrepaymentPickerEffect: Equatable where OperatorID: Equatable {}
extension PrepaymentPickerEffect.PaginatePayload: Equatable where OperatorID: Equatable {}
