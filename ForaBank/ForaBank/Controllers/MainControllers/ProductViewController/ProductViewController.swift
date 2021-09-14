//
//  ProductViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 31.08.2021.
//

import UIKit

class ProductViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {

    var products = [GetProductListDatum]()
    var product: GetProductListDatum?
    var tableView: UITableView?
    var backgroundView = UIView()
    var topStackView = UIStackView()
//    var buttonStackView = UIStackView(arrangedSubviews: [])
    
    // Stackview setup
    lazy var stackView: UIStackView = {

        let stackV = UIStackView(arrangedSubviews: [])

        stackV.translatesAutoresizingMaskIntoConstraints = false
        stackV.axis = .horizontal
        stackV.spacing = 20
        stackV.distribution = .fillEqually

        return stackV
    }()
    
    var buttonItem = UIButton()
    
    
    var card = CardCell()
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        var cardModel = CardViewModel(card: self.product!)
        self.navigationItem.setTitle(title: (product?.customName ?? product?.mainField)!, subtitle: product?.numberMasked ?? "")
        loadHistoryForCard()
        view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .gray
        
        view.addSubview(backgroundView)
        view.addSubview(card)
        
        backgroundView.backgroundColor = UIColor(hexString: product?.background[0] ?? "")
        backgroundView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: card.centerYAnchor, right: view.rightAnchor)
//        backgroundView.backgroundColor = UIColor(hex: "#\(product?.background[0] ?? "")")
//        view.backgroundColor = .red

        
        //Add buttons
        let button = UIButton()
        button.setTitle("btn 1", for: .normal)
        let btnImage = UIImage(named: "plus")
        button.tintColor = .black
        button.setImage(btnImage , for: .normal)
        button.backgroundColor = UIColor(hexString: "F6F6F7")
        button.translatesAutoresizingMaskIntoConstraints = false

        let button2 = UIButton()
        button2.layer.cornerRadius = 10
        button2.setTitle("btn 2", for: .normal)
        let btnImage2 = UIImage(named: "image")
        button2.tintColor = .black
        button2.setImage(btnImage2 , for: .normal)
        button2.backgroundColor = UIColor(hexString: "F6F6F7")
        button2.translatesAutoresizingMaskIntoConstraints = false

        let button3 = UIButton()
        button3.setTitle("btn 3", for: .normal)
        let btnImage3 = UIImage(named: "image")
        button3.tintColor = .black
        button3.setImage(btnImage3 , for: .normal)
        button3.backgroundColor = UIColor(hexString: "F6F6F7")
        button3.translatesAutoresizingMaskIntoConstraints = false
        
        let button4 = UIButton()
        button4.setTitle("btn 4", for: .normal)
        let btnImage4 = UIImage(named: "image")
        button4.tintColor = .black
        button4.setImage(btnImage4 , for: .normal)
        button4.backgroundColor = UIColor(hexString: "F6F6F7")
        button4.translatesAutoresizingMaskIntoConstraints = false

        
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8.0

        stackView.addArrangedSubview(button)
        stackView.addArrangedSubview(button2)
        stackView.addArrangedSubview(button3)
        stackView.addArrangedSubview(button4)

        view.addSubview(stackView)
        stackView.anchor(top: card.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        
        
        //CollectionView set
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: CardCell.reuseId)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, height: 100)
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.centerX(inView: view)
        
        
        //CardView set
        card.anchor(top: collectionView.bottomAnchor, paddingTop: 20,  paddingBottom: 20,  width: 268, height: 172)
        card.backgroundColor = .clear
        card.centerX(inView: view)
        card.card = product
        
        //TableView set
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableView?.dataSource = self
        tableView?.delegate = self
        view.addSubview(tableView ?? UITableView())
        tableView?.anchor(top: stackView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 20)
        
    
        //Right navigation button
        let item = UIBarButtonItem(image: UIImage(named: "pencil-3"), style: .done, target: self, action: #selector(customName))
        self.navigationItem.setRightBarButton(item, animated: false)
    }
    
    @objc func customName(){
        let alertController = UIAlertController(title: "Название карты", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
               textField.placeholder = "Enter Second Name"
           }
        let saveAction = UIAlertAction(title: "Созранить", style: UIAlertAction.Style.default, handler: { alert -> Void in
               let nameTextField = alertController.textFields![0] as UITextField
            guard let idCard = self.product?.cardID else { return }
            guard let name = nameTextField.text else { return }
            let body = [ "id" : idCard,
                         "name" : name
                         ] as [String : AnyObject]
            
            NetworkManager<SaveCardNameDecodableModel>.addRequest(.saveCardName, [:], body) { model, error in
                if error != nil {
                    print("DEBUG: Error: ", error ?? "")
                }
                guard let model = model else { return }
                print("DEBUG: LatestPayment: ", model)
                if model.statusCode == 0 {
                    
                    guard let lastPaymentsList  = model.data else { return }
//                    self.dataUSD = lastPaymentsList
                } else {
                    print("DEBUG: Error: ", model.errorMessage ?? "")
                    DispatchQueue.main.async {
                        if model.errorMessage == "Пользователь не авторизован"{
                            AppLocker.present(with: .validate)
                        }
                    }
                }
            }
           })
        
        let cancelAction = UIAlertAction(title: "Отмена", style: UIAlertAction.Style.default, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
           
        self.present(alertController, animated: true, completion: nil)
    }
    
    func loadHistoryForCard(){
        let body = [   "cardNumber": product?.number
                     ] as [String : AnyObject]
        
        NetworkManager<GetCardStatementDecodableModel>.addRequest(.getCardStatement, [:], body) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: LatestPayment: ", model)
            if model.statusCode == 0 {
                guard let lastPaymentsList  = model.data else { return }
//                    self.dataUSD = lastPaymentsList
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
                DispatchQueue.main.async {
                    if model.errorMessage == "Пользователь не авторизован"{
                        AppLocker.present(with: .validate)
                    }
                }
            }
        }
    }

}
extension ProductViewController{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: CardCell.reuseId, for: indexPath) as? CardCell
//        item?.card = products[indexPath.item]
        item?.card = products[indexPath.row]
        item?.backgroundColor = .clear
        item?.layer.shadowPath = .none
        item?.layer.shadowRadius = 0
        item?.maskCardLabel.isHidden = true
        item?.balanceLabel.isHidden = true
        item?.cardNameLabel.isHidden = true
        item?.backgroundImageView.image = products[indexPath.row].smallDesign?.convertSVGStringToImage()
        
        return item ?? UICollectionViewCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
       {
            let width = UIScreen.main.bounds.width
           return CGSize(width: width, height: 50)
       }

       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
       {
           return UIEdgeInsets(top: 20, left: 8, bottom: 5, right: 8)
       }
    
}

extension ProductViewController{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            
            let label = UILabel()
            label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
            label.text = "Notification Times"
            label.font = .systemFont(ofSize: 16)
            label.textColor = .yellow
            
            headerView.addSubview(label)
            
            return headerView
        }
    
}



extension UINavigationItem {
    
    func setTitle(title:String, subtitle:String) {
        let one = UILabel()
        one.text = title
        one.font = UIFont.systemFont(ofSize: 18)
        one.sizeToFit()
        
        let two = UILabel()
        two.text = subtitle
        two.font = UIFont.systemFont(ofSize: 12)
        two.textAlignment = .center
        two.sizeToFit()
        
        let stackView = UIStackView(arrangedSubviews: [one, two])
        stackView.distribution = .equalCentering
        stackView.axis = .vertical
        stackView.alignment = .center
        
        let width = max(one.frame.size.width, two.frame.size.width)
        stackView.frame = CGRect(x: 0, y: 0, width: width, height: 35)
        
        one.sizeToFit()
        two.sizeToFit()
        
        self.titleView = stackView
    }
}
