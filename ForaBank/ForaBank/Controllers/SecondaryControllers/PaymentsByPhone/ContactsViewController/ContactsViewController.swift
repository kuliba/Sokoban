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
//    let lastPaymentsCollectionView: UICollectionView!

//    var collectionView: UICollectionView!
    var lastPaymentsCollectionView: UICollectionView!
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchContacts()
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
        
    }
    
    private func setupCollectionView() {
        

        let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
            layout.itemSize = CGSize(width: 111, height: 80)
            layout.scrollDirection = .horizontal
        
        lastPaymentsCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 125), collectionViewLayout: layout)
        lastPaymentsCollectionView.delegate   = self
        lastPaymentsCollectionView.dataSource = self
        lastPaymentsCollectionView.register(UINib(nibName: "LastPaymentsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LastPaymentsCollectionViewCell")
        lastPaymentsCollectionView.backgroundColor = UIColor.white
        let flowLayout = UICollectionViewFlowLayout()
       collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        
        collectionView.register(UINib(nibName: "ContactCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ContactCollectionViewCell")
//        lastPaymentsCollectionView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        lastPaymentsCollectionView?.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 100).isActive = true
        collectionView.backgroundColor = .white
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        collectionView.backgroundColor = .white
        view.backgroundColor = .white
        view.addSubview(collectionView)
//        view.addSubview(lastPaymentsCollectionView)
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        lastPaymentsCollectionView?.dataSource = self
        lastPaymentsCollectionView?.delegate = self
        
    }
}

extension ContactsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case collectionView:
            if banks?.count ?? 0 > 0 {
                return banks?.count ?? 0
            } else {
                return contacts.count
            }
        case lastPaymentsCollectionView:
            return 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case collectionView:
            let item = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactCollectionViewCell", for: indexPath) as! ContactCollectionViewCell
            
            if ((banks?.isEmpty) == nil){
                item.contactLabel.text = "\(contacts[indexPath.item].givenName) " + " " + " \(contacts[indexPath.item].familyName)"
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
            let item = collectionView.dequeueReusableCell(withReuseIdentifier: "lastPaymentsCollectionView", for: indexPath) as? LastPaymentsCollectionViewCell
            item?.nameLabel.text = "1111"
            return item ?? UICollectionViewCell()
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if banks?.count ?? 0 > 0 {
            let vc = PaymentByPhoneViewController()
//            vc.confurmVCModel = self.confurmVCModel
            vc.modalPresentationStyle = .fullScreen
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
                    self.collectionView.reloadData()
                }
            } else {
                self.dismissActivity()
                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        }
        
    }
    
}

