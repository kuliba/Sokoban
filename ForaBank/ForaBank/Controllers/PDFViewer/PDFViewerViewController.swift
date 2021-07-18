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
        let resultId = id ?? 0
        let body = [
            "paymentOperationDetailId": 202,
            "printFormType" : "contactAddressless"
        ] as [String: AnyObject]
        let pdfManager = NetworkPDFManager(self.view, body)
        pdfManager.displayPdf()
        
//        let customView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
//        self.view.addSubview(customView)
        
    }
    
}
