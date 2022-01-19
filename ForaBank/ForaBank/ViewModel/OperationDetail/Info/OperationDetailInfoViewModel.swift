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
    let title = "Детали операций"
    let logo: Image?
    let cells: [DefaultCellViewModel]
    let dismissAction: () -> Void
    
    var token: NotificationToken?
    var allProductList: Results<UserAllCardsModel>? = nil
    var products = [UserAllCardsModel]()
    
    init(logo: Image?, cells: [DefaultCellViewModel], dismissAction: @escaping () -> Void) {
        
        self.logo = nil
        self.cells = cells
        self.dismissAction = dismissAction

    
    }
    
    init?(with statement: ProductStatementProxy, operation: OperationDetailDatum?, product: UserAllCardsModel, dismissAction: @escaping () -> Void) {


        
        let tranDateString = DateFormatter.operation.string(from: statement.tranDate)
        let foraBankName = "Фора Банк"
        let foraBankIcon = Image("foraContactImage", bundle: nil)
        let currency = statement.currencyCode
        
        var logo: Image? = nil
        var cells = [DefaultCellViewModel]()

        lazy var realm = try? Realm()

        
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
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: tranDateString))

            
        case .betweenTheir:
            /*
             /rest/getProductListByFilter || payeeCardNumber
             amount + currencyCode
             fee
             product
             tranDate
             */
            if let payeeCardNumber = operation?.payeeCardNumber, let productObjects = realm?.objects(UserAllCardsModel.self){
                    for product in productObjects{
                        if product.number?.suffix(4) == payeeCardNumber.suffix(4){
                            print(product)
                            if let smallDesign = product.smallDesign?.convertSVGStringToImage(),
                                  let productName = product.mainField,
                                  let additionalField = product.additionalField,
                               let productCurrency = product.currency,
                               let description = product.number?.suffix(4){
                                let balanceString = product.balance.currencyFormatter(symbol: productCurrency)
                            
                                cells.append(ProductCellViewModel(title: "Счет пополнения", icon: Image(uiImage: smallDesign), name: productName, iconPaymentService: nil, balance: balanceString, description: "· \(description) · \(additionalField)"))
                            }
                        }
                    }
                }
            
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let payerFee = operation?.payerFee {
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: payerFee.currencyFormatter(symbol: currency)))
            }
            
            if let payerCardNumber = operation?.payerCardNumber, let productObjects = realm?.objects(UserAllCardsModel.self){
                for product in productObjects{
                    if product.number?.suffix(4) == payerCardNumber.suffix(4){
                        print(product)
                        if let smallDesign = product.smallDesign?.convertSVGStringToImage(),
                              let productName = product.mainField,
                              let additionalField = product.additionalField,
                           let productCurrency = product.currency,
                           let description = product.number?.suffix(4){
                            let balanceString = product.balance.currencyFormatter(symbol: productCurrency)
                        
                            cells.append(ProductCellViewModel(title: "Счет списания", icon: Image(uiImage: smallDesign), name: productName, iconPaymentService: nil, balance: balanceString, description: "· \(description) · \(additionalField)"))
                        }
                    }
                }
            }
//            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
//                cells.append(debitAccounCell)
//            }
            
                cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: tranDateString))

            
        case  .insideBank:
            /*
             payeeAccountNumber || payeeCardNumber || || payeePhone
             payeeFullName
             svgImage
             amount + currencyCode
             fee
             product
             tranDate
             */
            
            if let payeeAccountNumber = operation?.payeeAccountNumber {
                cells.append(PropertyCellViewModel(title: "Номер счета получателя", iconType: .bank, value: payeeAccountNumber))
                
            } else if let payeeCardNumber = operation?.payeeCardNumber {
                
                cells.append(PropertyCellViewModel(title: "Номер карты получателя", iconType: .bank, value: payeeCardNumber))
                
            } else if let payeePhone = operation?.payeePhone {
                let phoneFormatter = PhoneNumberFormater()
                let formattedPhone = phoneFormatter.format(payeePhone)
                cells.append(PropertyCellViewModel(title: "Номер телефона получателя", iconType: .phone, value: formattedPhone))
            }
        
                cells.append(PropertyCellViewModel(title: "Получатель", iconType: .user, value: statement.merchantName))
            
            
            
            cells.append(BankCellViewModel(title: "Банк получателя", icon:  foraBankIcon, name: foraBankName))
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
            }
            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
                cells.append(debitAccounCell)
            }
            
            if let comment = statement.comment {
                cells.append(PropertyCellViewModel(title: "Назначение платежа", iconType: .purpose, value: comment))
            }
            
                cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: tranDateString))
            
        case .contactAddressless:
            /*
             svgImage
             merchantName || merchantNameRus
             countryName
             amount + currencyCode
             fee
             "Наличные"
             product
             transferReference
             tranDate
             */
            logo = statement.svgImage
            
            cells.append(PropertyCellViewModel(title: "Получатель", iconType: .user, value: statement.merchantName))
            
            if let countryName = operation?.countryName {
                
                cells.append(PropertyCellViewModel(title: "Страна", iconType: .geo, value: countryName))
            }
            
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
            }
            
            cells.append(PropertyCellViewModel(title: "Способ выплаты", iconType: .cash, value: "Наличные"))

            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
                cells.append(debitAccounCell)
            }
            
            if let transferReference = operation?.transferReference  {
                
                cells.append(PropertyCellViewModel(title: "Номер перевода", iconType: .operationNumber, value: transferReference))
            }
            
                cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: tranDateString))
            
        case .direct:
            /*
             svgImage
             payeePhone
             merchantName || merchantNameRus
             amount + currencyCode
             fee
             product
             tranDate
             */
            
            
            let directLogoImage = Image("MigAvatar")
            logo = directLogoImage
            
            if let foreignPhoneNumber = operation?.payeePhone {
                let phoneFormatter = PhoneNumberFormater()
                let formattedPhone = phoneFormatter.format(foreignPhoneNumber)
                cells.append(PropertyCellViewModel(title: "Номер телефона получателя", iconType: .phone, value: formattedPhone))
                
            }

            cells.append(PropertyCellViewModel(title: "Получатель", iconType: .user, value: statement.merchantName))
            
            if let memberId = operation?.memberID,
               let bank = Dict.shared.banks?.first(where: { $0.memberID == memberId }),
               let bankLogoSVG = bank.svgImage, let name = bank.memberNameRus {
                
                let bankLogoImage = Image(uiImage: bankLogoSVG.convertSVGStringToImage())
                cells.append(BankCellViewModel(title: "Банк получателя", icon: bankLogoImage, name: name))
            }
            
            if let countryName = operation?.countryName {
                
                cells.append(PropertyCellViewModel(title: "Страна", iconType: .geo, value: countryName))
            }
            
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
            }
            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
                cells.append(debitAccounCell)
            }
            
            if let transferReference = operation?.transferReference  {
                
                cells.append(PropertyCellViewModel(title: "Номер перевода", iconType: .operationNumber, value: transferReference))
            }
            
            
                cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: tranDateString))
            
            
        case .externalIndivudual:
            /*
             payeeFullName
             payeeAccountNumber/ payeeCardNumber
             amount + currencyCode
             product
             tranDate
             */
            
            
            if let payeeFullName = operation?.payeeFullName {
                
                cells.append(PropertyCellViewModel(title: "Получатель", iconType: .user, value: payeeFullName))
            }
            
            if let payeeAccountNumber = operation?.payeeAccountNumber {
                
                cells.append(PropertyCellViewModel(title: "Номер счета получателя", iconType: .account, value: payeeAccountNumber))
                
            } else if let payeeCardNumber = operation?.payeeCardNumber {
                
                cells.append(PropertyCellViewModel(title: "Номер счета получателя", iconType: .account, value: payeeCardNumber))
            }
            
            if let bankBic = operation?.payeeBankBIC,
               let bank = Dict.shared.bankFullInfoList?.first(where: {$0.bic == bankBic}),
               let bankLogoSVG = bank.svgImage {
                
                let bankLogoImage = Image(uiImage: bankLogoSVG.convertSVGStringToImage())
                
                cells.append(BankCellViewModel(title: "Бик банка получателя", icon: bankLogoImage, name: bankBic))
            }
            
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
            }
            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
                cells.append(debitAccounCell)
            }
            
            if let comment = statement.comment {
                
                cells.append(PropertyCellViewModel(title: "Назначение платежа", iconType: .purpose, value: comment))
            }
            
                cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: tranDateString))
            
        case .externalEntity:
            /*
             payeeFullName
             payeeAccountNumber
             payeeInn
             payeeKPP
             amount + currencyCode
             tranDate
             */
            
            if let payeeFullName = operation?.payeeFullName {
                
                cells.append(PropertyCellViewModel(title: "Получатель", iconType: .user, value: payeeFullName))
            }
            
            if let payeeAccountNumber = operation?.payeeAccountNumber {
                
                cells.append(PropertyCellViewModel(title: "Номер счета получателя", iconType: .account, value: payeeAccountNumber))
                
            } else if let payeeCardNumber = operation?.payeeCardNumber {
                
                cells.append(PropertyCellViewModel(title: "Номер счета получателя", iconType: .account, value: payeeCardNumber))
            }
            
            if let payeeINN = operation?.payeeINN  {
                
                cells.append(PropertyCellViewModel(title: "ИНН получателя", iconType: .nil, value: payeeINN))
            }
            
            if let payeeKPP = operation?.payeeKPP {
                
                cells.append(PropertyCellViewModel(title: "КПП получателя", iconType: .nil, value: payeeKPP))
            }
            
            if let bankBic = operation?.payeeBankBIC,
               let memberId = operation?.memberID,
               let bank = Dict.shared.banks?.first(where: { $0.memberID == memberId }),
               let bankLogoSVG = bank.svgImage {
                
                let bankLogoImage = Image(uiImage: bankLogoSVG.convertSVGStringToImage())
                
                cells.append(BankCellViewModel(title: "Банк получателя", icon: bankLogoImage, name: bankBic))
            }
            
            if let comment = statement.comment {
                
                cells.append(PropertyCellViewModel(title: "Назначение платежа", iconType: .purpose, value: comment))
            }
            
                cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: tranDateString))
            
        case .insideOther:
            /*
             svgImage
             merchantName || merchantNameRus
             groupName
             amount + currencyCode
             tranDate
             */
            //TODO: add iconType with dif image
            cells.append(BankCellViewModel(title: "Наименование операции", icon: statement.svgImage, name: statement.merchantName))
            cells.append(PropertyCellViewModel(title: "Категория операции", iconType: .nil, value: statement.groupName))
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: tranDateString))

            
        case .mobile:
            /*
             svgImage
             payeePhone
             svgImage
             provider
             fee
             product
             tranDate
             */
            
            logo = statement.svgImage
            
            
            if let payeePhone = operation?.payeePhone {
                    let phoneFormatter = PhoneNumberFormater()
                    let formattedPhone = phoneFormatter.format(payeePhone)
                    cells.append(PropertyCellViewModel(title: "Номер телефона", iconType: .phone, value: formattedPhone))
                    
                }
            
            if let provider = operation?.provider {

                cells.append(BankCellViewModel(title: "Наименование получателя", icon: statement.svgImage, name: provider))
            }
            
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))

            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
            }
            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
                cells.append(debitAccounCell)
            }
            
            
                cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: tranDateString))
            
            
        case .internet:
            /*
             svgImage
             merchantName || merchantNameRus
             account
             amount + currencyCode
             product
             tranDate
             */
            
            logo = statement.svgImage
            
            if let provider = operation?.provider {

                cells.append(BankCellViewModel(title: "Наименование получателя", icon: statement.svgImage, name: provider))
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
            
                cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: tranDateString))
            
        case .housingAndCommunalService:
            /*
             svgImage
             merchantName || merchantNameRus
             payeeInn
             period
             account
             amount + currencyCode
             fee
             product
             tranDate
             */
            logo = statement.svgImage
            
            cells.append(BankCellViewModel(title: "Наименование получателя", icon: statement.svgImage, name: statement.merchantName))
    
            
//            if let account = operation?.account {
//
//                cells.append(PropertyCellViewModel(title: "Номер счета получателя", iconType: .account, value: account))
//            }
            
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
            
                cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: tranDateString))
            
            
        case .notFinance:
           return nil
            
        case .outsideCash:
            /*
             product
             amount + currencyCode
             fee
             tranDate
             */
            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
            }
            
                cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: tranDateString))
            
        case .outsideOther:
            /*
             svgImage
             merchantName || merchantNameRus + mcc
             amount + currencyCode
             fee
             product
             tranDate
             */
            logo = statement.svgImage
            
            cells.append(PropertyCellViewModel(title: "Наименование получателя", iconType: .user, value: statement.merchantName))
            cells.append(PropertyCellViewModel(title: "Категория операции", iconType: .nil, value: "\(statement.groupName) (\(statement.mcc))"))
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
            }
            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
                cells.append(debitAccounCell)
            }
            
                cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: tranDateString))
            
            
        case .sfp:
            /*
             image(sbp)
             foreignPhoneNumber
             merchantName || merchantNameRus
             svgImage
             amount + currencyCode
             product
             documentComment
             transferNumber
             tranDate
             */
            let sfpLogoImage = Image("sbp-logo")
            logo = sfpLogoImage
            
            if let foreignPhoneNumber = statement.foreignPhoneNumber {
                let phoneFormatter = PhoneNumberFormater()
                let formattedPhone = phoneFormatter.format(foreignPhoneNumber)
                cells.append(PropertyCellViewModel(title: "Номер телефона получателя", iconType: .phone, value: formattedPhone))
                
            }
            
            cells.append(PropertyCellViewModel(title: "Получатель", iconType: .user, value: statement.merchantName))
            
            if let bankName = statement.fastPayment?.foreignBankName, statement.operationType == .debit{
                cells.append(BankCellViewModel(title: "Банк получателя", icon:  statement.svgImage, name: bankName))
            } else if let bankName = statement.fastPayment?.foreignBankName{
                cells.append(BankCellViewModel(title: "Банк отправителя", icon:  statement.svgImage, name: bankName))
            }

            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
            }
            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
                cells.append(debitAccounCell)
            }
            
            if let documentComment = statement.documentComment, documentComment != ""{
                
                cells.append(PropertyCellViewModel(title: "Назначение платежа", iconType: .purpose, value: documentComment))
            }
            
            if let transferNumber = operation?.transferNumber {
                
                cells.append(PropertyCellViewModel(title: "Номер операции СБП", iconType: .operationNumber, value: transferNumber))
            }
            
            
                cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: tranDateString))
        case .transport:
            /*
             svgImage
             merchantName || merchantNameRus
             account
             amount + currencyCode
             product
             tranDate
             */
            logo = statement.svgImage

            cells.append(BankCellViewModel(title: "Наименование получателя", icon: statement.svgImage, name: statement.merchantName))
            
            if let accountTitle = operation?.accountTitle, let account =  operation?.account{
                
                cells.append(PropertyCellViewModel(title: accountTitle, iconType: .operationNumber, value: account))
            }
            
            cells.append(PropertyCellViewModel(title: "Сумма перевода", iconType: .balance, value: statement.amount.currencyFormatter(symbol: currency)))
            
            if let fee = operation?.payerFee {
                
                cells.append(PropertyCellViewModel(title: "Комиссия", iconType: .commission, value: fee.currencyFormatter(symbol: currency)))
            }
            
            if let debitAccounCell = Self.debitAccountCell(with: product, currency: currency) {
                
                cells.append(debitAccounCell)
            }
            
            cells.append(PropertyCellViewModel(title: "Дата и время операции (МСК)", iconType: .date, value: tranDateString))
  
        }
        
        self.logo = logo
        self.cells = cells
        self.dismissAction = dismissAction
    }
}

//MARK: - Private helpers

private extension OperationDetailInfoViewModel {
    
    static func debitAccountCell(with product: UserAllCardsModel, currency: String) -> DefaultCellViewModel? {
        
        guard let smallDesign = product.smallDesign?.convertSVGStringToImage(),
              let productName = product.mainField,
              let additionalField = product.additionalField,
              let productCurrency = product.currency,
              let description = product.number?.suffix(4) else  {
                  return nil
              }
        let balanceString = product.balance.currencyFormatter(symbol: productCurrency)
        
        return ProductCellViewModel(title: "Счет списания", icon: Image(uiImage: smallDesign), name: productName, iconPaymentService: nil, balance:balanceString, description: "· \(description) · \(additionalField)")
    }
}

extension OperationDetailInfoViewModel{
//    func observerRealm(currency: String){
//        guard let products = self.allProductList else {
//            return
//        }
//        for product in products {
//            if product.number?.suffix(6) == payeeCardNumber.suffix(6){
//                print(product)
//                if let smallDesign = product.smallDesign?.convertSVGStringToImage(),
//                      let productName = product.mainField,
//                      let additionalField = product.additionalField,
//                   let description = product.number?.suffix(4){
//                    let balanceString = product.balance.currencyFormatter(symbol: currency)
//
//                    cells.append(ProductCellViewModel(title: "Счет пополнения", icon: Image(uiImage: smallDesign), name: productName, iconPaymentService: nil, balance: balanceString, description: "· \(description) · \(additionalField)"))
//                }
//            }
//        }
//
//   }
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
    
    class BankCellViewModel: DefaultCellViewModel {
        
        var icon: Image
        var name: String
        
        internal init(title: String, icon: Image, name: String) {
            self.icon = icon
            self.name = name
            super.init(title: title)
            
        }
    }
    
    class ProductCellViewModel: DefaultCellViewModel{
        
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
                // change icon
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
                                                  ], dismissAction: {})
        
    }()
}
