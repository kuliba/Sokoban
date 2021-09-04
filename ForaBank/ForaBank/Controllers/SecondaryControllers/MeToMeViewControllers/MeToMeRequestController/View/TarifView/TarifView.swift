//
//  TarifView.swift
//  ForaBank
//
//  Created by Mikhail on 03.09.2021.
//

import UIKit

class TarifView: UIView {
    
    //MARK: - Property
    private let kContentXibName = "TarifView"

    var viewDidTapped: (() -> Void)?
    
    @IBOutlet var contentView: UIView!
    
    //MARK: - Viewlifecicle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(kContentXibName, owner: self, options: nil)
        contentView.fixInView(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 48).isActive = true
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
    }
    
    @IBAction private func viewDidTapped(_ sender: Any) {
        viewDidTapped?()
    }
    
}
