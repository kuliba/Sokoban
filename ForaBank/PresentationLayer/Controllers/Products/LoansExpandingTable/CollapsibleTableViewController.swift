//
//  CollapsibleTableViewController.swift
//  ios-swift-collapsible-table-section
//
//  Created by Yong Su on 5/30/16.
//  Copyright © 2016 Yong Su. All rights reserved.
//

import UIKit

//
// MARK: - View Controller
//
class CollapsibleTableViewController: UITableViewController {
    
    
    var sectionLoans = [LaonSchedules](){
          didSet {
                 tableView.reloadData()
        }
    }
    
    var arraySectionAndCellLoans = [ClassSectionAndItemLoan]()


      override func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)
          NetworkManager.shared().getLoansPayment { (loan, success, sectionLoans) in
              if success {
                  self.sectionLoans = sectionLoans ?? []
              }
          }
        NetworkManager.shared().getLoansPayment { [weak self] (loan, success, arrayLoanSchedule) in
                     if success{
                         print("arrayLoanSchedule = ", arrayLoanSchedule![0])
                         guard arrayLoanSchedule != nil, arrayLoanSchedule?.count != 0 else {return}
                         //self!.arrayLaonSchedules = arrayLoanSchedule!
                      
                         self!.getSectionAndCellLoanTB(arrayLoans: arrayLoanSchedule ?? [])
                     }
                 }
        
      }
    
      func getSectionAndCellLoanTB(arrayLoans: Array<LaonSchedules>){
            var arrayDateLoans = Array<String?>()
            for iloan in arrayLoans{ //получаем все даты
                arrayDateLoans.append(iloan.paymentDate)
            }
            let filteredArrayDateLoans = Array(Set(arrayDateLoans)) // убираем дублирующиеся даты
            
            for dateLoan in filteredArrayDateLoans{ //цикл по датам
                var arrayLoansSection = Array<LaonSchedules>()
                var amountSection: Double = 0.0
                for loan in arrayLoans{ // цикл по выплатам
                    if loan.paymentDate == dateLoan{ //если даты совпали
                        arrayLoansSection.append(loan) //добавляем в выплату в массив
                        amountSection += loan.paymentAmount ?? 0.0 //прибавляем в сумму для секций
                    }
                }
                //print("dateLoan = ", dateLoan)
                let sectionAndCellLoan = ClassSectionAndItemLoan(sectionAmount: amountSection,
                                                                 sectionDate: getDateFromString(strTime: (dateLoan ?? "") + " 12:00"),
                                                                 arrayCellLoans: arrayLoansSection)
    //            print("dateLoan = ", dateLoan!.replacingOccurrences(of: "-", with: " "))
    //            let aaaa = getDateFromString(strTime: dateLoan!.replacingOccurrences(of: "-", with: " "))
    //            print("dateLoanDate  = ", aaaa)
    //            print("dateLoanDateStr  = ", getDateToDateMonthYear(date: aaaa!))
                
                self.arraySectionAndCellLoans.append(sectionAndCellLoan)
            }
            self.arraySectionAndCellLoans = self.arraySectionAndCellLoans.sorted(by: { $0.sectionDate > $1.sectionDate})
            self.tableView.reloadData()
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset.top = 100
        tableView.contentOffset.y = 100
        // Auto resizing the height of the cell
        tableView.contentInset.top = 26
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableView.automaticDimension
        
        self.title = "Apple Products"
    }
    
}

//
// MARK: - View Controller DataSource and Delegate
//
extension CollapsibleTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return arraySectionAndCellLoans.count
    }
     
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionLoans[section].collapsed ? 0 : 1
    }
    
    // Cell
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell: CollapsibleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CollapsibleTableViewCell ??
             CollapsibleTableViewCell(style: .default, reuseIdentifier: "cell")
         
        let item: ClassSectionAndItemLoan = arraySectionAndCellLoans[indexPath.section]
        cell.nameLabel.text = getDateFromFormate(date: arraySectionAndCellLoans[indexPath.row].sectionDate, format: "dd MMMM yyyy")
        cell.detailLabel.text = String((item.sectionAmount))
        cell.creditPayment.text = getDateFromFormate(date: arraySectionAndCellLoans[indexPath.row].sectionDate, format: "dd MMMM yyyy")
         
         return cell
     }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: "header")
        
        header.titleLabel.text = getDateFromFormate(date: arraySectionAndCellLoans[section].sectionDate, format: "dd MMMM yyyy")
        header.arrowLabel.text = ">"
        header.setCollapsed(sectionLoans[section].collapsed)
        
        header.section = section
        header.delegate = self
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }

}

//
// MARK: - Section Header Delegate
//
extension CollapsibleTableViewController: CollapsibleTableViewHeaderDelegate {
    
    func toggleSection(_ header: CollapsibleTableViewHeader, section: Int) {
        let collapsed = !sectionLoans[section].collapsed
        
        // Toggle collapse
        sectionLoans[section].collapsed = collapsed
        header.setCollapsed(collapsed)
        
        tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
    }
    
}
