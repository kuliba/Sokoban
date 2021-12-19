//
//  DocDepositCollectionViewCell.swift
//  ForaBank
//
//  Created by Mikhail on 10.12.2021.
//

import UIKit

class DocDepositCollectionViewCell: UICollectionViewCell {

    let cellIdentifier = "DocDepositTableViewCell"
    
    var documentsList: [DocumentsList]? = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
    }
    
    
    @IBAction func hideButton(_ sender: Any) {
        print(#function)
    }
    
}

extension DocDepositCollectionViewCell: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentsList?.count ?? 0
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DocDepositTableViewCell
        cell.document = documentsList?[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let url = URL(string: documentsList?[indexPath.row].url ?? "") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
    }
    
    
    
}
