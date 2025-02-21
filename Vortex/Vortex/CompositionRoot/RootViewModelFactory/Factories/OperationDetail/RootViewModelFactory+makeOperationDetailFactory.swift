//
//  RootViewModelFactory+makeOperationDetailFactory.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.02.2025.
//

extension RootViewModelFactory {
    
    func makeOperationDetailFactory() -> OperationDetailFactory {
        
        return .init(makeOperationDetailViewModel: makeOperationDetailViewModel)
    }
    
    func makeOperationDetailViewModel(
        productID: ProductData.ID,
        productStatementID: ProductStatementData.ID
    ) -> OperationDetailFactory.OperationDetail? {
        
        guard let (statementData, productData) = model.nonFinanceStatementsWithProductData(
            for: productID,
            and: productStatementID
        ) else { return nil }
        
        switch statementData.paymentDetailType {
        case "C2G_PAYMENT": // extract to String private static let
            return .v3("C2G_PAYMENT")
            
        default:
            return .legacy(.init(
                productStatement: statementData,
                product: productData,
                updateFastAll: { [weak self] in
                    
                    self?.model.action.send(ModelAction.Products.Update.Fast.All())
                },
                model: model
            ))
        }
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
