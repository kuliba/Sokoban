//
//  PDFViewerViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 24.06.2021.
//

import UIKit
import PDFKit

class PDFViewerViewController: UIViewController, URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
    }
    
    
    var id: Int?
    
    var pdfView = PDFView()
        var pdfURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        let resultId = id ?? 0
        let body = [
            "paymentOperationDetailId": 202,
            "printFormType" : "contactAddressless"
        ] as [String: AnyObject]

        createPdfDocument(body)
        
    }
    
    override func viewDidLayoutSubviews() {
            pdfView.frame = view.frame
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
                self.view.addSubview(self.pdfView)
                if let document = PDFDocument(url: url!) {
                    self.pdfView.autoresizesSubviews = true
                    self.pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleLeftMargin]
                    self.pdfView.displayDirection = .vertical

                    self.pdfView.autoScales = true
                    self.pdfView.displayMode = .singlePageContinuous
                    self.pdfView.displaysPageBreaks = true
                    self.pdfView.document = document

                    self.pdfView.maxScaleFactor = 4.0
                    self.pdfView.minScaleFactor = self.pdfView.scaleFactorForSizeToFit
                        }
            }
        }.resume()
    
    }
    
}
