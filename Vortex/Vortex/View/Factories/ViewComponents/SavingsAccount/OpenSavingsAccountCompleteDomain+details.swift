//
//  OpenSavingsAccountCompleteDomain+details.swift
//  Vortex
//
//  Created by Andryusina Nataly on 28.02.2025.
//

import SwiftUI
import UIPrimitives

// MARK: - Transaction Details

extension OperationDetailDomain.Product {
    
    var cellProductWithTitle: DetailsCell.Product {
        
        return .init(title: header, icon: look.icon.image, name: title, formattedBalance: amountFormatted, description: "∙ " + number + "  ∙ " + title)
    }
}

extension OpenSavingsAccountCompleteDomain.Details: TransactionDetailsProviding {
    
    var transactionDetails: [DetailsCell] {
        
        return [
            accountProductField.asField,
            product.map { .product($0.cellProductWithTitle) },
            formattedAmountField.asField,
            formattedFeeField.asField,
            dateForDetailField.asField,
        ].compactMap { $0 }
    }
    
    private var accountProductField: DetailsCell.Product? {
        
        payeeAccountNumber.map {
             .init(title: .accountTitle, icon: .ic32AccountsRub, name: .accountName, formattedBalance: formattedAmount ?? "", description: $0)
        }
    }

    private var dateForDetailField: DetailsCell.Field? {
        
        if (product != nil) {
            return dataForDetails.map {
                .init(image: .ic24Calendar, title: .dateForDetail, value: $0)
            }
        }
        return nil
    }
    
    private var formattedAmountField: DetailsCell.Field? {
        
        formattedAmount.map {
            
            .init(image: .ic24Coins, title: .formattedAmount, value: $0)
        }
    }
    
    private var formattedFeeField: DetailsCell.Field? {
        
        formattedFee.map {
            
            .init(image: percent(), title: .formattedFee, value: $0)
        }
    }
    
    private func percent() -> Image {
        
        coloredImage(named: "ic24PercentCommission", color: .textPlaceholder)
    }
    
    func coloredImage(named imageName: String, color: Color) -> Image {
        
        guard let uiImage = UIImage(named: imageName) else { return Image(imageName) }

        let uiColor = UIColor(color)
        let renderer = UIGraphicsImageRenderer(size: uiImage.size)
        let newUIImage = renderer.image { context in
            let rect = CGRect(origin: .zero, size: uiImage.size)
            
            uiColor.setFill()
            context.fill(rect)
            
            uiImage.draw(in: rect, blendMode: .destinationIn, alpha: 1.0)
        }
        
        return Image(uiImage: newUIImage)
    }
}

private extension Optional where Wrapped == DetailsCell.Field {
    
    var asField: DetailsCell? { map(DetailsCell.field) }
}

private extension Optional where Wrapped == DetailsCell.Product {
    
    var asField: DetailsCell? { map(DetailsCell.product) }
}

private extension String {
    
    static let accountTitle = "Открытый счет"
    static let accountName = "Накопительный"
    static let productFrom = "Счет списания"
    static let formattedAmount = "Сумма пополнения"
    static let formattedFee = "Комиссия"
    static let dateForDetail = "Дата и время операции (МСК)"
    static let dateForDetailShort = "Дата операции (МСК)"
}
