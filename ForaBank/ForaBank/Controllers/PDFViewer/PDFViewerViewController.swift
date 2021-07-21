//
//  PDFViewerViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 24.06.2021.
//

import UIKit
import PDFKit

class PDFViewerViewController: UIViewController, URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {}
    
    var pdfView = PDFView()
    lazy var button = UIButton(title: "Сохранить или отправить")
    var printFormType: String?
    var id: Int?
    var pdfURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCloseButton()
        
        self.view.addSubview(self.pdfView)
        pdfView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        self.view.addSubview(self.button)
        button.anchor(left: self.view.leftAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, right: self.view.rightAnchor, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, height: 48)
        
        guard  let pdfId = id else {
            return
        }
        guard let pdfType = printFormType else {
            return
        }
        
        let body = [
            "paymentOperationDetailId": pdfId,
            "printFormType" : pdfType
        ] as [String: AnyObject]
        
        createPdfDocument(body)
        button.actions(forTarget: (#selector(sharePDF)), forControlEvent: .touchUpInside)
        
    }
    
    override func viewDidLayoutSubviews() {
            pdfView.frame = view.frame
        }
    
    @objc func sharePDF(){
        let path = Bundle.main.path(forResource: "nameFile",  ofType:"pdf")
        let pdfDocument = PDFDocument(url: URL(fileURLWithPath: path!))

        var filesToShare = [Any]()
        filesToShare.append(pdfDocument!)

        let activityViewController = UIActivityViewController(activityItems: filesToShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
    }
    
    func createPdfDocument(_ requestBody: [String: AnyObject]?) {
        
        var router = RouterManager.getPrintForm.request()
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
//                    self.pdfView.autoresizesSubviews = true
//                    self.pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleLeftMargin]
//                    self.pdfView.displayDirection = .vertical
                    
                    self.pdfView.autoScales = true
//                    self.pdfView.displayMode = .singlePageContinuous
//                    self.pdfView.displaysPageBreaks = true
                    self.pdfView.document = document
                    
//                    self.pdfView.maxScaleFactor = 4.0
//                    self.pdfView.minScaleFactor = self.pdfView.scaleFactorForSizeToFit
                }
            }
        }.resume()
        
    }
    
    
    
}
