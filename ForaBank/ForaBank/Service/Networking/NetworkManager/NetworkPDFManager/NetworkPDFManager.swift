//
//  NetworkPDFManager.swift
//  ForaBank
//
//  Created by Константин Савялов on 23.06.2021.
//

import Foundation
import PDFKit

class NetworkPDFManager: NSObject, URLSessionDownloadDelegate {
    
    
    let view: UIView?
    let requestBody: [String: AnyObject]?
    var pdfUrl:URL!
    
    func createPdfDocument() {
        
        var router = RouterManager.getPrintForm.request()
        var a: URL!
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
        let u = router?.url?.absoluteString
        let m = router?.httpMethod
        let c = router?.allHTTPHeaderFields
        print("DEBUG PDF :", u!, m!, c!)
        session.downloadTask(with: router!) { (url, response, err) in
            
            if let response = response as? HTTPURLResponse {
                
                print(response.mimeType)
            }
        }.resume()
    
    }
    
    func displayPDF() {
        let _ = createPdfDocument()
        guard pdfUrl != nil else { return }
        let doc = PDFDocument(url: pdfUrl)
        let pdfview = PDFView(frame: self.view!.bounds)
        pdfview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfview.autoScales = true
        self.view?.addSubview(pdfview)
        pdfview.document = doc
    }
    
    
    
    init(_ view: UIView, _ requestBody: [String: AnyObject]) {
        self.view = view
        self.requestBody = requestBody
    }
    
}

extension NetworkPDFManager {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
               print("DEBUG PDF Delegate downloadLocation:", location)
               do {
                   let documentsURL = try
                       FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask,
                                               appropriateFor: nil,
                                               create: false)

                   let savedURL = documentsURL.appendingPathComponent("yourCustomName90.pdf")
                   self.pdfUrl = savedURL
                   try FileManager.default.moveItem(at: location, to: savedURL)

               } catch {
                   print ("file error: \(error)")
               }
    }
}

import MobileCoreServices

extension URL {
    func mimeType() -> String {
        let pathExtension = self.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    var containsImage: Bool {
        let mimeType = self.mimeType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeImage)
    }
    var containsAudio: Bool {
        let mimeType = self.mimeType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeAudio)
    }
    var containsVideo: Bool {
        let mimeType = self.mimeType()
        guard  let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeMovie)
    }

}
