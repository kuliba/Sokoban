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
    ) -> OperationDetailViewModel? {
        
        guard let (statementData, productData) = model.statementsWithProductData(
            for: productID,
            and: productStatementID
        ) else { return nil }
        
        return .init(
            productStatement: statementData,
            product: productData,
            updateFastAll: { [weak self] in
                
                self?.model.action.send(ModelAction.Products.Update.Fast.All())
            },
            model: model
        )
    }
}

// MARK: - Helpers

extension Model {
    
    func statementsWithProductData(
        for productID: ProductData.ID,
        and statementID: ProductStatementData.ID
    ) -> (ProductStatementData, ProductData)? {
        
        guard let storage = statements.value[productID],
              let statements = storage.statements
            .filter({ $0.operationId == statementID })
            .sorted(by: { ($0.tranDate ?? $0.date) > ($1.tranDate ?? $1.date) })
            .first,
              statements.paymentDetailType != .notFinance,
              let productData = products.value.values
            .flatMap({ $0 })
            .first(where: { $0.id == productID })
        else { return nil }
        
        return (statements, productData)
    }
}
