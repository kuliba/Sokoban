//
//  NetworkPDFManagerExtension.swift
//  ForaBank
//
//  Created by Константин Савялов on 23.06.2021.
//

import Foundation
import PDFKit

extension NetworkPDFManager:  URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("downloadLocation:", location)
        let fileManager = FileManagerHandler()
        fileManager.fileSave("pdf", fileText: location.absoluteString)
        NotificationCenter.default.post(name: .pdf, object: nil)
    }
    
    final public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard error == nil else {
            debugPrint("PDFTask completed: \(task), error: \(String(describing: error))")
            return
        }
    }
    
    func setPDF(_ mainView: UIView) {
        
        let fileManager = FileManagerHandler()
        let pdfView = PDFView()
        
        NotificationCenter.default.addObserver(forName: .pdf, object: nil, queue: .main) { [weak self] _ in
            
            let url = fileManager.fileRead ("pdf")
            let pdfURL = URL(fileURLWithPath: url)
            mainView.addSubview(pdfView)
            if let document = PDFDocument(url: pdfURL) {
                pdfView.document = document
            }
        }
    }
    
            
    //       1. NetworkPDFManager.addRequest(.getPrintForm, parameters, body)
    
    //       2.     override func viewDidLayoutSubviews() {
    //                pdfView.frame = view.frame
    //            }
    
    //       3. setPDF(view)
    
    
}
