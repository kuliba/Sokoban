//
//  ContactsViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 23.06.2021.
//

import UIKit
import Contacts

class ContactsViewController: UIViewController, UISearchBarDelegate {

    
    var banks: [FastPayment]?

    
    var contacts = [CNContact](){
        didSet{
            setupCollectionView()
        }
    }
    
    var lastPayment = [GetLatestPaymentsDatum(bankName: "Фора - Банк", bankID: "000121221", phoneNumber: "000517217", amount: "10")]{
        didSet{
            setupCollectionView()
        }
    }
//    let lastPaymentsCollectionView: UICollectionView!

//    var collectionView: UICollectionView!
    var lastPaymentsCollectionView: UICollectionView!
    var contactCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchContacts()
        getLastPayments()
        setupCollectionView()
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
    
    func fetchContacts(){
       let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
       let request = CNContactFetchRequest(keysToFetch: keys)
       
       let contactStore = CNContactStore()
       do {
           try contactStore.enumerateContacts(with: request) {
               (contact, stop) in

            self.contacts.append(contact)
           }
       }
       catch {
           print("unable to fetch contacts")
       }
    }
    
    
    private func setupSearchBar() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.automaticallyShowsCancelButton = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Номер телефона"
        searchController.searchBar.backgroundColor = .white
        searchController.searchBar.showsBookmarkButton = true
//        let view = UINib(nibName: "SearchContact", bundle: .main).instantiate(withOwner: nil, options: nil).first as! UIView
//        // let view = Bundle.main.loadNibNamed("CustomView", owner: nil, options: nil)!.first as! UIView // does the same as above
//        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: 44)
////        view.centerXAnchor. = self.view.centerXAnchor
//        self.view.addSubview(view)
        
        
    }
    
    private func setupCollectionView() {
        

        let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
            layout.itemSize = CGSize(width: 80, height: 120)
            layout.scrollDirection = .horizontal
    
        
        lastPaymentsCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 125), collectionViewLayout: layout)
     

        lastPaymentsCollectionView.backgroundColor = UIColor.white
        let flowLayout = UICollectionViewFlowLayout()
        contactCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        contactCollectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        
       
        lastPaymentsCollectionView.register(UINib(nibName: "LastPaymentsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LastPaymentsCollectionViewCell")
        contactCollectionView.register(UINib(nibName: "ContactCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ContactCollectionViewCell")
//        lastPaymentsCollectionView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        lastPaymentsCollectionView?.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 100).isActive = true
        contactCollectionView.backgroundColor = .white
        contactCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
//        collectionView.backgroundColor = .white
        view.backgroundColor = .white
        view.addSubview(contactCollectionView)
        view.addSubview(lastPaymentsCollectionView)
        
        
        contactCollectionView.delegate = self
        contactCollectionView.dataSource = self
        lastPaymentsCollectionView?.dataSource = self
        lastPaymentsCollectionView?.delegate = self
        
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
            return lastPayment.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        switch collectionView {
        case contactCollectionView:
            let item = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactCollectionViewCell", for: indexPath) as! ContactCollectionViewCell
            
            if ((banks?.isEmpty) == nil){
                item.contactLabel.text = "\(contacts[indexPath.item].givenName) " + " " + " \(contacts[indexPath.item].familyName)"
                checkOwner(number: "79626129268")

    //            item.phoneLabel.text = (contacts[indexPath.item].phoneNumbers[0].value ).value(forKey: "digits") as? String
            } else {
                
                
                item.phoneLabel.isHidden = true
                item.contactLabel.text = banks?[indexPath.item].memberNameRus
                guard let imageBank = banks?[indexPath.item].id else {
                    return item
                }
                item.contactImageView.image = UIImage(named: imageBank)
            }
            return item
        case lastPaymentsCollectionView:
            let item = collectionView.dequeueReusableCell(withReuseIdentifier: "LastPaymentsCollectionViewCell", for: indexPath) as! LastPaymentsCollectionViewCell
            item.nameLabel.text = lastPayment[indexPath.item].phoneNumber
            if lastPayment.count > 3{
                item.contactImageView.image = UIImage(named: lastPayment[indexPath.item].bankID ?? "")
                item.bankNameLabel.isHidden = true
                item.bankNameLabel.text = lastPayment[indexPath.item].bankName
                item.nameLabel.text = lastPayment[indexPath.item].amount
                
            }
            
            return item
            
        default: 
//            if collectionView == contactCollectionView {
//                let item = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactCollectionViewCell", for: indexPath) as! ContactCollectionViewCell
//                return item
//            } else if collectionView == lastPaymentsCollectionView {
//                let item = collectionView.dequeueReusableCell(withReuseIdentifier: "LastPaymentsCollectionViewCell", for: indexPath) as! LastPaymentsCollectionViewCell
////                item.nameLabel.text = lastPayment[indexPath.item].phoneNumber
//                return item
//            }
            if collectionView == lastPaymentsCollectionView{
                let item = collectionView.dequeueReusableCell(withReuseIdentifier: "LastPaymentsCollectionViewCell", for: indexPath) as! LastPaymentsCollectionViewCell
                item.nameLabel.text = lastPayment[indexPath.item].phoneNumber
                return item
            } else if collectionView == contactCollectionView{
                let item = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactCollectionViewCell", for: indexPath) as! ContactCollectionViewCell
                
                if ((banks?.isEmpty) == nil){
                    item.contactLabel.text = "\(contacts[indexPath.item].givenName) " + " " + " \(contacts[indexPath.item].familyName)"
                    checkOwner(number: "79626129268")

        //            item.phoneLabel.text = (contacts[indexPath.item].phoneNumbers[0].value ).value(forKey: "digits") as? String
                } else {
                    
                    item.phoneLabel.isHidden = true
                    item.contactLabel.text = banks?[indexPath.item].memberNameRus
                    guard let imageBank = banks?[indexPath.item].id else {
                        return item
                    }
                    item.contactImageView.image = UIImage(named: imageBank)
                }
                return item
            } else {
                return UICollectionViewCell.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case contactCollectionView:
            return CGSize(width: UIScreen.main.bounds.width, height: 60)
        default:
            return CGSize(width: 120, height: 120)

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if banks?.count ?? 0 > 0 {
            let vc = PaymentByPhoneViewController()
//            vc.confurmVCModel = self.confurmVCModel
            vc.modalPresentationStyle = .fullScreen
            vc.selectBank = banks?[indexPath.row].memberNameRus
            if banks?[indexPath.item].memberNameRus != "ФОРА - Банк"{
                vc.sbp = true
            }
            self.present(vc, animated: true, completion: nil)
            } else if collectionView == lastPaymentsCollectionView{
                let vc = PaymentByPhoneViewController()
    //            vc.confurmVCModel = self.confurmVCModel
                vc.modalPresentationStyle = .fullScreen
                vc.selectBank = lastPayment[indexPath.row].bankName
                self.present(vc, animated: true, completion: nil)
            } else {
                getBankList()
                collectionView.reloadData()
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
    func checkOwner(number: String?){
        showActivity()
        
        NetworkManager<GetOwnerPhoneNumberPhoneDecodableModel>.addRequest(.getOwnerPhoneNumber, [:], [:]) { model, error in
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
                    
                    self.lastPayment = [GetLatestPaymentsDatum(bankName: "Фора - Банк", bankID: "00072121", phoneNumber: "9626129268", amount: "Александр К."),GetLatestPaymentsDatum(bankName: "Альфа - Банк", bankID: "100000000008", phoneNumber: "9626129268", amount: "Александр К."), GetLatestPaymentsDatum(bankName: "Сбербанк", bankID: "sberBank", phoneNumber: "9626129268", amount: "Александр К."), GetLatestPaymentsDatum(bankName: "Райфайзен б.", bankID: "raiffei1test", phoneNumber: "9626129268", amount: "Александр К."), GetLatestPaymentsDatum(bankName: "ВТБ", bankID: "100000000005", phoneNumber: "9626129268", amount: "Александр К.")]
                    self.lastPaymentsCollectionView.reloadData()

                }
            } else {
                self.dismissActivity()
                
                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        }
    }
    
}

