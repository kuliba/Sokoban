//
//  ActiveContractView.swift
//
//
//  Created by Igor Malyarov on 12.01.2024.
//

import PaymentComponents
import SwiftUI
import UIPrimitives

struct ActiveContractView: View {
    
    let contractDetails: UserPaymentSettings.Details
    let event: (FastPaymentsSettingsEvent) -> Void
    let config: ActiveContractConfig
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack {
                
                Group(content: content)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(config.backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        Group {
            
            PaymentContractView(
                paymentContract: contractDetails.paymentContract,
                action: { event(.contract(.deactivateContract)) },
                config: config.paymentContract
            )
            
            BankDefaultView(
                bankDefault: contractDetails.bankDefaultResponse.bankDefault,
                action: { event(.bankDefault(.setBankDefault)) },
                config: config.bankDefault
            )
            
            ConsentListView(
                state: contractDetails.consentList.uiState,
                event: { event(.consentList($0)) },
                config: config.consentList
            )
        }
        .padding()
        
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
    }
}

// MARK: - Adapters

private extension Product {
    
    var product: ProductSelect.Product {
        
        .init(
            id: productSelectProductID,
            type: productSelectProductType,
            header: header,
            title: title,
            footer: number,
            amountFormatted: amountFormatted,
            balance: balance,
            look: look.productSelectProductLook
        )
    }
    
    private var productSelectProductID: ProductSelect.Product.ID {
        
        switch id {
        case let .account(accountID):
            return .init(accountID.rawValue)
            
        case let .card(cardID, _):
            return .init(cardID.rawValue)
        }
    }
    
    private var productSelectProductType: ProductSelect.Product.ProductType {
        
        switch id {
        case .account:
            return .account
            
        case .card:
            return .card
        }
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
        case let .image(image): return .image(image)
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
            
        case let .select(product):
            return .selectProduct(product.productID)
        }
    }
}

private extension ProductSelect.Product {
    
    var productID: SelectableProductID {
        
        switch type {
        case .account:
            return .account(.init(id.rawValue))
            
        case .card:
            return .card(.init(id.rawValue))
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
