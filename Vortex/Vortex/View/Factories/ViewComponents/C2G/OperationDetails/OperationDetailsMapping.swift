//
//  OperationDetailsMapping.swift
//  Vortex
//
//  Created by Igor Malyarov on 20.02.2025.
//

import SwiftUI
import UIPrimitives

// MARK: - Transaction Details

extension OperationDetailDomain.State.Details: TransactionDetailsProviding {
    
    var transactionDetails: [DetailsCell] {
        
        return [
            transAmmField.map(DetailsCell.field),
            discountField.map(DetailsCell.field),
            discountExpiryField.map(DetailsCell.field),
            formattedAmountField.map(DetailsCell.field),
            dateForDetailField.map(DetailsCell.field),
            statusField.map(DetailsCell.field),
            .product(product.cellProduct),
            payeeFullNameField.map(DetailsCell.field),
            supplierBillIDField.map(DetailsCell.field),
            commentField.map(DetailsCell.field),
            realPayerFIOField.map(DetailsCell.field),
            realPayerINNField.map(DetailsCell.field),
            realPayerKPPField.map(DetailsCell.field),
            dateNField.map(DetailsCell.field),
            paymentTermField.map(DetailsCell.field),
            legalActField.map(DetailsCell.field),
            upnoField.map(DetailsCell.field),
            transferNumberField.map(DetailsCell.field),
        ].compactMap { $0 }
    }
}

// MARK: - Payment Requisites

extension OperationDetailDomain.State.Details: PaymentRequisitesProviding {
    
    var paymentRequisites: [DetailsCell.Field] {
        
        return [
            dateForDetailField,
            realPayerFIOField,
            payeeFullNameField,
            supplierBillIDField,
            commentField,
            realPayerINNField,
            realPayerKPPField,
            dateNField,
            paymentTermField,
            legalActField,
            transAmmField,
            discountField,
            discountExpiryField,
            formattedAmountField,
            upnoField,
            transferNumberField,
        ].compactMap { $0 }
    }
    
    // TODO: extract titles to static strings in fileprivate scape
    
    private var statusField: DetailsCell.Field? {
        
        .init(image: status.image, isLarge: true, title: "Статус операции", value: status.title)
        
    }
    
    private var dateForDetailField: DetailsCell.Field? {
        
        dateForDetail.map {
            
            .init(image: .ic24Calendar, title: "Дата и время операции (МСК)", value: $0)
        }
    }
    
    private var realPayerFIOField: DetailsCell.Field? {
        
        realPayerFIO.map {
            
            .init(image: .ic24User, title: "Информация о плательщике", value: $0)
        }
    }
    
    private var payeeFullNameField: DetailsCell.Field? {
        
        payeeFullName.map {
            
            .init(image: .ic24Bank, title: "Получатель", value: $0)
        }
    }
    
    private var supplierBillIDField: DetailsCell.Field? {
        
        supplierBillID.map {
            
            .init(image: .ic24File, title: "Номер документа (УИН)", value: $0)
        }
    }
    
    private var commentField: DetailsCell.Field? {
        
        comment.map {
            
            .init(image: .ic24Tax, title: "Назначение платежа", value: $0)
        }
    }
    
    private var realPayerINNField: DetailsCell.Field? {
        
        realPayerINN.map {
            
            .init(image: .ic24FileHash, title: "ИНН плательщика", value: $0)
        }
    }
    
    private var realPayerKPPField: DetailsCell.Field? {
        
        realPayerKPP.map {
            
            .init(image: .ic24Hash, title: "КПП плательщика", value: $0)
        }
    }
    
    private var dateNField: DetailsCell.Field? {
        
        dateN.map {
            
            .init(image: .ic24Calendar, title: "Дата начисления", value: $0)
        }
    }
    
    private var paymentTermField: DetailsCell.Field? {
        
        paymentTerm.map {
            
            .init(image: .ic24CalendarPayment, title: "Срок оплаты", value: $0)
        }
    }
    
    private var legalActField: DetailsCell.Field? {
        
        legalAct.map {
            
            .init(image: .ic24FileText, title: "Информация о НПА", value: $0)
        }
    }
    
    private var transAmmField: DetailsCell.Field? {
        
        transAmm.map {
            
            .init(image: .ic24Cash, title: "Сумма начисления", value: $0)
        }
    }
    
    private var discountField: DetailsCell.Field? {
        
        discount.map {
            
            .init(image: .ic24Percent, title: "Скидка", value: $0)
        }
    }
    
    private var discountExpiryField: DetailsCell.Field? {
        
        discountExpiry.map {
            
            .init(image: .ic24Clock, title: "Срок действия скидки", value: $0)
        }
    }
    
    private var formattedAmountField: DetailsCell.Field? {
        
        formattedAmount.map {
            
            .init(image: .ic24Coins, title: "Сумма платежа", value: $0)
        }
    }
    
    private var upnoField: DetailsCell.Field? {
        
        upno.map {
            
            .init(image: .ic24FileHash, title: "УПНО", value: $0)
        }
    }
    
    private var transferNumberField: DetailsCell.Field? {
        
        transferNumber.map {
            
            .init(image: .ic24Hash, title: "Идентификатор операции СБП", value: $0)
        }
    }
}

private extension OperationDetailDomain.State.Status {
    
    var image: Image {
        
        switch self {
        case .completed: return .init("OkOperators")
        case .inflight:  return .ic16Waiting
        case .rejected:  return .ic16Denied
        }
    }
    
    var title: String {
        
        switch self {
        case .completed: return "Успешно"
        case .inflight:  return "В обработке"
        case .rejected:  return "Отказ"
        }
    }
}

// MARK: - Short Transaction Details

extension OperationDetailDomain.State.EnhancedResponse: TransactionDetailsProviding {
    
    var transactionDetails: [DetailsCell] {
        
        return [
            productCell,
            formattedAmountField.map(DetailsCell.field),
            formattedDateField.map(DetailsCell.field),
        ].compactMap { $0 }
    }
    
    private var productCell: DetailsCell {
        
        .product(product.cellProduct)
    }
    
    private var formattedAmountField: DetailsCell.Field? {
        
        formattedAmount.map {
            
            .init(image: .ic24Coins, title: "Сумма платежа", value: $0)
        }
    }
    
    private var formattedDateField: DetailsCell.Field? {
        
        formattedDate.map {
            
            .init(image: .ic24Calendar, title: "Дата и время операции (МСК)", value: $0)
        }
    }
}

extension OperationDetailDomain.State.Product {
    
    var cellProduct: DetailsCell.Product {
        
        return .init(title: header, icon: look.icon.image, name: title, formattedBalance: amountFormatted, description: number)
    }
}
