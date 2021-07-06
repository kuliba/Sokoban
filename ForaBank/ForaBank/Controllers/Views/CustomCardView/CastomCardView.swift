//
//  CastomCardView.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.07.2021.
//

import UIKit

class CastomCardView: UIView {
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var dateStackView: UIStackView!
    @IBOutlet var contentView: UIView!
    
   
    @IBOutlet weak var cardTextField: MaskedTextField!
    @IBOutlet weak var dateTaxtField: UITextField!
    @IBOutlet weak var cvcTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var qrButton: UIButton!
    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var dateLable: UILabel!
    @IBOutlet weak var cvcLable: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var dateLineView: UIView!
    @IBOutlet weak var cvcLineView: UIView!
    @IBOutlet weak var nameLineView: UIView!
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    func commonInit() {
        Bundle.main.loadNibNamed("CastomCardXIB", owner: self, options: nil)
        contentView.fixView(self)
        cardTextField.maskString = "0000 0000 0000 0000"
    }
    
    
    @IBAction func qrButton(_ sender: UIButton) {
    }
    @IBAction func goBackButton(_ sender: UIButton) {
    }
    @IBAction func cardTextField(_ sender: Any) {
    }
    @IBAction func dateTaxtField(_ sender: UITextField) {
    }
    @IBAction func cvcTextField(_ sender: UITextField) {
    }
    @IBAction func nameTextField(_ sender: UITextField) {
    }
}

