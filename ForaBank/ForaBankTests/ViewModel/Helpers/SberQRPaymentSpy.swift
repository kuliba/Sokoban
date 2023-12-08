//
//  SberQRPaymentSpy.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 05.12.2023.
//

@testable import ForaBank
import Foundation
import SberQR

final class SberQRPaymentSpy {
    
    typealias Completion = MakeSberQRPaymentCompletion
    typealias Message = (URL, GetSberQRDataResponse, completion: Completion)
    
    private(set) var messages = [Message]()
    
    func make(
    _ url: URL,
    _ data: GetSberQRDataResponse,
    completion: @escaping MakeSberQRPaymentCompletion
    ) -> ForaBank.SberQRConfirmPaymentViewModel {
        
        messages.append((url, data, completion))
        
        return SberQRConfirmPaymentViewModel(sberQRURL: url, sberQRData: data, commit: completion)
    }
    
    func complete(
        with result: Result<Data, Error>,
        at index: Int = 0
    ) {
        messages.map(\.completion)[index](result)
    }
}
