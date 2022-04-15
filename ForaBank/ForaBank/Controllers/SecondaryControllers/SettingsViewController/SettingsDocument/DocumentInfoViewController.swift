//
//  DocumentInfoViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.04.2022.
//

import UIKit

class DocumentInfoViewController: UIViewController {
    
    var subView: DocumentInfoView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.view.addSubview(subView)
        self.view.backgroundColor  = .white
    }
    
    required init(model: DocumentInfoView) {
            self.subView = model
            super.init(nibName: nil, bundle: nil)
        }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
