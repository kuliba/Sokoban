//
//  ProductsViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 30.08.2021.
//

import UIKit

class ProductsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    var totalMoney: Double = 0.0 {
        didSet{
            totalMoneyView.totalBalance.text = String(totalMoney)
        }
    }
    
    var products = [GetProductListDatum](){
        didSet {
            DispatchQueue.main.async {
                self.totalMoney = 0.0
                for i in self.products{
                    self.totalMoney += i.balance!
                }
                self.tableView?.reloadData()
            }
        }
    }
    let totalMoneyView: TotalMoneyView = UIView.fromNib()

    var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCardList { products, errorMessage in
            self.products = products ?? []
        }
        // Do any additional setup after loading the view.
        setupUI()
    }
    

    func setupUI() {
        
        title = "Мои продукты"
        totalMoneyView.backgroundColor = .clear
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(action))
        self.navigationItem.rightBarButtonItem?.tintColor = .black


        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
//        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView?.anchor(top: totalMoneyView.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, width: 200, height: 500)
        tableView = UITableView(frame: CGRect(x: 0, y: totalMoneyView.bounds.height, width: displayWidth, height: displayHeight))
        tableView.register(ProductTableViewCell.nib(), forCellReuseIdentifier: ProductTableViewCell.identifier)
        tableView?.delegate = self
        tableView?.dataSource = self

        
        view.addSubview(totalMoneyView)
        view.addSubview(tableView)
        tableView?.anchor(top: totalMoneyView.bottomAnchor ,left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,paddingTop: 10, paddingLeft: 20, paddingRight: 20)


        totalMoneyView.anchor(top: view.topAnchor ,left: view.leftAnchor,
                          right: view.rightAnchor, paddingTop: 20)

        tableView?.backgroundColor = .white
        tableView.separatorStyle = .none
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 0.965, green: 0.965, blue: 0.969, alpha: 1)
        totalMoneyView.backgroundColor = UIColor(red: 0.965, green: 0.965, blue: 0.969, alpha: 1)
        view.backgroundColor = .white
    }
    @objc func action(sender: UIBarButtonItem) {
        // Function body goes here
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.identifier, for: indexPath) as! ProductTableViewCell
        cell.titleProductLabel.text = products[indexPath.row].productName
        cell.numberProductLabel.text = products[indexPath.row].numberMasked
        cell.balanceLabel.text = "\(products[indexPath.row].balance?.currencyFormatter() ?? "")"
        cell.coverpProductImage.image = products[indexPath.row].smallDesign?.convertSVGStringToImage()
        cell.cardTypeImage.image = products[indexPath.row].paymentSystemImage?.convertSVGStringToImage()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ProductViewController()
        vc.addCloseButton()
        vc.modalPresentationStyle = .fullScreen
        vc.products = products
        vc.product = products[indexPath.row]
        present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            let label = UILabel()
            label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
            label.text = "Карты и счета"
            label.font = .boldSystemFont(ofSize: 18)
            label.textColor = .black
            headerView.addSubview(label)
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
//            button.setImage(UIImage(systemName: "arrow"), for: .normal)

            headerView.backgroundColor = .white
//            button.anchor()
            headerView.addSubview(button)
            
            return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 50
    }
    
    
    private func getCardList(completion: @escaping (_ cardList: [GetProductListDatum]?, _ error: String?) ->() ) {
        
        let param = ["isCard": "true", "isAccount": "true", "isDeposit": "false", "isLoan": "false"]
        
        NetworkManager<GetProductListDecodableModel>.addRequest(.getProductListByFilter, param, [:]) { model, error in
            if error != nil {
                completion(nil, error)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                guard let cardList = model.data else { return }
                self.products = model.data ?? []
                
                completion(cardList, nil)
            } else {
                guard let error = model.errorMessage else { return }
                completion(nil, error)
            }
        }

        

}
}
