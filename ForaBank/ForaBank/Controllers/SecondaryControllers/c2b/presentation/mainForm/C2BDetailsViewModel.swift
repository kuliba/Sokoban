//
//  C2BDetailsViewModel.swift
//  ForaBank
//
//  Created by Роман Воробьев on 15.03.2022.
//

import Foundation

class C2BDetailsViewModel {
    var controller: C2BDetailsViewController? = nil
    var consent: [FastPaymentContractFindListDatum]? = nil
    var qrData: GetQRDataAnswer? = nil
    var c2bLink = ""
    static var recipientText = ""
    static var recipientIconSrc = ""
    static var recipientDescription = ""
    static var sum = ""
    static var makeTransfer: MakeTransferDecodableModel? = nil
    static var modelCreateC2BTransfer: CreateDirectTransferDecodableModel? = nil

    init() {
        c2bLink = GlobalModule.c2bURL ?? ""
        GlobalModule.c2bURL = nil
        getConsent()
        C2BApiRequests.getQRData(link: c2bLink) { model, error in
            if error != nil {
                self.controller?.dismissActivity()
                self.controller?.showAlert(with: "Ошибка", and: error!)
            } else {
                self.qrData = model
                self.dataArrived()
            }
        }
    }

    func getConsent() {
        C2BApiRequests.getFastPaymentContractList { model, error in
            if error != nil {
                self.controller?.dismissActivity()
                self.controller?.showAlert(with: "Ошибка", and: error!)
            } else {
                self.consent = model
                self.dataArrived()
            }
        }
    }

    func dataArrived() {
        if (consent != nil && qrData != nil) {
            controller?.updateUIFromQR(qrData)
        }
    }

    func createC2BTransfer(body: [String: AnyObject], completion: @escaping (_ model: CreateDirectTransferDecodableModel?, _ error: String?) -> ()) {
        C2BApiRequests.createC2BTransfer (body: body) { model, error in
            completion (model, error)
        }
    }

    func updateContract(contractId: String?, cardModel: GetProductListDatum, isOff: Bool, completion: @escaping (_ success: Bool, _ error: String?) -> ()) {
        C2BApiRequests.updateContract(contractId: contractId, cardModel: cardModel, isOff: isOff, completion: completion)
    }

    func createContract(cardModel: GetProductListDatum, completion: @escaping (_ success: Bool, _ error: String?) -> ()) {
        C2BApiRequests.createContract(cardModel: cardModel, completion: completion)
    }

    func makePayment(completion: @escaping (_ model: MakeTransferDecodableModel?, _ error: String?) -> ()) {
        C2BApiRequests.makePayment(completion: completion)
    }

}
