//
//  ContactTableViewCell.swift
//  ForaBank
//
//  Created by Дмитрий on 09.02.2021.
//  Copyright © 2021 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

protocol ContactTableViewCellDelegate: AnyObject{
    func didTapOnButton(_ list: ListInput?, index: Int?, data: ListInput?)
    func didChangeEnd(fieldName: String?, index: Int?, value: String?)
    func clearInputs(refresh: Bool)
    func didOpenSearchList(index: Int?)
}

class ContactTableViewCell: UITableViewCell, ListOperationViewControllerProtocol {
    func backFromDismiss(value: String?, key: String?, index: Int?, valueKey: String, fieldEmpty: Bool, segueId: String, listInputs: [ListInput?], parameters: [Additional]) {
        textField.text = value
        selectCountry.setTitle(value, for: .normal)
    }
    
    func onUserAction(value: String?, key: String?) {
        selectCountry.setTitle(value, for: .normal)
    }
    

    weak var delegate: ContactTableViewCellDelegate?
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var selectCountry: UIButton!
    
    var fieldname: String?
    var fieldid: Int?
    var dataList: ListInput?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if titleLabel.text == "Сумма перевода в валюте выдачи"{
            self.contentView.heightConstaint?.constant = 0
        }
        textField.indent(size: 10)
        // Initialization code
    }

    @IBAction func didBeginChanged(_ sender: Any) {
        if fieldname == "search"{
        delegate?.didOpenSearchList(index: fieldid)
        }
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func selectCountry(_ sender: Any) {
        delegate?.didTapOnButton(nil, index: fieldid, data: dataList)

    }
    @IBAction func textFieldDidChangeEnd(_ sender: Any) {
        guard let fieldNameUnwrapped = fieldname, let fieldIdUnwrapped = fieldid, let fieldValue = textField.text else {
            return
        }
        textField.text = textField.text?.capitalizingFirstLetter()
        delegate?.didChangeEnd(fieldName: fieldNameUnwrapped, index: fieldIdUnwrapped, value: fieldValue.capitalizingFirstLetter())
    }
    
    
}
extension UITextField {
    func indent(size:CGFloat) {
        self.leftView = UIView(frame: CGRect(x: self.frame.minX, y: self.frame.minY, width: size, height: self.frame.height))
        self.leftViewMode = .always
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}
