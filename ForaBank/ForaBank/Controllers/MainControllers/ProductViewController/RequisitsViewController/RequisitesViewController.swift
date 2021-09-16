//
//  RequisitesViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 16.09.2021.
//

import UIKit

class RequisitesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView()
    
    var mockItem: [PaymentsModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
//        tableView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none

        tableView.register(UINib(nibName: "RequisitsTableViewCell", bundle: nil), forCellReuseIdentifier: "RequisitsTableViewCell")
     
        
        // Do any additional setup after loading the view.
    }
    
    
    func setupUI(){
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "Реквизиты счета карты"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        self.navigationItem.leftItemsSupplementBackButton = true
        let close = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(backButton))
        close.tintColor = .black
        //        self.navigationItem.setRightBarButton(close, animated: true)
        
        //        self.navigationItem.rightBarButtonItem?.action = #selector(backButton)
        self.navigationItem.rightBarButtonItem = close
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .highlighted)
    }

    @objc func backButton(){
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mockItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequisitsTableViewCell", for: indexPath) as? RequisitsTableViewCell
        cell?.nameCellLabel.text = mockItem[indexPath.row].name
        cell?.titleLabel.text = mockItem[indexPath.row].description
        return cell ?? UITableViewCell()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
