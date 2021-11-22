//
//  ChooseCurrencyPaymentController.swift
//  ForaBank
//
//  Created by Mikhail on 15.11.2021.
//

import UIKit

class ChooseCurrencyPaymentController: UIViewController {

    let cellReuse = "ChooseCurrencyTableViewCell"
    var itemIsSelect: ((String) -> Void)?
    var elements: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
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

        cell.titleLabel.text = ""
        let currArr = Dict.shared.currencyList
        currArr?.forEach({ currency in
            if currency.code == elements[indexPath.row] {
                cell.titleLabel.text = currency.name
            }
        })

        cell.currencyLabel.text = elements[indexPath.row].getSymbol()
        cell.selectionStyle = .none
        return cell
    }
    
}

extension ChooseCurrencyPaymentController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemIsSelect?(elements[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
}
