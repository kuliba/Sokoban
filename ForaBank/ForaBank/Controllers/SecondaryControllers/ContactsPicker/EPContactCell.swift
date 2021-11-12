//
//  EPContactCell.swift
//  EPContacts
//
//  Created by Prabaharan Elangovan on 13/10/15.
//  Copyright © 2015 Prabaharan Elangovan. All rights reserved.
//

import UIKit

class EPContactCell: UITableViewCell {

    @IBOutlet weak var contactTextLabel: UILabel!
    @IBOutlet weak var contactDetailTextLabel: UILabel!
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var contactInitialLabel: UILabel!
    @IBOutlet weak var contactContainerView: UIView!
    @IBOutlet weak var ownerImageView: UIImageView!
    
    var contact: EPContact?
    var banks: BanksList?
    var needChek = false

    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        
        ownerImageView.layer.cornerRadius = ownerImageView.frame.size.width/2
        ownerImageView.clipsToBounds = true
        selectionStyle = UITableViewCell.SelectionStyle.none
        contactContainerView.layer.masksToBounds = true
        contactContainerView.layer.cornerRadius = contactContainerView.frame.size.width/2
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateInitialsColorForIndexPath(_ indexpath: IndexPath) {
        //Applies color to Initial Label
        let colorArray = [EPGlobalConstants.Colors.amethystColor,EPGlobalConstants.Colors.asbestosColor,EPGlobalConstants.Colors.emeraldColor,EPGlobalConstants.Colors.peterRiverColor,EPGlobalConstants.Colors.pomegranateColor,EPGlobalConstants.Colors.pumpkinColor,EPGlobalConstants.Colors.sunflowerColor]
        let randomValue = (indexpath.row + indexpath.section) % colorArray.count
        contactInitialLabel.backgroundColor = colorArray[randomValue]
    }
    
    func updateBankCell(){
        contactContainerView.layer.cornerRadius = 0
        guard let banksList = Dict.shared.banks else {
            return
        }
        for item in banksList {
            if item.memberID == banks?.memberID{
                self.contactImageView?.image = item.svgImage?.convertSVGStringToImage()
            self.contactImageView.isHidden = false
            }
            
        }
    }
    
    func updateContactsinUI(_ contact: EPContact, indexPath: IndexPath, subtitleType: SubtitleCellValue) {
        self.contact = contact
   
        self.contactTextLabel?.text = contact.displayName()
        updateSubtitleBasedonType(subtitleType, contact: contact)
        if contact.thumbnailProfileImage != nil {
            self.contactImageView?.image = contact.thumbnailProfileImage
            self.contactImageView.isHidden = false
            self.contactInitialLabel.isHidden = true
        } else {
            self.contactInitialLabel.text = contact.contactInitials()
            updateInitialsColorForIndexPath(indexPath)
            self.contactImageView.isHidden = true
            self.contactInitialLabel.isHidden = false
        }
        if needChek && !contact.phoneNumbers.isEmpty {
            checkOwner(number: contact.phoneNumbers.first?.phoneNumber) { [weak self] needShow in
                DispatchQueue.main.async {
                    self?.ownerImageView.isHidden = !needShow
                }
            }
        } else {
            ownerImageView.isHidden = true
        }
        
    }
    
    func updateSubtitleBasedonType(_ subtitleType: SubtitleCellValue , contact: EPContact) {
        
        switch subtitleType {
            
        case SubtitleCellValue.phoneNumber:
            let phoneNumberCount = contact.phoneNumbers.count
            
            if phoneNumberCount == 1  {
                self.contactDetailTextLabel.text = "\(contact.phoneNumbers[0].phoneNumber)"
            }
            else if phoneNumberCount > 1 {
                self.contactDetailTextLabel.text = "\(contact.phoneNumbers[0].phoneNumber) и \(contact.phoneNumbers.count-1) еще"
            }
            else {
                self.contactDetailTextLabel.text = EPGlobalConstants.Strings.phoneNumberNotAvaialable
            }
        case SubtitleCellValue.email:
            let emailCount = contact.emails.count
        
            if emailCount == 1  {
                self.contactDetailTextLabel.text = "\(contact.emails[0].email)"
            }
            else if emailCount > 1 {
                self.contactDetailTextLabel.text = "\(contact.emails[0].email) и \(contact.emails.count-1) еще"
            }
            else {
                self.contactDetailTextLabel.text = EPGlobalConstants.Strings.emailNotAvaialable
            }
        case SubtitleCellValue.birthday:
            self.contactDetailTextLabel.text = contact.birthdayString
        case SubtitleCellValue.organization:
            self.contactDetailTextLabel.text = contact.company
        }
    }
    
    func checkOwner(number: String?, completion: @escaping (Bool) -> () ) {
        guard let number = number else { return }
        let body = [ "phoneNumber": number.digits ] as [String: AnyObject]
        NetworkManager<GetOwnerPhoneNumberPhoneDecodableModel>.addRequest(.getOwnerPhoneNumber, [:], body) { model, error in
            print(body)
            if error != nil {
                completion(false)
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                if model.data != "" && model.data != nil {
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
                    print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        }
        
    }
}
