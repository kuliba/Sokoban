/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Foundation
import Alamofire
import UIKit

class NetworkManager {

    // MARK: - Properties

    private static var sharedNetworkManager: NetworkManager = {
        let host = apiBaseURL

        let authService = AuthService(baseURLString: host)
        let cardService = CardService(baseURLString: host)
        let paymentServices = PaymentServices(baseURLString: host)
        let regService = RegService(baseURLString: host)
        let depositsService = DepositService(baseURLString: host)
        let accountsService = AccountsService(baseURLString: host)
        let loansService = LoansService(baseURLString: host)
        let historyService = HistoryService(baseURLString: host)
        let statementService = StatementService(baseURLString: host)
        let loanPaymentSchedule = LoanPaymentSchedule(baseURLString: host)
        let productService = ProductsService(baseURLString: host)
        

        let networkManager = NetworkManager(host, authService, regService, cardService, paymentServices, depositsService, accountsService, loanPaymentSchedule, historyService, loansService, statementService, productService: productService)
        // Configuration


        return networkManager
    }()
    private let authService: AuthServiceProtocol
    private let regService: RegServiceProtocol
    private let cardService: CardServiceProtocol
    private let paymentServices: IPaymetsApi
    private let productService: IProductService
    private let depositsService: DepositsServiceProtocol
    private let accountsService: AccountsServiceProtocol
    private let loanPaymentSchedule: LoanPaymentScheduleProtocol
    private let historyService: HistoryServiceProtocol
    private let loansService: LoansServiceProtocol
    private let statementService: StatementServiceProtocol

    private let baseURLString: String
    public var headers: HTTPHeaders = [
        "Accept": "application/json",
        "Content-Type": "application/json",
        "X-XSRF-TOKEN": "40e3a7ef-2a2d-48f4-9d1d-f024429aac3a",
        "JSESSIONID": "983F3FBC20F69C7A1A89B4DEAE690175"
    ]

// Initialization
    private init(_ baseURLString: String, _ authService: AuthServiceProtocol, _ regService: RegServiceProtocol, _ cardService: CardServiceProtocol, _ paymentsServices: IPaymetsApi, _ depositsService: DepositsServiceProtocol, _ accountsService: AccountsServiceProtocol, _ LaonSchedules: LoanPaymentScheduleProtocol, _ historyService: HistoryServiceProtocol, _ loansService: LoansServiceProtocol, _ statementService: StatementServiceProtocol, productService: IProductService) {
        self.baseURLString = baseURLString
        self.authService = authService
        self.regService = regService
        self.cardService = cardService
        self.paymentServices = paymentsServices
        self.loansService = loansService
        self.loanPaymentSchedule = LaonSchedules
        self.depositsService = depositsService
        self.accountsService = accountsService
        self.historyService = historyService
        self.statementService = statementService
        self.productService = productService
    }

// MARK: - Accessors

    class func shared() -> NetworkManager {
        return sharedNetworkManager
    }

//MARK: - auth service
    func isSignedIn(completionHandler: @escaping (_ success: Bool) -> Void) {
        authService.isSignedIn(completionHandler: completionHandler)
    }

    func login(login: String,
               password: String,
               completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
            if success {
                self.headers.merge(newHeaders ?? [:], uniquingKeysWith: { (_, k2) -> String in
                    return k2
                })
                self.authService.loginDo(headers: self.headers,
                                         login: login,
                                         password: password,
                                         completionHandler: { (success, errorMessage) in
                                             completionHandler(success, errorMessage)
                                         })
            }
            else {
                completionHandler(false, nil)
            }
        }
    }
    func prepareResetPassword(login: String,
                              completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
            if success {
                self.headers.merge(newHeaders ?? [:], uniquingKeysWith: { (_, k2) -> String in
                    return k2
                })
                self.authService.prepareResetPassword(headers: self.headers,
                                                      login: login,
                                                      completionHandler: { (success, errorMessage) in
                                                          completionHandler(success, errorMessage)
                                                      })
            }
            else {
                completionHandler(false, nil)
            }
        }
    }
    func newPasswordReset(password: String,
                          completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
            if success {
                self.headers.merge(newHeaders ?? [:], uniquingKeysWith: { (_, k2) -> String in
                    return k2
                })
                self.authService.newPasswordReset(headers: self.headers,
                                                  password: password,
                                                  completionHandler: { (success, errorMessage) in
                                                      completionHandler(success, errorMessage)
                                                  })
            }
            else {
                completionHandler(false, nil)
            }
        }
    }

    func checkVerificationCode(code: String,
                               completionHandler: @escaping (_ success: Bool) -> Void) {
        authService.checkVerificationCode(headers: self.headers, code: code, completionHandler: completionHandler)
    }
    func checkCodeResetPassword(code: String,
                                completionHandler: @escaping (_ success: Bool) -> Void) {
        authService.checkCodeResetPassword(headers: self.headers, code: code, completionHandler: completionHandler)
    }

    func logOut(completionHandler: ((_ success: Bool) -> Void)?) {
        authService.logOut { (success) in
            if completionHandler != nil {
                completionHandler!(success)
            }
        }
    }

    func getProfile(completionHandler: @escaping (_ success: Bool, _ profile: Profile?, _ errorMessage: String?) -> Void) {
        authService.getProfile(headers: headers) { [unowned self] (success, profile, errorMessage) in
            if self.checkForClosingSession(errorMessage) == false {
                completionHandler(success, profile, errorMessage)
            } else {
                completionHandler(false, profile, errorMessage)
            }
        }
    }

//MARK: - registration service
    func checkClient(cardNumber: String,
                     login: String,
                     password: String,
                     phone: String,
                     verificationCode: Int,
                     completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
            if success {
                self.headers.merge(newHeaders ?? [:], uniquingKeysWith: { (_, k2) -> String in
                    return k2
                })
                self.regService.checkClient(headers: self.headers, cardNumber: cardNumber, login: login, password: password, phone: phone, verificationCode: verificationCode, completionHandler: completionHandler)
            }
            else {
                completionHandler(false, nil)
            }
        }
    }

    func doRegistration(completionHandler: @escaping (_ success: Bool, _ errorMessage: String?, _ login: String?, _ password: String?) -> Void) {
        authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
            if success {
                self.headers.merge(newHeaders ?? [:], uniquingKeysWith: { (_, k2) -> String in
                    return k2
                })
                self.regService.doRegistration(headers: self.headers, completionHandler: completionHandler)
            }
            else {
                completionHandler(false, nil, nil, nil)
            }
        }
    }
    func saveCardName(newName: String, id: Double, completionHandler: @escaping (_ success: Bool, _ errorMessage: String?, _ id: Double?, _ name: String?) -> Void) {
          authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
              if success {
                self.regService.saveCardName(headers: self.headers, id: id,newName: newName, completionHandler: completionHandler)
              }
              else {
                  completionHandler(false, nil, nil, nil)
              }
          }
      }
    func best2Pay(completionHandler: @escaping (_ success: Bool, _ errorMessage: String?, _ id: Double?, _ name: String?) -> Void) {
        self.best2Pay(completionHandler: completionHandler)
                
             }
    func verifyCode(verificationCode: Int,
                    completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        authService.csrf(headers: headers) { [unowned self] (success, newHeaders) in
            if success {
                self.headers.merge(newHeaders ?? [:], uniquingKeysWith: { (_, k2) -> String in
                    return k2
                })
                self.regService.verifyCode(headers: self.headers, verificationCode: verificationCode, completionHandler: completionHandler)
            }
            else {
                completionHandler(false, nil)
            }
        }
    }
    

//MARK: - card service
    func getCardList(completionHandler: @escaping (_ success: Bool, _ cards: [Card]?) -> Void) {
        cardService.getCardList(headers: headers, completionHandler: completionHandler)
    }

    func getPaymentsList(completionHandler: @escaping (_ success: Bool, _ payments: [Operations]?) -> Void) {
        paymentServices.getPaymentsList(completionHandler: completionHandler)
    }

    func blockCard(withNumber num: String,
                   completionHandler: @escaping (Bool) -> Void) {
        cardService.blockCard(withNumber: num, completionHandler: completionHandler)
    }

    func getTransactionsStatement(forCardNumber number: String,
                                  fromDate: Date,
                                  toDate: Date,
                                  completionHandler: @escaping (_ success: Bool, _ datedTransactions: [DatedTransactions]?) -> Void) {
        cardService.getTransactionsStatement(forCardNumber: number,
                                             fromDate: fromDate,
                                             toDate: toDate,
                                             headers: headers,
                                             completionHandler: completionHandler)
    }

//MARK: - Statement service
    func getSortedFullStatement(completionHandler: @escaping (Bool, [DatedTransactionsStatement]?, String?) -> Void) {
        statementService.getSortedFullStatement(headers: headers) { [unowned self] (success, fullStatement, errorMessage) in
            if self.checkForClosingSession(errorMessage) == false {
                completionHandler(success, fullStatement, errorMessage)
            } else {
                completionHandler(false, fullStatement, errorMessage)
            }
        }
    }

//MARK: - deposits service
    func getBonds(completionHandler: @escaping (_ success: Bool, _ obligations: [Deposit]?) -> Void) {
        depositsService.getBonds(headers: headers, completionHandler: completionHandler)
    }
    func getLoans(completionHandler: @escaping (_ success: Bool, _ obligations: [Loan]?) -> Void) {
        loansService.getLoans(headers: headers, completionHandler: completionHandler)
    }
    func getLoansPayment(completionHandler: @escaping (_ success: Bool, _ obligations: [LaonSchedules]?) -> Void) {
        loanPaymentSchedule.getLoansPayment(headers: headers, completionHandler: completionHandler)
    }
    func getHistoryCard(completionHandler: @escaping (_ success: Bool, _ obligations: [HistoryCard]?) -> Void) {
        historyService.getHistoryCard(headers: headers, completionHandler: completionHandler)
    }
//MARK: - deposits service
    func getDepos(completionHandler: @escaping (_ success: Bool, _ obligations: [Account]?) -> Void) {
        accountsService.getDepos(headers: headers, completionHandler: completionHandler)
    }
//MARK: - check errorMessage for closing session
    func checkForClosingSession(_ errorMessage: String?) -> Bool {
        if let errorMessage = errorMessage,
            errorMessage.range(of: "Сессия не авторизована") != nil {
            logOut { (success) in
            }
            return true
        } else {
            return false
        }
    }
}

//MARK: - Products

extension NetworkManager: IProductsApi {
    func getProducts(completionHandler: @escaping (Bool, [Product]?) -> Void) {
        productService.getProducts(completionHandler: completionHandler)
    }
}

//MARK: - Payments

extension NetworkManager: IPaymetsApi {
    func allPaymentOptions(completionHandler: @escaping (Bool, [PaymentOption]?) -> Void) {
        paymentServices.allPaymentOptions(completionHandler: completionHandler)
    }

    func prepareCard2Phone(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?) -> Void) {
        paymentServices.prepareCard2Phone(from: sourceNumber, to: destinationNumber, amount: amount, completionHandler: completionHandler)
    }

    func prepareCard2Card(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?) -> Void) {
        paymentServices.prepareCard2Card(from: sourceNumber, to: destinationNumber, amount: amount, completionHandler: completionHandler)
    }

    func makeCard2Card(code: String,
                       completionHandler: @escaping (_ success: Bool) -> Void) {
        paymentServices.makeCard2Card(code: code, completionHandler: completionHandler)
    }
}
