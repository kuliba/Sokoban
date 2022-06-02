//
//  AccountStatementPDFController.swift
//  ForaBank
//
//  Created by Mikhail on 17.11.2021.
//

import UIKit
import PDFKit

class AccountStatementPDFController: UIViewController, URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {}
    
    var pdfView = PDFView()
    lazy var button = UIButton(title: "Сохранить или отправить")
    var model: ResultAccountStatementModel
    var printFormType: String?
    var id: Int?
    var pdfURL: URL!
    
    required init?(model: ResultAccountStatementModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Сохранить или отправить чек"
        view.backgroundColor = .white
        addCloseButton()
        
        self.view.addSubview(self.pdfView)
        pdfView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        self.view.addSubview(self.button)
        button.anchor(left: self.view.leftAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, right: self.view.rightAnchor, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, height: 48)
        button.addTarget(self, action: #selector(sharePDF), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var id = model.product.productType == "ACCOUNT" ? model.product.id : model.product.accountID
        if model.product.productType == ProductType.loan.rawValue {
            id = model.product.settlementAccountId
        }
        
        
        switch model.product.productType {
        case ProductType.card.rawValue:
            let idCard = model.product.id
            let body = [
                "id" : idCard,
                "startDate": "\(model.startDate)",
                "endDate": "\(model.endDate)",
                "cardNumber": ""
            ] as [String: AnyObject]
            
            getPrintFormForCardStatmentRequest(body)
        case ProductType.deposit.rawValue:
            
            let accountId = model.product.accountID
            let body = [
                "id" : accountId,
                "startDate": "\(model.startDate)",
                "endDate": "\(model.endDate)",
                "cardNumber": ""
            ] as [String: AnyObject]
            
            createPdfDocument(body)
        default:
            let printType = printFormType ?? ""
            let body = [
                "paymentOperationDetailId": id,
                "printFormType" : printType
            ] as [String: AnyObject]
            createPdfDocument(body)
        }
    }
    
    ///rest/getPrintFormForCardStatment
    private func getPrintFormForCardStatmentRequest(_ body: [String: AnyObject]?) {
        var router = RouterManager.getPrintFormForCardStatment.request()
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: body!, options: [])
            router?.httpBody = jsonAsData
            
            if router?.value(forHTTPHeaderField: "Content-Type") == nil {
                router?.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            debugPrint(NetworkError.encodingFailed)
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        router?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = CSRFToken.token {
            router?.allHTTPHeaderFields = ["X-XSRF-TOKEN": token]
        }
        
        session.downloadTask(with: router!) { (url, response, err) in
            
            if let response = response as? HTTPURLResponse {
                if let document = PDFDocument(url: url!) {
                    self.pdfView.pageBreakMargins = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
                    self.pdfView.autoScales = true
                    self.pdfView.document = document
                }
            }
        }.resume()
    }
    
    @objc func sharePDF(){
        guard let pdfDocument = pdfView.document?.dataRepresentation() else { return }
        var filesToShare = [Any]()
        filesToShare.append(pdfDocument)
        
        let activityViewController = UIActivityViewController(activityItems: filesToShare , applicationActivities: [])
        present(activityViewController, animated: true, completion: nil)
    }
    
    func createPdfDocument(_ requestBody: [String: AnyObject]?) {
        
        var router = RouterManager.getPrintFormForAccountStatement.request()
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: requestBody!, options: [])
            router?.httpBody = jsonAsData
            
            if router?.value(forHTTPHeaderField: "Content-Type") == nil {
                router?.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            debugPrint(NetworkError.encodingFailed)
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        router?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = CSRFToken.token {
            router?.allHTTPHeaderFields = ["X-XSRF-TOKEN": token]
        }
        
        session.downloadTask(with: router!) { (url, response, err) in
            
            if let response = response as? HTTPURLResponse {
                if let document = PDFDocument(url: url!) {
                    
                    self.pdfView.pageBreakMargins = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
                    self.pdfView.autoScales = true
                    self.pdfView.document = document
                }
            }
        }.resume()
    }
}
