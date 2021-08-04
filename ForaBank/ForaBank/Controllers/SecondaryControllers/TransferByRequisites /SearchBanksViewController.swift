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
            banks = banks.filter({$0.fullName?.lowercased().prefix(text.count) ?? "" == text.lowercased() || $0.bic?.lowercased().prefix(text.count) ?? "" == text.lowercased()})
        } else if text == ""{
            banks = allBanks
        }
        bankListCollectionView.reloadData()
        //        banks = banks.filter({$0.memberNameRus?.lowercased().prefix(text.count) ?? "" == text})
        //        contactCollectionView.reloadData()
    }
    

    var bankListCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 60)
        let collectionView = UICollectionView(
            frame: UIScreen.main.bounds, collectionViewLayout: flowLayout)
        return collectionView
    }()
    
    var banks = [BankFullInfoList]()
    
    let searchContact: SearchContact = UIView.fromNib()

    var delegate: passTextFieldText? = nil
    
    var didBankTapped: ((BankFullInfoList) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchContact.delegateNumber = self
//        banks = banks.filter({$0.fullName != "Смотреть все"})
        allBanks = banks
        setupUI()
    }
    
    @objc func backAction(){
        dismiss(animated: true, completion: nil)
        navigationController?.dismiss(animated: true, completion: nil)
    }

    func setupUI() {
        setupNavigationBar()
        setupCollectionView()
        
        searchContact.numberTextField.placeholder = "Введите название или БИК банка"
        
        let contactView = UIView()
        contactView.isUserInteractionEnabled = true
        contactView.addSubview(bankListCollectionView)
        contactView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        let stackView = UIStackView(arrangedSubviews: [searchContact, contactView])
        view.addSubview(stackView)
//            searchContact.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 20).isActive = true
//            searchContact.leadingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -20).isActive = true
        
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.backgroundColor = .white
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0)

    }
    
    private func setupCollectionView() {
        bankListCollectionView.isScrollEnabled = true
        bankListCollectionView.delegate = self
        bankListCollectionView.dataSource = self
        bankListCollectionView.backgroundColor = .white
        bankListCollectionView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        bankListCollectionView.register(UINib(nibName: "ContactCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ContactCollectionViewCell")
    }
    
    
    private func setupNavigationBar() {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "Выберите банк"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        self.navigationItem.leftItemsSupplementBackButton = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Закрыть", style: .plain, target: self, action:  #selector(backAction))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(
            [.foregroundColor: UIColor.black], for: .normal)
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(
            [.foregroundColor: UIColor.black], for: .highlighted)
    }
    
    private func updateInitialsColorForIndexPath(_ indexpath: IndexPath) -> UIColor {
        //Applies color to Initial Label
        let colorArray = [Constants.Colors.amethystColor, Constants.Colors.asbestosColor, Constants.Colors.emeraldColor, Constants.Colors.pumpkinColor, Constants.Colors.sunflowerColor]
        let randomValue = (indexpath.row + indexpath.section) % colorArray.count
        return colorArray[randomValue]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return banks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = bankListCollectionView.dequeueReusableCell(withReuseIdentifier: "ContactCollectionViewCell", for: indexPath) as! ContactCollectionViewCell
        var image = UIImage()
        if let imageString = banks[indexPath.item].svgImage {
            image = imageString.convertSVGStringToImage()
        } else {
            image = UIImage(named: "BankIcon")!
        }
        item.contactImageView.image = image
        item.contactImageView.backgroundColor = banks[indexPath.item].svgImage != nil
            ? .clear : updateInitialsColorForIndexPath(indexPath)
        
        item.contactLabel.text = banks[indexPath.item].fullName
        item.phoneLabel.text = banks[indexPath.item].bic
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
        let bank = banks[indexPath.item]
        didBankTapped?(bank)
        dismiss(animated: true, completion: nil)
    }
}
