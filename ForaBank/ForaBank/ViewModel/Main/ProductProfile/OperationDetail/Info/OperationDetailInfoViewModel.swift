//
//  DetailsViewModel.swift
//  ForaBank
//
//  Created by Дмитрий on 27.12.2021.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift

final class OperationDetailInfoViewModel: Identifiable {
    
    let id = UUID()
    let title = "Детали операции"
    var logo: Image?
    var cells: [DefaultCellViewModel]
    let dismissAction: () -> Void
    let model: Model
    
    init(model: Model, logo: Image?, cells: [DefaultCellViewModel], dismissAction: @escaping () -> Void) {
        
        self.model = model
        self.logo = nil
        self.cells = cells
        self.dismissAction = dismissAction
    }
    
    init(model: Model, operation: OperationDetailData, dismissAction: @escaping () -> Void) {
        
        self.model = model
        self.dismissAction = dismissAction
        self.cells = []
        
        cells = makeItems(operation: operation)
        
        switch operation.transferEnum {
        case .sfp:
            self.logo = .ic24Sbp
            
        default: break
        }
    }
    
    init?(with statement: ProductStatementData, operation: OperationDetailData?, product: ProductData, dismissAction: @escaping () -> Void, model: Model) {
        
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
        
        switch statement.paymentDetailType {
        case .otherBank:
            if let payeeCardNumber = operation?.payeeCardNumber {
                
                cells.append(PropertyCellViewModel(title: "Счет пополнения", iconType: .bank, value: payeeCardNumber))
            }
            
            if let amountCell = Self.amountCell(with: model, amount: statement.amount, currency: currency) {
                
                cells.append(amountCell)
            }
            
            if let fee = operation?.payerFee, let comissionCell = Self.commissionCell(with: model, fee: fee, currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let debitAccounCell = Self.accountCell(with: product, model: model, currency: currency, operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
        case .betweenTheir:
            
            if let payeeCardId = operation?.payeeCardId {
                
                for i in model.products.value {
                    
                    if let card = i.value.first(where: { $0.id == payeeCardId }) {
                        
                        if let description = card.number?.suffix(4),
                           let balance = card.balance,
                           let balanceFormatted = model.amountFormatted(amount: balance, currencyCode: card.currency, style: .clipped), let icon = card.smallDesign.image,
                           let additional = card.additionalField {
                            
                            cells.append(ProductCellViewModel(title: "Счет пополнения", icon: icon, name: card.mainField, iconPaymentService: nil, balance: balanceFormatted, description: "· \(description) · \(additional)"))
                        }
                    }
                }
            }
            
            if let amountCell = Self.amountCell(with: model, amount: statement.amount, currency: currency) {
                
                cells.append(amountCell)
            }
            
            if let fee = operation?.payerFee, let comissionCell = Self.commissionCell(with: model, fee: fee, currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let payerCardId = operation?.payerCardId {
                
                for i in model.products.value {
                    
                    if let card = i.value.first(where: { $0.id == payerCardId }) {
                        
                        if let description = card.number?.suffix(4),
                           let balance = card.balance,
                           let balanceFormatted = model.amountFormatted(amount: balance, currencyCode: card.currency, style: .clipped),
                           let icon = card.smallDesign.image,
                           let additional = card.additionalField {
                            
                            cells.append(ProductCellViewModel(title: "Счет списания", icon: icon, name: card.mainField, iconPaymentService: nil, balance: balanceFormatted, description: "· \(description) · \(additional)"))
                        }
                    }
                }
            }
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
        case .insideBank:
            
            if let payeeAccountNumber = operation?.payeeAccountNumber {
                
                cells.append(PropertyCellViewModel(title: "Номер счета получателя", iconType: .bank, value: payeeAccountNumber))
                
            } else if let payeeCardNumber = operation?.payeeCardNumber {
                
                cells.append(PropertyCellViewModel(title: "Номер карты получателя", iconType: .bank, value: payeeCardNumber))
                
            } else if let payeePhone = operation?.payeePhone {
                let phoneFormatter = PhoneNumberKitFormater()
                let formattedPhone = phoneFormatter.format(payeePhone)
                cells.append(PropertyCellViewModel(title: "Номер телефона получателя", iconType: .phone, value: formattedPhone))
            }
            
            cells.append(PropertyCellViewModel(title: "Получатель", iconType: .user, value: statement.merchant))
            cells.append(BankCellViewModel(title: "Банк получателя", icon:  foraBankIcon, name: foraBankName))
            
            if let amountCell = Self.amountCell(with: model, amount: statement.amount, currency: currency) {
                
                cells.append(amountCell)
            }
            
            if let fee = operation?.payerFee, let comissionCell = Self.commissionCell(with: model, fee: fee, currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let debitAccounCell = Self.accountCell(with: product, model: model, currency: currency, operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Назначение платежа", iconType: .purpose, value: statement.comment))
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
        case .contactAddressless:
            
            if let image = model.images.value[statement.md5hash]?.image {
                
                logo = image
            }
            
            cells.append(PropertyCellViewModel(title: "Получатель", iconType: .user, value: statement.merchant))
            
            if let countryName = operation?.countryName {
                
                cells.append(PropertyCellViewModel(title: "Страна", iconType: .geo, value: countryName))
            }
            
            if let amountCell = Self.amountCell(with: model, amount: statement.amount, currency: currency) {
                
                cells.append(amountCell)
            }
            
            if let fee = operation?.payerFee, let comissionCell = Self.commissionCell(with: model, fee: fee, currency: currency) {
                
                cells.append(comissionCell)
            }
                
            if let payeeAmount = operation?.payeeAmount, let payeeCurrency = operation?.payeeCurrency,
               let amountCell = Self.amountCell(with: model, title: "Сумма зачисления в валюте", amount: payeeAmount, currency: payeeCurrency) {
                
                cells.append(amountCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Способ выплаты", iconType: .cash, value: "Наличные"))
            
            
            if let debitAccounCell = Self.accountCell(with: product, model: model, currency: currency, operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            if let transferReference = operation?.transferReference  {
                
                cells.append(PropertyCellViewModel(title: "Номер перевода", iconType: .operationNumber, value: transferReference))
            }
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
        case .direct:
            
            let directLogoImage = Image("MigAvatar")
            logo = directLogoImage
            
            if let foreignPhoneNumber = operation?.payeePhone {
                let phoneFormatter = PhoneNumberKitFormater()
                let formattedPhone = phoneFormatter.format(foreignPhoneNumber)
                cells.append(PropertyCellViewModel(title: "Номер телефона получателя", iconType: .phone, value: formattedPhone))
                
            }
            
            cells.append(PropertyCellViewModel(title: "Получатель", iconType: .user, value: statement.merchant))
            
            if let memberId = operation?.memberId,
               let bank = bankList.first(where: { $0.memberId == memberId }) {
                
                let bankLogoSVG = bank.svgImage.image
                let name = bank.memberNameRus
                guard let bankLogoImage = bankLogoSVG else { return }
                
                cells.append(BankCellViewModel(title: "Банк получателя", icon: bankLogoImage, name: name))
            }
            
            if let countryName = operation?.countryName {
                
                cells.append(PropertyCellViewModel(title: "Страна", iconType: .geo, value: countryName))
            }
            
            if let amountCell = Self.amountCell(with: model, amount: statement.amount, currency: currency) {
                
                cells.append(amountCell)
            }
            
            if let fee = operation?.payerFee, let comissionCell = Self.commissionCell(with: model, fee: fee, currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let payeeAmount = operation?.payeeAmount, let payeeCurrency = operation?.payeeCurrency,
               let amountCell = Self.amountCell(with: model, title: "Сумма зачисления в валюте", amount: payeeAmount, currency: payeeCurrency) {
                
                cells.append(amountCell)
            }
            
            if let debitAccounCell = Self.accountCell(with: product, model: model, currency: currency, operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            if let transferReference = operation?.transferReference  {
                
                cells.append(PropertyCellViewModel(title: "Номер перевода", iconType: .operationNumber, value: transferReference))
            }
            
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
        case .externalIndivudual:
            
            if let payeeFullName = operation?.payeeFullName {
                
                cells.append(PropertyCellViewModel(title: "Получатель", iconType: .user, value: payeeFullName))
            }
            
            if let payeeAccountNumber = operation?.payeeAccountNumber {
                
                cells.append(PropertyCellViewModel(title: "Номер счета получателя", iconType: .account, value: payeeAccountNumber))
                
            } else if let payeeCardNumber = operation?.payeeCardNumber {
                
                cells.append(PropertyCellViewModel(title: "Номер счета получателя", iconType: .account, value: payeeCardNumber))
            }
            
            if let bankBic = operation?.payeeBankBIC,
               let bank = model.dictionaryFullBankInfoBank(for: bankBic),
               let bankLogoImage = bank.svgImage.image {
                
                cells.append(BankCellViewModel(title: "Бик банка получателя", icon: bankLogoImage, name: bankBic))
            }
            
            if let amountCell = Self.amountCell(with: model, amount: statement.amount, currency: currency) {
                
                cells.append(amountCell)
            }
            
            if let fee = operation?.payerFee, let comissionCell = Self.commissionCell(with: model, fee: fee, currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let debitAccounCell = Self.accountCell(with: product, model: model, currency: currency, operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Назначение платежа", iconType: .purpose, value: statement.comment))
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
        case .externalEntity:
            
            if let payeeFullName = operation?.payeeFullName {
                
                cells.append(PropertyCellViewModel(title: "Наименование получателя", iconType: .nil, value: payeeFullName))
            }
            
            if let payeeAccountNumber = operation?.payeeAccountNumber {
                
                cells.append(PropertyCellViewModel(title: "Номер счета получателя", iconType: .account, value: payeeAccountNumber))
            }
            
            if let payeeINN = operation?.payeeINN  {
                
                cells.append(PropertyCellViewModel(title: "ИНН получателя", iconType: .nil, value: payeeINN))
            }
            
            if let payeeKPP = operation?.payeeKPP {
                
                cells.append(PropertyCellViewModel(title: "КПП получателя", iconType: .nil, value: payeeKPP))
            }
                
            if let bankBic = operation?.payeeBankBIC,
               let bank = model.dictionaryFullBankInfoBank(for: bankBic),
               let bankLogoImage = bank.svgImage.image {
                
                cells.append(BankCellViewModel(title: "Банк получателя", icon: bankLogoImage, name: bankBic))
            }
            
            if let amountCell = Self.amountCell(with: model, amount: statement.amount, currency: currency) {
                
                cells.append(amountCell)
            }
            
            if let fee = operation?.payerFee, let comissionCell = Self.commissionCell(with: model, fee: fee, currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let debitAccounCell = Self.accountCell(with: product, model: model, currency: currency, operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Назначение платежа", iconType: .purpose, value: statement.comment))
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
        case .insideOther:
            
            if let image = model.images.value[statement.md5hash]?.image {
                
                cells.append(BankCellViewModel(title: "Наименование операции", icon: image, name: statement.merchant))
            }
            
            cells.append(PropertyCellViewModel(title: "Категория операции", iconType: .nil, value: statement.groupName))

            if let amountCell = Self.amountCell(with: model, amount: statement.amount, currency: currency) {
                
                cells.append(amountCell)
            }

            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
            
        case .mobile:
            
            if let image = model.images.value[statement.md5hash]?.image {
                
                logo = image
            }
            
            if let payeePhone = operation?.payeePhone {
                let phoneFormatter = PhoneNumberKitFormater()
                let formattedPhone = phoneFormatter.format(payeePhone)
                cells.append(PropertyCellViewModel(title: "Номер телефона", iconType: .phone, value: formattedPhone))
                
            }
            
            if let provider = operation?.provider, let image = model.images.value[statement.md5hash]?.image {
                
                cells.append(BankCellViewModel(title: "Наименование получателя", icon: image, name: provider))
            }
            
            if let amountCell = Self.amountCell(with: model, amount: statement.amount, currency: currency) {
                
                cells.append(amountCell)
            }
            
            if let fee = operation?.payerFee, let comissionCell = Self.commissionCell(with: model, fee: fee, currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let debitAccounCell = Self.accountCell(with: product, model: model, currency: currency, operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
        case .internet:
            
            if let image = model.images.value[statement.md5hash]?.image {
                
                logo = image
                
                cells.append(BankCellViewModel(title: "Наименование получателя", icon: image, name: statement.merchant))
            }
            
            if let account = operation?.account {
                
                cells.append(PropertyCellViewModel(title: "Номер счета получателя", iconType: .account, value: account))
            }
            
            if let amountCell = Self.amountCell(with: model, amount: statement.amount, currency: currency) {
                
                cells.append(amountCell)
            }
            
            if let fee = operation?.payerFee, let comissionCell = Self.commissionCell(with: model, fee: fee, currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let debitAccounCell = Self.accountCell(with: product, model: model, currency: currency, operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
        case .housingAndCommunalService:
            
            if let image = model.images.value[statement.md5hash]?.image {
                
                logo = image
                
                cells.append(BankCellViewModel(title: "Наименование получателя", icon: image, name: statement.merchant))
            }
            
            if let payeeINN = operation?.payeeINN  {
                
                cells.append(PropertyCellViewModel(title: "ИНН получателя", iconType: .nil, value: payeeINN))
            }
            
            if let period = operation?.period {
                
                cells.append(PropertyCellViewModel(title: "Период оплаты", iconType: .date, value: period))
            }
            
            if let account = operation?.account {
                
                cells.append(PropertyCellViewModel(title: "Код плательщика", iconType: .account, value: account))
            }
            
            if let amountCell = Self.amountCell(with: model, amount: statement.amount, currency: currency) {
                
                cells.append(amountCell)
            }
            
            if let fee = operation?.payerFee, let comissionCell = Self.commissionCell(with: model, fee: fee, currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let debitAccounCell = Self.accountCell(with: product, model: model, currency: currency, operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
            
        case .notFinance:
            return nil
            
        case .outsideCash:
            
            if let debitAccounCell = Self.accountCell(with: product, model: model, currency: currency, operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            if let amountCell = Self.amountCell(with: model, amount: statement.amount, currency: currency) {
                
                cells.append(amountCell)
            }
            
            if let fee = operation?.payerFee, let comissionCell = Self.commissionCell(with: model, fee: fee, currency: currency) {
                
                cells.append(comissionCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
        case .outsideOther:
            
            if let image = model.images.value[statement.md5hash]?.image {
                
                logo = image
                
                cells.append(BankCellViewModel(title: "Наименование получателя", icon: image, name: statement.merchant))
            }
                    
            if let mcc = statement.mcc {
                
                cells.append(PropertyCellViewModel(title: "Категория операции", iconType: .nil, value: "\(statement.groupName) (\(mcc))"))
            } else {
                
                cells.append(PropertyCellViewModel(title: "Категория операции", iconType: .nil, value: "\(statement.groupName)"))
            }
            
            if let formattedAmount = model.amountFormatted(amount: statement.amount, currencyCode: currency, style: .fraction) {
                
                let amount = statement.operationType == .credit ? "+ \(formattedAmount)" : formattedAmount
                cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: amount))
            }
            
            if let fee = operation?.payerFee, let comissionCell = Self.commissionCell(with: model, fee: fee, currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let debitAccounCell = Self.accountCell(with: product, model: model, currency: currency, operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
            
        case .sfp:
            
            let sfpLogoImage = Image("sbp-logo")
            logo = sfpLogoImage
            
            if statement.operationType == .credit {
                
                if let foreignPhoneNumber = statement.fastPayment?.foreignPhoneNumber {
                    let phoneFormatter = PhoneNumberKitFormater()
                    let formattedPhone = phoneFormatter.format(foreignPhoneNumber)
                    cells.append(PropertyCellViewModel(title: "Номер телефона отправителя", iconType: .phone, value: formattedPhone))
                    
                }
                
                cells.append(PropertyCellViewModel(title: "Отправитель", iconType: .user, value: statement.merchant))
                
            } else if statement.operationType == .debit {
                
                if let foreignPhoneNumber = statement.fastPayment?.foreignPhoneNumber {
                    let phoneFormatter = PhoneNumberKitFormater()
                    let formattedPhone = phoneFormatter.format(foreignPhoneNumber)
                    cells.append(PropertyCellViewModel(title: "Номер телефона получателя", iconType: .phone, value: formattedPhone))
                    
                }
                
                cells.append(PropertyCellViewModel(title: "Получатель", iconType: .user, value: statement.merchant))
            }
            
            if let bankName = statement.fastPayment?.foreignBankName, statement.operationType == .debit {
                cells.append(BankCellViewModel(title: "Банк получателя", icon:  model.images.value[statement.md5hash]?.image ?? Image.ic12LogoForaColor, name: bankName))
            } else if let bankName = statement.fastPayment?.foreignBankName {
                cells.append(BankCellViewModel(title: "Банк отправителя", icon:  model.images.value[statement.md5hash]?.image ?? Image.ic12LogoForaColor, name: bankName))
            }
            
            if let formattedAmount = model.amountFormatted(amount: statement.amount, currencyCode: currency, style: .fraction) {
                
                let amount = statement.operationType == .credit ? "+ \(formattedAmount)" : formattedAmount
                cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: amount))
            }
            
            if let fee = operation?.payerFee, let comissionCell = Self.commissionCell(with: model, fee: fee, currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let debitAccounCell = Self.accountCell(with: product, model: model, currency: currency, operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            if let documentComment = statement.fastPayment?.documentComment, documentComment != "" {
                
                cells.append(PropertyCellViewModel(title: "Назначение платежа", iconType: .purpose, value: documentComment))
            }
            
            if let transferNumber = operation?.transferNumber {
                
                cells.append(PropertyCellViewModel(title: "Номер операции СБП", iconType: .operationNumber, value: transferNumber))
            }
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
        case .transport:
            
            if let image = model.images.value[statement.md5hash]?.image {
                
                logo = image
                
                cells.append(BankCellViewModel(title: "Наименование получателя", icon: image, name: statement.merchant))
            }
            
            if let accountTitle = operation?.accountTitle, let account =  operation?.account{
                if operation?.isTrafficPoliceService == true{
                    cells.append(PropertyCellViewModel(title: accountTitle, iconType: .account, value: account))
                } else {
                    cells.append(PropertyCellViewModel(title: accountTitle, iconType: .operationNumber, value: account))
                }
            }
            
            if let formattedAmount = model.amountFormatted(amount: statement.amount, currencyCode: currency, style: .fraction) {
                
                let amount = statement.operationType == .credit ? "+ \(formattedAmount)" : formattedAmount
                cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: amount))
            }
            
            if let fee = operation?.payerFee, let comissionCell = Self.commissionCell(with: model, fee: fee, currency: currency) {
                
                cells.append(comissionCell)
            }
            
            if let debitAccounCell = Self.accountCell(with: product, model: model, currency: currency, operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
        case .c2b:
            logo = Image("sbp-logo")
            
            let bankImage: Image? = {
                
                guard let bank = model.dictionaryFullBankInfoList().first(where: { $0.bic == statement.fastPayment?.foreignBankBIC }),
                      let uiImage = bank.svgImage.uiImage else {
                    return nil
                }
                
                return .init(uiImage: uiImage)
            }()
            
            if let formattedAmount = model.amountFormatted(amount: statement.amount, currencyCode: currency, style: .fraction) {
                
                let amount = statement.operationType == .credit ? "+ \(formattedAmount)" : formattedAmount
                cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: amount))
            }
            
            if let image = model.images.value[statement.md5hash]?.image {
                
                cells.append(BankCellViewModel(title: "Наименование ТСП", icon: image, name: statement.merchant))
            }
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
            if let status = operation?.operationStatus {
             
                let title = "Статус операции"
                switch status {
                    
                case .complete:
                    cells.append(BankCellViewModel(title: title, icon: Image("OkOperators"), name: "Успешно"))
                    
                case .inProgress:
                    cells.append(BankCellViewModel(title: title, icon: Image("waiting"), name: "В обработке"))

                case .rejected:
                    cells.append(BankCellViewModel(title: title, icon: Image("rejected"), name: "Отказ"))

                case .unknown:
                    break
                }
                
            } else if let isCancellation = statement.isCancellation, isCancellation {
                
                cells.append(BankCellViewModel(title: title, icon: Image("rejected"), name: "Отказ"))
                
            } else if operation == nil, statement.isCancellation == nil {
                
                cells.append(BankCellViewModel(title: title, icon: Image("OkOperators"), name: "Успешно"))
            }
            
            if let debitAccounCell = Self.accountCell(with: product, model: model, currency: currency, operationType: statement.operationType) {
            
                cells.append(debitAccounCell)
            }
            
            let payeerLabel = statement.operationType == .debit ? "Получатель" : "Отправитель"
            
            cells.append(BankCellViewModel(title: payeerLabel, icon: Image("hash"), name: statement.fastPayment?.foreignName ?? ""))
            if let bankName = statement.fastPayment?.foreignBankName, statement.operationType == .debit {
                
                cells.append(BankCellViewModel(title: "Банк получателя", icon:  bankImage ?? Image("BankIcon"), name: bankName))
                
            } else if let bankName = statement.fastPayment?.foreignBankName {
                
                cells.append(BankCellViewModel(title: "Банк отправителя", icon: bankImage ?? Image("BankIcon"), name: bankName))
            }
            
            if let comment = statement.fastPayment?.documentComment {
            
                cells.append(BankCellViewModel(title: "Сообщение получателю", icon: Image("hash"), name: comment))
            }
            
            cells.append(BankCellViewModel(title: "Идентификатор операции", icon: Image("hash"), name: statement.fastPayment?.opkcid ?? ""))
            cells.append(IconCellViewModel(icon: Image("sbptext")))
        
        case .insideDeposit:

            if let image = model.images.value[statement.md5hash]?.image {
                
                cells.append(BankCellViewModel(title: "Наименование получателя", icon: image, name: statement.merchant))
            }
            
            if let formattedAmount = model.amountFormatted(amount: statement.amount, currencyCode: currency, style: .clipped) {
                
                let amount = statement.operationType == .credit ? "+ \(formattedAmount)" : formattedAmount
                cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: amount))
            }
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))

        default:
            //FIXME: implement taxes
            break
        }
        
        self.logo = logo
        //FIXME: why dismissAction is commented?
        //        self.dismissAction = dismissAction
    }
}

//MARK: - Private helpers

private extension OperationDetailInfoViewModel {
    
    static func accountCell(with product: ProductData, model: Model, currency: String, operationType: OperationType) -> DefaultCellViewModel? {
        
        let productCurrency = product.currency
        let title = operationType == .debit ? "Счет списания" : "Счет зачисления"
        
        guard let smallDesign = product.smallDesign.image,
              let description = product.number?.suffix(4),
              let balanceString = model.amountFormatted(amount: product.balanceValue, currencyCode: productCurrency, style: .clipped) else  {
            return nil
        }
        
        let productName = product.mainField
        
        if let additionalField = product.additionalField {
         
            return ProductCellViewModel(title: title, icon: smallDesign, name: productName, iconPaymentService: nil, balance: balanceString, description: "· \(description) · \(additionalField)")
        } else {
            
            return ProductCellViewModel(title: title, icon: smallDesign, name: productName, iconPaymentService: nil, balance: balanceString, description: "· \(description)")
        }
    }
    
    static func commissionCell(with model: Model, icon: PropertyIconType = .commission, fee: Double, currency: String) -> PropertyCellViewModel? {
        
        guard let feeFormatted = model.amountFormatted(amount: fee, currencyCode: currency, style: .clipped) else {
            return nil
        }
        
        return .init(title: "Коммиссия", iconType: .commission, value: feeFormatted)
    }
    
    static func amountCell(with model: Model, title: String = "Сумма перевода", icon: PropertyIconType = .balance, amount: Double, currency: String) -> PropertyCellViewModel? {
        
        guard let amountFormatted = model.amountFormatted(amount: amount, currencyCode: currency, style: .clipped) else {
            return nil
        }

        return .init(title: title, iconType: .balance, value: amountFormatted)
    }
}

// MARK: - Methods

extension OperationDetailInfoViewModel {
    
    private func makeItems(operation: OperationDetailData) -> [DefaultCellViewModel] {
        
        let payeeProductId = [operation.payeeCardId, operation.payeeAccountId].compactMap {$0}.first
        let payeeProductNumber = [operation.payeeCardNumber, operation.payeeAccountNumber].compactMap {$0}.first
        
        let payerProductId = [operation.payerCardId, operation.payerAccountId].compactMap {$0}.first
        let payerProductNumber = [operation.payerCardNumber, operation.payerAccountNumber].compactMap {$0}.first
        
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
                amountViewModel,
                commissionViewModel,
                payerViewModel,
                purposeViewModel,
                dateViewModel
            ]
            
            if let payeeAmount = operation.payeeAmount,
               let payeeCurrency = operation.payeeCurrency,
               let formattedAmount = model.amountFormatted(amount: payeeAmount, currencyCode: payeeCurrency, style: .fraction) {
                
                directCells.insert((PropertyCellViewModel.init(title: "Сумма зачисления в валюте", iconType: .balance, value: formattedAmount)), at: 5)
            }
            
            let payeeAmount = operation.payerAmount
            let payeeCurrency = operation.payerCurrency
            if let formattedAmount = model.amountFormatted(amount: payeeAmount, currencyCode: payeeCurrency, style: .fraction) {
                
                directCells.insert((PropertyCellViewModel.init(title: "Сумма списания", iconType: .balance, value: formattedAmount)), at: 6)
            }
            
            return directCells.compactMap {$0}
            
        case .contactAddressing, .contactAddressingCash, .contactAddressless:

           if let method = operation.paymentMethod,
              let transferReference = operation.transferReference,
              let countryName = operation.countryName {
               
               let methodViewModel = PropertyCellViewModel(title: "Способ выплаты",
                                                           iconType: .cash,
                                                           value: method.rawValue)
               
               let transferReferenceViewModel = PropertyCellViewModel(title: "Номер перевода",
                                                           iconType: .operationNumber,
                                                            value: transferReference)
               
               let countryViewModel = PropertyCellViewModel(title: "Страна",
                                                            iconType: .geo,
                                                            value: countryName)
               
               if let formattedAmount = model.amountFormatted(amount: operation.payerAmount, currencyCode: operation.payerCurrency, style: .fraction),
                  let amount = operation.payeeAmount,
                  let payeeAmount = model.amountFormatted(amount: amount, currencyCode: operation.payeeCurrency, style: .fraction) {
                
                   let transferAmount = PropertyCellViewModel(title: "Сумма списания", iconType: .balance, value: formattedAmount)
                   
                   let amount = PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: payeeAmount)
                   
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
            switch operation.externalTransferType {
            case .entity:
                return [
                    payeeNameViewModel,
                    payeeViewModel,
                    payeeBankViewModel,
                    amountViewModel,
                    commissionViewModel,
                    payerViewModel,
                    purposeViewModel,
                    dateViewModel].compactMap { $0 }

            default:
                var cells = [DefaultCellViewModel?]()
                cells.append(contentsOf: [
                    payeeNameViewModel,
                    payeeViewModel
                ])
                
                if let payeeINN = operation.payeeINN {
                    
                    cells.append(PropertyCellViewModel(title: "ИНН получателя", iconType: .nil, value: payeeINN))
                }
                
                if let payeeKPP = operation.payeeKPP {
                    
                    cells.append(PropertyCellViewModel(title: "КПП получателя", iconType: .nil, value: payeeKPP))
                }

                cells.append(contentsOf: [
                    payeeBankViewModel,
                    amountViewModel,
                    commissionViewModel,
                    payerViewModel,
                    purposeViewModel,
                    dateViewModel
                ])
                
                return cells.compactMap { $0 }
            }
            
        default:
            
            return [
                payerViewModel,
                amountViewModel,
                commissionViewModel,
                payeeViewModel,
                dateViewModel].compactMap {$0}
        }
    }
    
    func makePropertyViewModel(productId: Int?, operation: OperationDetailData, iconType: PropertyIconType) -> PropertyCellViewModel? {
        
        guard let productId = productId,
              let productData = model.product(productId: productId) ?? model.product(additionalId: productId) else {
            return nil
        }
        
        switch iconType {
        case .balance:
            
            let formattedAmount = model.amountFormatted(amount: operation.payerAmount, currencyCode: operation.payerCurrency, style: .fraction)
            
            guard let formattedAmount = formattedAmount else {
                return nil
            }
            
            return .init(title: "Сумма перевода", iconType: .balance, value: formattedAmount)
            
        case .commission:
            
            let payerFee = model.amountFormatted(amount: operation.payerFee, currencyCode: productData.currency, style: .fraction)
            
            guard let payerFee = payerFee else {
                return nil
            }
            
            return .init(title: "Комиссия", iconType: .commission, value: payerFee)

        case .purpose:
            //FIXME: backend send "" if comment nil
            guard let comment = operation.comment, operation.comment != "" else {
                return nil
            }
            
            return .init(title: "Назначение платежа", iconType: .purpose, value: comment)

        case .date:
            switch operation.transferEnum {
            case .depositClose:
                return .init(title: "Тип платежа", iconType: .date, value: "Закрытие вклада")
            default:
                return .init(title: "Дата и время операции (МСК)", iconType: .date, value: operation.responseDate)
            }
            
        case .phone:
            
            guard let payeePhone = operation.payeePhone else {
                return nil
            }
            
            let phoneFormatter = PhoneNumberKitFormater()
            
            //TODO: remove after backend will be send number with country code
            if operation.transferEnum == .sfp {
                
                let formattedPhone = phoneFormatter.format("7\(payeePhone)")
                return .init(title: "Номер телефона получателя", iconType: .phone, value: formattedPhone)

            } else {
                
                let formattedPhone = phoneFormatter.format(payeePhone)
                return .init(title: "Номер телефона получателя", iconType: .phone, value: formattedPhone)
            }
                
        case .user:
            
            guard let payeeName = operation.payeeFullName else {
                return nil
            }

            return .init(title: "Получатель", iconType: .user, value: payeeName)

        case .operationNumber:
            
            guard let transferNumber = operation.transferNumber else {
                return nil
            }

            return .init(title: "Номер операции СБП", iconType: .operationNumber, value: transferNumber)

        default:
            return nil
        }
    }
    
    private func makeProductViewModel(title: String, productId: Int?, productNumber: String?) -> ProductCellViewModel? {
        
        guard let productId = productId,
              let productData = model.product(productId: productId) ?? model.product(additionalId: productId),
              let icon = productData.smallDesign.image,
              let balance = productData.balance,
              let formattedBalance = model.amountFormatted(amount: balance, currencyCode: productData.currency, style: .fraction) else {
            return nil
        }
        
        var image: Image? = nil
        
        if let productCardData = productData as? ProductCardData,
           let paymentSystemImage = productCardData.paymentSystemImage {
            image = paymentSystemImage.image
        }
        
        let productNumber = productNumber ?? ""
        let lastNumber = productNumber.isEmpty == false ? "• \(productNumber.suffix(4)) • " : ""
        let name = ProductView.ViewModel.name(product: productData, style: .main)
        let description = productData.additionalField ?? ""
        
        let viewModel: ProductCellViewModel = .init(title: title, icon: icon, name: name, iconPaymentService: image, balance: formattedBalance, description: "\(lastNumber)\(description)")
        
        return viewModel
    }
    
    private func makeBankViewModel(operation: OperationDetailData) -> BankCellViewModel? {
         
        guard let bankName = operation.payeeBankName,
              let memberId = operation.memberId else {
            
            return nil
        }
        
        let title = "Банк получателя"
        
        if let md5hash = model.bankList.value.first(where: {$0.memberId == "EVOCA"})?.md5hash,
           let icon = model.images.value[md5hash]?.image {

            return BankCellViewModel(title: title, icon: icon, name: bankName)

        } else if let icon = model.dictionaryBankList.first(where: {$0.memberId == memberId})?.svgImage.image {
            
            return BankCellViewModel(title: title, icon: icon, name: bankName)

        } else {
            
            return BankCellViewModel(title: title, icon: Image("BankIcon"), name: bankName)
        }
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
        
        let iconType: PropertyIconType?
        let value: String
        
        internal init(title: String, iconType: OperationDetailInfoViewModel.PropertyIconType, value: String) {
            
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
        case `nil`
        
        var icon: Image {
            
            switch self {
            case .balance: return Image("coins", bundle: nil)
            case .phone: return Image("smartphone", bundle: nil)
            case .user: return Image("person", bundle: nil)
            case .bank: return Image("BankIcon", bundle: nil)
            case .commission: return Image("percent", bundle: nil)
            case .purpose: return Image("message", bundle: nil)
            case .operationNumber: return Image("hash", bundle: nil)
            case .date: return Image("date", bundle: nil)
            case .geo: return Image("map-pin", bundle: nil)
            case .account: return Image("accaunt", bundle: nil)
            case .file: return Image("file", bundle: nil)
            case .cash: return Image("Frame 579", bundle: nil)
            case .nil: return Image("", bundle: nil)
                
            }
        }
    }
}

extension OperationDetailInfoViewModel {
    
    static let detailMockData: OperationDetailInfoViewModel = {
        
        return OperationDetailInfoViewModel(model: .emptyMock, logo: nil, cells: [PropertyCellViewModel(title: "По номеру телефона", iconType: .phone, value: "+7 (962) 62-12-12"),
                                                               PropertyCellViewModel(title: "Получатель", iconType: .user, value: "Алексей Андреевич К."),
                                                               BankCellViewModel(title: "Банк получателя", icon: Image("Bank Logo Sample"), name: "СБЕР"),
                                                               PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: "1 000,00 ₽"),
                                                               PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: "10,20 ₽"),
                                                               ProductCellViewModel(title: "Счет списания", icon: Image("card_sample"), name: "Standart", iconPaymentService: Image("card_mastercard_logo"), balance: "10 ₽", description: "· 4896 · Корпоративная"),
                                                               PropertyCellViewModel(title: "Назначение платежа", iconType: .purpose, value: "Оплата по договору №285"),
                                                               PropertyCellViewModel(title: "Номер операции СБП", iconType: .operationNumber, value: "B11271248585590B00001750251A3F95"),
                                                               PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: "10.05.2021 15:38:12")
                                                              ], dismissAction: {})
        
    }()
}
