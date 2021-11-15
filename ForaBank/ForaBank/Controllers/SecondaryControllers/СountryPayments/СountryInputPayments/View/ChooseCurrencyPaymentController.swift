//
//  ChooseCurrencyPaymentController.swift
//  ForaBank
//
//  Created by Mikhail on 15.11.2021.
//

import UIKit

class ChooseCurrencyPaymentController: UIViewController {

    let cellReuse = "ChooseCurrencyTableViewCell"
    
    var elements: [String] = []
    
    var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    
//    var product: GetProductListDatum?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = .boldSystemFont(ofSize: 16)
        label.text = "Выберите валюту выдачи"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        view.backgroundColor = .white
        setupTableView()
        
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.anchor(
            top: view.topAnchor, left: view.leftAnchor,
            bottom: view.bottomAnchor, right: view.rightAnchor,
            paddingTop: 0, paddingLeft: 20,
            paddingBottom: 20, paddingRight: 20)
        tableView.register(UINib(nibName: cellReuse, bundle: nil), forCellReuseIdentifier: cellReuse)
        tableView.separatorStyle = .none
        tableView.rowHeight = 56
    }
    
    
}

extension ChooseCurrencyPaymentController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuse, for: indexPath) as? ChooseCurrencyTableViewCell else { return UITableViewCell() }
//        switch indexPath.row {
//        case 0:
//            cell.titleLabel.text = "Реквизиты счета карты"
//            cell.imageButton.image = UIImage(named: "file-text")?.withRenderingMode(.alwaysTemplate)
//        case 1:
//            cell.titleLabel.text = "Выписка по счету"
//            cell.imageButton.image = UIImage(named: "accaunt")?.withRenderingMode(.alwaysTemplate)
//        default:
//            cell.titleLabel.text = "default"
//            cell.imageButton.image = UIImage(named: "otherAccountButton")
//        }
//        cell.imageButton.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        cell.selectionStyle = .none
        return cell
    }
    
}

extension ChooseCurrencyPaymentController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            print("первый")
        case 1:
            print("второй")
            
        default:
            print("по умолчанию")
//            self.dismiss(animated: true, completion: nil)
        }
    }
}
