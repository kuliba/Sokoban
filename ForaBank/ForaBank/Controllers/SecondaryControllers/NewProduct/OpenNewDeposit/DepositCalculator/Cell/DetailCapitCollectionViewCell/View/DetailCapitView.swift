//
//  DetailCapitView.swift
//  ForaBank
//
//  Created by Mikhail on 28.04.2022.
//

import UIKit

class DetailCapitView: UIView {
    
    let kContentXibName = "DetailCapitView"
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var rateleft: UILabel!
    @IBOutlet weak var rateRight: UILabel!
    
    //MARK: - Viewlifecicle
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
        self.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
    }

}
