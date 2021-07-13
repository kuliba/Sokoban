//
//  ContactsViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 23.06.2021.
//

import UIKit
import ContactsUI


class ContactsViewController: UIViewController,SelectImageDelegate{
    func didSelectImage(image: String) {
        if !reserveContacts.isEmpty{
            loadContacts(filter: .none)
        }
        let filteredContacts = contacts.filter({$0.name?.lowercased().prefix(image.count) ?? "" == image.lowercased()})
        reserveContacts = contacts
        if image.count != 0{
            contactCollectionView.reloadData()
            contacts = filteredContacts
        }
        if image.count == 10, (image.firstIndex(of: "9") != nil){
            selectPhoneNumber = image
            getBankList()
            getLastPhonePayments()
        }
    }
    
    
    var reserveContacts = [PhoneContact]()
    var numberPhone: String?
    


    var banks: [FastPayment]?

    var selectPhoneNumber: String?

    let searchContact: SearchContact = UIView.fromNib()
    
    var checkOwnerFetch: Bool?
    

    var lastPayment = [GetLatestPaymentsDatum]()
    
    var lastPhonePayment = [GetLatestPhone](){
        didSet{
            lastPaymentsCollectionView.reloadData()
        }
    }
    
    var contacts = [PhoneContact]() {
        didSet{
            contactCollectionView.reloadData()
    //            setupCollectionView()
        }
        willSet{
            contactCollectionView.reloadData()
        }
    }// array of PhoneContact(It is model find it below)
    var filter: ContactsFilter = .none
   

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

//    let lastPaymentsCollectionView: UICollectionView!

//    var collectionView: UICollectionView!
    var lastPaymentsCollectionView: UICollectionView!
    var contactCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        searchContact.delegate = self
        
        let layout = UICollectionViewFlowLayout()

            layout.itemSize = CGSize(width: 80, height: 120)
            layout.scrollDirection = .horizontal
        lastPaymentsCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
         let xib = UINib.init(nibName: "LastPaymentsCollectionViewCell", bundle: nil)
        lastPaymentsCollectionView.register(xib, forCellWithReuseIdentifier: "LastPaymentsCollectionViewCell")

      
        
            let viewLastPayments = UIView()
            viewLastPayments.addSubview(lastPaymentsCollectionView)
        
            let flowLayout = UICollectionViewFlowLayout()
            
        lastPaymentsCollectionView.isScrollEnabled = true
        
        contactCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)

          
         
            viewLastPayments.heightAnchor.constraint(equalToConstant: 120).isActive = true
            viewLastPayments.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: 120)

            let contactView = UIView()
            
            contactView.addSubview(contactCollectionView)
            
            lastPaymentsCollectionView.backgroundColor = .white
            contactCollectionView.delegate = self
            contactCollectionView.dataSource = self
            lastPaymentsCollectionView?.dataSource = self
            lastPaymentsCollectionView?.delegate = self
            contactCollectionView.backgroundColor = .white
      
        
            contactCollectionView.register(UINib(nibName: "HeaderBanksCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderBanksCollectionReusableView")

            contactCollectionView.register(UINib(nibName: "ContactCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ContactCollectionViewCell")
            lastPaymentsCollectionView.register(UINib(nibName: "LastPaymentsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LastPaymentsCollectionViewCell")
       
        lastPaymentsCollectionView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
            let stackView = UIStackView(arrangedSubviews: [searchContact,lastPaymentsCollectionView, contactView])

            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.distribution = .fill
            stackView.spacing = 10
            stackView.backgroundColor = .white
//            view.addSubview(lastPaymentsCollectionView)
//            view.addSubview(contactView)
        
            view.addSubview(stackView)
        

            stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0)

            
        
        
        
        setupUI()
//        fetchContacts()
        phoneNumberWithContryCode()
        self.loadContacts(filter: filter) // Calling loadContacts methods

        getLastPayments()

        
        
    }
    
    
    
    func setupUI(){
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "Выберите контакт"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        self.navigationItem.leftItemsSupplementBackButton = true
        let close = UILabel(text: "Закрыть", font: .none, color: .black)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: close)
    }
    
    func phoneNumberWithContryCode() -> [String] {

        let contacts = PhoneContacts.getContacts() // here calling the getContacts methods
        var arrPhoneNumbers = [String]()
        for contact in contacts {
            for ContctNumVar: CNLabeledValue in contact.phoneNumbers {
                if let fulMobNumVar  = ContctNumVar.value as? CNPhoneNumber {
                    //let countryCode = fulMobNumVar.value(forKey: "countryCode") get country code
                       if let MccNamVar = fulMobNumVar.value(forKey: "digits") as? String {
                            arrPhoneNumbers.append(MccNamVar)
                    }
                }
            }
        }
        return arrPhoneNumbers // here array has all contact numbers.
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
                item.contactLabel.text = contacts[indexPath.item].name
                item.phoneLabel.text = contacts[indexPath.item].phoneNumber.first
               
                    if self.contacts[indexPath.item].avatarData?.isEmpty != nil{
                        DispatchQueue.main.async {
                        item.contactImageView.image =  UIImage(data: (self.contacts[indexPath.item].avatarData)!)
                    }
                }
                if checkOwnerFetch == nil {
                    DispatchQueue.main.async{ [self] in
                        if checkOwner(number: "7\(self.contacts[indexPath.item].phoneNumber.first?.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").dropFirst() ?? "")", index: indexPath.item) ?? false {
                            item.bankImage.isHidden = false
                            
                        }
                    }
                }
                if contacts[indexPath.item].bankImage == true{
                    item.bankImage.isHidden = false
                }
            
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
                item.nameLabel.text = lastPhonePayment[indexPath.item].bankName
                item.contactImageView.image = UIImage(named: "\(lastPhonePayment[indexPath.item].bankID!)")
                item.bankNameLabel.isHidden = false
                item.bankNameLabel.text = lastPhonePayment[indexPath.item].bankName
                return item
            } else {
                
                let item = lastPaymentsCollectionView.dequeueReusableCell(withReuseIdentifier: "LastPaymentsCollectionViewCell", for: indexPath) as! LastPaymentsCollectionViewCell
                item.nameLabel.text = lastPayment[indexPath.item].phoneNumber
//                for cell in contacts {
//                    cell.phoneNumber[0] = lastPayment[indexPath.item].phoneNumber ?? ""
//                    item.nameLabel.text = cell.name
//                }
                if lastPayment.count > 3{
                    item.contactImageView.image = UIImage(named: lastPayment[indexPath.item].bankID ?? "")
                    item.bankNameLabel.isHidden = true
                    item.bankNameLabel.text = lastPayment[indexPath.item].bankName
                    item.nameLabel.text = lastPayment[indexPath.item].amount
                    
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
                item.nameLabel.text = lastPayment[indexPath.item].phoneNumber
                if lastPayment.count > 3{
                    item.contactImageView.image = UIImage(named: lastPayment[indexPath.item].bankID ?? "")
                    item.bankNameLabel.isHidden = true
                    item.bankNameLabel.text = lastPayment[indexPath.item].bankName
                    item.nameLabel.text = lastPayment[indexPath.item].amount
                    
                }
                return item
            }
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
      
        if collectionView == contactCollectionView{
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderBanksCollectionReusableView", for: indexPath) as! HeaderBanksCollectionReusableView
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
            return CGSize(width: 80, height: 120)

        }
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if banks?.count ?? 0 > 0, collectionView == contactCollectionView {
            let vc = PaymentByPhoneViewController()
//            vc.confurmVCModel = self.confurmVCModel
            vc.modalPresentationStyle = .fullScreen
            
            vc.selectBank = banks?[indexPath.row].memberNameRus
            vc.bankImage = UIImage(named: "\(banks?[indexPath.row].id ?? "")")
            if banks?[indexPath.item].memberNameRus != "ФОРА-БАНК"{
                vc.sbp = true
            }
            vc.phoneField.text = selectPhoneNumber ?? ""
            vc.addCloseButton()
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
            } else if collectionView == lastPaymentsCollectionView{
                let vc = PaymentByPhoneViewController()
                if lastPhonePayment.count > 0{
                    vc.selectBank = lastPhonePayment[indexPath.row].bankName
                    vc.bankImage = UIImage(named: "\(lastPhonePayment[indexPath.row].bankID ?? "")")
                    if lastPhonePayment[indexPath.row].bankName == "ФОРА-БАНК"{
                        vc.sbp = false
                    } else {
                        vc.sbp = true
                    }
                } else {
                    vc.selectNumber = lastPayment[indexPath.item].phoneNumber ?? ""
                    vc.summTransctionField.textField.text = lastPayment[indexPath.item].amount
                    vc.selectBank = lastPayment[indexPath.row].bankName
                    vc.bankImage = UIImage(named: "\(lastPayment[indexPath.row].bankID ?? "")")
                    if lastPayment[indexPath.row].bankName == "ФОРА-БАНК"{
                        vc.sbp = false
                    } else {
                        vc.sbp = true
                    }
                }
    //            vc.confurmVCModel = self.confurmVCModel
                vc.modalPresentationStyle = .fullScreen
                
                vc.phoneField.text = selectPhoneNumber ?? ""
                vc.addCloseButton()

                let navController = UINavigationController(rootViewController: vc)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
                
            } else {
                selectPhoneNumber = contacts[indexPath.item].phoneNumber.first
                guard let numberPhone = contacts[indexPath.item].phoneNumber.first else {
                    return
                }
//                searchContact.numberTextField[0].text = numberPhone.dropFirst().description
                getBankList()
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
            if error != nil {
                self.dismissActivity()
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: Card list: ", model)
            if model.statusCode == 0 {
                self.dismissActivity()
                guard let data  = model.data else { return }
//                self.selectedCardNumber = cardNumber
                DispatchQueue.main.async {
                    self.lastPayment = data
                    self.lastPaymentsCollectionView.reloadData()
                }
            } else {
                self.dismissActivity()
                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        }
        
    }
    
    func getLastPhonePayments() {
        showActivity()
        
        let body = [
            "phoneNumber": selectPhoneNumber
        ] as [String: AnyObject]
        
        NetworkManager<GetLatestPhonePaymentsDecodableModel>.addRequest(.getLatestPhonePayments, [:], body) { model, error in
//            if error != nil {
//                self.dismissActivity()
//                print("DEBUG: Error: ", error ?? "")
//            }
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
    
    func checkOwner(number: String?, index: Int) -> Bool?{
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
                    self.checkOwnerFetch = true
                    self.contacts[index].bankImage = true
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

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

