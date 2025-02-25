//
//  RootViewModelFactory+makeOperationDetailFactory.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.02.2025.
//

import Foundation

extension RootViewModelFactory {
    
    func makeOperationDetailFactory() -> OperationDetailFactory {
        
        return .init(makeOperationDetailViewModel: makeOperationDetailViewModel)
    }
    
    @inlinable
    func makeOperationDetailViewModel(
        productID: ProductData.ID,
        productStatementID: ProductStatementData.ID
    ) -> OperationDetailFactory.OperationDetail? {
        
        guard let (statement, product) = model.nonFinanceStatementsWithProductData(
            for: productID,
            and: productStatementID
        ) else { return nil }
        
        switch statement.paymentDetailType {
        case .c2gPayment:
            guard let details = makeOperationDetail(product, statement)
            else { return nil }
            
            details.event(.load)
            
            let content = StatementDetails.Content(
                logo: statement.md5hash,
                name: statement.fastPayment?.foreignName
            )
            
            return .v3(.init(content: content, details: details))
            
        default:
            return .legacy(.init(
                productStatement: statement,
                product: product,
                updateFastAll: { [weak self] in
                    
                    self?.model.action.send(ModelAction.Products.Update.Fast.All())
                },
                model: model
            ))
        }
    }
    
    @inlinable
    func makeOperationDetail(
        _ product: ProductData,
        _ statement: ProductStatementData
    ) -> OperationDetailDomain.Model? {
        
        let formattedAmount = format(
            amount: statement.amount,
            currencyCodeNumeric: statement.currencyCodeNumeric
        )
        let dateString = DateFormatter.operation.string(from: statement.tranDate ?? statement.date) // TODO: - improve: such formatting should be injected (copy from OperationDetailInfoViewModel.swift:100)
        
        guard let product = productSelectProduct(for: product),
              let digest = statement.digest(
                formattedAmount: formattedAmount,
                formattedDate: dateString,
                product: product
              )
        else { return nil }
        
        return makeOperationDetail(digest: digest)
    }
}

// MARK: - Adapters

extension ProductStatementData {
    
    func digest(
        formattedAmount: String?,
        formattedDate: String?,
        product: OperationDetailDomain.Product
    ) -> OperationDetailDomain.StatementDigest? {
        
        guard let documentId else { return nil }
        
        return .init(
            documentID: "\(documentId)",
            product: product,
            formattedAmount: formattedAmount,
            formattedDate: formattedDate,
            dateN: dateN,
            discount: discount,
            discountExpiry: discountExpiry,
            legalAct: legalAct,
            paymentTerm: paymentTerm,
            realPayerFIO: realPayerFIO,
            realPayerINN: realPayerINN,
            realPayerKPP: realPayerKPP,
            supplierBillID: supplierBillID,
            transAmm: transAmm,
            upno: upno
        )
    }
}

// MARK: - Helpers

extension Model {
    
    func nonFinanceStatementsWithProductData(
        for productID: ProductData.ID,
        and statementID: ProductStatementData.ID
    ) -> (ProductStatementData, ProductData)? {
        
        guard let statements = latestStatements(for: productID, and: statementID),
              statements.paymentDetailType != .notFinance,
              let productData = productData(for: productID)
        else { return nil }
        
        return (statements, productData)
    }
    
    func latestStatements(
        for productID: ProductData.ID,
        and statementID: ProductStatementData.ID
    ) -> ProductStatementData? {
        
        statements.value[productID]?.latest(for: productID, and: statementID)
    }
    
    func productData(
        for productID: ProductData.ID
    ) -> ProductData? {
        
        return products.value.values
            .flatMap { $0 }
            .first { $0.id == productID }
    }
}

extension ProductStatementsStorage {
    
    func latest(
        for productID: ProductData.ID,
        and statementID: ProductStatementData.ID
    ) -> ProductStatementData? {
        
        return statements
            .filter { $0.operationId == statementID }
            .sorted { ($0.tranDate ?? $0.date) > ($1.tranDate ?? $1.date) }
            .first
    }
}

private extension String {
    
    static let c2gPayment: Self = "C2G_PAYMENT"
}
