//
//  CustomCardListView.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.07.2021.
//

import UIKit

class CustomCardListView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    func commonInit() {
        Bundle.main.loadNibNamed("CustomCardListView", owner: self, options: nil)
        contentView.fixView(self)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    @IBAction func closeButton(_ sender: UIButton) {
    }
    
}

extension CustomCardListView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.font = .systemFont(ofSize: 13)
        label.textColor = .lightGray
        
        switch section  {
        case 0: label.text = "Свои"
        case 1: label.text = "Сохраненные"
        default: label.text = ""
        }
        
        headerView.addSubview(label)
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath) as! CustomCardListCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    
}
