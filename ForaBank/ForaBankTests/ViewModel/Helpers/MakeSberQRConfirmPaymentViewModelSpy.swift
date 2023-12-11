//
//  MakeSberQRConfirmPaymentViewModelSpy.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 05.12.2023.
//

@testable import ForaBank
import Foundation
import SberQR

final class MakeSberQRConfirmPaymentViewModelSpy {
    
    typealias Completion = CreateSberQRPaymentCompletion
    typealias Message = (URL, GetSberQRDataResponse, completion: Completion)
    
    private(set) var messages = [Message]()
    
    func make(
        _ url: URL,
        _ data: GetSberQRDataResponse,
        completion: @escaping Completion,
        pay: @escaping (SberQRConfirmPaymentState) -> Void
    ) -> SberQRConfirmPaymentViewModel {
        
        messages.append((url, data, completion))
        
        return SberQRConfirmPaymentViewModel(
            initialState: <#T##State#>,
            reduce: <#T##Reduce#>,
            scheduler: .immediate
        )
    }
    
    func complete(
        with result: CreateSberQRPaymentResult,
        at index: Int = 0
    ) {
        messages.map(\.completion)[index](result)
    }
}
