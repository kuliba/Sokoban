//
//  InitiateAnywayPaymentMicroServiceIntegrationTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 11.08.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import RemoteServices

final class InitiateAnywayPaymentMicroServiceComposer {
    
    private let getOutlineProduct: GetOutlineProduct
    private let processPayload: ProcessPayload
    
    init(
        getOutlineProduct: @escaping GetOutlineProduct,
        processPayload: @escaping ProcessPayload
    ) {
        self.getOutlineProduct = getOutlineProduct
        self.processPayload = processPayload
    }
    
    typealias GetOutlineProduct = AnywayPaymentSourceParser.GetOutlineProduct
    typealias ProcessPayload = MicroService.ProcessPayload
    
    typealias MicroService = InitiateAnywayPaymentMicroService<AnywayPaymentSourceParser.Source, AnywayPaymentSourceParser.Output, RemoteServices.ResponseMapper.CreateAnywayTransferResponse, AnywayTransactionState.Transaction>
}

extension InitiateAnywayPaymentMicroServiceComposer {
    
    func compose() -> MicroService {
        
        let sourceParser = AnywayPaymentSourceParser(
            getOutlineProduct: getOutlineProduct
        )
        let validator = AnywayPaymentContextValidator()
        let transactionComposer = InitialAnywayTransactionComposer(
            isValid: { validator.validate($0) == nil }
        )
        
        return .init(
            parseSource: sourceParser.parse,
            processPayload: processPayload,
            initiateTransaction: transactionComposer.compose
        )
    }
}

private extension AnywayPaymentSourceParser {
    
    func parse(_ source: Source) -> Output? {
        
        try? parse(source: source)
    }
}

private extension InitialAnywayTransactionComposer {
    
    func compose(
        _ output: AnywayPaymentSourceParser.Output,
        _ response: Response
    ) -> Transaction? {
        
        let input = Input(outline: output.outline, firstField: output.firstField)
        return compose(with: input, and: response)
    }
}
