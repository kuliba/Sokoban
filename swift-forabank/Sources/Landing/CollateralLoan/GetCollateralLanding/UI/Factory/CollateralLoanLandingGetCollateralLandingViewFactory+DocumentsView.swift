//
//  CollateralLoanLandingGetCollateralLandingViewFactory+DocumentsView.swift
//  
//
//  Created by Valentin Ozerov on 10.12.2024.
//

extension CollateralLoanLandingGetCollateralLandingViewFactory {
    
    func makeDocumentsView(with product: GetCollateralLandingProduct)
        -> CollateralLoanLandingGetCollateralLandingDocumentsView? {

            guard
                !product.documents.isEmpty
            else { return nil }
            
            return .init(
                config: config,
                theme: product.theme.map(),
                documents: product.documents
            )
    }
}
