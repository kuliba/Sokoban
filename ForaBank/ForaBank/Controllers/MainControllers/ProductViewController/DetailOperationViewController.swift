//
//  DetailOperationViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 03.11.2021.
//

import UIKit

class DetailOperationViewController: UIViewController {

    var name: String?
    var amount: String?
    var commisstion: String?
    var date: String?
    var adress: String?
    var card: String?
    var terminal: String?
    var merchant: String?
    var code: String?
    
    var tableView: UITableView?
    
    var data =  MockItems.returnDetails()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexString: "f8f8f8")
        data[0].controllerName = name ?? ""
        data[1].controllerName = amount ?? ""
        data[2].controllerName = commisstion ?? ""
        data[3].controllerName = date ?? ""
        data[4].controllerName = adress ?? ""
        data[5].controllerName = card ?? ""
        data[6].controllerName = terminal ?? ""
        data[7].controllerName = merchant ?? ""
        data[8].controllerName = code ?? ""



//        tableView.frame = tableView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 20))


        tableView = UITableView(frame: CGRect(x: 0, y: 20, width: 300, height: 300))

        tableView?.separatorStyle = .none
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.estimatedRowHeight = 76
        tableView?.register(UINib(nibName: "DetailOperationTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailOperationCell")
        view.addSubview(tableView ?? UITableView())
        tableView?.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingBottom: 30, paddingRight: 20)
        tableView?.add_Border(1, .lightGray)
    }

}

extension DetailOperationViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailOperationCell") as? DetailOperationTableViewCell
        cell?.categoryLabel.text =  data[indexPath.row].name
        cell?.titleLabel.text = data[indexPath.row].controllerName
//        cell?.titleLabel.text = data[indexPath.row].iconName
        return cell ?? UITableViewCell()
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 10
//    }
    
    
}
