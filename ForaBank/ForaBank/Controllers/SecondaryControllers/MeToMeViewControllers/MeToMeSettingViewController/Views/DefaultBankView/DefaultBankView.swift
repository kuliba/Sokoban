//
//  DefaultBankView.swift
//  ForaBank
//
//  Created by Mikhail on 25.07.2022.
//

import UIKit

class DefaultBankView: UIView {
    
    //MARK: - Property
    let kContentXibName = "DefaultBankView"
    
    @IBOutlet var contentView: UIView!
   
    
    //MARK: - Viewlifecicle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(frame: CGRect = .zero, viewModel: ForaInputModel) {
        super.init(frame: frame)
        commonInit()
    }

    
    func commonInit() {
        Bundle.main.loadNibNamed(kContentXibName, owner: self, options: nil)
        contentView.fixInView(self)
    }
    
    
}
