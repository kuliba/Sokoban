//
//  OperationDetailsMapping.swift
//  Vortex
//
//  Created by Igor Malyarov on 20.02.2025.
//

import UIPrimitives

// MARK: - Transaction Details

extension OperationDetailDomain.State.Details: TransactionDetailsProviding {
    
    var transactionDetails: [DetailsCell] {
        
        return [
            .field(.init(image: .ic16Tv, title: "Sample title", value: "Sample value"))
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
            
            .init(image: .ic24Bank, title: "Информация о плательщике", value: $0)
        }
    }
    
    private var supplierBillIDField: DetailsCell.Field? {
        
        supplierBillID.map {
         
            .init(image: .ic24File, title: "Номер документа (УИН)", value: $0)
        }
    }
    
    private var commentField: DetailsCell.Field? {
        
        comment.map {
         
            .init(image: .ic24Tax, title: "Номер документа (УИН)", value: $0)
        }
    }
    
    private var realPayerINNField: DetailsCell.Field? {
        
        realPayerINN.map {
         
            .init(image: .ic24FileHash, title: "Номер документа (УИН)", value: $0)
        }
    }
    
    private var realPayerKPPField: DetailsCell.Field? {
        
        realPayerKPP.map {
         
            .init(image: .ic24Hash, title: "Номер документа (УИН)", value: $0)
        }
    }
    
    private var dateNField: DetailsCell.Field? {
        
        dateN.map {
         
            .init(image: .ic24Calendar, title: "Номер документа (УИН)", value: $0)
        }
    }
    
    private var paymentTermField: DetailsCell.Field? {
        
        paymentTerm.map {
         
            .init(image: .ic24CalendarPayment, title: "Номер документа (УИН)", value: $0)
        }
    }
    
    private var legalActField: DetailsCell.Field? {
        
        legalAct.map {
         
            .init(image: .ic24FileText, title: "Номер документа (УИН)", value: $0)
        }
    }
    
    private var transAmmField: DetailsCell.Field? {
        
        transAmm.map {
         
            .init(image: .ic24Cash, title: "Номер документа (УИН)", value: $0)
        }
    }
    
    private var discountField: DetailsCell.Field? {
        
        discount.map {
         
            .init(image: .ic24Percent, title: "Номер документа (УИН)", value: $0)
        }
    }
    
    private var discountExpiryField: DetailsCell.Field? {
        
        discountExpiry.map {
         
            .init(image: .ic24Clock, title: "Номер документа (УИН)", value: $0)
        }
    }
    
    private var formattedAmountField: DetailsCell.Field? {
        
        formattedAmount.map {
         
            .init(image: .ic24Coins, title: "Номер документа (УИН)", value: $0)
        }
    }
    
    private var upnoField: DetailsCell.Field? {
        
        upno.map {
         
            .init(image: .ic24FileHash, title: "Номер документа (УИН)", value: $0)
        }
    }
    
    private var transferNumberField: DetailsCell.Field? {
        
        transferNumber.map {
         
            .init(image: .ic24Hash, title: "Номер документа (УИН)", value: $0)
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
        
        .product(.init(title: "Счет списания"))
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
