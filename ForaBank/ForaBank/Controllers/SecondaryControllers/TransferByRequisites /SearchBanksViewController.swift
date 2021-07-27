//
//  SearchBanksViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 14.07.2021.
//

import UIKit

class SearchBanksViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, passTextFieldText {
   var allBanks = [BankFullInfoList]()
    func passTextFieldText(text: String) {
        
        if text != ""{
            banks = allBanks
            banks = banks.filter({$0.fullName?.lowercased().prefix(text.count) ?? "" == text || $0.memberID?.lowercased().prefix(text.count) ?? "" == text})
        } else if text == ""{
            banks = allBanks
        }
        contactCollectionView.reloadData()
//        banks = banks.filter({$0.memberNameRus?.lowercased().prefix(text.count) ?? "" == text})
//        contactCollectionView.reloadData()
    }
    
    
    

    var contactCollectionView: UICollectionView!
    
    var banks = [BankFullInfoList]()
    
    let searchContact: SearchContact = UIView.fromNib()

    var delegate: passTextFieldText? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        searchContact.delegateNumber = self
        banks = banks.filter({$0.fullName != "Смотреть все"})
        allBanks = banks
        setupUI()
    }
    
    @objc func backAction(){
        dismiss(animated: true, completion: nil)
        navigationController?.dismiss(animated: true, completion: nil)
    }

    func setupUI(){
        searchContact.numberTextField.placeholder = "Введите название или Бик банка"
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: view.bounds.width, height: 60)
        contactCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
            
        contactCollectionView.register(UINib(nibName: "ContactCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ContactCollectionViewCell")

            let contactView = UIView()
            
            contactView.addSubview(contactCollectionView)
            contactCollectionView.delegate = self
            contactCollectionView.dataSource = self
            contactCollectionView.backgroundColor = .white

        
        let stackView = UIStackView(arrangedSubviews: [searchContact, contactView])
//            searchContact.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 20).isActive = true
//            searchContact.leadingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -20).isActive = true
        contactView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        contactCollectionView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        

            stackView.isLayoutMarginsRelativeArrangement = true
            contactView.isUserInteractionEnabled = true
            contactCollectionView.isScrollEnabled = true
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.distribution = .fill
            stackView.spacing = 10
            stackView.backgroundColor = .white
            
//            view.addSubview(lastPaymentsCollectionView)
//            view.addSubview(contactView)
        
            view.addSubview(stackView)
        

            stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0)
        
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "Выберите контакт"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        self.navigationItem.leftItemsSupplementBackButton = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action:  #selector(backAction))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .highlighted)


    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return banks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = contactCollectionView.dequeueReusableCell(withReuseIdentifier: "ContactCollectionViewCell", for: indexPath) as! ContactCollectionViewCell
        item.contactImageView.image = banks[indexPath.item].svgImage?.convertSVGStringToImage()
        item.contactLabel.text = banks[indexPath.item].fullName
        item.phoneLabel.text = banks[indexPath.item].memberID
        return item
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: UIScreen.main.bounds.width, height: 60)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: self.view.frame.width / 3 - 100 , height: collectionView.frame.size.height - 100)
//    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
    }
}
