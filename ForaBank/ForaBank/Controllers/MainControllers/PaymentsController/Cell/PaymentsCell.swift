//
//  PaymentsCell.swift
//  ForaBank
//
//  Created by Mikhail on 03.06.2021.
//

import UIKit
import Contacts
import RealmSwift


class PaymentsCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseId: String = "PaymentsCell"
    
    var operatorsList: Results<GKHOperatorsModel>? = nil
    var operatorsListInternet: Results<InternetTVLatestOperationsModel>? = nil

    lazy var realm = try? Realm()

    
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
    
    var stackView = UIStackView()
    
    let titleLabel: UILabel = {
        let label = UILabel(text: "", font: .systemFont(ofSize: 12, weight: .regular), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    let descriptionLabel: UILabel = {
        let label = UILabel(text: "12", font: .systemFont(ofSize: 12, weight: .regular), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
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

        operatorsList = realm?.objects(GKHOperatorsModel.self)

        guard let payment: PaymentsModel = value as? PaymentsModel else { return }
        self.avatarImageView.image = nil

        switch payment.type {
        case "phone":
            descriptionLabel.isHidden = true
            titleLabel.alpha = 1
            iconImageView.alpha = 1
            titleLabel.text = payment.name
            guard let banks = Dict.shared.banks  else {
                return
            }
            for i in banks{
                if i.memberID == payment.lastPhonePayment?.bankID{
                    iconCountryImageView.image = i.svgImage?.convertSVGStringToImage()
                    iconCountryImageView.isHidden = false
                }
            }
            guard let avatarImage = UIImage(named: "smartphonegray") else { return }
            self.iconImageView.image = avatarImage
            self.initialsLabel.text = ""
            self.searchForContactUsingPhoneNumber(phoneNumber: String(payment.lastPhonePayment?.phoneNumber?.digits.dropFirst() ?? "")) { contact in
                    
                    self.titleLabel.text = "\(contact.givenName) \(contact.familyName)"
                    
                    
                    if contact.isKeyAvailable(CNContactImageDataKey) {
                        self.iconImageView.image = nil
                        if let contactImageData = contact.imageData {
                            self.avatarImageView.image = UIImage(data: contactImageData)
                        } else {
                            self.initialsLabel.text = self.contactInitialsPhone(model: contact)
                        }
                    } else {
                        guard let avatarImage = UIImage(named: "smartphonegray") else { return }
                        self.iconImageView.image = avatarImage
                    }
                }
            
        case "country":
            descriptionLabel.isHidden = true
            titleLabel.alpha = 1
            iconImageView.alpha = 1
            titleLabel.text = payment.lastCountryPayment?.shortName
            setCountry(code: payment.lastCountryPayment?.countryCode ?? "")
            iconCountryImageView.isHidden = false
            self.iconImageView.image = nil
            self.avatarImageView.image = nil
            
            
            if contactInitials(model: payment.lastCountryPayment) != ""{
                self.iconImageView.image = nil
                initialsLabel.text = contactInitials(model: payment.lastCountryPayment)
            } else {
                guard let avatarImage = UIImage(named: "smartphonegray") else { return }
//                self.iconImageView.images = avatarImage
            }
                    
            
            self.searchForContactUsingPhoneNumber(phoneNumber: String(payment.lastCountryPayment?.phoneNumber?.digits.dropFirst() ?? "")) { contact in
                    
                    self.titleLabel.text = "\(contact.givenName) \(contact.familyName)"
                    
                    
                    if contact.isKeyAvailable(CNContactImageDataKey) {
                        self.iconImageView.image = nil
                        if let contactImageData = contact.imageData {
                            self.avatarImageView.image = UIImage(data: contactImageData)
                        } else {
                            self.initialsLabel.text = self.contactInitialsPhone(model: contact)
                        }
                    }
                }
            
        case "service":
            descriptionLabel.isHidden = false
            titleLabel.alpha = 1
            iconImageView.alpha = 1
            guard let operators = operatorsList else {
                return
            }
            iconCountryImageView.isHidden = true
            self.avatarImageView.isHidden = false
            self.avatarImageView.image = UIImage(named: "GKH")

            for i in operators{
                if i.puref == payment.lastGKHPayment?.puref{
                    self.avatarImageView.image = i.logotypeList.first?.svgImage?.convertSVGStringToImage()
                    self.titleLabel.text = i.name
                    self.descriptionLabel.text = payment.lastGKHPayment?.amount?.string()
                    self.descriptionLabel.isHidden = false
                    iconCountryImageView.isHidden = true
                    self.avatarImageView.isHidden = false
                    break
                }
            }
            
            
        case "mobile":
            descriptionLabel.isHidden = true
            titleLabel.alpha = 1
            iconImageView.alpha = 1
            self.initialsLabel.text = ""
            guard let banks = Dict.shared.mobileSystem  else {
                return
            }
            for i in banks{
                if i.puref == payment.lastMobilePayment?.puref{
                    iconCountryImageView.image = i.svgImage?.convertSVGStringToImage()
                    iconCountryImageView.isHidden = false
                }
            }
            let phoneNumber = payment.lastMobilePayment?.additionalList?.filter{$0.fieldName == "a3_NUMBER_1_2"}
            let number = phoneNumber?.first?.fieldValue ?? ""
            let mask = StringMask(mask: "+7 (000) 000-00-00")
            self.titleLabel.text = mask.mask(string: number)
            guard let avatarImage = UIImage(named: "smartphonegray") else { return }
            self.iconImageView.image = avatarImage
            self.avatarImageView.image = nil
            self.searchForContactUsingPhoneNumber(phoneNumber: number) { contact in
                    
                    self.titleLabel.text = "\(contact.givenName) \(contact.familyName)"
                    
                    
                    if contact.isKeyAvailable(CNContactImageDataKey) {
                        self.iconImageView.image = nil
                        if let contactImageData = contact.imageData {
                            self.avatarImageView.image = UIImage(data: contactImageData)
                        } else {
                            self.initialsLabel.text = self.contactInitialsPhone(model: contact)
                        }
                    } else {
                        guard let avatarImage = UIImage(named: "smartphonegray") else { return }
                        self.iconImageView.image = avatarImage
                    }
                }

        case "internet":
            descriptionLabel.isHidden = false
            titleLabel.alpha = 1
            iconImageView.alpha = 1
            iconCountryImageView.isHidden = true
            self.avatarImageView.isHidden = false
            self.avatarImageView.image = UIImage(named: "GKH")

            let payModelArray = realm?.objects(InternetTVLatestOperationsModel.self)
            payModelArray?.forEach({ lastOperation in
                if lastOperation.puref == payment.lastInternetPayment?.puref{
                    let found = operatorsList?.filter {op in
                        op.puref == lastOperation.puref
                    }
                    if let arr = found, arr.count > 0, let op = arr.first {
                        self.titleLabel.text = op.name?.capitalizingFirstLetter() ?? ""
                        self.descriptionLabel.text = String(lastOperation.amount)
                        if let svgImage = op.logotypeList.first?.svgImage, svgImage != "" {
                            self.avatarImageView.image = svgImage.convertSVGStringToImage()
                        } else {
                            self.avatarImageView.image = UIImage(named: "GKH")
                        }
                    }
                }
            })

        default:
            titleLabel.text = payment.name
            titleLabel.alpha = 0.3
            iconImageView.alpha = 0.3
            iconCountryImageView.isHidden = true
            self.iconImageView.image = UIImage(named: "star")
            self.avatarImageView.image = nil
            initialsLabel.text = ""
            descriptionLabel.text = ""
        }
        

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
      
        stackView = UIStackView(arrangedSubviews: [titleLabel,
                                                   descriptionLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
        stackView.isUserInteractionEnabled = true
        addSubview(stackView)
        
        addSubview(iconImageView)
        addSubview(avatarImageView)
        addSubview(iconCountryImageView)

        initialsLabel.fillSuperview()
        
        iconImageView.center(inView: view)
        iconImageView.setDimensions(height: 32, width: 32)
        
        stackView.anchor(left: self.leftAnchor, right: self.rightAnchor)
        stackView.centerX(
            inView: view, topAnchor: view.bottomAnchor, paddingTop: 8)
//        descriptionLabel.anchor(top: titleLabel.bottomAnchor)
        
        iconCountryImageView.anchor(
            top: view.topAnchor, right: view.rightAnchor, paddingRight: -8)
        avatarImageView.center(inView: view)
        avatarImageView.setDimensions(height: 56, width: 56)
    }
    
    func contactInitials(model: GetAllLatestPaymentsDatum?) -> String {
        var initials = String()
        
        if let firstNameFirstChar = model?.firstName?.first {
            initials.append(firstNameFirstChar)
        }
        
        if let lastNameFirstChar = model?.surName?.first {
            initials.append(lastNameFirstChar)
        }
        
        return initials
    }
    
    func contactInitialsPhone(model: CNContact?) -> String {
        var initials = String()
        
        if let firstNameFirstChar = model?.givenName.first {
            initials.append(firstNameFirstChar)
        }
        
        if let lastNameFirstChar = model?.familyName.first {
            initials.append(lastNameFirstChar)
        }
        
        return initials
    }
    
    
    func setCountry(code: String){
        let list = Dict.shared.countries
        list?.forEach({ country in
            if country.code == code {
                self.iconCountryImageView.image = country.svgImage?.convertSVGStringToImage()
            }
        })
    }
    
    func searchForContactUsingPhoneNumber(phoneNumber: String, completion: @escaping  (_ contact: CNContact) -> Void) {
        self.requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                var contacts = [CNContact]()
                
                let contactsStore = CNContactStore()
                do {
                    try contactsStore.enumerateContacts(with: CNContactFetchRequest(keysToFetch: self.allowedContactKeys())) {
                        (contact, cursor) -> Void in
                        if (!contact.phoneNumbers.isEmpty) {
                            let phoneNumberToCompareAgainst = phoneNumber.components(
                                separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
                            for phoneNumber in contact.phoneNumbers {
                                if let phoneNumberStruct = phoneNumber.value as? CNPhoneNumber {
                                    let phoneNumberString = phoneNumberStruct.stringValue.digits
                                    let phoneNumberToCompare = phoneNumberString.components(
                                        separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
                                    
                                    if phoneNumberToCompare.suffix(7) == phoneNumberToCompareAgainst.suffix(7) {
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
