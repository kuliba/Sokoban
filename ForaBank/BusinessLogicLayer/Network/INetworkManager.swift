//
//  INetworkManager.swift
//  ForaBank
//
//  Created by Бойко Владимир on 23.10.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import Alamofire

//Тип продукта
public enum productTypes {
    case AccauntType
    case DepositType
    case CardType
    case LoanType
}

protocol AuthServiceProtocol {
    func isSignedIn(completionHandler: @escaping (_ success: Bool) -> Void)
    func csrf(headers: HTTPHeaders,
              completionHandler: @escaping (_ success: Bool, _ headers: HTTPHeaders?) -> Void)
    func loginDo(headers: HTTPHeaders,
                 login: String,
                 password: String,
                 completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void)
    func prepareResetPassword(headers: HTTPHeaders,
                              login: String,
                              completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void)
    func newPasswordReset(headers: HTTPHeaders,
                          password: String,
                          completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void)
    func changePassword(headers: HTTPHeaders,
                        oldPassword: String,
                        newPassword: String,
                        completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void)

    func checkVerificationCode(headers: HTTPHeaders,
                               code: String,
                               completionHandler: @escaping (_ success: Bool) -> Void)
    func checkCodeResetPassword(headers: HTTPHeaders,
                                code: String,
                                completionHandler: @escaping (_ success: Bool) -> Void)

    func logOut(completionHandler: @escaping (_ success: Bool) -> Void)
    func getProfile(headers: HTTPHeaders,
                    completionHandler: @escaping (_ success: Bool, _ profile: Profile?, _ errorMessage: String?) -> Void)
}

protocol CardServiceProtocol {
    func getCardList(headers: HTTPHeaders,
                     completionHandler: @escaping (_ success: Bool, _ cards: [Card]?) -> Void)

    func blockCard(withNumber num: String,
                   completionHandler: @escaping (_ success: Bool) -> Void)
    func getTransactionsStatement(forCardNumber: String,
                                  fromDate: Date,
                                  toDate: Date,
                                  headers: HTTPHeaders,
                                  completionHandler: @escaping (_ success: Bool, _ datedTransactions: [DatedTransactions]?) -> Void)
}


protocol CardInfoServiceProtocol {
    func getCardInfo(cardNumber: String?, headers: HTTPHeaders,
                         completionHandler: @escaping (_ success: Bool, _ saveCardName: [AboutItem]?) -> Void)
}
protocol SuggestBankServiceProtocol {
    func getSuggestBank(bicBank: String?, headers: HTTPHeaders,
                        completionHandler: @escaping (_ success: Bool, _ saveCardName: [BankSuggest]?,_ bicBank: String?) -> Void)
}
protocol SuggestCompanyServiceProtocol {
    func getSuggestCompany(bicBank: String?, headers: HTTPHeaders,
                        completionHandler: @escaping (_ success: Bool, _ saveCardName: [BankSuggest]?,_ bicBank: String?) -> Void)
}

protocol SaveCardNameProtocol {
    func getSaveCardName(headers: HTTPHeaders,
                         completionHandler: @escaping (_ success: Bool, _ saveCardName: [Product]?) -> Void)
}

protocol IPaymetsApi {
    func getPaymentsList(completionHandler: @escaping (_ success: Bool, _ payments: [Operations]?) -> Void)
    func allPaymentOptions(completionHandler: @escaping (Bool, [PaymentOption]?) -> Void)
    func prepareCard2Card(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?) -> Void)
    func prepareCard2Phone(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?) -> Void)
    func prepareCard2Account(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?) -> Void)
    func prepareAccount2Phone(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?) -> Void)
    func prepareAccount2Card(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?) -> Void)
    func prepareAccount2Account(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?) -> Void)
    func makeCard2Card(code: String, completionHandler: @escaping (Bool) -> Void)
}

protocol AccountsServiceProtocol {
    func getDepos(headers: HTTPHeaders,
                  completionHandler: @escaping (_ success: Bool, _ obligations: [Account]?) -> Void)
}
protocol LoanPaymentScheduleProtocol {
    func getLoansPayment(headers: HTTPHeaders,
                         completionHandler: @escaping (_ success: Bool, _ obligations: [LaonSchedules]?) -> Void)
}
protocol HistoryServiceProtocol {
    func getHistoryCard(headers: HTTPHeaders, cardNumber : String,
                        completionHandler: @escaping (_ success: Bool, _ obligations: [DatedCardTransactionsStatement]?) -> Void)
}
protocol LoansServiceProtocol {
    func getLoans(headers: HTTPHeaders,
                  completionHandler: @escaping (_ success: Bool, _ obligations: [Loan]?) -> Void)
}

protocol paymentCompany {
    func paymentCompany(headers: HTTPHeaders,
                      numberAcoount: String,
                      amount: String,
                      kppBank: String,
                      payerCard: String,
                      innBank: String,
                      bikBank: String,
                      comment: String,
                      nameCompany: String,
                      commission: Double,
                      completionHandler: @escaping (_ success: Bool, _ errorMessage: String?, _ commission: Double?) -> Void)
}
protocol DepositsServiceProtocol {
    func getBonds(headers: HTTPHeaders,
                  completionHandler: @escaping (_ success: Bool, _ obligations: [Deposit]?) -> Void)
}

protocol MapServiceProtocol {
    func getBankBranches(headers: HTTPHeaders,
                         completionHandler: @escaping (_ success: Bool, Data?, _ errorMessage: String?) -> Void)
}

protocol best2PayProtocol {
    func best2Pay(headers: HTTPHeaders,
                  completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void)
}

protocol RegServiceProtocol {
    func checkClient(headers: HTTPHeaders,
                     cardNumber: String,
                     login: String,
                     password: String,
                     phone: String,
                     verificationCode: Int,
                     completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void)
    func paymentCompany(headers: HTTPHeaders,
                         numberAcoount: String,
                         amount: String,
                         payerCard: String,
                         kppBank: String,
                         innBank: String,
                         bikBank: String,
                         comment: String,
                         nameCompany: String,
                         commission: Double,
                         completionHandler: @escaping (_ success: Bool, _ errorMessage: String?, _ commission: Double?) -> Void)
    func verifyCode(headers: HTTPHeaders,
                    verificationCode: Int,
                    completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void)

    func doRegistration(headers: HTTPHeaders,
                        completionHandler: @escaping (_ success: Bool, _ errorMessage: String?, _ login: String?, _ password: String?) -> Void)
    func saveCardName(headers: HTTPHeaders, id: Double, newName: String,
                      completionHandler: @escaping (_ success: Bool, _ errorMessage: String?, _ id: Double?, _ name: String?) -> Void)
    func saveLoanName(headers: HTTPHeaders, id: Int, newName: String,
    completionHandler: @escaping (_ success: Bool, _ errorMessage: String?, _ id: Int?, _ name: String?) -> Void)
    func saveCustomName(headers: HTTPHeaders, id: Int, newName: String, productType: productTypes,
    completionHandler: @escaping (_ success: Bool, _ errorMessage: String?, _ id: Int?, _ name: String?) -> Void)
}

protocol StatementServiceProtocol {
    func getSortedFullStatement(headers: HTTPHeaders,
                                completionHandler: @escaping (_ success: Bool, _ obligations: [DatedTransactionsStatement]?, _ errorMessage: String?) -> Void)
}

//MARK: - Products
protocol IProductsApi {
    func getProducts(completionHandler: @escaping (_ success: Bool, _ products: [Product]?) -> Void)
}

//MARK: Rates
protocol CurrencysProtocol {
    func getABSCurrencyRates(headers: HTTPHeaders, currencyOne: String, currencyTwo: String, rateTypeID: Int, completionHandler: @escaping (_ success: Bool, _ currencysCB: Double?) -> Void)
    func getExchangeCurrencyRates(headers: HTTPHeaders, currency: String, completionHandler: @escaping (_ success: Bool, _ currency: Currency?) -> Void)
}
