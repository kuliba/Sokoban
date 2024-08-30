//
//  DetailsViewModel.swift
//  ForaBank
//
//  Created by Дмитрий on 27.12.2021.
//

import Foundation
import SwiftUI
import Combine
import PhoneNumberWrapper

final class OperationDetailInfoViewModel: Identifiable {
    
    let title = "Детали операции"
    var logo: Image?
    var cells: [DefaultCellViewModel]
    let dismissAction: () -> Void
    let model: Model
    
    typealias IconType = PropertyIconType
    
    init(
        model: Model,
        logo: Image?,
        cells: [DefaultCellViewModel],
        dismissAction: @escaping () -> Void
    ) {
        self.model = model
        self.logo = logo
        self.cells = cells
        self.dismissAction = dismissAction
    }
    
    convenience init(model: Model, operation: OperationDetailData, dismissAction: @escaping () -> Void) {
        
        let logo = Self.logo(model: model, operation: operation)
        self.init(model: model, logo: logo, cells: [], dismissAction: dismissAction)
        self.cells = makeItems(operation: operation)
    }
    
    static func logo(model: Model, operation: OperationDetailData) -> Image? {
        
        switch operation.transferEnum {
        case .sfp:
            return .ic24Sbp
            
        case .internet:
            guard let puref = operation.puref,
                  let operatorValue = model.dictionaryAnywayOperator(for: puref),
                  let image = operatorValue.iconImageData?.image else {
                
                return .ic40TvInternet
            }
            
            return image
            
        case .housingAndCommunalService:
            guard let puref = operation.puref,
                  let operatorValue = model.dictionaryAnywayOperator(for: puref),
                  let image = operatorValue.iconImageData?.image else {
                
                return .ic40ZkxServices
            }
            
            return image
            
        case .transport:
            guard let puref = operation.puref,
                  let operatorValue = model.dictionaryAnywayOperator(for: puref),
                  let image = operatorValue.iconImageData?.image else {
                
                return .ic40Transport
            }
            
            return image
            
        default:
            return nil
        }
    }
    
    init?(
        with statement: ProductStatementData,
        operation: OperationDetailData?,
        product: ProductData,
        dismissAction: @escaping () -> Void,
        model: Model
    ) {
        self.model = model
        let dateString = DateFormatter.operation.string(from: statement.tranDate ?? statement.date)
        let foraBankName = "Фора Банк"
        let foraBankIcon = Image("foraContactImage", bundle: nil)
        
        guard let currency = model.dictionaryCurrency(for: statement.currencyCodeNumeric)?.code else {
            return nil
        }
        
        self.dismissAction = dismissAction
        var logo: Image? = nil
        self.cells = [DefaultCellViewModel]()
        let bankList = Model.shared.bankList.value
        
        let dateTimeCell = PropertyCellViewModel(
            title: "Дата и время операции (МСК)",
            iconType: IconType.date.icon,
            value: dateString
        )
        
        switch statement.paymentDetailType {
            
        case .otherBank:
            if let payeeCardNumber = operation?.payeeCardNumber {
                
                cells.append(PropertyCellViewModel(
                    title: "Счет пополнения",
                    iconType: IconType.bank.icon,
                    value: payeeCardNumber))
            }
            
            if let amountCell = Self.amountCell(
                with: model,
                amount: statement.amount,
                currency: currency) {
                
                cells.append(amountCell)
            }
            
            if let fee = operation?.payerFee,
               let comissionCell = Self.commissionCell(
                with: model,
                fee: fee,
                currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let debitAccounCell = Self.accountCell(
                with: product,
                model: model,
                operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(dateTimeCell)
            
        case .betweenTheir:
            
            if let payeeCardId = operation?.payeeCardId {
                
                for i in model.products.value {
                    
                    if let card = i.value.first(where: { $0.id == payeeCardId }) {
                        
                        if let description = card.number?.suffix(4),
                           let balance = card.balance,
                           let balanceFormatted = model.amountFormatted(
                            amount: balance,
                            currencyCode: card.currency,
                            style: .clipped
                           ),
                           let icon = model.images.value[card.smallDesignMd5hash]?.image,
                           let additional = card.additionalField {
                            
                            cells.append(ProductCellViewModel(
                                title: "Счет пополнения",
                                icon: icon,
                                name: card.displayName,
                                iconPaymentService: model.images.value[card.paymentSystemMd5Hash]?.image,
                                balance: balanceFormatted,
                                description: "· \(description) · \(additional)"
                            ))
                        }
                    }
                }
            }
            
            if let amountCell = Self.amountCell(
                with: model,
                amount: statement.amount,
                currency: currency) {
                
                cells.append(amountCell)
            }
            
            if let fee = operation?.payerFee,
               let comissionCell = Self.commissionCell(
                with: model,
                fee: fee,
                currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let payerCardId = operation?.payerCardId {
                
                for i in model.products.value {
                    
                    if let card = i.value.first(where: { $0.id == payerCardId }) {
                        
                        if let description = card.number?.suffix(4),
                           let balance = card.balance,
                           let balanceFormatted = model.amountFormatted(
                            amount: balance,
                            currencyCode: card.currency,
                            style: .clipped
                           ),
                           let icon = model.images.value[card.smallDesignMd5hash]?.image,
                           let additional = card.additionalField {
                            
                            cells.append(ProductCellViewModel(
                                title: "Счет списания",
                                icon: icon,
                                name: card.displayName,
                                iconPaymentService: model.images.value[card.paymentSystemMd5Hash]?.image,
                                balance: balanceFormatted,
                                description: "· \(description) · \(additional)"
                            ))
                        }
                    }
                }
            }
            
            cells.append(dateTimeCell)
            
        case .insideBank:
            
            if let payeeAccountNumber = operation?.payeeAccountNumber {
                
                cells.append(PropertyCellViewModel(
                    title: "Номер счета получателя",
                    iconType: IconType.bank.icon,
                    value: payeeAccountNumber))
                
            } else if let payeeCardNumber = operation?.payeeCardNumber {
                
                cells.append(PropertyCellViewModel(
                    title: "Номер карты получателя",
                    iconType: IconType.bank.icon,
                    value: payeeCardNumber))
                
            } else if let payeePhone = operation?.payeePhone {
                let phoneFormatter = PhoneNumberKitFormater()
                let formattedPhone = phoneFormatter.format(payeePhone)
                cells.append(PropertyCellViewModel(
                    title: "Номер телефона получателя",
                    iconType: IconType.phone.icon,
                    value: formattedPhone))
            }
            
            cells.append(PropertyCellViewModel(
                title: "Получатель",
                iconType: IconType.user.icon,
                value: statement.merchant))
            cells.append(BankCellViewModel(
                title: "Банк получателя",
                icon:  foraBankIcon,
                name: foraBankName))
            
            if let amountCell = Self.amountCell(
                with: model,
                amount: statement.amount,
                currency: currency) {
                
                cells.append(amountCell)
            }
            
            if let fee = operation?.payerFee,
               let comissionCell = Self.commissionCell(
                with: model,
                fee: fee,
                currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let debitAccounCell = Self.accountCell(
                with: product,
                model: model,
                operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(PropertyCellViewModel(
                title: "Назначение платежа",
                iconType: IconType.purpose.icon,
                value: statement.comment))
            
            cells.append(dateTimeCell)
            
        case .contactAddressless:
            
            if let image = model.images.value[statement.md5hash]?.image {
                
                logo = image
            }
            
            cells.append(PropertyCellViewModel(
                title: "Получатель",
                iconType: IconType.user.icon,
                value: statement.merchant))
            
            if let countryName = operation?.countryName {
                
                cells.append(PropertyCellViewModel(
                    title: "Страна",
                    iconType: IconType.geo.icon,
                    value: countryName))
            }
            
            if let amountCell = Self.amountCell(
                with: model,
                amount: statement.amount,
                currency: currency) {
                
                cells.append(amountCell)
            }
            
            if let fee = operation?.payerFee,
               let comissionCell = Self.commissionCell(
                with: model,
                fee: fee,
                currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let payeeAmount = operation?.payeeAmount,
               let payeeCurrency = operation?.payeeCurrency,
               let amountCell = Self.amountCell(
                with: model,
                title: "Сумма зачисления в валюте",
                amount: payeeAmount,
                currency: payeeCurrency) {
                
                cells.append(amountCell)
            }
            
            cells.append(PropertyCellViewModel(
                title: "Способ выплаты",
                iconType: IconType.cash.icon,
                value: "Наличные"))
            
            
            if let debitAccounCell = Self.accountCell(
                with: product,
                model: model,
                operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            if let transferReference = operation?.transferReference  {
                
                cells.append(PropertyCellViewModel(
                    title: "Номер перевода",
                    iconType: IconType.operationNumber.icon,
                    value: transferReference))
            }
            
            cells.append(dateTimeCell)
            
        case .direct:
            
            let directLogoImage = Image("MigAvatar")
            logo = directLogoImage
            
            if let foreignPhoneNumber = operation?.payeePhone {
                let phoneFormatter = PhoneNumberKitFormater()
                let formattedPhone = phoneFormatter.format(foreignPhoneNumber)
                cells.append(PropertyCellViewModel(
                    title: "Номер телефона получателя",
                    iconType: IconType.phone.icon,
                    value: formattedPhone))
                
            }
            
            cells.append(PropertyCellViewModel(
                title: "Получатель",
                iconType: IconType.user.icon,
                value: statement.merchant))
            
            if let memberId = operation?.memberId,
               let bank = bankList.first(where: { $0.memberId == memberId }) {
                
                let bankLogoSVG = bank.svgImage.image
                let name = bank.memberNameRus
                guard let bankLogoImage = bankLogoSVG else { return }
                
                cells.append(BankCellViewModel(
                    title: "Банк получателя",
                    icon: bankLogoImage,
                    name: name))
            }
            
            if let countryName = operation?.countryName {
                
                cells.append(PropertyCellViewModel(
                    title: "Страна",
                    iconType: IconType.geo.icon,
                    value: countryName))
            }
            
            if let amount = operation?.amount,
               let foremattedAmount = self.model.amountFormatted(
                amount: amount,
                currencyCode: operation?.currencyAmount,
                style: .normal) {
                
                cells.append(PropertyCellViewModel.init(
                    title: "Сумма перевода",
                    iconType: IconType.balance.icon,
                    value: foremattedAmount))
            }
            
            if let fee = operation?.payerFee,
               let comissionCell = Self.commissionCell(
                with: model,
                fee: fee,
                currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let payeeAmount = operation?.payeeAmount,
               let payeeCurrency = operation?.payeeCurrency,
               let amountCell = Self.amountCell(
                with: model,
                title: "Сумма зачисления в валюте",
                amount: payeeAmount,
                currency: payeeCurrency) {
                
                cells.append(amountCell)
            }
            
            if let debitAccounCell = Self.accountCell(
                with: product,
                model: model,
                operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            if let transferReference = operation?.transferReference  {
                
                cells.append(PropertyCellViewModel(
                    title: "Номер перевода",
                    iconType: IconType.operationNumber.icon,
                    value: transferReference))
            }
            
            
            cells.append(dateTimeCell)
            
        case .externalIndivudual, .externalEntity:
            
            let amountCell = Self.amountCell(
                with: model,
                amount: statement.amount,
                currency: currency)
            
            let comissionCell = {
                if let fee = operation?.payerFee {
                    return Self.commissionCell(
                        with: model,
                        fee: fee,
                        currency: currency)
                }
                return nil
            }
            
            let debitAccounCell = Self.accountCell(
                with: product,
                model: model,
                operationType: statement.operationType)
            let type: OperationDetailData.ExternalTransferType = statement.paymentDetailType == .externalEntity ? .entity : .individual
            cells = Self.makeHistoryItemsForExternal(
                dictionaryFullBankInfoBank: model.dictionaryFullBankInfoBank,
                type,
                operation,
                amountCell,
                comissionCell(),
                debitAccounCell,
                statement.comment,
                dateString)
            
        case .insideOther:
            
            if let payeeProductId = [operation?.payeeCardId,
                                     operation?.payeeAccountId].compactMap({$0}).first {
                
                for i in model.products.value {
                    
                    if let productInfo = i.value.first(where: { $0.id == payeeProductId }) {
                        
                        if let description = productInfo.number?.suffix(4),
                           let balance = productInfo.balance,
                           let balanceFormatted = model.amountFormatted(amount: balance,
                                                                        currencyCode: productInfo.currency,
                                                                        style: .clipped),
                           let icon = model.images.value[productInfo.smallDesignMd5hash]?.image,
                           let additional = productInfo.additionalField {
                            
                            cells.append(ProductCellViewModel(
                                title: "Счет пополнения",
                                icon: icon,
                                name: productInfo.displayName,
                                iconPaymentService: model.images.value[productInfo.paymentSystemMd5Hash]?.image,
                                balance: balanceFormatted,
                                description: "· \(description) · \(additional)"
                            ))
                        }
                    }
                }
            }
            
            
            if let image = model.images.value[statement.md5hash]?.image {
                
                cells.append(BankCellViewModel(
                    title: "Наименование операции",
                    icon: image,
                    name: statement.merchant))
                
                cells.append(PropertyCellViewModel(
                    title: "Категория операции",
                    iconType: image,
                    value: statement.groupName))
            }
            
            if let amountCell = Self.amountCell(
                with: model,
                amount: statement.amount,
                currency: currency) {
                
                cells.append(amountCell)
            }
            
            
            if let fee = operation?.payerFee,
               let comissionCell = Self.commissionCell(
                with: model,
                fee: fee,
                currency: currency) {
                
                cells.append(comissionCell)
            }
            
            cells.append(dateTimeCell)
            
        case .mobile:
            
            if let image = model.images.value[statement.md5hash]?.image {
                
                logo = image
            }
            
            if let payeePhone = operation?.payeePhone?.addCodeRuIfNeeded() {
                let phoneFormatter = PhoneNumberKitFormater()
                let formattedPhone = phoneFormatter.format(payeePhone)
                cells.append(PropertyCellViewModel(
                    title: "Номер телефона",
                    iconType: IconType.phone.icon,
                    value: formattedPhone))
                
            }
            
            if let provider = operation?.provider,
               let image = model.images.value[statement.md5hash]?.image {
                
                cells.append(BankCellViewModel(
                    title: "Наименование получателя",
                    icon: image,
                    name: provider))
            }
            
            if let amountCell = Self.amountCell(
                with: model,
                amount: statement.amount,
                currency: currency) {
                
                cells.append(amountCell)
            }
            
            if let fee = operation?.payerFee,
               let comissionCell = Self.commissionCell(
                with: model,
                fee: fee,
                currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let debitAccounCell = Self.accountCell(
                with: product,
                model: model,
                operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(dateTimeCell)
            
        case .internet:
            
            if let image = model.images.value[statement.md5hash]?.image {
                
                logo = image
                
                cells.append(BankCellViewModel(
                    title: "Наименование получателя",
                    icon: image,
                    name: statement.merchant))
            }
            
            if let account = operation?.account {
                
                cells.append(PropertyCellViewModel(
                    title: "Номер счета получателя",
                    iconType: IconType.account.icon,
                    value: account))
            }
            
            if let amountCell = Self.amountCell(
                with: model,
                amount: statement.amount,
                currency: currency) {
                
                cells.append(amountCell)
            }
            
            if let fee = operation?.payerFee,
               let comissionCell = Self.commissionCell(
                with: model,
                fee: fee,
                currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let debitAccounCell = Self.accountCell(
                with: product,
                model: model,
                operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(dateTimeCell)
            
        case .housingAndCommunalService:
            
            if let image = model.images.value[statement.md5hash]?.image {
                
                logo = image
                
                cells.append(BankCellViewModel(
                    title: "Наименование получателя",
                    icon: image,
                    name: statement.merchant))
            }
            
            if let payeeINN = operation?.payeeINN  {
                
                cells.append(PropertyCellViewModel(
                    title: "ИНН получателя",
                    iconType: IconType.account.icon,
                    value: payeeINN))
            }
            
            if let period = operation?.period {
                
                cells.append(PropertyCellViewModel(
                    title: "Период оплаты",
                    iconType: IconType.date.icon,
                    value: period))
            }
            
            if let account = operation?.account {
                
                cells.append(PropertyCellViewModel(
                    title: "Код плательщика",
                    iconType: IconType.account.icon,
                    value: account))
            }
            
            if let amountCell = Self.amountCell(
                with: model,
                amount: statement.amount,
                currency: currency) {
                
                cells.append(amountCell)
            }
            
            if let fee = operation?.payerFee,
               let comissionCell = Self.commissionCell(
                with: model,
                fee: fee,
                currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let debitAccounCell = Self.accountCell(
                with: product,
                model: model,
                operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(dateTimeCell)
            
            
        case .notFinance:
            return nil
            
        case .outsideCash:
            
            if let debitAccounCell = Self.accountCell(
                with: product,
                model: model,
                operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            if let amountCell = Self.amountCell(
                with: model,
                amount: statement.amount,
                currency: currency) {
                
                cells.append(amountCell)
            }
            
            if let fee = operation?.payerFee,
               let comissionCell = Self.commissionCell(
                with: model,
                fee: fee,
                currency: currency) {
                
                cells.append(comissionCell)
            }
            
            cells.append(dateTimeCell)
            
        case .outsideOther:
            
            if let image = model.images.value[statement.md5hash]?.image {
                
                logo = image
                
                cells.append(BankCellViewModel(
                    title: "Наименование получателя",
                    icon: image,
                    name: statement.merchant))
            }
            
            if let mcc = statement.mcc {
                
                cells.append(PropertyCellViewModel(
                    title: "Категория операции",
                    iconType: nil,
                    value: "\(statement.groupName) (\(mcc))"))
            } else {
                
                cells.append(PropertyCellViewModel(
                    title: "Категория операции",
                    iconType: nil,
                    value: "\(statement.groupName)"))
            }
            
            if let formattedAmount = model.amountFormatted(
                amount: statement.amount,
                currencyCode: currency,
                style: .fraction) {
                
                let amount = statement.formattedAmountWithSign(formattedAmount)
                cells.append(PropertyCellViewModel(
                    title: "Сумма перевода",
                    iconType: IconType.balance.icon,
                    value: amount))
            }
            
            if let fee = operation?.payerFee,
               let comissionCell = Self.commissionCell(
                with: model,
                fee: fee,
                currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let debitAccounCell = Self.accountCell(
                with: product,
                model: model,
                operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(dateTimeCell)
            
        case .sfp:
            
            logo = Image("sbp-logo")
            
            if statement.isCreditType {
                
                if let foreignPhoneNumber = statement.fastPayment?.foreignPhoneNumber {
                    let phoneFormatter = PhoneNumberKitFormater()
                    let formattedPhone = phoneFormatter.format(foreignPhoneNumber)
                    cells.append(PropertyCellViewModel(
                        title: "Номер телефона отправителя",
                        iconType: IconType.phone.icon,
                        value: formattedPhone))
                    
                }
                
                cells.append(PropertyCellViewModel(
                    title: "Отправитель",
                    iconType: IconType.user.icon,
                    value: statement.merchant))
                
            } else if statement.isDebitType {
                
                if let foreignPhoneNumber = statement.fastPayment?.foreignPhoneNumber {
                    let phoneFormatter = PhoneNumberKitFormater()
                    let formattedPhone = phoneFormatter.format(foreignPhoneNumber)
                    cells.append(PropertyCellViewModel(
                        title: "Номер телефона получателя",
                        iconType: IconType.phone.icon,
                        value: formattedPhone))
                    
                }
                
                cells.append(PropertyCellViewModel(
                    title: "Получатель",
                    iconType: IconType.user.icon,
                    value: statement.merchant))
            }

            if let bankName = statement.fastPayment?.foreignBankName {

              let bankCell = statement.getBankCell(
                bankName: bankName,
                icon: model.images.value[statement.md5hash]?.image
              )

              cells.append(bankCell)
            }
            
            if let formattedAmount = model.amountFormatted(
                amount: statement.amount,
                currencyCode: currency,
                style: .fraction) {
                
                let amount = statement.formattedAmountWithSign(formattedAmount)
                cells.append(PropertyCellViewModel(
                    title: "Сумма перевода",
                    iconType: IconType.balance.icon,
                    value: amount))
            }
            
            if let fee = operation?.payerFee,
               let comissionCell = Self.commissionCell(
                with: model,
                fee: fee,
                currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let debitAccounCell = Self.accountCell(
                with: product,
                model: model,
                operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            if let documentComment = statement.fastPayment?.documentComment,
               documentComment != "" {
                
                cells.append(PropertyCellViewModel(
                    title: "Назначение платежа",
                    iconType: IconType.purpose.icon,
                    value: documentComment))
            }
            
            if let transferNumber = statement.fastPayment?.opkcid {
                
                cells.append(PropertyCellViewModel(
                    title: "Номер операции СБП",
                    iconType: IconType.operationNumber.icon,
                    value: transferNumber))
            }
            
            cells.append(dateTimeCell)
            
        case .transport:
            
            guard let operation else {
                return nil
            }
            
            if let image = model.images.value[statement.md5hash]?.image {
                
                logo = image
            }
            
            let payerViewModel = makeProductViewModel(
                title: "Счет списания",
                productId: operation.payerProductId,
                productNumber: operation.payerProductNumber)
            
            let amountViewModel = makePropertyViewModel(
                productId: operation.payerProductId,
                operation: operation,
                iconType: .balance)
            
            let commissionViewModel = makePropertyViewModel(
                productId: operation.payerProductId,
                operation: operation,
                iconType: .commission)
            
            let payeeViewModel = makeProductViewModel(
                title: "Счет зачисления",
                productId: operation.payeeProductId,
                productNumber: operation.payeeProductNumber)
            
            let dateViewModel = makePropertyViewModel(
                productId: operation.payerProductId,
                operation: operation,
                iconType: .date)
            
            cells = Self.makeItemsForTransport(
                dictionaryAnywayOperator: model.dictionaryAnywayOperator,
                operation,
                amountViewModel,
                commissionViewModel,
                payerViewModel,
                payeeViewModel,
                dateViewModel
            )
            
        case .c2b:
            logo = Image("sbp-logo")
            
            let bankImage: Image? = {
                
                guard let bank = model.dictionaryFullBankInfoList().first(where: { $0.bic == statement.fastPayment?.foreignBankBIC }),
                      let uiImage = bank.svgImage.uiImage else {
                    return nil
                }
                
                return .init(uiImage: uiImage)
            }()
            
            if let formattedAmount = model.amountFormatted(
                amount: statement.amount,
                currencyCode: currency,
                style: .fraction) {
                
                let amount = statement.formattedAmountWithSign(formattedAmount)
                cells.append(PropertyCellViewModel(
                    title: "Сумма перевода",
                    iconType: IconType.balance.icon,
                    value: amount))
            }
            
            if let image = model.images.value[statement.md5hash]?.image {
                
                cells.append(BankCellViewModel(
                    title: "Наименование ТСП",
                    icon: image,
                    name: statement.merchant))
            }
            
            cells.append(dateTimeCell)
            
            if let status = operation?.operationStatus {
                
                let title = "Статус операции"
                switch status {
                    
                case .complete:
                    cells.append(BankCellViewModel(
                        title: title,
                        icon: Image("OkOperators"),
                        name: "Успешно"))
                    
                case .inProgress:
                    cells.append(BankCellViewModel(
                        title: title,
                        icon: .ic16Waiting,
                        name: "В обработке"))
                    
                case .rejected:
                    cells.append(BankCellViewModel(
                        title: title,
                        icon: .ic16Denied,
                        name: "Отказ"))
                    
                case .unknown:
                    break
                }
                
            } else if let isCancellation = statement.isCancellation,
                      isCancellation {
                
                cells.append(BankCellViewModel(
                    title: title,
                    icon: .ic16Denied,
                    name: "Отказ"))
                
            } else if operation == nil,
                      statement.isCancellation == nil {
                
                cells.append(BankCellViewModel(
                    title: title,
                    icon: Image("OkOperators"),
                    name: "Успешно"))
            }
            
            if let debitAccounCell = Self.accountCell(
                with: product,
                model: model,
                operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            let title = statement.payeerTitle()
            
            cells.append(BankCellViewModel(
                title: title,
                icon: Image("hash"),
                name: statement.fastPayment?.foreignName ?? ""))
            
            if let bankName = statement.fastPayment?.foreignBankName {

              let bankCell = statement.getBankCell(
                bankName: bankName,
                icon: bankImage
              )

              cells.append(bankCell)
            }
            
            if let comment = statement.fastPayment?.documentComment {
                
                cells.append(BankCellViewModel(
                    title: "Сообщение получателю",
                    icon: Image("hash"),
                    name: comment))
            }
            
            cells.append(BankCellViewModel(
                title: "Идентификатор операции",
                icon: Image("hash"),
                name: statement.fastPayment?.opkcid ?? ""))
            
            cells.append(IconCellViewModel(icon: Image("sbptext")))
            
        case .insideDeposit:
            
            if let image = model.images.value[statement.md5hash]?.image {
                
                cells.append(BankCellViewModel(
                    title: "Наименование получателя",
                    icon: image,
                    name: statement.merchant))
            }
            
            if let formattedAmount = model.amountFormatted(
                amount: statement.amount,
                currencyCode: currency,
                style: .clipped) {
                
                let amount = statement.formattedAmountWithSign(formattedAmount)
                cells.append(PropertyCellViewModel(
                    title: "Сумма перевода",
                    iconType: IconType.balance.icon,
                    value: amount))
            }
            
            cells.append(dateTimeCell)
            
        case .taxes:
            
            if let image = model.images.value[statement.md5hash]?.image,
               let payeeFullName = operation?.payeeFullName {
                
                cells.append(BankCellViewModel(
                    title: "Наименование получателя",
                    icon: image,
                    name: payeeFullName))
            }
            
            if let payeeINN = operation?.payeeINN {
                
                cells.append(PropertyCellViewModel(
                    title: "ИНН получателя",
                    iconType: nil,
                    value: payeeINN))
            }
            
            if let formattedAmount = model.amountFormatted(
                amount: statement.amount,
                currencyCode: currency,
                style: .clipped) {
                
                let amount = statement.formattedAmountWithSign(formattedAmount)
                cells.append(PropertyCellViewModel(
                    title: "Сумма перевода",
                    iconType: IconType.balance.icon,
                    value: amount))
            }
            
            if let fee = operation?.payerFee,
               let comissionCell = Self.commissionCell(
                with: model,
                fee: fee,
                currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let payerProductId = [operation?.payerCardId,
                                     operation?.payerAccountId].compactMap({$0}).first {
                
                for i in model.products.value {
                    
                    if let productInfo = i.value.first(where: { $0.id == payerProductId }) {
                        
                        if let description = productInfo.number?.suffix(4),
                           let balance = productInfo.balance,
                           let balanceFormatted = model.amountFormatted(
                            amount: balance,
                            currencyCode: productInfo.currency,
                            style: .clipped
                           ),
                           let icon = model.images.value[productInfo.smallDesignMd5hash]?.image,
                           let additional = productInfo.additionalField {
                           let iconPaymentService = model.images.value[productInfo.paymentSystemMd5Hash]?.image
                            
                            cells.append(ProductCellViewModel(title: "Счет списания", icon: icon, name: productInfo.displayName, iconPaymentService: iconPaymentService, balance: balanceFormatted, description: "· \(description) · \(additional)"))
                        }
                    }
                }
            }
            cells.append(dateTimeCell)
            
        case .sberQRPayment:
            cells = Self.sberQRPayment(
                statement: statement,
                operation: operation,
                product: product,
                model: model,
                dateTimeCell: dateTimeCell,
                currency: currency
            )
            
        default:
            break
        }
        
        self.logo = logo
        //FIXME: why dismissAction is commented?
        //        self.dismissAction = dismissAction
    }
}

private extension ProductStatementData {
    
    typealias BankCellVM = OperationDetailInfoViewModel.BankCellViewModel
    
    func getBankCell(bankName: String, icon: Image? = nil) -> BankCellVM {
        
        if isDebitType {
            
          return BankCellVM(
            title: "Банк получателя",
            icon: icon ?? Image("BankIcon"),
            name: bankName)
        } else {
            
          return BankCellVM(
            title: "Банк отправителя",
            icon: icon ?? Image("BankIcon"),
            name: bankName)
        }
      }
}

extension OperationDetailInfoViewModel {
    
    static func sberQRPayment(
        statement: ProductStatementData,
        operation: OperationDetailData?,
        product: ProductData,
        model: Model,
        dateTimeCell: PropertyCellViewModel,
        currency: String
    ) -> [DefaultCellViewModel] {
        
        let amount = amount(
            statement: statement,
            currency: currency,
            model: model
        )
        let payee = payee(
            statement: statement,
            operation: operation,
            model: model
        )
        let status = operationStatus(
            operationType: statement.operationType,
            operation: operation
        )
        let account = accountCell(
            with: product,
            model: model,
            operationType: statement.operationType
        )
        let merchant = merchant(statement: statement)
        let bank = bank(
            operationType: statement.operationType,
            operation: operation,
            bank: model.bank(memberID:)
        )
        
        return [
            amount,
            statement.isDebitType ? payee : nil,
            dateTimeCell,
            status,
            account,
            merchant,
            bank,
        ].compactMap { $0 }
    }
    
    static func amount(
        statement: ProductStatementData,
        currency: String,
        model: Model
    ) -> PropertyCellViewModel? {
        
        let formattedAmount = model.amountFormatted(
            amount: statement.amount,
            currencyCode: currency,
            style: .fraction)
        
        return formattedAmount.map {
            
            .init(
                title: "Сумма перевода",
                iconType: IconType.balance.icon,
                value: $0
            )
        }
    }
    
    static func payee(
        statement: ProductStatementData,
        operation: OperationDetailData?,
        model: Model
    ) -> BankCellViewModel? {
        
        let image: Image? = {
            guard let merchantIcon = operation?.merchantIcon,
                  let image = model.images.value[merchantIcon]?.image
            else { return nil }
            
            return image
        }()
        
        return .init(
            title: "Наименование ТСП",
            icon: image ?? .ic64Goods,
            name: operation?.merchantSubName ?? ""
        )
    }
    
    static func operationStatus(
        operationType: OperationType,
        operation: OperationDetailData?
    ) -> BankCellViewModel? {
        
        let title = "Статус операции"
        
        switch operationType {
        case .credit:
            return .init(
                title: title,
                icon: Image("OkOperators"),
                name: "Успешно")
                        
        case .debit:
            switch operation?.operationStatus {
            case .complete:
                return .init(
                    title: title,
                    icon: Image("OkOperators"),
                    name: "Успешно")
                
            case .inProgress:
                return .init(
                    title: title,
                    icon: .ic16Waiting,
                    name: "В обработке")
                
            case .rejected:
                return .init(
                    title: title,
                    icon: .ic16Denied,
                    name: "Отказ")
                
            case .none, .unknown:
                return nil
            }
            
        case .creditPlan, .debitPlan:
            return .init(
                title: title,
                icon: .ic16Waiting,
                name: "В обработке")
            
        case .creditFict, .debitFict:
            return .init(
                title: title,
                icon: .ic16Denied,
                name: "Отказ")
            
        case .demandDepositFromAccount, .open, .unknown:
            return nil
        }
    }
    
    static func merchant(
        statement: ProductStatementData
    ) -> BankCellViewModel {
        
        let title = statement.payeerTitle()
        
        return .init(
            title: title,
            icon: Image("customer"),
            name: statement.merchantNameRus ?? ""
        )
    }
    
    static func bank(
        operationType: OperationType,
        operation: OperationDetailData?,
        bank: @escaping (String) -> BankData?
    ) -> BankCellViewModel? {
        
        let title: String
        let memberID: String
        
        switch operationType {
        case .credit, .creditPlan, .creditFict:
            title = "Банк плательщика"
            memberID = "100000000111"
            
        case .debit, .debitPlan, .debitFict:
            title = "Банк получателя"
            guard let id = operation?.memberId
            else { return nil }
                
            memberID = id

        case .demandDepositFromAccount, .open, .unknown:
            return nil
        }
        
        guard let bank = bank(memberID)
        else { return nil }
        
        return .init(
            title: title,
            icon: bank.svgImage.image ?? Image("BankIcon"),
            name: bank.memberNameRus
        )
    }
}

//MARK: - Private helpers

private extension Model {

    func bank(memberID: String) -> BankData? {
        
        bankList.value[memberID]
    }
}

private extension Array where Element == BankData {
    
    subscript(memberId: String) -> Element? {
        
        first { $0.memberId == memberId }
    }
}

private extension OperationDetailInfoViewModel {
    
    static func accountCell(
        with product: ProductData,
        model: Model,
        operationType: OperationType
    ) -> DefaultCellViewModel? {
        
        let productCurrency = product.currency
        let title = operationType == .debit ? "Счет списания" : "Счет зачисления"
        
        guard let smallDesign = model.images.value[product.smallDesignMd5hash]?.image,
              let description = product.number?.suffix(4),
              let balanceString = model.amountFormatted(
                amount: product.balanceValue,
                currencyCode: productCurrency,
                style: .clipped)
        else  { return nil }
        
        if let additionalField = product.additionalField {
            
            return ProductCellViewModel(
                title: title,
                icon: smallDesign,
                name: product.displayName,
                iconPaymentService: model.images.value[product.paymentSystemMd5Hash]?.image,
                balance: balanceString,
                description: "· \(description) · \(additionalField)")
        } else {
            
            return ProductCellViewModel(
                title: title,
                icon: smallDesign,
                name: product.displayName,
                iconPaymentService: model.images.value[product.paymentSystemMd5Hash]?.image,
                balance: balanceString,
                description: "· \(description)")
        }
    }
    
    static func commissionCell(
        with model: Model,
        icon: PropertyIconType = .commission,
        fee: Double,
        currency: String
    ) -> PropertyCellViewModel? {
        
        guard let feeFormatted = model.amountFormatted(
            amount: fee,
            currencyCode: currency,
            style: .clipped)
        else { return nil }
        
        return .init(title: "Коммиссия",
                     iconType: IconType.commission.icon,
                     value: feeFormatted)
    }
    
    static func amountCell(
        with model: Model,
        title: String = "Сумма перевода",
        icon: PropertyIconType = .balance,
        amount: Double,
        currency: String
    ) -> PropertyCellViewModel? {
        
        guard let amountFormatted = model.amountFormatted(
            amount: amount,
            currencyCode: currency,
            style: .clipped)
        else { return nil }
        
        return .init(title: title,
                     iconType: IconType.balance.icon,
                     value: amountFormatted)
    }
}

// MARK: - Methods

extension OperationDetailInfoViewModel {
    
    func makeItems(operation: OperationDetailData) -> [DefaultCellViewModel] {
        
        let payeeProductId = [operation.payeeCardId,
                              operation.payeeAccountId].compactMap {$0}.first
        let payeeProductNumber = [operation.payeeCardNumber,
                                  operation.payeeAccountNumber].compactMap {$0}.first
        
        let payerProductId = [operation.payerCardId,
                              operation.payerAccountId].compactMap {$0}.first
        let payerProductNumber = [operation.payerCardNumber,
                                  operation.payerAccountNumber].compactMap {$0}.first
        
        let payerViewModel = makeProductViewModel(
            title: "Счет списания",
            productId: payerProductId,
            productNumber: payerProductNumber)
        
        let amountViewModel = makePropertyViewModel(
            productId: payerProductId,
            operation: operation,
            iconType: .balance)
        
        let commissionViewModel = makePropertyViewModel(
            productId: payerProductId,
            operation: operation,
            iconType: .commission)
        
        let payeeViewModel = makeProductViewModel(
            title: "Счет зачисления",
            productId: payeeProductId,
            productNumber: payeeProductNumber)
        
        let dateViewModel = makePropertyViewModel(
            productId: payerProductId,
            operation: operation,
            iconType: .date)
        
        let purposeViewModel = makePropertyViewModel(
            productId: payerProductId,
            operation: operation,
            iconType: .purpose)
        
        let payeeNumberPhone = makePropertyViewModel(
            productId: payerProductId,
            operation: operation,
            iconType: .phone)
        
        let payeeNameViewModel = makePropertyViewModel(
            productId: payerProductId,
            operation: operation,
            iconType: .user)
        
        let operationNumberViewModel = makePropertyViewModel(
            productId: payerProductId,
            operation: operation,
            iconType: .operationNumber)
        
        let payeeBankViewModel = makeBankViewModel(
            operation: operation)
        
        
        switch operation.transferEnum {
            
        case .sfp:
            
            return [
                payeeNumberPhone,
                payeeNameViewModel,
                payeeBankViewModel,
                amountViewModel,
                commissionViewModel,
                payerViewModel,
                purposeViewModel,
                operationNumberViewModel,
                dateViewModel
            ].compactMap {$0}
            
        case .depositClose:
            
            return [
                payeeViewModel,
                payerViewModel,
                amountViewModel,
                commissionViewModel,
                purposeViewModel,
                dateViewModel,
            ].compactMap {$0}
            
        case .accountClose:
            
            return [
                payerViewModel,
                amountViewModel,
                commissionViewModel,
                payeeViewModel,
                dateViewModel].compactMap {$0}
            
        case .direct:
            
            var directCells = [
                payeeNumberPhone,
                payeeNameViewModel,
                payeeBankViewModel,
                commissionViewModel,
                payerViewModel,
                purposeViewModel,
                dateViewModel
            ]
            
            if let formattedAmount = self.model.amountFormatted(
                amount: operation.amount,
                currencyCode: operation.currencyAmount,
                style: .normal) {
                
                directCells.insert((PropertyCellViewModel(
                    title: "Сумма перевода",
                    iconType: IconType.balance.icon,
                    value: formattedAmount)), at: 3)
            }
            
            if let payeeAmount = operation.payeeAmount,
               let payeeCurrency = operation.payeeCurrency,
               let formattedAmount = model.amountFormatted(
                amount: payeeAmount,
                currencyCode: payeeCurrency,
                style: .fraction) {
                
                directCells.insert((PropertyCellViewModel(
                    title: "Сумма зачисления в валюте",
                    iconType: IconType.balance.icon,
                    value: formattedAmount)), at: 5)
            }
            
            let payeeAmount = operation.payerAmount
            let payeeCurrency = operation.payerCurrency
            if let formattedAmount = model.amountFormatted(
                amount: payeeAmount,
                currencyCode: payeeCurrency,
                style: .fraction) {
                
                directCells.insert((PropertyCellViewModel(
                    title: "Сумма списания",
                    iconType: IconType.balance.icon,
                    value: formattedAmount)), at: 6)
            }
            
            return directCells.compactMap {$0}
            
        case .contactAddressing, .contactAddressingCash, .contactAddressless:
            
            if let method = operation.paymentMethod,
               let transferReference = operation.transferReference,
               let countryName = operation.countryName {
                
                let methodViewModel = PropertyCellViewModel(
                    title: "Способ выплаты",
                    iconType: IconType.cash.icon,
                    value: method.rawValue)
                
                let transferReferenceViewModel = PropertyCellViewModel(
                    title: "Номер перевода",
                    iconType: IconType.operationNumber.icon,
                    value: transferReference)
                
                let countryViewModel = PropertyCellViewModel(
                    title: "Страна",
                    iconType: IconType.geo.icon,
                    value: countryName)
                
                if let formattedAmount = model.amountFormatted(
                    amount: operation.payerAmount,
                    currencyCode: operation.payerCurrency,
                    style: .fraction),
                   let amount = operation.payeeAmount,
                   let payeeAmount = model.amountFormatted(
                    amount: amount,
                    currencyCode: operation.payeeCurrency,
                    style: .fraction) {
                    
                    let transferAmount = PropertyCellViewModel(
                        title: "Сумма списания",
                        iconType: IconType.balance.icon,
                        value: formattedAmount)
                    
                    let amount = PropertyCellViewModel(
                        title: "Сумма перевода",
                        iconType: IconType.balance.icon,
                        value: payeeAmount)
                    
                    return [
                        payeeNumberPhone,
                        payeeNameViewModel,
                        countryViewModel,
                        payeeBankViewModel,
                        transferAmount,
                        commissionViewModel,
                        amount,
                        methodViewModel,
                        payerViewModel,
                        purposeViewModel,
                        transferReferenceViewModel,
                        dateViewModel
                    ].compactMap {$0}
                    
                }
                
                return [
                    payeeNumberPhone,
                    payeeNameViewModel,
                    countryViewModel,
                    payeeBankViewModel,
                    commissionViewModel,
                    amountViewModel,
                    methodViewModel,
                    payerViewModel,
                    purposeViewModel,
                    transferReferenceViewModel,
                    dateViewModel
                ].compactMap {$0}
            } else {
                
                return [
                    payeeNumberPhone,
                    payeeNameViewModel,
                    payeeBankViewModel,
                    amountViewModel,
                    commissionViewModel,
                    payerViewModel,
                    purposeViewModel,
                    dateViewModel
                ].compactMap {$0}
            }
            
        case .external:
            return Self.makeItemsForExternal(dictionaryFullBankInfoBank: model.dictionaryFullBankInfoBank, operation, payeeNameViewModel, payeeViewModel, payeeBankViewModel, amountViewModel, commissionViewModel, payerViewModel, purposeViewModel, dateViewModel)
            
        case .internet:
            
            var cells = [
                amountViewModel,
                commissionViewModel,
                payerViewModel,
                payeeViewModel,
                dateViewModel].compactMap { $0 }
            
            
            if let puref = operation.puref,
               let account = operation.account {
                
                let operatorValue = model.dictionaryAnywayOperator(for: puref)
                let numberViewModel = PropertyCellViewModel(
                    title: "Номер счета получателя",
                    iconType: operatorValue?.parameterList.first?.svgImage?.image ?? PropertyIconType.account.icon,
                    value: account)
                
                cells.insert(numberViewModel, at: 0)
            }
            
            
            if let puref = operation.puref,
               let payeeFullName = operation.payeeFullName {
                
                let operatorValue = model.dictionaryAnywayOperator(for: puref)
                let operatorViewModel = PropertyCellViewModel(
                    title: "Наименование получателя",
                    iconType: operatorValue?.iconImageData?.image ?? .ic40TvInternet,
                    value: payeeFullName)
                cells.insert(operatorViewModel, at: 0)
            }
            
            return cells
            
        case .housingAndCommunalService:
            
            var cells = [
                amountViewModel,
                commissionViewModel,
                payerViewModel,
                dateViewModel
            ]
            
            let puref = operation.puref ?? ""
            let operatorValue = model.dictionaryAnywayOperator(for: puref)
            
            if let account = operation.account {
                
                let numberViewModel = PropertyCellViewModel(
                    title: "Лицевой счет",
                    iconType: IconType.account.icon,
                    value: account
                )
                cells.insert(numberViewModel, at: 0)
            }
            
            if let payeeINN = operation.payeeINN {
                
                cells.insert(PropertyCellViewModel(
                    title: "ИНН получателя",
                    iconType: IconType.account.icon,
                    value: payeeINN), at: 0)
            }
            
            if let payeeFullName = operation.payeeFullName {
                
                let operatorViewModel = PropertyCellViewModel(
                    title: "Наименование получателя",
                    iconType: operatorValue?.iconImageData?.image ?? .ic40ZkxServices,
                    value: payeeFullName
                )
                cells.insert(operatorViewModel, at: 0)
            }
            
            return cells.compactMap { $0 }
            
        case .cardToCard, .accountToCard:
            
            var cells = [
                amountViewModel,
                commissionViewModel,
                payerViewModel,
                dateViewModel
            ]
            
            if let payeeProductNumber {
                
                let payeeCellViewModel = PropertyCellViewModel(
                    title: "Номер карты получателя",
                    iconType: Image("otherCard"),
                    value: payeeProductNumber
                )
                
                cells.insert(payeeCellViewModel, at: 0)
            }
            
            return cells.compactMap {$0}
            
        case .transport:
            
            return Self.makeItemsForTransport(
                dictionaryAnywayOperator: model.dictionaryAnywayOperator,
                operation,
                amountViewModel,
                commissionViewModel,
                payerViewModel,
                payeeViewModel,
                dateViewModel
            )
            
        case .c2bPayment:
            
            return [
                amountViewModel,
                operation.merchant,
                dateViewModel,
                operationDetailStatus(status: operation.operationStatus),
                payerViewModel,
                payeeViewModel,
                payeeBankViewModel,
                purposeViewModel,
                operationNumberViewModel
            ].compactMap { $0 }
                        
        case .sberQRPayment:
            
            return [
                amountViewModel,
                operation.merchant,
                dateViewModel,
                operationDetailStatus(status: operation.operationStatus),
                payerViewModel,
                payeeViewModel,
                operation.payeeName,
                payeeBankViewModel,
                purposeViewModel,
                operationNumberViewModel
            ].compactMap { $0 }
        
        case .productPaymentOffice, .productPaymentCourier:
            var cells = [
                amountViewModel,
                payerViewModel,
                dateViewModel
            ]
            if let comment = operation.comment {
                
                let commentCell = PropertyCellViewModel(
                    title: "Наименование операции",
                    iconType: .ic40BankServices,
                    value: comment
                )
                
                cells.insert(commentCell, at: 0)
            }
            
            return cells.compactMap {$0}
            
        default:
            
            return [
                payerViewModel,
                amountViewModel,
                commissionViewModel,
                payeeViewModel,
                dateViewModel].compactMap {$0}
        }
    }
    
    func nameCompanyC2B(
        operation: OperationDetailData,
        image: Image? = .ic24Bank
    ) -> BankCellViewModel? {
        
        guard let image,
              let name = operation.merchantSubName
        else { return nil }
        
        return BankCellViewModel(
            title: "Наименование ТСП",
            icon: image,
            name: name)
    }
    
    func operationDetailStatus(
        status: OperationDetailData.OperationStatus?
    ) -> BankCellViewModel? {
        
        let title = "Статус операции"
        switch status {
            
        case .complete:
            return BankCellViewModel(title: title,
                                     icon: Image("OkOperators"),
                                     name: "Успешно")
            
        case .inProgress:
            return BankCellViewModel(title: title,
                                     icon: .ic16Waiting,
                                     name: "В обработке")
            
        case .rejected:
            return BankCellViewModel(title: title,
                                     icon: .ic16Denied,
                                     name: "Отказ")
            
        case .unknown:
            return nil
            
        case .none:
            return nil
        }
    }
    
    static func makeItemsForExternal(
        dictionaryFullBankInfoBank: @escaping (String) -> BankFullInfoData?,
        _ operation: OperationDetailData,
        _ payeeNameViewModel: PropertyCellViewModel?,
        _ payeeViewModel: ProductCellViewModel?,
        _ payeeBankViewModel: BankCellViewModel?,
        _ amountViewModel: PropertyCellViewModel?,
        _ commissionViewModel: PropertyCellViewModel?,
        _ payerViewModel: ProductCellViewModel?,
        _ purposeViewModel: PropertyCellViewModel?,
        _ dateViewModel: PropertyCellViewModel?
    ) -> [DefaultCellViewModel] {
        
        let payeeAccountNumber = operation.payeeAccountNumber.map {
            
            PropertyCellViewModel(
                for: .payeeAccountNumber,
                iconType: IconType.account,
                value: $0
            )
        }
        let payeeBankBIC = operation.payeeBankBIC.map { bankBic in
            
            let bank = dictionaryFullBankInfoBank(bankBic)
            
            return BankCellViewModel(
                title: "Бик банка получателя",
                icon: bank?.svgImage.image ?? IconType.account.icon,
                name: bankBic
            )
        }
        let payeeINN = operation.payeeINN.map {
            
            PropertyCellViewModel(
                for: .payeeINN,
                iconType: IconType.account,
                value: $0
            )
        }
        let payeeKPP = operation.payeeKPP.map {
            
            PropertyCellViewModel(
                for: .payeeKPP,
                iconType: IconType.account,
                value: $0
            )
        }
        
        switch operation.externalTransferType {
        case .none:
            return []
            
        case .entity, .unknown:
            return [
                payeeNameViewModel,
                payeeAccountNumber,
                payeeViewModel,
                payeeINN,
                payeeKPP,
                payeeBankBIC,
                payeeBankViewModel,
                amountViewModel,
                commissionViewModel,
                payerViewModel,
                purposeViewModel,
                dateViewModel
            ].compactMap { $0 }
            
        case .individual:
            return [
                payeeNameViewModel,
                payeeAccountNumber,
                payeeViewModel,
                payeeBankBIC,
                payeeBankViewModel,
                amountViewModel,
                commissionViewModel,
                payerViewModel,
                purposeViewModel,
                dateViewModel
            ].compactMap { $0 }
        }
    }
    
    static func makeItemsForTransport(
        dictionaryAnywayOperator: @escaping (String) -> OperatorGroupData.OperatorData?,
        _ operation: OperationDetailData,
        _ amountViewModel: PropertyCellViewModel?,
        _ commissionViewModel: PropertyCellViewModel?,
        _ payerViewModel: ProductCellViewModel?,
        _ payeeViewModel: ProductCellViewModel?,
        _ dateViewModel: PropertyCellViewModel?
    ) -> [DefaultCellViewModel] {
        
        var cells = [
            amountViewModel,
            commissionViewModel,
            payerViewModel,
            payeeViewModel,
            dateViewModel].compactMap { $0 }
        
        if let accountTitle = operation.accountTitle,
           let account =  operation.account, !account.isEmpty {
            
            if operation.isTrafficPoliceService {
                
                cells.insert(PropertyCellViewModel(
                    title: accountTitle,
                    iconType: IconType.account.icon,
                    value: account), at: 0)
            } else {
                
                cells.insert(PropertyCellViewModel(
                    title: accountTitle,
                    iconType: IconType.operationNumber.icon,
                    value: account), at:0)
            }
        }
        
        if let puref = operation.puref,
           let payeeFullName = operation.payeeFullName {
            
            let operatorValue = dictionaryAnywayOperator(puref)
            let operatorViewModel = PropertyCellViewModel(title: "Наименование получателя",
                                                          iconType: operatorValue?.iconImageData?.image ?? .ic40Transport,
                                                          value: payeeFullName)
            cells.insert(operatorViewModel, at: 0)
        }
        
        return cells
    }
    
    static func makeHistoryItemsForExternal(
        dictionaryFullBankInfoBank: @escaping (String) -> BankFullInfoData?,
        _ type: OperationDetailData.ExternalTransferType,
        _ operation: OperationDetailData?,
        _ amountCell: PropertyCellViewModel?,
        _ comissionCell: PropertyCellViewModel?,
        _ debitAccounCell: DefaultCellViewModel?,
        _ comment: String,
        _ dateString: String
    ) -> [DefaultCellViewModel] {
        
        func accountNumber() -> PropertyCellViewModel? {
            
            let payeeAccountNumber = operation?.payeeAccountNumber.map {
                
                PropertyCellViewModel(title: "Номер счета получателя",
                                      iconType: IconType.account.icon,
                                      value: $0)
            }
            
            if type == .entity {
                if (payeeAccountNumber != nil) {
                    
                    return payeeAccountNumber
                    
                } else {
                    return operation?.payeeCardNumber.map {
                        PropertyCellViewModel(title: "Номер счета получателя",
                                              iconType: IconType.account.icon,
                                              value: $0)
                    }
                }
            } else { return payeeAccountNumber }
        }
        return [
            
            operation?.payeeFullName.map {
                
                PropertyCellViewModel(title: "Наименование получателя",
                                      iconType: IconType.customer.icon,
                                      value: $0)
            },
            
            accountNumber(),
            
            operation?.payeeINN.map  {
                
                PropertyCellViewModel(title: "ИНН получателя",
                                      iconType: IconType.account.icon,
                                      value: $0)
            },
            
            (type == .entity) ? operation?.payeeKPP.map {
                
                PropertyCellViewModel(
                    title: "КПП получателя",
                    iconType: IconType.account.icon,
                    value: $0
                )
            } : nil,
            
            operation?.payeeBankBIC.map { bankBic in
                
                let bank = dictionaryFullBankInfoBank(bankBic)
                
                return BankCellViewModel(
                    title: "Бик банка получателя",
                    icon: bank?.svgImage.image ?? IconType.account.icon,
                    name: bankBic
                )
            },
            
            amountCell.map { $0 },
            
            comissionCell.map { $0 },
            
            debitAccounCell.map { $0 },
            
            PropertyCellViewModel(title: "Назначение платежа",
                                  iconType: IconType.purpose.icon,
                                  value: comment),
            
            PropertyCellViewModel(title: "Дата и время операции (МСК)",
                                  iconType: IconType.date.icon,
                                  value: dateString),
        ].compactMap { $0 }
    }
    
    func makePropertyViewModel(productId: Int?, operation: OperationDetailData, iconType: PropertyIconType) -> PropertyCellViewModel? {
        
        guard let productId = productId,
              let productData = model.product(productId: productId) ?? model.product(additionalId: productId) else {
            return nil
        }
        
        switch iconType {
        case .balance:
            
            let amount = operation.transferEnum == .external ? operation.payerAmount - operation.payerFee : operation.payerAmount
            let formattedAmount = model.amountFormatted(
                amount: amount,
                currencyCode: operation.payerCurrency,
                style: .fraction)
            
            guard let formattedAmount = formattedAmount else {
                return nil
            }
            
            return .init(
                title: "Сумма перевода",
                iconType: IconType.balance.icon,
                value: formattedAmount)
            
        case .commission:
            
            let payerFee = model.amountFormatted(
                amount: operation.payerFee,
                currencyCode: productData.currency,
                style: .fraction)
            
            guard let payerFee = payerFee else {
                return nil
            }
            
            return .init(
                title: "Комиссия",
                iconType: IconType.commission.icon,
                value: payerFee)
            
        case .purpose:
            //FIXME: backend send "" if comment nil
            guard let comment = operation.comment,
                  operation.comment != "" else {
                return nil
            }
            
            return .init(
                title: "Назначение платежа",
                iconType: IconType.purpose.icon,
                value: comment)
            
        case .date:
            switch operation.transferEnum {
            case .depositClose:
                return .init(
                    title: "Тип платежа",
                    iconType: IconType.date.icon,
                    value: "Закрытие вклада")
            default:
                return .init(
                    title: "Дата и время операции (МСК)",
                    iconType: IconType.date.icon,
                    value: operation.responseDate)
            }
            
        case .phone:
            guard let payeePhone = operation.payeePhone else {
                return nil
            }
            
            let phoneFormatter = PhoneNumberKitFormater()
            
            //TODO: remove after backend will be send number with country code
            if operation.transferEnum == .sfp {
                
                let formattedPhone = phoneFormatter.format(payeePhone.count == 10 ? "7\(payeePhone)" : payeePhone)
                
                return .init(
                    title: "Номер телефона получателя",
                    iconType: IconType.phone.icon,
                    value: formattedPhone)
                
            } else {
                
                let formattedPhone = phoneFormatter.format(payeePhone)
                
                return .init(
                    title: "Номер телефона получателя",
                    iconType: IconType.phone.icon,
                    value: formattedPhone)
            }
            
        case .user:
            
            guard let payeeName = operation.payeeFullName else {
                return nil
            }
            
            return .init(
                title: "Получатель",
                iconType: IconType.user.icon,
                value: payeeName)
            
        case .operationNumber:
            
            guard let transferNumber = operation.transferNumber else {
                return nil
            }
            
            return .init(
                title: "Номер операции СБП",
                iconType: IconType.operationNumber.icon,
                value: transferNumber)
            
        default:
            return nil
        }
    }
    
    private func makeProductViewModel(
        title: String,
        productId: Int?,
        productNumber: String?
    ) -> ProductCellViewModel? {
        
        guard let productId = productId,
              let productData = model.product(productId: productId) ?? model.product(additionalId: productId),
              let icon = model.images.value[productData.smallDesignMd5hash]?.image,
              let balance = productData.balance,
              let formattedBalance = model.amountFormatted(
                amount: balance,
                currencyCode: productData.currency,
                style: .fraction)
        else {
            return nil
        }
        
        let productNumber = productNumber ?? ""
        let lastNumber = productNumber.isEmpty == false ? "• \(productNumber.suffix(4)) • " : ""
        let name = ProductViewModel.name(
            product: productData,
            style: .main,
            creditProductName: .cardTitle
        )
        let description = productData.additionalField ?? ""
        
        let viewModel: ProductCellViewModel = .init(
            title: title,
            icon: icon,
            name: name,
            iconPaymentService: model.images.value[productData.paymentSystemMd5Hash]?.image,
            balance: formattedBalance,
            description: "\(lastNumber)\(description)")
        
        return viewModel
    }
    
    private func makeBankViewModel(operation: OperationDetailData) -> BankCellViewModel? {
        
        guard let bankName = operation.payeeBankName,
              let memberId = operation.memberId else {
            
            return nil
        }
        
        let title = "Банк получателя"
        
        if let md5hash = model.bankList.value.first(where: { $0.memberId == "EVOCA" })?.md5hash,
           let icon = model.images.value[md5hash]?.image {
            
            return BankCellViewModel(title: title,
                                     icon: icon,
                                     name: bankName)
            
        } else if let icon = model.dictionaryBankList.first(where: {$0.memberId == memberId})?.svgImage.image {
            
            return BankCellViewModel(title: title,
                                     icon: icon,
                                     name: bankName)
            
        } else {
            
            return BankCellViewModel(title: title,
                                     icon: Image("BankIcon"),
                                     name: bankName)
        }
    }
}

extension OperationDetailData {
    
    var merchant: OperationDetailInfoViewModel.BankCellViewModel? {
        
        guard let icon = merchantIcon,
              let image = ImageData(with: .init(description: icon))?.image,
              let name = merchantSubName
        else { return nil }
        
        return .init(
            title: "Наименование ТСП",
            icon: image,
            name: name
        )
    }
    
    var payeeName: OperationDetailInfoViewModel.PropertyCellViewModel? {
        
        let iconType = OperationDetailInfoViewModel.IconType.user.icon
        
        return payeeFullName.map { name in
            
                .init(
                    title: "Получатель",
                    iconType: iconType,
                    value: name
                )
        }
    }
}

private extension OperationDetailInfoViewModel.PropertyCellViewModel {
    
    convenience init(
        for cellType: CellType,
        iconType: OperationDetailInfoViewModel.IconType,
        value: String
    ) {
        self.init(
            title: cellType.rawValue,
            iconType: iconType.icon,
            value: value
        )
    }
    
    enum CellType: String {
        
        case payeeAccountNumber = "Номер счета получателя"
        case payeeINN = "ИНН получателя"
        case payeeKPP = "КПП получателя"
    }
}

//MARK: - Type

extension OperationDetailInfoViewModel {
    
    class DefaultCellViewModel: Identifiable {
        
        let id = UUID()
        let title: String
        
        internal init(title: String) {
            
            self.title = title
        }
    }
    
    class PropertyCellViewModel: DefaultCellViewModel{
        
        let iconType: Image?
        let value: String
        
        internal init(title: String, iconType: Image?, value: String) {
            
            self.iconType = iconType
            self.value = value
            super.init(title: title)
        }
    }
    
    class IconCellViewModel: DefaultCellViewModel {
        
        var icon: Image
        
        internal init(icon: Image) {
            
            self.icon = icon
            super.init(title: "title")
        }
    }
    
    class BankCellViewModel: DefaultCellViewModel {
        
        var icon: Image
        var name: String
        
        internal init(title: String, icon: Image, name: String) {
            
            self.icon = icon
            self.name = name
            super.init(title: title)
        }
    }
    
    class ProductCellViewModel: DefaultCellViewModel {
        
        var icon: Image
        var name: String
        var iconPaymentService: Image?
        var balance: String
        var description: String
        
        internal init(title: String, icon: Image, name: String, iconPaymentService: Image?, balance: String, description: String) {
            
            self.icon = icon
            self.name = name
            self.iconPaymentService = iconPaymentService
            self.balance = balance
            self.description = description
            super.init(title: title)
            
        }
    }
    
    enum PropertyIconType {
        
        case phone
        case user
        case balance
        case bank
        case commission
        case purpose
        case operationNumber
        case date
        case geo
        case account
        case file
        case cash
        case customer
        
        var icon: Image {
            
            switch self {
            case .balance: return Image("coins", bundle: nil)
            case .phone: return Image("smartphone", bundle: nil)
            case .user: return Image("person", bundle: nil)
            case .bank: return Image("BankIcon", bundle: nil)
            case .commission: return Image("percent-commission", bundle: nil)
            case .purpose: return Image("message", bundle: nil)
            case .operationNumber: return Image("hash", bundle: nil)
            case .date: return Image("date", bundle: nil)
            case .geo: return Image("map-pin", bundle: nil)
            case .account: return Image("file-hash", bundle: nil)
            case .file: return Image("file", bundle: nil)
            case .cash: return Image("Frame 579", bundle: nil)
            case .customer: return Image("customer", bundle: nil)
            }
        }
    }
}

// MARK: Preview content

extension OperationDetailInfoViewModel {
    
    static func detailMockData() -> OperationDetailInfoViewModel {
        
        return OperationDetailInfoViewModel(
            model: .emptyMock,
            logo: nil,
            cells: [
                PropertyCellViewModel(
                    title: "По номеру телефона",
                    iconType: IconType.phone.icon,
                    value: "+7 (962) 62-12-12"),
                PropertyCellViewModel(
                    title: "Получатель",
                    iconType: IconType.user.icon,
                    value: "Алексей Андреевич К."),
                BankCellViewModel(
                    title: "Банк получателя",
                    icon: Image("Bank Logo Sample"),
                    name: "СБЕР"),
                PropertyCellViewModel(
                    title: "Сумма перевода",
                    iconType: IconType.balance.icon,
                    value: "1 000,00 ₽"),
                PropertyCellViewModel(
                    title: "Комиссия",
                    iconType: IconType.commission.icon,
                    value: "10,20 ₽"),
                ProductCellViewModel(
                    title: "Счет списания",
                    icon: Image("card_sample"),
                    name: "Standart",
                    iconPaymentService: Image("card_mastercard_logo"),
                    balance: "10 ₽",
                    description: "· 4896 · Корпоративная"),
                PropertyCellViewModel(
                    title: "Назначение платежа",
                    iconType: IconType.purpose.icon,
                    value: "Оплата по договору №285"),
                PropertyCellViewModel(
                    title: "Номер операции СБП",
                    iconType: IconType.operationNumber.icon,
                    value: "B11271248585590B00001750251A3F95"),
                PropertyCellViewModel(
                    title: "Дата и время операции (МСК)",
                    iconType: IconType.date.icon,
                    value: "10.05.2021 15:38:12")],
            dismissAction: {})
    }
}
