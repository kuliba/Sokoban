//
//  ConfurmPaymentsView.swift
//  ForaBank
//
//  Created by Mikhail on 19.06.2021.
//

import UIKit

class ConfurmPaymentsView: UIView {

    //MARK: - Property
    let kContentXibName = "ConfurmPaymentsView"
    
    @IBOutlet var contentView: UIView!
    
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    func commonInit() {
        Bundle.main.loadNibNamed(kContentXibName, owner: self, options: nil)
        contentView.fixInView(self)
        
        layer.shadowRadius = 16
        
    }
    
}
