//
//  ViewController.swift
//  ExpandingCell
//
//  Created by Alexis Creuzot on 13/11/2016.
//  Copyright © 2016 alexiscreuzot. All rights reserved.
//

import UIKit

class TableExpansionViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var datasource = [ExpandingTableViewCellContent]()
    var card: Card? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView() // Removes empty cell separators
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        
        datasource = [ExpandingTableViewCellContent(title: "15 октября 2019",
                                                    subtitle: "Сумма кредита",
                                                    amountPerMonth: "8927 Р",
                                                    loanPerMonth: "3545 Р", percentPM: "1287 Р",
                                                    percentString: "Сумма процентов"
                                                    
                                                    ),
                      ExpandingTableViewCellContent(title: "15 ноября 2019",
                      subtitle: "Сумма кредита",
                      amountPerMonth: "8927 Р",
                      loanPerMonth: "3545 Р", percentPM: "1287 Р",
                      percentString: "Сумма процентов"
                      
                      ),
                      ExpandingTableViewCellContent(title: "15 декабря 2019",
                      subtitle: "Сумма кредита",
                      amountPerMonth: "8927 Р",
                      loanPerMonth: "3545 Р", percentPM: "1287 Р",
                      percentString: "Сумма процентов"
                      
                      ),
                      ExpandingTableViewCellContent(title: "15 января 2019",
                      subtitle: "Сумма кредита",
                      amountPerMonth: "8927 Р",
                      loanPerMonth: "3545 Р", percentPM: "1287 Р",
                      percentString: "Сумма процентов"
                      
                      ),
                      ExpandingTableViewCellContent(title: "15 февраля 2019",
                      subtitle: "Сумма кредита",
                      amountPerMonth: "8927 Р",
                      loanPerMonth: "3545 Р", percentPM: "1287 Р",
                      percentString: "Сумма процентов"
                      
                      ),
                    ExpandingTableViewCellContent(title: "15 февраля",
                      subtitle: "Сумма кредита",
                      amountPerMonth: "8927 Р",
                      loanPerMonth: "3545 Р", percentPM: "1287 Р",
                      percentString: "Сумма процентов"
                      
                      ),ExpandingTableViewCellContent(title: "15 октября",
                      subtitle: "Сумма кредита",
                      amountPerMonth: "8927 Р",
                      loanPerMonth: "3545 Р", percentPM: "1287 Р",
                      percentString: "Сумма процентов"
                      
                      ),ExpandingTableViewCellContent(title: "15 октября",
                      subtitle: "Сумма кредита",
                      amountPerMonth: "8927 Р",
                      loanPerMonth: "3545 Р", percentPM: "1287 Р",
                      percentString: "Сумма процентов"
                      
                      )  ]
    }
}

extension TableExpansionViewController : UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCell(withIdentifier: String(describing: ExpandingTableViewCell.self), for: indexPath) as! ExpandingTableViewCell
        cell.set(content: datasource[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let content = datasource[indexPath.row]
        content.expanded = !content.expanded
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}
