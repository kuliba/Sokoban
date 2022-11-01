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
    
    init(logo: Image?, cells: [DefaultCellViewModel], dismissAction: @escaping () -> Void, model: Model) {
        
        self.logo = nil
        self.cells = cells
        self.dismissAction = dismissAction
        self.model = model
        
    }
    
    init(model: Model, operation: OperationDetailData, dismissAction: @escaping () -> Void) {
        
        self.model = model
        self.dismissAction = dismissAction
        self.cells = []
        
        cells = makeItems(operation: operation)
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
            
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let payerFee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: payerFee.currencyFormatter(symbol: currency)))
            }
            
            if let debitAccounCell = Self.accountCell(with: product, currency: currency, operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
        case .betweenTheir:
            
            if let payeeCardId = operation?.payeeCardId {
                
                for i in model.products.value {
                    
                    if let card = i.value.first(where: { $0.id == payeeCardId }) {
                        
                        if let description = card.number?.suffix(4), let balance = card.balance?.currencyFormatter(symbol: card.currency), let icon = card.smallDesign.image, let additional = card.additionalField {
                            
                            cells.append(ProductCellViewModel(title: "Счет пополнения", icon: icon, name: card.mainField, iconPaymentService: nil, balance: balance, description: "· \(description) · \(additional)"))
                        }
                    }
                }
            }
            
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let payerFee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: payerFee.currencyFormatter(symbol: currency)))
            }
            
            if let payerCardId = operation?.payerCardId {
                
                for i in model.products.value {
                    
                    if let card = i.value.first(where: { $0.id == payerCardId }) {
                        
                        if let description = card.number?.suffix(4), let balance = card.balance?.currencyFormatter(symbol: card.currency), let icon = card.smallDesign.image, let additional = card.additionalField {
                            
                            cells.append(ProductCellViewModel(title: "Счет списания", icon: icon, name: card.mainField, iconPaymentService: nil, balance: balance, description: "· \(description) · \(additional)"))
                        }
                    }
                }
            }
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
        case  .insideBank:
            
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
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
            }
            
            if let debitAccounCell = Self.accountCell(with: product, currency: currency, operationType: statement.operationType) {
                
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
            
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
            }
            
            if let payeeAmount = operation?.payeeAmount, let payeeCurrency = operation?.payeeCurrency {
                
                cells.append(PropertyCellViewModel(title: "Сумма зачисления в валюте", iconType: .balance, value: payeeAmount.currencyFormatter(symbol: payeeCurrency)))
            }
            
            cells.append(PropertyCellViewModel(title: "Способ выплаты", iconType: .cash, value: "Наличные"))
            
            
            if let debitAccounCell = Self.accountCell(with: product, currency: currency, operationType: statement.operationType) {
                
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
            
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
            }
            
            if let payeeAmount = operation?.payeeAmount, let payeeCurrency = operation?.payeeCurrency {
                
                cells.append(PropertyCellViewModel(title: "Сумма зачисления в валюте", iconType: .balance, value: payeeAmount.currencyFormatter(symbol: payeeCurrency)))
            }
            
            if let debitAccounCell = Self.accountCell(with: product, currency: currency, operationType: statement.operationType) {
                
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
            
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
            }
            
            if let debitAccounCell = Self.accountCell(with: product, currency: currency, operationType: statement.operationType) {
                
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
            
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
            }
            
            if let debitAccounCell = Self.accountCell(with: product, currency: currency, operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Назначение платежа", iconType: .purpose, value: statement.comment))
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
        case .insideOther:
            
            if let image = model.images.value[statement.md5hash]?.image {
                
                cells.append(BankCellViewModel(title: "Наименование операции", icon: image, name: statement.merchant))
            }
            
            cells.append(PropertyCellViewModel(title: "Категория операции", iconType: .nil, value: statement.groupName))
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
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
            
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
            }
            
            if let debitAccounCell = Self.accountCell(with: product, currency: currency, operationType: statement.operationType) {
                
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
            
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
            }
            
            if let debitAccounCell = Self.accountCell(with: product, currency: currency, operationType: statement.operationType) {
                
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
            
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
            }
            
            if let debitAccounCell = Self.accountCell(with: product, currency: currency, operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
            
        case .notFinance:
            return nil
            
        case .outsideCash:
            
            if let debitAccounCell = Self.accountCell(with: product, currency: currency, operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
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
            
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
            }
            
            if let debitAccounCell = Self.accountCell(with: product, currency: currency, operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
            
        case .sfp:
            
            let sfpLogoImage = Image("sbp-logo")
            logo = sfpLogoImage
            
            if let foreignPhoneNumber = statement.fastPayment?.foreignPhoneNumber {
                let phoneFormatter = PhoneNumberKitFormater()
                let formattedPhone = phoneFormatter.format(foreignPhoneNumber)
                cells.append(PropertyCellViewModel(title: "Номер телефона получателя", iconType: .phone, value: formattedPhone))
                
            }
            
            cells.append(PropertyCellViewModel(title: "Получатель", iconType: .user, value: statement.merchant))
            
            if let bankName = statement.fastPayment?.foreignBankName, statement.operationType == .debit {
                cells.append(BankCellViewModel(title: "Банк получателя", icon:  model.images.value[statement.md5hash]?.image ?? Image.ic12LogoForaColor, name: bankName))
            } else if let bankName = statement.fastPayment?.foreignBankName {
                cells.append(BankCellViewModel(title: "Банк отправителя", icon:  model.images.value[statement.md5hash]?.image ?? Image.ic12LogoForaColor, name: bankName))
            }
            
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
            }
            
            if let debitAccounCell = Self.accountCell(with: product, currency: currency, operationType: statement.operationType) {
                
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
            
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
            }
            
            if let debitAccounCell = Self.accountCell(with: product, currency: currency, operationType: statement.operationType) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
        case .c2b:
            logo = Image("sbp-logo")
            let allBanks = Model.shared.dictionaryFullBankInfoList()
            let foundBank = allBanks?.filter({ $0.bic == statement.fastPayment?.foreignBankBIC })
            var imageBank: Image? = nil
            if foundBank != nil && foundBank?.count ?? 0 > 0 {
                _ = foundBank?.first?.rusName ?? ""
                let bankIconSvg = foundBank?.first?.svgImage
                if let image = bankIconSvg?.uiImage{
                    
                    imageBank = Image.init(uiImage: image)
                }
            }
            let amount = statement.operationType == .credit ? "+ \(statement.amount.currencyFormatter(symbol: currency))" : statement.amount.currencyFormatter(symbol: currency)
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: amount))
            
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
            
            if let debitAccounCell = Self.accountCell(with: product, currency: currency, operationType: statement.operationType) {
            
                cells.append(debitAccounCell)
            }
            
            let payeerLabel = statement.operationType == .debit ? "Получатель" : "Отправитель"
            
            cells.append(BankCellViewModel(title: payeerLabel, icon: Image("hash"), name: statement.fastPayment?.foreignName ?? ""))
            if let bankName = statement.fastPayment?.foreignBankName, statement.operationType == .debit {
                
                cells.append(BankCellViewModel(title: "Банк получателя", icon:  imageBank ?? Image("BankIcon"), name: bankName))
                
            } else if let bankName = statement.fastPayment?.foreignBankName {
                
                cells.append(BankCellViewModel(title: "Банк отправителя", icon: imageBank ?? Image("BankIcon"), name: bankName))
            }
            
            if let comment = statement.fastPayment?.documentComment {
            
                cells.append(BankCellViewModel(title: "Сообщение получателю", icon: Image("hash"), name: comment))
            }
            
            cells.append(BankCellViewModel(title: "Идентификатор операции", icon: Image("hash"), name: statement.fastPayment?.opkcid ?? ""))
            cells.append(IconCellViewModel(icon: Image("sbptext")))
            
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
    
    static func accountCell(with product: ProductData, currency: String, operationType: OperationType) -> DefaultCellViewModel? {
        
        let productCurrency = product.currency
        let title = operationType == .debit ? "Счет списания" : "Счет зачисления"
        
        guard let smallDesign = product.smallDesign.image,
              let description = product.number?.suffix(4),
              let balanceString = product.balance?.currencyFormatter(symbol: productCurrency) else  {
            return nil
        }
        
        let productName = product.mainField
        
        if let additionalField = product.additionalField {
         
            return ProductCellViewModel(title: title, icon: smallDesign, name: productName, iconPaymentService: nil, balance: balanceString, description: "· \(description) · \(additionalField)")
        } else {
            
            return ProductCellViewModel(title: title, icon: smallDesign, name: productName, iconPaymentService: nil, balance: balanceString, description: "· \(description)")
        }
    }
}

// MARK: - Methods

extension OperationDetailInfoViewModel {
    
    private func makeItems(operation: OperationDetailData) -> [DefaultCellViewModel] {
        
        let payeeProductId = [operation.payeeCardId, operation.payeeAccountId].compactMap {$0}.first
        let payeeProductNumber = [operation.payeeCardNumber, operation.payeeAccountNumber].compactMap {$0}.first
        
        let payerProductId = [operation.payerCardId, operation.payerAccountId].compactMap {$0}.first
        let payerProductNumber = [operation.payerCardNumber, operation.payerAccountNumber].compactMap {$0}.first
        
        let payeeViewModel = makeProductViewModel(
            title: "Счет пополнения",
            productId: payeeProductId,
            productNumber: payeeProductNumber)
        
        let balanceViewModel = makePropertyViewModel(
            productId: payerProductId,
            operation: operation,
            iconType: .balance)
        
        let commissionViewModel = makePropertyViewModel(
            productId: payerProductId,
            operation: operation,
            iconType: .commission)
        
        let payerViewModel = makeProductViewModel(
            title: "Счет списания",
            productId: payerProductId,
            productNumber: payerProductNumber)
        
        let dateViewModel = makePropertyViewModel(
            productId: payerProductId,
            operation: operation,
            iconType: .date)
        
        return [
            payeeViewModel,
            balanceViewModel,
            commissionViewModel,
            payerViewModel,
            dateViewModel].compactMap {$0}
    }
    
    func makePropertyViewModel(productId: Int?, operation: OperationDetailData, iconType: PropertyIconType) -> PropertyCellViewModel? {
        
        guard let productId = productId,
              let productData = model.product(productId: productId) else {
            return nil
        }
        
        switch iconType {
        case .balance:
            
            let formattedAmount = model.amountFormatted(amount: operation.amount, currencyCode: productData.currency, style: .fraction)
            
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
            
        case .date:
            return .init(title: "Дата и время операции (МСК)", iconType: .date, value: operation.responseDate)
            
        default:
            return nil
        }
    }
    
    private func makeProductViewModel(title: String, productId: Int?, productNumber: String?) -> ProductCellViewModel? {
        
        guard let productId = productId,
              let productData = model.product(productId: productId),
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
        
        return OperationDetailInfoViewModel(logo: nil, cells: [PropertyCellViewModel(title: "По номеру телефона", iconType: .phone, value: "+7 (962) 62-12-12"),
                                                               PropertyCellViewModel(title: "Получатель", iconType: .user, value: "Алексей Андреевич К."),
                                                               BankCellViewModel(title: "Банк получателя", icon: Image("Bank Logo Sample"), name: "СБЕР"),
                                                               PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: "1 000,00 ₽"),
                                                               PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: "10,20 ₽"),
                                                               ProductCellViewModel(title: "Счет списания", icon: Image("card_sample"), name: "Standart", iconPaymentService: Image("card_mastercard_logo"), balance: "10 ₽", description: "· 4896 · Корпоративная"),
                                                               PropertyCellViewModel(title: "Назначение платежа", iconType: .purpose, value: "Оплата по договору №285"),
                                                               PropertyCellViewModel(title: "Номер операции СБП", iconType: .operationNumber, value: "B11271248585590B00001750251A3F95"),
                                                               PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: "10.05.2021 15:38:12")
                                                              ], dismissAction: {}, model: .emptyMock)
        
    }()
}
