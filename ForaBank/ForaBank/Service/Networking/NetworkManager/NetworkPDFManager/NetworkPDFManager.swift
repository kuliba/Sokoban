//
//  NetworkPDFManager.swift
//  ForaBank
//
//  Created by Константин Савялов on 23.06.2021.
//

import Foundation
import PDFKit

final class NetworkPDFManager {
    
    let view: UIView?
    let requestBody: [String: AnyObject]?
    
    private func resourceUrl(forFileName fileName: String) -> URL? {
        if let resourceUrl = Bundle.main.url(forResource: fileName, withExtension: "pdf") {
            return resourceUrl
        }
        return nil
    }
    
    private func createPdfView(withFrame frame: CGRect) -> PDFView {
        
        let pdfView = PDFView(frame: frame)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfView.autoScales = true
        return pdfView
    }
    
    private func createPdfDocument(forFileName fileName: String) -> PDFDocument? {
        //            if let resourceUrl = self.resourceUrl(forFileName: fileName) {
        //                return PDFDocument(url: resourceUrl)
        //            }
        
        let url = URL(string: RouterUrlList.getPrintForm.rawValue)!
        if var urlComponents = URLComponents(url: url,
                                             resolvingAgainstBaseURL: false), !(requestBody?.isEmpty ?? true) {
            
            urlComponents.queryItems = [URLQueryItem]()
            requestBody?.forEach({ (key, value) in
                let queryItem = URLQueryItem(name: key,
                                             value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
                urlComponents.queryItems?.append(queryItem)
            })
            
            print("DEBUG: URLrequest:", urlComponents.url ?? "")
        }
        
        let resultUrl = url.absoluteString
        if let resourceUrl = URL(string: resultUrl) {
            return PDFDocument(url: resourceUrl)
        }
        return nil
    }
    
    final func displayPdf() {
        let pdfView = self.createPdfView(withFrame: self.view!.bounds)
        
        if let pdfDocument = self.createPdfDocument(forFileName: "heaps") {
            self.view?.addSubview(pdfView)
            pdfView.document = pdfDocument
        }
    }
    
    init(_ view: UIView, _ requestBody: [String: AnyObject]) {
        self.view = view
        self.requestBody = requestBody
    }
    
}
