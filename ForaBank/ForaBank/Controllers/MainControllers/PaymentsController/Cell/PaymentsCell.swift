//
//  PaymentsCell.swift
//  ForaBank
//
//  Created by Mikhail on 03.06.2021.
//

import UIKit
import Contacts

class PaymentsCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseId: String = "PaymentsCell"
    
    let iconImageView = UIImageView()
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 56/2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    
    let initialsLabel: UILabel = {
        let label = UILabel(text: "", font: .boldSystemFont(ofSize: 12), color: #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1))
        label.textAlignment = .center
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel(text: "", font: .systemFont(ofSize: 12, weight: .regular), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    let iconCountryImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage())
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(height: 24, width: 24)
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.isHidden = true
        return imageView
    }()
    
    func configure<U>(with value: U) where U : Hashable {
        guard let payment: PaymentsModel = value as? PaymentsModel else { return }
        if payment.name == "Шаблоны и\nавтоплатежи" {
            titleLabel.text = payment.name
            titleLabel.alpha = 0.3
            iconImageView.alpha = 0.3
            if let iconName = payment.iconName {
                iconImageView.image = UIImage(named: iconName)
            }
        } else {
            let mask = StringMask(mask: "+7 (000) 000-00-00")
            self.titleLabel.text = "\(payment.name)"
            guard let avatarImage = UIImage(named: "smartphonegray") else { return }
            self.iconImageView.image = avatarImage
            
            if let unMaskPhone = mask.unmask(string: payment.name) {
                self.searchForContactUsingPhoneNumber(phoneNumber: unMaskPhone) { contact in
                    
                    self.titleLabel.text = "\(contact.givenName) \(contact.familyName)"
                    
                    if contact.isKeyAvailable(CNContactImageDataKey) {
                        if let contactImageData = contact.imageData {
//                            print(UIImage(data: contactImageData))
                            // Print the image set on the contact
                            self.avatarImageView.image = UIImage(data: contactImageData)
                        }
                    } else {
                        // No Image available
//                        guard let avatarImageName = payment.avatarImageName else { return }
                        guard let avatarImage = UIImage(named: "smartphonegray") else { return }
                        self.iconImageView.image = avatarImage
                    }
                }
                
            } else {
                
                titleLabel.text = payment.name
                if let iconName = payment.iconName {
                    iconImageView.image = UIImage(named: iconName)
                }
                guard let avatarImageName = payment.avatarImageName else { return }
                guard let avatarImage = UIImage(named: avatarImageName) else { return }
                iconImageView.image = avatarImage
            }
        }

        if payment.lastCountryPayment != nil {
            iconCountryImageView.isHidden = false
            iconImageView.isHidden = true
            if payment.lastCountryPayment?.phoneNumber != nil {
                initialsLabel.isHidden = true
                iconImageView.isHidden = false
            } else {
                initialsLabel.isHidden = false
            }
        } else {
            iconCountryImageView.isHidden = true
            initialsLabel.isHidden = true
            iconImageView.isHidden = false
            
        }
        iconCountryImageView.image = payment.lastCountryPayment != nil
            ? payment.lastCountryPayment?.countryImage
            : UIImage()
        
        initialsLabel.text = contactInitials(model: payment.lastCountryPayment)
        
        guard let avatarImageName = payment.avatarImageName else { return }
        guard let avatarImage = UIImage(named: avatarImageName) else { return }
        iconImageView.image = avatarImage
        avatarImageView.image = UIImage()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupUI() {
        let view = UIView()
        addSubview(view)
        view.setDimensions(height: 56, width: 56)
        view.centerX(inView: self, topAnchor: self.topAnchor)
        view.layer.cornerRadius = 56 / 2
        view.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.968627451, alpha: 1)
        view.addSubview(initialsLabel)
        
        addSubview(titleLabel)
        addSubview(iconImageView)
        addSubview(iconCountryImageView)
        addSubview(avatarImageView)
             
        initialsLabel.fillSuperview()
        
        iconImageView.center(inView: view)
        iconImageView.setDimensions(height: 32, width: 32)
        
        titleLabel.anchor(left: self.leftAnchor, right: self.rightAnchor)
        titleLabel.centerX(
            inView: view, topAnchor: view.bottomAnchor, paddingTop: 8)
        
        iconCountryImageView.anchor(
            top: view.topAnchor, right: view.rightAnchor, paddingRight: -8)
        avatarImageView.center(inView: view)
        avatarImageView.setDimensions(height: 56, width: 56)
    }
    
    func contactInitials(model: ChooseCountryHeaderViewModel?) -> String {
        var initials = String()
        
        if let firstNameFirstChar = model?.firstName?.first {
            initials.append(firstNameFirstChar)
        }
        
        if let lastNameFirstChar = model?.surName?.first {
            initials.append(lastNameFirstChar)
        }
        
        return initials
    }
    
    
    
    func searchForContactUsingPhoneNumber(phoneNumber: String, completion: @escaping  (_ contact: CNContact) -> Void) {
        self.requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactImageDataKey, CNContactPhoneNumbersKey]
                var contacts = [CNContact]()
                var message: String!
                
                let contactsStore = CNContactStore()
                do {
                    try contactsStore.enumerateContacts(with: CNContactFetchRequest(keysToFetch: self.allowedContactKeys())) {
                        (contact, cursor) -> Void in
                        if (!contact.phoneNumbers.isEmpty) {
                            let phoneNumberToCompareAgainst = phoneNumber.components(
                                separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
                            for phoneNumber in contact.phoneNumbers {
                                if let phoneNumberStruct = phoneNumber.value as? CNPhoneNumber {
                                    let phoneNumberString = phoneNumberStruct.stringValue
                                    let phoneNumberToCompare = phoneNumberString.components(
                                        separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
                                    if phoneNumberToCompare == phoneNumberToCompareAgainst {
                                        contacts.append(contact)
                                    }
                                }
                            }
                        }
                    }
                    
                    if contacts.count == 0 {
                        message = "No contacts were found matching the given phone number."
                    }
                }
                catch {
                    message = "Unable to fetch contacts."
                }
                
                if message != nil {
                    DispatchQueue.main.async {
                        print(message ?? "")
                    }
                }
                else {
                    // Success
                    DispatchQueue.main.async {
                        
                        // Do someting with the contacts in the main queue, for example
                        /*
                         self.delegate.didFetchContacts(contacts) <= which extracts the required info and puts it in a tableview
                         */
                        print(contacts) // Will print all contact info for each contact (multiple line is, for example, there are multiple phone numbers or email addresses)
                        let contact = contacts[0] // For just the first contact (if two contacts had the same phone number)
                        completion(contact)
                        
                        
                        print(contact.givenName) // Print the "first" name
                        print(contact.familyName) // Print the "last" name
                        if contact.isKeyAvailable(CNContactImageDataKey) {
                            if let contactImageData = contact.imageData {
                                print(UIImage(data: contactImageData)) // Print the image set on the contact
                            }
                        } else {
                            // No Image available
                            
                        }
                    }
                }
            }
        }
        
    }
    
    func allowedContactKeys() -> [CNKeyDescriptor]{
        //We have to provide only the keys which we have to access. We should avoid unnecessary keys when fetching the contact. Reducing the keys means faster the access.
        return [CNContactNamePrefixKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactOrganizationNameKey as CNKeyDescriptor,
            CNContactBirthdayKey as CNKeyDescriptor,
            CNContactImageDataKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor,
            CNContactImageDataAvailableKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
        ]
    }
    
    func requestForAccess(completionHandler: @escaping  (_ accessGranted: Bool) -> Void) {
        // Get authorization
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        // Find out what access level we have currently
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
            
        case .denied, .notDetermined:
            CNContactStore().requestAccess(for: .contacts) { access, accessError in
                if access {
                    completionHandler(access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.denied {
                        DispatchQueue.main.async {
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            print(message)
                        }
                    }
                }
            }
            
        default:
            completionHandler(false)
        }
    }
    
    
    
    
}
