//
//  ContactCollectionViewCell.swift
//  ForaBank
//
//  Created by Дмитрий on 23.06.2021.
//

import UIKit
import Contacts

class ContactCollectionViewCell: UICollectionViewCell{
    
    static var reuseId: String = "ContactCollectionViewCell"

    var contact: PhoneContact? {
        didSet {
            guard let contact = contact else { return }
            setup(contact: contact)
            print(checkOwner(number: contact.phoneNumber.first))
        }
    }
    
    @IBOutlet weak var bankImage: UIImageView!
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        contactImageView.layer.cornerRadius = contactImageView.frame.height / 2
    }

    func setup(contact: PhoneContact) {
        
        contactLabel.text = contact.name
        phoneLabel.text = contact.phoneNumber.first
        
        if self.contact?.avatarData?.isEmpty != nil {
            DispatchQueue.main.async {
                self.contactImageView.image =  UIImage(data: (contact.avatarData)!)
            }
        }
        if contact.bankImage == true {
            bankImage.isHidden = false
        }
    }
    
    func checkOwner(number: String?) -> Bool?{
        //        showActivity()
        let body = [ "phoneNumber": number ] as [String: AnyObject]
        var checkOwner: Bool?
        NetworkManager<GetOwnerPhoneNumberPhoneDecodableModel>.addRequest(.getOwnerPhoneNumber, [:], body) { model, error in
            if error != nil {
                checkOwner = false
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: getOwnerPhoneNumber: ", model)
            if model.statusCode == 0 {
                print("DEBUG: getOwnerPhoneNumber: ", "true")
                checkOwner = true
            } else {
                checkOwner = false
                print("DEBUG: Error: ", model.errorMessage ?? "")
//                DispatchQueue.main.async {
//                if model.errorMessage == "Пользователь не авторизован"{
//                    AppLocker.present(with: .validate)
//                }
//                }
            }
        }
        return checkOwner
    }
    
    
}
