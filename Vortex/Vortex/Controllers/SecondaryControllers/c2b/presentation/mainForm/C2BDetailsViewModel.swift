//
//  C2BDetailsViewModel.swift
//  ForaBank
//
//  Created by Роман Воробьев on 15.03.2022.
//

import Foundation
import UIKit

class C2BDetailsViewModel {
    
    weak var controller: C2BDetailsViewController? = nil
    var consent: [FastPaymentContractFindListDatum]? = nil
    var qrData: GetQRDataAnswer? = nil
    var c2bLink: String = ""
    static var recipientText = ""
    static var recipientIcon: UIImage? = nil
    static var recipientDescription = ""
    static var sourceModel: UserAllCardsModel? = nil
    static var sum = ""
    static var makeTransfer: MakeTransferDecodableModel? = nil
    static var modelCreateC2BTransfer: CreateDirectTransferDecodableModel? = nil
    static var operationDetail: GetOperationDetailsByPaymentIdDatum? = nil

    init(urlString: String, getUImage: @escaping (Md5hash) -> UIImage?) {

        controller?.getUImage = getUImage
        c2bLink = urlString.replacingOccurrences(of: "amp;", with: "")
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
    
    func getOperationDetailByPaymentId(idDoc: String, completion: @escaping (_ model: GetOperationDetailsByPaymentIdAnswer?, _ error: String?) -> ()) {
        C2BApiRequests.getOperationDetailByPaymentId (idDoc: idDoc) { model, error in
            completion (model, error)
        }
    }
    
    func updateContract(contractId: String?, cardModel: UserAllCardsModel, isOff: Bool, completion: @escaping (_ success: Bool, _ error: String?) -> ()) {
        C2BApiRequests.updateContract(contractId: contractId, cardModel: cardModel, isOff: isOff, completion: completion)
    }
    
    func createContract(cardModel: UserAllCardsModel, completion: @escaping (_ success: Bool, _ error: String?) -> ()) {
        C2BApiRequests.createContract(cardModel: cardModel, completion: completion)
    }
    
    func makeTransfer(completion: @escaping (_ model: MakeTransferDecodableModel?, _ error: String?) -> ()) {
        C2BApiRequests.makeTransfer(completion: completion)
    }
}
