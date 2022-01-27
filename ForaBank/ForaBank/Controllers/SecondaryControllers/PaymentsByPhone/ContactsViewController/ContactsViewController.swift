//
//  ContactsViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 23.06.2021.
//

import UIKit
import ContactsUI


class ContactsViewController: UIViewController, UITextFieldDelegate, PassTextFieldText{
    
    
    let tableView = UITableView(frame: .zero, style: .plain)
    // MARK: - Properties
    
    open weak var contactDelegate: EPPickerDelegate?
    var contactsStore: CNContactStore?
    var resultSearchController = Bool()
    var orderedContacts = [String: [CNContact]]() //Contacts ordered in dicitonary alphabetically
    var orderedBanks = [String: [BanksList]]()
    var sortedContactKeys = [String]()
    
    var selectedContacts = [EPContact]()
    var filteredContacts = [CNContact]()
    
    var subtitleCellValue = SubtitleCellValue.phoneNumber
    var multiSelectEnabled: Bool = false //Default is single selection contact
    var banksActive = false
    var seeall: Bool?
    var stackView = UIStackView()
    var firstTap = true
    
    var lastPaymentsCollectionView: UICollectionView!
    var contactCollectionView: UICollectionView!
    var delegate: PassTextFieldText? = nil
    let contactView = UIView()
    var banksList = [BanksList]()
    
    var reserveContacts = [PhoneContact]()
    var numberPhone: String?
    
    var banks: [FastPayment]?
    
    var selectPhoneNumber: String?
    var selectPerson: String?
    
    let searchContact: SearchContact = UIView.fromNib()
    
    var lastPayment = [GetLatestPaymentsDatum](){
        didSet{
            stackView.insertArrangedSubview(lastPaymentsCollectionView, at: 1)
            lastPaymentsCollectionView.reloadData()
        }
    }

    var counterNumbers = 0
    
    var lastPhonePayment = [GetLatestPhone](){
        didSet{
            stackView.insertArrangedSubview(lastPaymentsCollectionView, at: 1)
            lastPaymentsCollectionView.reloadData()
        }
    }
    
    var contacts = [PhoneContact]() {
        didSet{
            for contact in contacts {
                contact.phoneNumber[0] = format(phoneNumber:  contact.phoneNumber.first!.description) ?? ""
            }
            contactCollectionView.reloadData()
            //            setupCollectionView()
        }
    }// array of PhoneContact(It is model find it below)
    var filter: ContactsFilter = .none
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        banksList = Dict.shared.banks?.filter({$0.paymentSystemCodeList?.first == "SFP"}) ?? []
        let viewLine = UIView()
        
        tableView.keyboardDismissMode = .interactive
        tableView.keyboardDismissMode = .onDrag
        view.backgroundColor = .white
        
        
        self.delegate = self
        configureTableView()
        registerContactCell()
        searchContact.maskPhone = true
        searchContact.delegateNumber = self
        searchContact.buttonStackView.isHidden = false
        searchContact.anchor(height:44)
        
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSize(width: 80, height: 100)
        layout.scrollDirection = .horizontal
        
        lastPaymentsCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        let xib = UINib.init(nibName: "LastPaymentsCollectionViewCell", bundle: nil)
        lastPaymentsCollectionView.register(xib, forCellWithReuseIdentifier: "LastPaymentsCollectionViewCell")
        
        let flowLayout = UICollectionViewFlowLayout()
        
        lastPaymentsCollectionView.isScrollEnabled = true
        
        contactCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        
        contactView.addSubview(tableView)
        contactCollectionView.isHidden = true
        tableView.anchor()
        lastPaymentsCollectionView.backgroundColor = .white
        contactCollectionView.delegate = self
        contactCollectionView.dataSource = self
        lastPaymentsCollectionView?.dataSource = self
        lastPaymentsCollectionView?.delegate = self
        contactCollectionView.backgroundColor = .white
        
        contactCollectionView.register(UINib(nibName: "HeaderBanksCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderBanksCollectionReusableView")
        
        contactCollectionView.register(UINib(nibName: "ContactCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ContactCollectionViewCell")
        lastPaymentsCollectionView.register(UINib(nibName: "LastPaymentsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LastPaymentsCollectionViewCell")
        
        lastPaymentsCollectionView.anchor(height: 100)
        
        lastPaymentsCollectionView.insetsLayoutMarginsFromSafeArea = true
        searchContact.insetsLayoutMarginsFromSafeArea = true
        lastPaymentsCollectionView.showsHorizontalScrollIndicator = false
        viewLine.anchor(width:  UIScreen.main.bounds.width + 20, height: 1)
        viewLine.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1)
        
        switch seeall {
        case true:
            stackView = UIStackView(arrangedSubviews: [searchContact, lastPaymentsCollectionView,viewLine, tableView, contactCollectionView])
        default:
            stackView = UIStackView(arrangedSubviews: [searchContact, lastPaymentsCollectionView,viewLine, tableView, contactCollectionView])
        }
        
        
        lastPaymentsCollectionView.isHidden = true
        searchContact.backgroundColor = .white
        
        stackView.isLayoutMarginsRelativeArrangement = true
        contactView.isUserInteractionEnabled = true
        contactCollectionView.isScrollEnabled = true
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.backgroundColor = .white
        
        view.addSubview(stackView)
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0)
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        setupUI()
        
        getLastPayments()
        reloadContacts()
        
        
    }
    
    fileprivate func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.sectionIndexColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1)
        //        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 16)
    }
    
    fileprivate func registerContactCell() {
        
        let podBundle = Bundle(for: self.classForCoder)
        if let bundleURL = podBundle.url(forResource: EPGlobalConstants.Strings.bundleIdentifier, withExtension: "bundle") {
            
            if let bundle = Bundle(url: bundleURL) {
                
                let cellNib = UINib(nibName: EPGlobalConstants.Strings.cellNibIdentifier, bundle: bundle)
                tableView.register(cellNib, forCellReuseIdentifier: "Cell")
            }
            else {
                assertionFailure("Could not load bundle")
            }
        }
        else {
            
            let cellNib = UINib(nibName: EPGlobalConstants.Strings.cellNibIdentifier, bundle: nil)
            tableView.register(cellNib, forCellReuseIdentifier: "Cell")
        }
    }
    
    func setupUI(){
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "Выберите контакт"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        self.navigationItem.leftItemsSupplementBackButton = true
        let close = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(backButton))
        close.tintColor = .black
        //        self.navigationItem.setRightBarButton(close, animated: true)
        
        //        self.navigationItem.rightBarButtonItem?.action = #selector(backButton)
        self.navigationItem.rightBarButtonItem = close
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .highlighted)
    }
    
    @objc func backButton(){
        dismiss(animated: true, completion: nil)
    }
    
    
    func passTextFieldText(textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        if text == "" {
            resultSearchController = false
            banksActive = false
            lastPhonePayment.removeAll()
            getLastPayments()
            orderedContacts.removeAll()
            reloadContacts()
            tableView.reloadData()
        }
        reserveContacts = contacts
        if text.count != 0{
            if text.digits.count > 0 {
                searchForContactUsingPhoneNumber(phoneNumber: text)
            } else {
                searchForContactUsingName(text: text)
            }
            resultSearchController = true
            tableView.reloadData()
        }
        if text.digits.count == 10{
            selectPhoneNumber = "+7\(text)"
            getLastPhonePayments()
            banksActive = true
            orderedBanks.removeAll()
            
        }
    }
   
    func check(_ givenString: String) -> Bool {
        return givenString.range(of: "^[7-8]9.", options: .regularExpression) != nil
    }
    
    func searchForContactUsingPhoneNumber(phoneNumber: String) {
            DispatchQueue.global().async {
                let searchNumber = phoneNumber
                if searchNumber.count > 0 {
                    
                    self.resultSearchController = true
                    var contacts = [CNContact]()
                    var message: String!
                    
                    let contactsStore = CNContactStore()
                    do { try contactsStore.enumerateContacts(with: CNContactFetchRequest(keysToFetch: self.allowedContactKeys())) {
                        (contact, cursor) -> Void in
                        if (!contact.phoneNumbers.isEmpty) {
                            
                            let phoneNumberToCompareAgainst =  searchNumber.components(
                                separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
                            for phoneNumber in contact.phoneNumbers {
                                if let phoneNumberStruct = phoneNumber.value as? CNPhoneNumber {
                                    let phoneNumberString = phoneNumberStruct.stringValue
                                    var phoneNumberToCompare = phoneNumberString.components(
                                        separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
                                    if self.check(phoneNumberToCompare)  {
                                        phoneNumberToCompare = String(phoneNumberToCompare.dropFirst())
                                    }
                                    let phoneNumberFin = phoneNumberToCompare.prefix(phoneNumberToCompareAgainst.count)
                                    if phoneNumberFin == phoneNumberToCompareAgainst {
                                        contacts.append(contact)
                                    }
                                }
                            }
                        }
                    }
                    
                    if contacts.count == 0 {
                        message = "No contacts were found matching the given phone number."
                        print(message!)
                    }
                    } catch {
                        message = "Unable to fetch contacts."
                    }
                    if message != nil {
                        DispatchQueue.main.async {
                            print(message!)
                        }
                    } else {
                        // Success
                        DispatchQueue.main.async {
                            
                            self.filteredContacts = contacts
                        }
                    }
                }
            }
  }
    
    
    
    private func searchForContactUsingName(text: String) {
        
        var predicate: NSPredicate
        if text.count > 0, !text.isNumeric{
            resultSearchController = true
            predicate = CNContact.predicateForContacts(matchingName: text)
        } else {
            predicate = CNContact.predicateForContactsInContainer(withIdentifier: contactsStore!.defaultContainerIdentifier())
        }
        
        let store = CNContactStore()
        do {
            filteredContacts = try store.unifiedContacts(matching: predicate,
                                                         keysToFetch: allowedContactKeys())
            print(predicate)
            print(filteredContacts)
        }
        catch {
            print("Error!")
        }
    }
    
    fileprivate func loadContacts(filter: ContactsFilter) {
        contacts.removeAll()
        var allContacts = [PhoneContact]()
        for contact in PhoneContacts.getContacts(filter: filter) {
            allContacts.append(PhoneContact(contact: contact))
        }
        
        var filterdArray = [PhoneContact]()
        if self.filter == .mail {
            filterdArray = allContacts.filter({ $0.email.count > 0 }) // getting all email
        } else if self.filter == .message {
            filterdArray = allContacts.filter({ $0.phoneNumber.count > 0 })
        } else {
            filterdArray = allContacts.filter({$0.phoneNumber.count != 0}).sorted { lhs, rhs in
                lhs.name ?? "" < rhs.name ?? ""
            }
        }
        contacts.append(contentsOf: filterdArray)
        
    }
}

extension ContactsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case contactCollectionView:
            if banks?.count ?? 0 > 0 {
                return banks?.count ?? 0
            } else {
                return contacts.count
            }
        case lastPaymentsCollectionView:
            if lastPhonePayment.count > 1{
                return lastPhonePayment.count
            } else {
                return lastPayment.count
            }
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == contactCollectionView{
            let item = contactCollectionView.dequeueReusableCell(withReuseIdentifier: "ContactCollectionViewCell", for: indexPath) as! ContactCollectionViewCell
            DispatchQueue.main.async{ [self] in
                if ((self.banks?.isEmpty) == nil){
                    item.contact = contacts[indexPath.item]
                    
                } else {
                    
                    item.bankImage.isHidden = true
                    item.phoneLabel.isHidden = true
                    item.contactLabel.text = banks?[indexPath.item].memberNameRus
                    guard let imageBank = banks?[indexPath.item].id else {
                        return
                    }
                    item.contactImageView.image = UIImage(named: imageBank)
                }
            }
            return item
            
        } else if collectionView == lastPaymentsCollectionView{
            if lastPhonePayment.count > 1{
                let item = lastPaymentsCollectionView.dequeueReusableCell(withReuseIdentifier: "LastPaymentsCollectionViewCell", for: indexPath) as! LastPaymentsCollectionViewCell
                item.nameLabel.numberOfLines = 0
                if lastPhonePayment[indexPath.item].payment == true{
                    item.nameLabel.numberOfLines = 1
                    item.nameLabel.text = selectPerson
                    for contact in contacts {
                        if contact.phoneNumber[0] == format(phoneNumber: searchContact.numberTextField.text ?? "")! {
                            item.nameLabel.text = contact.name
                            item.nameLabel.isHidden = false
                            break
                        } else {
                            item.nameLabel.text = format(phoneNumber: searchContact.numberTextField.text ?? "")
                        }
                    }
                } else {
                    item.nameLabel.isHidden = true
                }
                for bank in banksList {
                    if bank.memberID == lastPhonePayment[indexPath.item].bankID{
                        item.contactImageView.image = bank.svgImage?.convertSVGStringToImage()
                    }
                }
                item.bankNameLabel.isHidden = false
                if lastPhonePayment[indexPath.item].bankName == "ФОРА-БАНК"{
                    item.bankNameLabel.text = "Фора-Банк"
                } else {
                    item.bankNameLabel.text = lastPhonePayment[indexPath.item].bankName
                }
                return item
            } else {
                
                let item = lastPaymentsCollectionView.dequeueReusableCell(withReuseIdentifier: "LastPaymentsCollectionViewCell", for: indexPath) as! LastPaymentsCollectionViewCell
                item.nameLabel.text = format(phoneNumber: lastPayment[indexPath.item].phoneNumber ?? "")
                if lastPayment.count >= 1{
                    item.nameLabel.isHidden = false
                    item.nameLabel.numberOfLines = 0
                    item.bankNameLabel.isHidden = true
                    item.nameLabel.text = format(phoneNumber: lastPayment[indexPath.item].phoneNumber ?? "")
                    item.contactImageView.image = UIImage(named: "phoneBackgroundImage")
                    for contact in contacts {
                        if contact.phoneNumber[0] == format(phoneNumber: lastPayment[indexPath.item].phoneNumber ?? "")! {
                            item.nameLabel.text = contact.name
                            if contact.avatarData != nil{
                                item.contactImageView.image = UIImage(data: (contact.avatarData) ?? Data())
                            }
                            break
                        } else {
                            item.nameLabel.text = format(phoneNumber: lastPayment[indexPath.item].phoneNumber ?? "")
                        }
                    }
                }
                return item
            }
        } else {
            if lastPhonePayment.count > 1{
                let item = lastPaymentsCollectionView.dequeueReusableCell(withReuseIdentifier: "LastPaymentsCollectionViewCell", for: indexPath) as! LastPaymentsCollectionViewCell
                item.nameLabel.text = lastPhonePayment[indexPath.item].bankName
                item.contactImageView.image = UIImage(named: "\(lastPhonePayment[indexPath.item].bankID!)")
                item.bankNameLabel.isHidden = false
                item.bankNameLabel.text = lastPhonePayment[indexPath.item].bankName
                return item
            } else {
                
                let item = lastPaymentsCollectionView.dequeueReusableCell(withReuseIdentifier: "LastPaymentsCollectionViewCell", for: indexPath) as! LastPaymentsCollectionViewCell
                item.nameLabel.text = format(phoneNumber: lastPayment[indexPath.item].phoneNumber ?? "")
                item.nameLabel.text = lastPayment[indexPath.item].bankName
                if lastPayment.count > 3{
                    item.contactImageView.image = UIImage(named: lastPayment[indexPath.item].bankID ?? "")
                    item.bankNameLabel.isHidden = false
                    item.bankNameLabel.text = lastPayment[indexPath.item].bankName
                    item.nameLabel.text = lastPayment[indexPath.item].amount
                    
                }
                return item
            }
        }
        
    }
    
    @objc func hideCollectionView(){
        if self.banks?.count ?? 0 > 1{
            self.banks = [FastPayment(id: "", memberID: "", memberName: "", memberNameRus: "")]
            contactCollectionView.reloadData()
        } else {
            getBankList()
            contactCollectionView.reloadData()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if collectionView == contactCollectionView{
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderBanksCollectionReusableView", for: indexPath) as! HeaderBanksCollectionReusableView
            reusableview.tag = indexPath.section
            
            if self.banks?.count ?? 0 > 1{
                reusableview.rightImage.image = UIImage(systemName: "chevron.down")
            } else {
                reusableview.rightImage.image = UIImage(systemName: "chevron.up")
            }
            
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(hideCollectionView))
            reusableview.addGestureRecognizer(tapGestureRecognizer)
            
            if banks?.count ?? 0 > 0{
                reusableview.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width - 40, height: 40)
            } else {
                reusableview.frame = CGRect(x: 0 , y: 0, width: 0, height: 40)
            }
            //do other header related calls or settups
            return reusableview
        } else {
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderBanksCollectionReusableView", for: indexPath) as! HeaderBanksCollectionReusableView
            
            reusableview.frame = CGRect(x: 0 , y: 0, width: 0, height: 0)
            //do other header related calls or settups
            
            return  reusableview
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == contactCollectionView, banks?.count ?? 0 > 0{
            return CGSize(width: collectionView.frame.width, height: 40) //add your height here
        } else {
            return CGSize(width: 0, height: 0) //add your height here
            
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case contactCollectionView:
            return CGSize(width: UIScreen.main.bounds.width, height: 60)
        default:
            return CGSize(width: 80, height: 100)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if banks?.count ?? 0 > 0, collectionView == contactCollectionView {
            let vc = PaymentByPhoneViewController()
            //            vc.confurmVCModel = self.confurmVCModel
            vc.modalPresentationStyle = .fullScreen
            let fastPaymentBank = banks?[indexPath.row]
            self.banksList.forEach { bank in
                if bank.memberID == fastPaymentBank?.memberID {
                    vc.selectedBank = bank
                    vc.bankId = bank.memberID ?? ""
                }
            }
            if banks?[indexPath.item].memberNameRus != "ФОРА-БАНК"{
                vc.sbp = true
            }
            vc.phoneField.text = selectPhoneNumber ?? ""
            vc.addCloseButton()
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
            
        } else if collectionView == lastPaymentsCollectionView {
            let vc = PaymentByPhoneViewController()
            if lastPhonePayment.count > 0 {
                let lastPaymentBank = lastPhonePayment[indexPath.row]
                self.banksList.forEach { bank in
                    if bank.memberID == lastPaymentBank.bankID {
                        vc.selectedBank = bank
                        vc.bankId = bank.memberID ?? ""
                    }
                }
                if lastPaymentBank.bankName == "ФОРА-БАНК" {
                    vc.sbp = false
                } else {
                    vc.sbp = true
                }
            } else {
                let lastPaymentBank = lastPayment[indexPath.row]
                self.banksList.forEach { bank in
                    if bank.memberID == lastPaymentBank.bankID {
                        vc.selectedBank = bank
                        vc.bankId = bank.memberID ?? ""
                    }
                }
                
                vc.selectNumber =  format(phoneNumber: lastPayment[indexPath.item].phoneNumber ?? "")
                vc.summTransctionField.text = lastPayment[indexPath.item].amount ?? ""
                
                if lastPaymentBank.bankName == "ФОРА-БАНК"{
                    vc.sbp = false
                } else {
                    vc.sbp = true
                }
            }
            vc.modalPresentationStyle = .fullScreen
            
            if lastPhonePayment.count > 0{
                vc.phoneField.text = selectPhoneNumber ?? ""
                vc.selectNumber = selectPhoneNumber ?? ""
            } else {
                let mask = StringMask(mask: "0 (000) 000-00-00")
                let maskPhone = mask.mask(string: "8\(lastPayment[indexPath.item].phoneNumber ?? "")")
                vc.selectNumber = maskPhone
            }
            vc.addCloseButton()
            
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
            
        } else {
            selectPhoneNumber = contacts[indexPath.item].phoneNumber.first
            selectPerson = contacts[indexPath.item].name
            guard let numberPhone = contacts[indexPath.item].phoneNumber.first else {
                return
            }
            searchContact.numberTextField.text = numberPhone.dropFirst(2).description
            banks = [FastPayment.init(id: "", memberID: "", memberName: "", memberNameRus: "")]
            contactCollectionView.reloadData()
            getLastPhonePayments()
            
        }
        
    }
    
    func getBankList() {
        showActivity()
        
        NetworkManager<FastPaymentBanksListDecodableModel>.addRequest(.fastPaymentBanksList, [:], [:]) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: Card list: ", model)
            if model.statusCode == 0 {
                self.dismissActivity()
                guard let data  = model.data else { return }
                //                self.selectedCardNumber = cardNumber
                DispatchQueue.main.async {
                    self.banks = data
                    //                        .sorted { lhs, rhs in
                    //                        lhs.memberNameRus ?? "" < rhs.memberNameRus ?? ""
                    //                    }
                    self.lastPaymentsCollectionView.anchor(height:100)
                    self.contactCollectionView.isHidden = false
                    self.contactCollectionView.reloadData()
                    
                }
            } else {
                self.dismissActivity()
                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        }
        
    }
    
    func getLastPayments() {
        showActivity()
        NetworkManager<GetLatestPaymentsDecodableModel>.addRequest(.getLatestPayments, [:], [:]) { model, error in
            self.dismissActivity()
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: LatestPayment: ", model)
            if model.statusCode == 0 {
                guard let data  = model.data else { return }
                DispatchQueue.main.async {
                    self.lastPayment = data
                    self.lastPaymentsCollectionView.isHidden = self.lastPayment.count == 0 ? true : false
                    self.lastPaymentsCollectionView.reloadData()
                }
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        }
    }
    
    func getLastPhonePayments() {
        showActivity()
        var newPhone = String()
        if selectPhoneNumber?.prefix(1) == "7" || selectPhoneNumber?.prefix(1) == "8"{
            newPhone = selectPhoneNumber?.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "+", with: "").replacingOccurrences(of: "-", with: "").dropFirst().description ?? ""
        } else {
            newPhone = selectPhoneNumber?.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "+", with: "").replacingOccurrences(of: "-", with: "") ?? ""
        }
        let body = [
            "phoneNumber": "\(newPhone)"
        ] as [String: AnyObject]
        
        NetworkManager<GetLatestPhonePaymentsDecodableModel>.addRequest(.getLatestPhonePayments, [:], body) { model, error in
            self.dismissActivity()
            guard let model = model else { return }
            print("DEBUG: Card list: ", model)
            if model.statusCode == 0 {
                self.dismissActivity()
                guard let data  = model.data else { return }
                //                self.selectedCardNumber = cardNumber
                DispatchQueue.main.async {
                    self.lastPhonePayment = data
                    if self.lastPhonePayment.count != 0{
                        
                        
                        self.lastPaymentsCollectionView.isHidden = false
                        self.lastPaymentsCollectionView.reloadData()
                    } else {
                        self.lastPaymentsCollectionView.isHidden = true
                    }
                    
                    
                }
            } else {
                self.dismissActivity()
                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        }
        
    }
    
    func format(phoneNumber sourcePhoneNumber: String) -> String? {
        // Remove any character that is not a number
        
        var numbersOnly = sourcePhoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if numbersOnly.prefix(1) == "7" || numbersOnly.prefix(1) == "8" {
            numbersOnly = String(numbersOnly.dropFirst())
        }
        let length = numbersOnly.count
        let hasLeadingOne = numbersOnly.hasPrefix("1")
        
        // Check for supported phone number length
        guard length == 7 || length == 10 || (length == 11) else {
            return nil
        }
        
        let hasAreaCode = (length >= 10)
        var sourceIndex = 0
        
        // Leading 1
        var leadingOne = ""
        if hasLeadingOne {
            leadingOne = "1 "
            sourceIndex += 1
        }
        
        // Area code
        var areaCode = ""
        if hasAreaCode {
            let areaCodeLength = 3
            guard let areaCodeSubstring = numbersOnly.substring(start: sourceIndex, offsetBy: areaCodeLength) else {
                return nil
            }
            areaCode = String(format: "(%@) ", areaCodeSubstring)
            sourceIndex += areaCodeLength
        }
        
        // Prefix, 3 characters
        let prefixLength = 3
        guard let prefix = numbersOnly.substring(start: sourceIndex, offsetBy: prefixLength) else {
            return nil
        }
        sourceIndex += prefixLength
        
        // Suffix, 4 characters
        let suffixLength = 4
        guard let suffix = numbersOnly.substring(start: sourceIndex, offsetBy: suffixLength) else {
            return nil
        }
        
        return "+7 \(leadingOne + areaCode + prefix + "-" + suffix)"
    }
}


extension ContactsViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    convenience public init(delegate: EPPickerDelegate?) {
        self.init(delegate: delegate, multiSelection: false)
    }
    
    convenience public init(delegate: EPPickerDelegate?, multiSelection : Bool) {
        self.init()
        self.multiSelectEnabled = multiSelection
        contactDelegate = delegate
    }
    
    convenience public init(delegate: EPPickerDelegate?, multiSelection : Bool, subtitleCellType: SubtitleCellValue) {
        self.init()
        self.multiSelectEnabled = multiSelection
        contactDelegate = delegate
        subtitleCellValue = subtitleCellType
    }
    
    open func reloadContacts() {
        getContacts( {(contacts, error) in
            if (error == nil) {
                DispatchQueue.main.async(execute: {
                    for contact in contacts {
                        for number in contact.phoneNumbers {
                            let phone: PhoneContact = .init(contact: contact)
                            phone.phoneNumber = phone.phoneNumber.filter({$0 == number.value.stringValue})
                            print(number.value.stringValue)
                            self.reserveContacts.append(phone)
                        }
                    }
                    self.tableView.reloadData()
                })
            }
        })
    }
    
    func getContacts(_ completion:  @escaping ContactsHandler) {
        if contactsStore == nil {
            //ContactStore is control for accessing the Contacts
            contactsStore = CNContactStore()
        }
        let error = NSError(domain: "EPContactPickerErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "No Contacts Access"])
        
        switch CNContactStore.authorizationStatus(for: CNEntityType.contacts) {
        case CNAuthorizationStatus.denied, CNAuthorizationStatus.restricted:
            //User has denied the current app to access the contacts.
            
            let productName = Bundle.main.infoDictionary!["CFBundleName"]!
            
            let alert = UIAlertController(title: "Unable to access contacts", message: "\(productName) does not have access to contacts. Kindly enable it in privacy settings ", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: {  action in
                completion([], error)
                //                      self.dismiss(animated: true, completion: {
                //                          self.contactDelegate?.epContactPicker(self, didContactFetchFailed: error)
                //                      })
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            
        case CNAuthorizationStatus.notDetermined:
            //This case means the user is prompted for the first time for allowing contacts
            contactsStore?.requestAccess(for: .contacts, completionHandler: { (granted, error) -> Void in
                //At this point an alert is provided to the user to provide access to contacts. This will get invoked if a user responds to the alert
                if  (!granted ){
                    DispatchQueue.main.async(execute: { () -> Void in
                        completion([], error! as NSError?)
                    })
                }
                else{
                    self.getContacts(completion)
                }
            })
            
        case  CNAuthorizationStatus.authorized:
            //Authorization granted by user for this app.
            var contactsArray = [CNContact]()
            
            let contactFetchRequest = CNContactFetchRequest(keysToFetch: allowedContactKeys())
            
            do {
                try contactsStore?.enumerateContacts(with: contactFetchRequest, usingBlock: { (contact, stop) -> Void in
                    //Ordering contacts based on alphabets in firstname
                    contactsArray.append(contact)
                
                    var key: String = "#"
                    //If ordering has to be happening via family name change it here.
                    if let firstLetter = contact.givenName[0..<1] , firstLetter.containsAlphabets() {
                        key = firstLetter.uppercased()
                    }
                    var contacts = [CNContact]()
                    
                    if let segregatedContact = self.orderedContacts[key] {
                        contacts = segregatedContact
                    }
                    
                    contacts.append(contact)
                    self.orderedContacts[key] = contacts
                    
                })
                self.sortedContactKeys = Array(self.orderedContacts.keys).sorted(by: <)
                if self.sortedContactKeys.first == "#" {
                    self.sortedContactKeys.removeFirst()
                    self.sortedContactKeys.append("#")
                }
                completion(contactsArray, nil)
            }
            //Catching exception as enumerateContactsWithFetchRequest can throw errors
            catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
    }
    
    func allowedContactKeys() -> [CNKeyDescriptor]{
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
    
    func alphabetScroll(){
        orderedBanks.removeAll()
        var contactsArray = [BanksList]()
        for bank in banksList {
            contactsArray.append(bank)
            var key: String = "#"
            //If ordering has to be happening via family name change it here.
            if let firstLetter = bank.memberNameRus?[0..<1] , firstLetter.containsAlphabets() {
                key = firstLetter.uppercased()
            }
            var banks = [BanksList]()
            
            if let segregatedContact = self.orderedBanks[key] {
                banks = segregatedContact
            }
            banks.append(bank)
            self.orderedBanks[key] = banks
            
            
            self.sortedContactKeys = Array(self.orderedBanks.keys).sorted(by: <)
            if self.sortedContactKeys.first == "#" {
                self.sortedContactKeys.removeFirst()
                self.sortedContactKeys.append("#")
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - Table View DataSource
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        if banksActive{
            return sortedContactKeys.count
        } else {
            if resultSearchController == true { return 1 }
            return sortedContactKeys.count
        }
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if banksActive{
            let contactsForSection = orderedBanks[sortedContactKeys[section]]
            return contactsForSection?.count ?? 0
        } else {
            if resultSearchController == true { return filteredContacts.count }
            if let contactsForSection = orderedContacts[sortedContactKeys[section]] {
                return contactsForSection.count
            }
            return 0
        }
    }
    
    // MARK: - Table View Delegates
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EPContactCell
        cell.accessoryType = .none
        //Convert CNContact to EPContact
        cell.contactDetailTextLabel.isHidden = false
        cell.contactInitialLabel.isHidden  = false
        
        if banksActive{
            
            let banks = orderedBanks[sortedContactKeys[indexPath.section]]
            
            cell.contactImageView.image = UIImage(imageLiteralResourceName: "bankDefault")
            cell.banks = banks?[indexPath.item]
            cell.updateBankCell()
            cell.contactTextLabel.text = banks?[indexPath.row].memberNameRus
            cell.contactDetailTextLabel.isHidden = true
            cell.contactInitialLabel.isHidden = true
            cell.ownerImageView.isHidden = true
            cell.needChek = false
            
        } else if banksActive == false{
            let contact: EPContact
            if resultSearchController == true {
                contact = EPContact(contact: filteredContacts[(indexPath as NSIndexPath).row])
            } else {
                guard let contactsForSection = orderedContacts[sortedContactKeys[(indexPath as NSIndexPath).section]] else {
                    assertionFailure()
                    return UITableViewCell()
                }
                contact = EPContact(contact: contactsForSection[(indexPath as NSIndexPath).row])
                cell.needChek = true
            }
            
            if multiSelectEnabled  && selectedContacts.contains(where: { $0.contactId == contact.contactId }) {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            }
            cell.updateContactsinUI(contact, indexPath: indexPath, subtitleType: subtitleCellValue)
            
        }
        return cell
    }
    
    
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! EPContactCell
        resultSearchController = false
        if banksActive{
            let banks = orderedBanks[sortedContactKeys[indexPath.section]]
            let vc = PaymentByPhoneViewController()
            vc.selectNumber = selectPhoneNumber
            vc.selectedBank = banks?[indexPath.row]
            vc.bankId = banks?[indexPath.row].memberID ?? ""
            
            if banksList[indexPath.row].memberNameRus == "ФОРА-БАНК"{
                vc.sbp = false
            } else {
                vc.sbp = true
            }
            
            vc.modalPresentationStyle = .fullScreen
            
            vc.phoneField.text = selectPhoneNumber ?? ""
            vc.addCloseButton()
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        } else {
            let selectedContact =  cell.contact!
            selectPerson = selectedContact.displayName()
            selectPhoneNumber = selectedContact.phoneNumbers.first?.phoneNumber
            guard let clearNumber = format(phoneNumber: selectPhoneNumber ?? "") else {
                return
            }
            if selectedContact.phoneNumbers.count > 1{
                counterNumbers = 0
                let controller = ChoosePhoneNumberController()
                var numbers = [String]()
                for i in selectedContact.phoneNumbers{
                    numbers.append(i.phoneNumber)
                }
                controller.elements = numbers
                self.counterNumbers = numbers.count
                controller.itemIsSelect = { currency in
                    self.selectPhoneNumber = currency
                    let newNumber = currency.dropFirst(2)
                    self.searchContact.numberTextField.text  = newNumber.description
                    self.banksActive = true
                    self.orderedBanks.removeAll()
                    self.getLastPhonePayments()
                    tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top , animated: false)
                    tableView.reloadData()
                    
                }
                let navController = UINavigationController(rootViewController: controller)
                navController.modalPresentationStyle = .custom
                navController.transitioningDelegate = self
                self.present(navController, animated: true)
            } else{
                let newNumber = clearNumber.dropFirst(2)
                searchContact.numberTextField.text  = newNumber.description
                banksActive = true
                orderedBanks.removeAll()
                getLastPhonePayments()
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top , animated: false)
                tableView.reloadData()
            }
        }
        
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    open  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && banksActive == true{
            return 40
        } else {
            return 0
        }
    }
    
    open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if resultSearchController == true { return 0 }
        
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: UITableView.ScrollPosition.top , animated: false)
        for item in orderedBanks {
            print(item)
        }
        if firstTap{
            orderedBanks.removeAll()
        }
        switch banksActive {
        case true:
            if firstTap{
                return 1
                
            } else {
                return sortedContactKeys.firstIndex(of: title)!
            }
        default:
            return sortedContactKeys.firstIndex(of: title)!
        }
    }
    
    open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if banksActive == true {
            if orderedBanks.isEmpty{
                sortedContactKeys = []
            }
            if resultSearchController == true { return nil }
            return sortedContactKeys
        } else {
            if resultSearchController == true { return nil }
            return sortedContactKeys
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 && banksActive == true{
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))
            
            let label = UILabel()
            
            label.text = "В другой банк"
            label.font = .systemFont(ofSize: 16)
            label.textColor = .black
            headerView.backgroundColor = .white
            let image = UIImageView()
            let button = UIButton()
            headerView.addSubview(button)
            headerView.addSubview(image)
            headerView.addSubview(label)
            button.setImage(UIImage(systemName: "chevron.up"), for: .normal)
            image.image = UIImage(imageLiteralResourceName: "sbp-logo")
            button.tintColor = .gray
            image.anchor(left: headerView.leftAnchor, paddingLeft: 5,paddingRight: 5, width: 24, height: 24)
            label.anchor(left: image.rightAnchor ,right: button.rightAnchor, paddingLeft: 10,paddingRight: 10, height: 40)
            label.centerY(inView: image)
            button.anchor(right: headerView.rightAnchor ,paddingRight: 5, width: 32, height: 40)
            button.contentVerticalAlignment = .center
            button.addTarget(self, action: #selector(selectedSectionStoredButtonClicked), for: .touchUpInside)
            button.centerY(inView: label)
            
            if self.orderedBanks.count > 1{
                button.setImage(UIImage(systemName: "chevron.up"), for: .normal)
            } else  {
                button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            }
            
            return headerView
        } else {
            return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        }
    }
    
    @objc func selectedSectionStoredButtonClicked(){
        if orderedBanks.isEmpty{
            firstTap = false
            alphabetScroll()
            banksList = banksList.sorted { (first, second) -> Bool in
                if let one = first.memberNameRus, let two = second.memberNameRus {
                    return one < two
                }
                return true
            }
            tableView.reloadData()
        } else {
            firstTap = true
            orderedBanks.removeAll()
            tableView.reloadData()
        }
    }
    
}



extension String {
    /// This method makes it easier extract a substring by character index where a character is viewed as a human-readable character (grapheme cluster).
    internal func substring(start: Int, offsetBy: Int) -> String? {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return nil
        }
        
        guard let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) else {
            return nil
        }
        
        return String(self[substringStartIndex ..< substringEndIndex])
    }
}

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

extension ContactsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        presenter.height = (counterNumbers * 40) + 160
        return presenter
    }
}
