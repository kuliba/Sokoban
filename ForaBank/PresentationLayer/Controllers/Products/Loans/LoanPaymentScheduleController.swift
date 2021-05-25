//
//  ProductAboutViewController.swift
//  ForaBank
//
//  Created by Бойко Владимир on 06/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import UIKit
import Foundation


class LoanPaymentScheduleController: UITableViewController {

    var items: [LaonSchedules]?
    var arraySectionAndCellLoans = [ClassSectionAndItemLoan]()

//    func set(card: Card?) {
//        self.card = card
//        if startDateLabel != nil {
//            updateTable()
//        }
//    }

    override func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)
        
           NetworkManager.shared().getLoansPayment { [weak self] (loan, success, arrayLoanSchedule) in
                       if success{
                           print("arrayLoanSchedule = ", arrayLoanSchedule![0])
                           guard arrayLoanSchedule != nil, arrayLoanSchedule?.count != 0 else {return}
                           //self!.arrayLaonSchedules = arrayLoanSchedule!
                        
                           self!.getSectionAndCellLoanTB(arrayLoans: arrayLoanSchedule ?? [])
                       }
                   }
        
      }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()

        tableView.contentInset.top = 35
        tableView.contentInset.bottom = 10

       
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        //let item = items?[indexPath.item]

  

        return cell
    }
}
