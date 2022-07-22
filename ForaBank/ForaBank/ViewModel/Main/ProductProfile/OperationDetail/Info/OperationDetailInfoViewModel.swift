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
            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
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
                let phoneFormatter = PhoneNumberFormater()
                let formattedPhone = phoneFormatter.format(payeePhone)
                cells.append(PropertyCellViewModel(title: "Номер телефона получателя", iconType: .phone, value: formattedPhone))
            }
            
            cells.append(PropertyCellViewModel(title: "Получатель", iconType: .user, value: statement.merchant))
            cells.append(BankCellViewModel(title: "Банк получателя", icon:  foraBankIcon, name: foraBankName))
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
            }
            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
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
            
            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
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
                let phoneFormatter = PhoneNumberFormater()
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
            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
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
            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
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
            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
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
                let phoneFormatter = PhoneNumberFormater()
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
            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
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
            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
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
            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
            
        case .notFinance:
            return nil
            
        case .outsideCash:
            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
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
            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
            
        case .sfp:
            
            let sfpLogoImage = Image("sbp-logo")
            logo = sfpLogoImage
            
            if let foreignPhoneNumber = statement.fastPayment?.foreignPhoneNumber {
                let phoneFormatter = PhoneNumberFormater()
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
            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
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
            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            
        case .c2b:
            logo = Image("sbp-logo")
            let allBanks = Dict.shared.bankFullInfoList
            let foundBank = allBanks?.filter({ $0.bic == statement.fastPayment?.foreignBankBIC })
            var imageBank: Image? = nil
            if foundBank != nil && foundBank?.count ?? 0 > 0 {
                _ = foundBank?.first?.rusName ?? ""
                let bankIconSvg = foundBank?.first?.svgImage ?? ""
                imageBank = Image(uiImage: bankIconSvg.convertSVGStringToImage())
            }
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let image = model.images.value[statement.md5hash]?.image {
                
                cells.append(BankCellViewModel(title: "Наименование ТСП", icon: image, name: statement.merchant))
            }
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: dateString))
            cells.append(BankCellViewModel(title: "Статус операции", icon: Image("OkOperators"), name: "Исполнен"))
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                cells.append(debitAccounCell)
            }
            cells.append(BankCellViewModel(title: "Отправитель", icon: Image("hash"), name: statement.fastPayment?.foreignName ?? ""))
            if let bankName = statement.fastPayment?.foreignBankName, statement.operationType == .debit {
                
                cells.append(BankCellViewModel(title: "Банк получателя", icon:  imageBank ?? Image("bank_icon"), name: bankName))
                
            } else if let bankName = statement.fastPayment?.foreignBankName, let icon = model.images.value[statement.md5hash]?.image {
                
                cells.append(BankCellViewModel(title: "Банк отправителя", icon: icon, name: bankName))
            }
            
            cells.append(BankCellViewModel(title: "Сообщение получателю", icon: Image("hash"), name: statement.fastPayment?.documentComment ?? ""))
            
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
    
    static func debitAccountCell(with product: ProductData, currency: String) -> DefaultCellViewModel? {
        
        let productCurrency = product.currency
        
        guard let smallDesign = product.smallDesign.image,
              let additionalField = product.additionalField,
              let description = product.number?.suffix(4),
              let balanceString = product.balance?.currencyFormatter(symbol: productCurrency) else  {
            return nil
        }
        
        let productName = product.mainField
        
        return ProductCellViewModel(title: "Счет списания", icon: smallDesign, name: productName, iconPaymentService: nil, balance: balanceString, description: "· \(description) · \(additionalField)")
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
