//
//  ContactsViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 23.06.2021.
//

import UIKit
import ContactsUI
protocol DisplayViewControllerDelegate : NSObjectProtocol{
    func doSomethingWith(data: String)
}
protocol PassSectionDelegate: AnyObject {
  func passDataFromSectionUp(sectionController: String)
}

protocol UpdateDataDelegate: AnyObject {
  func passUpdateData(data: String);
}

class ContactsViewController: UIViewController, MyPickerDelegate{
    
    
    var numberPhone: String?
    func didSelectSomething(some: String) {
        numberPhone = some
    }
    weak var delegate: UpdateDataDelegate? = nil
    

    weak var delegate1 : DisplayViewControllerDelegate?

    var banks: [FastPayment]?

    var selectPhoneNumber: String?

    let searchContact: SearchContact = UIView.fromNib()
    
    

    var lastPayment = [GetLatestPaymentsDatum(bankName: "Фора - Банк", bankID: "000121221", phoneNumber: "000517217", amount: "10")]{
        didSet{
            lastPaymentsCollectionView.reloadData()
        }
    }
    var lastPhonePayment = [GetLatestPhone(bankName: "ФОРА-БАНК123", bankID: "100000000217")]{
        didSet{
            lastPaymentsCollectionView.reloadData()
        }
    }
    var contacts = [PhoneContact]() {
        didSet{
    //            setupCollectionView()
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
                filterdArray = allContacts
            }
        contacts.append(contentsOf: filterdArray)
    }
    
//    let lastPaymentsCollectionView: UICollectionView!

//    var collectionView: UICollectionView!
    var lastPaymentsCollectionView: UICollectionView!
    var contactCollectionView: UICollectionView!

    var myDelegate: MyPickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        delegate?.passUpdateData(data: "test")
        
            let layout = UICollectionViewFlowLayout()

                layout.itemSize = CGSize(width: 80, height: 120)
                layout.scrollDirection = .horizontal
      
            let flowLayout = UICollectionViewFlowLayout()
            
            lastPaymentsCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
            contactCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)

          
        
            let viewLastPayments = UIView()
            viewLastPayments.backgroundColor = .clear
            lastPaymentsCollectionView.backgroundColor = .clear
            viewLastPayments.addSubview(lastPaymentsCollectionView)
            let contactView = UIView()
            viewLastPayments.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 120)
            contactView.addSubview(contactCollectionView)
            
            
      
        
            contactCollectionView.register(UINib(nibName: "HeaderBanksCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderBanksCollectionReusableView")
        
//            lastPaymentsCollectionView.register(UINib(nibName: "HeaderBanksCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderBanksCollectionReusableView")
            
            lastPaymentsCollectionView.backgroundColor = UIColor.white
            lastPaymentsCollectionView.backgroundColor = .white
            
            contactCollectionView.register(UINib(nibName: "ContactCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ContactCollectionViewCell")
            
            
            let stackView = UIStackView(arrangedSubviews: [searchContact, contactCollectionView])

            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.distribution = .fill
            stackView.spacing = 10
            stackView.backgroundColor = .white
            
           
            view.addSubview(contactView)
            view.addSubview(stackView)
            

            stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0)

            
        
        
        
        setupUI()
//        fetchContacts()
        phoneNumberWithContryCode()
        self.loadContacts(filter: filter) // Calling loadContacts methods

        getLastPayments()
//        setupCollectionView()
  
        
        
        contactCollectionView.delegate = self
        contactCollectionView.dataSource = self
        lastPaymentsCollectionView?.dataSource = self
        lastPaymentsCollectionView?.delegate = self
        contactCollectionView.backgroundColor = .clear
        lastPaymentsCollectionView.register(UINib(nibName: "LastPaymentsCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: "LastPaymentsCollectionViewCell")
        lastPaymentsCollectionView.register(LastPaymentsCollectionViewCell.self, forCellWithReuseIdentifier: "LastPaymentsCollectionViewCell")
        setupSearchBar()
        
        
    }
    

    func setupUI(){
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "Выберите контакт"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        self.navigationItem.leftItemsSupplementBackButton = true
        let close = UILabel(text: "Закрыть", font: .none, color: .black)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: close)
        
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
    
    
    private func setupSearchBar() {


        
    }
    
//    private func setupCollectionView() {
//
//
//
//
//        let layout = UICollectionViewFlowLayout()
//
//            layout.itemSize = CGSize(width: 80, height: 120)
//            layout.scrollDirection = .horizontal
//
//        let flowLayout = UICollectionViewFlowLayout()
//
//        lastPaymentsCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
//        contactCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
//
//
//        let viewLastPayments = UIView()
//        viewLastPayments.backgroundColor = .clear
//        lastPaymentsCollectionView.backgroundColor = .clear
//        viewLastPayments.addSubview(lastPaymentsCollectionView)
//        let contactView = UIView()
//        viewLastPayments.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 120)
//        contactView.addSubview(contactCollectionView)
//
//
//        lastPaymentsCollectionView.register(LastPaymentsCollectionViewCell.self, forCellWithReuseIdentifier: "LastPaymentsCollectionViewCell")
//        let nib = UINib(nibName: "LastPaymentsCollectionViewCell", bundle:nil)
//        self.lastPaymentsCollectionView.register(nib, forCellWithReuseIdentifier: "LastPaymentsCollectionViewCell")
//        contactCollectionView.register(UINib(nibName: "HeaderBanksCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderBanksCollectionReusableView")
//
//        lastPaymentsCollectionView.register(UINib(nibName: "HeaderBanksCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderBanksCollectionReusableView")
//
//        lastPaymentsCollectionView.backgroundColor = UIColor.white
//        lastPaymentsCollectionView.backgroundColor = .white
//
//        contactCollectionView.register(UINib(nibName: "ContactCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ContactCollectionViewCell")
//
//        let stackView = UIStackView(arrangedSubviews: [searchContact, viewLastPayments, contactCollectionView])
//
//        stackView.axis = .vertical
//        stackView.alignment = .fill
//        stackView.distribution = .fill
//        stackView.spacing = 10
//        stackView.backgroundColor = .white
//
//
//        view.addSubview(contactView)
//        view.addSubview(stackView)
//
//
//        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0)
//
//
//    }
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
//        lastPaymentsCollectionView.register(UINib(nibName: "LastPaymentsCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: "LastPaymentsCollectionViewCell")
//        lastPaymentsCollectionView.register(LastPaymentsCollectionViewCell.self, forCellWithReuseIdentifier: "LastPaymentsCollectionViewCell")
  
        if collectionView == contactCollectionView{
            let item = contactCollectionView.dequeueReusableCell(withReuseIdentifier: "ContactCollectionViewCell", for: indexPath) as! ContactCollectionViewCell
            
            if ((banks?.isEmpty) == nil){
                item.contactLabel.text = contacts[indexPath.item].name
                item.phoneLabel.text = contacts[indexPath.item].phoneNumber.first
                if contacts[indexPath.item].avatarData?.isEmpty != nil{
                item.contactImageView.image =  UIImage(data: (contacts[indexPath.item].avatarData)!)
                }
                DispatchQueue.main.async{
//                    if self.checkOwner(number: self.contacts[indexPath.item].phoneNumber.first) ?? false {
//                        item.contactImageView.isHidden = false
//                    }
                }
            } else {
                
                
                item.phoneLabel.isHidden = true
                item.contactLabel.text = banks?[indexPath.item].memberNameRus
                guard let imageBank = banks?[indexPath.item].id else {
                    return item
                }
                item.contactImageView.image = UIImage(named: imageBank)
            }
            return item
        } else if collectionView == lastPaymentsCollectionView{
            if lastPhonePayment.count > 1{
                let item = contactCollectionView.dequeueReusableCell(withReuseIdentifier: "LastPaymentsCollectionViewCell", for: indexPath) as! LastPaymentsCollectionViewCell
                item.nameLabel.text = lastPhonePayment[indexPath.item].bankName
                item.contactImageView.image = UIImage(named: "\(lastPhonePayment[indexPath.item].bankID!)")
                item.bankNameLabel.isHidden = false
                item.bankNameLabel.text = lastPhonePayment[indexPath.item].bankName
                return item
            } else {
                
                let item = contactCollectionView.dequeueReusableCell(withReuseIdentifier: "LastPaymentsCollectionViewCell", for: indexPath) as! LastPaymentsCollectionViewCell
                item.nameLabel.text = lastPayment[indexPath.item].phoneNumber
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
                let item = contactCollectionView.dequeueReusableCell(withReuseIdentifier: "LastPaymentsCollectionViewCell", for: indexPath) as! LastPaymentsCollectionViewCell
                item.nameLabel.text = lastPhonePayment[indexPath.item].bankName
                item.contactImageView.image = UIImage(named: "\(lastPhonePayment[indexPath.item].bankID!)")
                item.bankNameLabel.isHidden = false
                item.bankNameLabel.text = lastPhonePayment[indexPath.item].bankName
                return item
            } else {
                
                let item = contactCollectionView.dequeueReusableCell(withReuseIdentifier: "LastPaymentsCollectionViewCell", for: indexPath) as! LastPaymentsCollectionViewCell
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
        
//        switch collectionView {
//        case contactCollectionView:
//            let item = contactCollectionView.dequeueReusableCell(withReuseIdentifier: "ContactCollectionViewCell", for: indexPath) as! ContactCollectionViewCell
//
//            if ((banks?.isEmpty) == nil){
//                item.contactLabel.text = contacts[indexPath.item].name
//                item.phoneLabel.text = contacts[indexPath.item].phoneNumber.first
//                if contacts[indexPath.item].avatarData?.isEmpty != nil{
//                item.contactImageView.image =  UIImage(data: (contacts[indexPath.item].avatarData)!)
//                }
//                DispatchQueue.main.async{
////                    if self.checkOwner(number: self.contacts[indexPath.item].phoneNumber.first) ?? false {
////                        item.contactImageView.isHidden = false
////                    }
//                }
//            } else {
//
//
//                item.phoneLabel.isHidden = true
//                item.contactLabel.text = banks?[indexPath.item].memberNameRus
//                guard let imageBank = banks?[indexPath.item].id else {
//                    return item
//                }
//                item.contactImageView.image = UIImage(named: imageBank)
//            }
//            return item
//        case lastPaymentsCollectionView:
//            if lastPhonePayment.count > 1{
//                let item = contactCollectionView.dequeueReusableCell(withReuseIdentifier: "LastPaymentsCollectionViewCell", for: indexPath) as! LastPaymentsCollectionViewCell
//                item.nameLabel.text = lastPhonePayment[indexPath.item].bankName
//                item.contactImageView.image = UIImage(named: "\( lastPhonePayment[indexPath.item].bankID!)")
//                item.bankNameLabel.isHidden = false
//                item.bankNameLabel.text = lastPhonePayment[indexPath.item].bankName
//                return item
//            } else {
//                let item = lastPaymentsCollectionView.dequeueReusableCell(withReuseIdentifier: "LastPaymentsCollectionViewCell", for: indexPath) as! LastPaymentsCollectionViewCell
//                item.nameLabel.text = lastPayment[indexPath.item].phoneNumber
//                if lastPayment.count > 3{
//                    item.contactImageView.image = UIImage(named: lastPayment[indexPath.item].bankID ?? "")
//                    item.bankNameLabel.isHidden = true
//                    item.bankNameLabel.text = lastPayment[indexPath.item].bankName
//                    item.nameLabel.text = lastPayment[indexPath.item].amount
//
//                }
//
//                return item
//            }
//
//        default:
//            var item  = UICollectionViewCell()
//            if collectionView == contactCollectionView{
//                 item = contactCollectionView.dequeueReusableCell(withReuseIdentifier: "ContactCollectionViewCell", for: indexPath) as! ContactCollectionViewCell
//            } else {
//                 item = lastPaymentsCollectionView.dequeueReusableCell(withReuseIdentifier: "LastPaymentsCollectionViewCell", for: indexPath) as! LastPaymentsCollectionViewCell
//            }
//            return item
//        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
      
        if collectionView == contactCollectionView{
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderBanksCollectionReusableView", for: indexPath) as! HeaderBanksCollectionReusableView
            if banks?.count ?? 0 > 0{
                reusableview.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: 40)
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
        
//        switch collectionView {
//        case contactCollectionView:
//            lastPaymentsCollectionView.register(UINib(nibName: "HeaderBanksCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderBanksCollectionReusableView")
//            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderBanksCollectionReusableView", for: indexPath) as! HeaderBanksCollectionReusableView
//            if banks?.count ?? 0 > 0{
//                reusableview.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: 40)
//            } else {
//                reusableview.frame = CGRect(x: 0 , y: 0, width: 0, height: 40)
//
//            }
//             //do other header related calls or settups
//                return reusableview
//
//        case lastPaymentsCollectionView:
//
//            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderBanksCollectionReusableView", for: indexPath) as! HeaderBanksCollectionReusableView
//
//            reusableview.frame = CGRect(x: 0 , y: 0, width: 0, height: 0)
//             //do other header related calls or settups
//
//            return  reusableview
//        default:
//
//            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderBanksCollectionReusableView", for: indexPath) as! HeaderBanksCollectionReusableView
//
//            if banks?.count ?? 0 > 0{
//                reusableview.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: 40)
//            } else {
//                reusableview.frame = CGRect(x: 0 , y: 0, width: 0, height: 0)
//
//            }
//                         //do other header related calls or settups
//                return reusableview
//
//        }
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
            self.myDelegate?.didSelectSomething(some: "\(searchContact.numberTextField.text)")
            vc.addCloseButton()
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
            } else if collectionView == lastPaymentsCollectionView{
                let vc = PaymentByPhoneViewController()
    //            vc.confurmVCModel = self.confurmVCModel
                vc.modalPresentationStyle = .fullScreen
                vc.selectBank = lastPayment[indexPath.row].bankName
                vc.bankImage = UIImage(named: "\(lastPayment[indexPath.row].bankID ?? "")")
                
                vc.phoneField.text = selectPhoneNumber ?? ""
                vc.addCloseButton()
                self.myDelegate?.didSelectSomething(some: "\(searchContact.numberTextField.text)")

                let navController = UINavigationController(rootViewController: vc)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
                
            } else {
                self.myDelegate?.didSelectSomething(some: "\(searchContact.numberTextField.text)")
                self.delegate?.passUpdateData(data: selectPhoneNumber ?? "123")
                self.delegate1?.doSomethingWith(data: "12232")
                selectPhoneNumber = contacts[indexPath.item].phoneNumber.first
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
                        if self.lastPhonePayment.count < 1{
                        self.lastPaymentsCollectionView.isHidden = true
                            self.lastPaymentsCollectionView.reloadData()
                        }
                    
                    
                }
            } else {
                self.dismissActivity()
                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
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

