//
//  OrderCardView.swift
//  ForaBank
//
//  Created by Mikhail on 01.06.2021.
//

import UIKit

class OrderCardView: UIView {

    //MARK: - Property
    let kContentXibName = "OrderCardView"
    var orderCardTapped: (() -> Void)?
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
    }
    
    //MARK: - IBAction
    @IBAction func OrderCardDidTapped(_ sender: Any) {
        orderCardTapped?()
    }
    
}
