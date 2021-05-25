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

class LoanPaymentSchedule: LoanPaymentScheduleProtocol {

    var loan = "10001475158"

    private let host: Host

    init(host: Host) {
        self.host = host
    }

    func getLoansPayment(headers: HTTPHeaders, completionHandler: @escaping (String?, Bool, [LaonSchedules]?) -> Void) {
        var dataPayment = [LaonSchedules]()
        let url = host.apiBaseURL + "rest/getLoanPaymentSchedule"
        let parameters: [String: AnyObject] = [
            "id": loan as AnyObject
        ]

        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler("string",false, dataPayment)
                    return
                }

                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>,
                        let data = json["data"] as? Array<Any> {
                        for cardData in data {
                            if let cardData = cardData as? Dictionary<String, Any>,
                                let paymentDate: String = String?(dayMonthYear(milisecond: (cardData["paymentDate"] as? Double ?? 1.00))),
                                let actionEntryList = cardData["actionEntryList"] as? Array<Dictionary<String, Any>> {
                                for dataAction in actionEntryList {
                                    let userAnnual = dataAction["userAnnual"] as? Double
                                    let principalDebt = dataAction["principalDebt"] as? Double
                                    let loanID = dataAction["principalDebt"] as? String
                                    let actionTypeBrief = dataAction["actionTypeBrief"] as? String
                                    let actionType = dataAction["actionType"] as? String
                                    let paymentAmount = dataAction["paymentAmount"] as? Double

                                    let items = LaonSchedules(principalDebt: principalDebt, userAnnual: userAnnual, loanID: loanID, actionTypeBrief: actionTypeBrief, paymentDate: paymentDate, items: [Item](), actionType: actionType, paymentAmount: paymentAmount)
                                    dataPayment.append(items)
                                }
                            }
                        }
                        completionHandler("string", true, dataPayment)
                    } else {
                        print("rest/getDepositList cant parse json \(String(describing: response.result.value))")
                        completionHandler("string", false, dataPayment)
                    }

                case .failure(let error):
                    print("rest/getDepositList \(error) \(self)")
                    completionHandler("string", false, dataPayment)
                }
        }
    }
}
