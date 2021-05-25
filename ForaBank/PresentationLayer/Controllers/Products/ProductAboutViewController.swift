//
//  ProductAboutViewController.swift
//  ForaBank
//
//  Created by Бойко Владимир on 06/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import UIKit
import Alamofire

public typealias HTTPHeaders = [String: String]

class ProductAboutViewController: UITableViewController {
  
    private var datedTransactions = [DatedTransactions]()


    @IBOutlet weak var textlLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var cards =  [Card]()
    var deposits = [Deposit]()
    var aboutCard = [IAboutItem]()
    var items: [IAboutItem]?
    var numberCard: String = ""
    var depositId: String = ""

//    let flattenCollection = [locationsAll, items].joined() // type: FlattenBidirectionalCollection<[Array<Int>]>
//    let flattenArray = Array(flattenCollection)

    

//    func set(card: Card?) {
//        self.card = card
//        if startDateLabel != nil {
//            updateTable()
//        }
//    }


    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.contentInset.top = 35
        tableView.contentInset.bottom = 10
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension


            
        NetworkManager.shared().getCardList { [weak self] (success, cards) in
            self?.cards = cards ?? []
        }
        NetworkManager.shared().getCardInfo(cardNumber: numberCard) { [weak self] (success, cards) in
                  self?.aboutCard = cards ?? []
            self?.numberCard = self!.numberCard
            if self?.aboutCard.count != 0{
            self?.items?.append((self!.aboutCard[0]))
            self?.tableView.reloadData()
            }
        }
     

        
        
        
        
        
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = format.string(from: date)
        print(formattedDate)
        let timeNow = AboutItem(title: String("Дата и время актуализации остатка"), value: formattedDate)
        self.items?.append(timeNow)


       
        
        // Uncomment the following line to pre10
        //         serve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollUserInfo = ["tableView": tableView]
        NotificationCenter.default.post(name: NSNotification.Name("TableViewScrolled"), object: nil, userInfo: scrollUserInfo as [AnyHashable: Any])
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productAboutCell", for: indexPath) as! PaymentTemplateCell
        let item = items![indexPath.row]
        //let cardInfo = numberCard
        cell.textLabel?.numberOfLines = 3
        cell.textLabel?.adjustsFontSizeToFitWidth = true;


        cell.backgroundColor = UIColor.white
        cell.tintColor = UIColor.white
//        cell.textLabel?.text = item.title ?? cardInfo
//        cell.textLabel?.font = UIFont(name: "Roboto-Light", size: 16.0)
        cell.textLabel?.numberOfLines = 0
        cell.titleLabel.text = item.title //?? cardInfo
        cell.descriptionLabel.text = item.value //?? "123"
//        cell.detailTextLabel?.text = item.value ?? "123"
//        cell.detailTextLabel?.font = UIFont(name: "Roboto", size: 18.0)
//        cell.detailTextLabel?.textColor = UIColor(named: "black")
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.textColor = UIColor.black
        
        cell.detailTextLabel?.textColor = UIColor.black


        return cell
    }
}






