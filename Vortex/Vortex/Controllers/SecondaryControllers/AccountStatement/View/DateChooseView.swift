//
//  DateChooseView.swift
//  ForaBank
//
//  Created by Mikhail on 16.11.2021.
//

import UIKit

class DateChooseView: UIView {
    
    //MARK: - Property
    let kContentXibName = "DateChooseView"
    var buttonIsTapped: ((UIButton) -> Void)?

    @IBOutlet var contentView: UIView!
    
    //MARK: - Viewlifecicle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(viewModel: ForaInputModel(title: ""))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(viewModel: ForaInputModel(title: ""))
    }
    
    required init(frame: CGRect = .zero, viewModel: ForaInputModel) {
        super.init(frame: frame)
        commonInit(viewModel: viewModel)
    }

    
    func commonInit(viewModel: ForaInputModel) {
        Bundle.main.loadNibNamed(kContentXibName, owner: self, options: nil)
        contentView.fixInView(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        isHidden = true
        alpha = 0
//        contentView.backgroundColor = .red
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        self.buttonIsTapped?(sender)
    }
    
    
}
