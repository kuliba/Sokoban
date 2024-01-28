//
//  ActiveContractView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 12.01.2024.
//

import FastPaymentsSettings
import PaymentComponents
import SwiftUI

struct ActiveContractView: View {
    
    let contractDetails: UserPaymentSettings.Details
    let event: (FastPaymentsSettingsEvent) -> Void
    let config: ActiveContractConfig
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack {
                
                Group {
                    
                    PaymentContractView(
                        paymentContract: contractDetails.paymentContract,
                        action: { event(.contract(.deactivateContract)) }
                    )
                    
                    BankDefaultView(
                        bankDefault: contractDetails.bankDefaultResponse.bankDefault,
                        action: { event(.bankDefault(.setBankDefault)) }
                    )
                    
                    ConsentListView(
                        state: contractDetails.consentList.uiState,
                        event: { event(.consentList($0)) }
                    )
                    
                    ProductSelectView(
                        state: contractDetails.productSelect,
                        event: { event(.products($0.productSelect)) },
                        config: config.productSelect
                    ) {
                        ProductCardView(
                            productCard: .init(product: $0),
                            config: config.productSelect.card.productCardConfig
                        )
                    }
                    
                    AccountLinkingSettingsButton(action: { event(.subscription(.getC2BSubButtonTapped)) })
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Adapters

private extension Product {
    
    var product: ProductSelect.Product {
        
        .init(
            id: .init(id.rawValue),
            type: type.productSelectProductType,
            header: header,
            title: title,
            footer: number,
            amountFormatted: amountFormatted,
            balance: balance,
            look: look.productSelectProductLook
        )
    }
}

private extension Product.Look {
    
    var productSelectProductLook: ProductSelect.Product.Look {
        
        .init(
            background: background.productSelectIcon,
            color: color,
            icon: icon.productSelectIcon
        )
    }
}

private extension Product.Look.Icon {
    
    var productSelectIcon: Icon {
        
        switch self {
        case let .svg(svg): return .svg(svg)
        }
    }
}

private extension Product.ProductType {
    
    var productSelectProductType: ProductSelect.Product.ProductType {
        
        switch self {
        case .account: return  .account
        case .card:    return  .card
        }
    }
}

private extension UserPaymentSettings.Details {
    
    var productSelect: ProductSelect {
        
        .init(
            selected: productSelector.productSelectSelected,
            products: productSelector.productSelectProducts
        )
    }
}

private extension UserPaymentSettings.ProductSelector {
    
    var productSelectSelected: ProductSelect.Product? {
        
        selectedProduct.map(\.product)
    }
    
    var productSelectProducts: ProductSelect.Products? {
        
        switch status {
        case .collapsed:
            return nil
            
        case .expanded:
            return products.map(\.product)
        }
    }
}

private extension ProductSelectEvent {
    
    var productSelect: ProductsEvent {
        
        switch self {
        case .toggleProductSelect:
            return .toggleProducts
            
        case let .select(id):
            return .selectProduct(.init(id.rawValue))
        }
    }
}

// MARK: - Previews

struct ActiveContractView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            activeContractView(.preview(paymentContract: .active))
        }
    }
    
    private static func activeContractView(
        _ contractDetails: UserPaymentSettings.Details
    ) -> some View {
        
        ActiveContractView(
            contractDetails: contractDetails,
            event: { _ in },
            config: .preview
        )
    }
}
