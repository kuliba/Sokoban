//
//  DetailInformationViewController.swift
//  ForaBank
//
//  Created by Mikhail on 30.11.2021.
//

import UIKit

class DetailInformationViewController: UIViewController {

    let cellReuse = "DetailInformationViewCell"
    var elements: [DetailedСondition]? = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = .boldSystemFont(ofSize: 16)
        label.text = "Дополнительные условия"
        
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
            bottom: view.bottomAnchor, right: view.rightAnchor)
        tableView.register(UINib(nibName: cellReuse, bundle: nil), forCellReuseIdentifier: cellReuse)
        tableView.separatorStyle = .none
        tableView.rowHeight = 44
    }
    
    
}

extension DetailInformationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuse, for: indexPath) as? DetailInformationViewCell else { return UITableViewCell() }

        cell.viewModel = elements?[indexPath.row]
        
        return cell
    }
    
}
