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
    var banks: FastPayment?

    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        ownerImageView.layer.cornerRadius = ownerImageView.frame.size.width/2
        ownerImageView.clipsToBounds = true
        selectionStyle = UITableViewCell.SelectionStyle.none
        contactContainerView.layer.masksToBounds = true
        contactContainerView.layer.cornerRadius = contactContainerView.frame.size.width/2
        if checkOwner(number: contact?.phoneNumbers.first?.phoneNumber) ?? false {
            ownerImageView.isHidden = false
        }
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
 
    func updateContactsinUI(_ contact: EPContact, indexPath: IndexPath, subtitleType: SubtitleCellValue) {
        self.contact = contact
        
//        DispatchQueue.main.async{ [self] in
//            if checkOwner(number: "7\(contact[indexPath.item].phoneNumbers.first?.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").dropFirst() ?? "")", index: indexPath.item) ?? false {
//                item.bankImage.isHidden = false
//
//            }
//        }
        if checkOwner(number: contact.phoneNumbers.first?.phoneNumber) ?? false {
            ownerImageView.isHidden = false
        }
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
    
    func checkOwner(number: String?) -> Bool?{
//        showActivity()
        let body = [
            "phoneNumber": number
        ] as [String: AnyObject]
        
        var checkOwner: Bool?
        
        NetworkManager<GetOwnerPhoneNumberPhoneDecodableModel>.addRequest(.getOwnerPhoneNumber, [:], body) { model, error in
            if error != nil {
                
                checkOwner = false
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: Card list: ", model)
         

            if model.statusCode == 0 {
                
//                self.selectedCardNumber = cardNumber
                DispatchQueue.main.sync {
                    checkOwner = true
                    
//                    self.checkOwnerFetch = true
//                    self.contacts[index].bankImage = true
//                    self.contactCollectionView.reloadItems(at: [IndexPath(index: index)])

                }
            } else {
                
                checkOwner = false
                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        }
        return checkOwner
    }
}
