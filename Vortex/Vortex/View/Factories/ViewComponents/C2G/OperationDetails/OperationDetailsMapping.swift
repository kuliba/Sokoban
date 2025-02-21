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
            transAmmField.asField,
            discountField.asField,
            discountExpiryField.asField,
            formattedAmountField.asField,
            dateForDetailField.asField,
            statusField.asField,
            .product(product.cellProduct),
            payeeFullNameField.asField,
            supplierBillIDField.asField,
            commentField.asField,
            realPayerFIOField.asField,
            realPayerINNField.asField,
            realPayerKPPField.asField,
            dateNField.asField,
            paymentTermField.asField,
            legalActField.asField,
            upnoField.asField,
            transferNumberField.asField,
        ].compactMap { $0 }
    }
}

private extension Optional where Wrapped == DetailsCell.Field {
    
    var asField: DetailsCell? { map(DetailsCell.field) }
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
        
        .init(image: status.image, isLarge: true, title: .status, value: status.title)
        
    }
    
    private var dateForDetailField: DetailsCell.Field? {
        
        dateForDetail.map {
            
            .init(image: .ic24Calendar, title: .dateForDetail, value: $0)
        }
    }
    
    private var realPayerFIOField: DetailsCell.Field? {
        
        realPayerFIO.map {
            
            .init(image: .ic24User, title: .realPayerFIO, value: $0)
        }
    }
    
    private var payeeFullNameField: DetailsCell.Field? {
        
        payeeFullName.map {
            
            .init(image: .ic24Bank, title: .payeeFullName, value: $0)
        }
    }
    
    private var supplierBillIDField: DetailsCell.Field? {
        
        supplierBillID.map {
            
            .init(image: .ic24File, title: .supplierBillID, value: $0)
        }
    }
    
    private var commentField: DetailsCell.Field? {
        
        comment.map {
            
            .init(image: .ic24Tax, title: .comment, value: $0)
        }
    }
    
    private var realPayerINNField: DetailsCell.Field? {
        
        realPayerINN.map {
            
            .init(image: .ic24FileHash, title: .realPayerINN, value: $0)
        }
    }
    
    private var realPayerKPPField: DetailsCell.Field? {
        
        realPayerKPP.map {
            
            .init(image: .ic24Hash, title: .realPayerKPP, value: $0)
        }
    }
    
    private var dateNField: DetailsCell.Field? {
        
        dateN.map {
            
            .init(image: .ic24Calendar, title: .dateNField, value: $0)
        }
    }
    
    private var paymentTermField: DetailsCell.Field? {
        
        paymentTerm.map {
            
            .init(image: .ic24CalendarPayment, title: .paymentTerm, value: $0)
        }
    }
    
    private var legalActField: DetailsCell.Field? {
        
        legalAct.map {
            
            .init(image: .ic24FileText, title: .legalAct, value: $0)
        }
    }
    
    private var transAmmField: DetailsCell.Field? {
        
        transAmm.map {
            
            .init(image: .ic24Cash, title: .transAmm, value: $0)
        }
    }
    
    private var discountField: DetailsCell.Field? {
        
        discount.map {
            
            .init(image: .ic24Percent, title: .discount, value: $0)
        }
    }
    
    private var discountExpiryField: DetailsCell.Field? {
        
        discountExpiry.map {
            
            .init(image: .ic24Clock, title: .discountExpiry, value: $0)
        }
    }
    
    private var formattedAmountField: DetailsCell.Field? {
        
        formattedAmount.map {
            
            .init(image: .ic24Coins, title: .formattedAmount, value: $0)
        }
    }
    
    private var upnoField: DetailsCell.Field? {
        
        upno.map {
            
            .init(image: .ic24FileHash, title: .upno, value: $0)
        }
    }
    
    private var transferNumberField: DetailsCell.Field? {
        
        transferNumber.map {
            
            .init(image: .ic24Hash, title: .transferNumber, value: $0)
        }
    }
}

private extension String {
    
    static let comment = "Назначение платежа"
    static let dateForDetail = "Дата и время операции (МСК)"
    static let dateNField = "Дата начисления"
    static let discount = "Скидка"
    static let discountExpiry = "Срок действия скидки"
    static let formattedAmount = "Сумма платежа"
    static let legalAct = "Информация о НПА"
    static let payeeFullName = "Получатель"
    static let paymentTerm = "Срок оплаты"
    static let realPayerFIO = "Информация о плательщике"
    static let realPayerINN = "ИНН плательщика"
    static let realPayerKPP = "КПП плательщика"
    static let status = "Статус операции"
    static let supplierBillID = "Номер документа (УИН)"
    static let transAmm = "Сумма начисления"
    static let transferNumber = "Идентификатор операции СБП"
    static let upno = "УПНО"
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
