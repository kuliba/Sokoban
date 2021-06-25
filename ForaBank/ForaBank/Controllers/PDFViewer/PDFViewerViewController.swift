//
//  PDFViewerViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 24.06.2021.
//

import UIKit
import PDFKit

class PDFViewerViewController: UIViewController {

    
    
    var id: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black

        let body = ([
            "paymentOperationDetailId": id ?? 0,
            "printFormType": "sbp"
        ] as? [String: AnyObject])!
        
        print(body)
        
        NetworkPDFManager.addRequest([:], body)

        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        self.view.addSubview(customView)
        
        
        setPDF(customView)
        
    }
    
    
    func setPDF(_ mainView: UIView) {
        
        let fileManager = FileManagerHandler()
        let pdfView = PDFView()
        
        NotificationCenter.default.addObserver(forName: .pdf, object: nil, queue: .main) { _ in
            
            let url = fileManager.fileRead ("pdf")
            let pdfURL = URL(fileURLWithPath: url)
            mainView.addSubview(pdfView)
            if let document = PDFDocument(url: pdfURL) {
                pdfView.document = document
            }
        }
    }
    
    

}
