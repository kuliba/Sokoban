//
//  EPContactSelfDataView.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.03.2022.
//

import UIKit

class EPContactSelfDataView: UIView {

    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var userPhone: UILabel!
    @IBOutlet weak var tapViewButton: UIButton!
    
    var tapClouser: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        addPhone()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initUI()
        addPhone()
    }
    
    private func initUI() {
        Bundle.main.loadNibNamed("EPContactSelfDataView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        topLineView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1)
        bottomLineView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1)
    }
    
    private func addPhone() {
        guard var phone = UserDefaults.standard.object(forKey: "UserPhone") as? String else { return }
        if phone.first == "7" {
            let mask = StringMask(mask: "+0 (000) 000-00-00")
            let maskPhone = mask.mask(string: phone)
            self.userPhone.text = maskPhone?.description
            
        } else if phone.first == "8" {
            phone.removeFirst()
            let mask = StringMask(mask: "+7 (000) 000-00-00")
            let maskPhone = mask.mask(string: phone)
            self.userPhone.text = maskPhone?.description
        }
    }
    
    @IBAction func tapViewButton(_ sender: UIButton) {
        tapClouser!()
    }
}
