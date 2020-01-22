//
//  PaymentsTableViewController.swift
//  ForaBank
//
//  Created by Бойко Владимир on 08.10.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class PaymentsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var backButton: UIButton!

    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        if navigationController == nil {
            dismiss(animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if navigationController != nil || tabBarController != nil {
            backButton.isHidden = true
        } else if isModal {
            backButton.isHidden = false
        }
        
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.backgroundColor = .white
        cell.selectionStyle = .none
        cell.textLabel?.textColor = .black
    
        
        tableView.separatorColor = .lightGray
        tableView.separatorStyle = .singleLine
        cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
      
        switch indexPath.item {
        case 0:
            cell.imageView?.image = UIImage(named: "cardscolor")
            cell.textLabel?.text = "Между своими счетами"
            break
        case 1:
            cell.imageView?.image = UIImage(named: "towncolor")
            cell.textLabel?.text = "Клиенту Фора-Банка"
            break
        case 2:
            cell.imageView?.image = UIImage(named: "mobilecolorweight")
            cell.textLabel?.text = "По номеру телефона"
            break
        case 3:
            cell.imageView?.image = UIImage(named: "freecolor")
            cell.textLabel?.text = "По свободным реквизитам"
            break
        default:
            break
        }
        return cell
    }
    


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        store.dispatch(startPayment(sourceOption: nil, destionationOption: nil))

        guard let paymentDetailsVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetailsViewController") as? PaymentsDetailsViewController else {
            return
        }
        guard let freeDetailsVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "FreeDetailsController") as? FreeDetailsViewController else {
                   return
               }

        let sourceProvider = PaymentOptionCellProvider()
        let destinationProvider = PaymentOptionCellProvider()
        let destinationProviderCardNumber = CardNumberCellProvider()
        let destinationProviderAccountNumber = AccountNumberCellProvider()
        let destinationProviderPhoneNumber = PhoneNumberCellProvider()

        paymentDetailsVC.sourceConfigurations = [
            PaymentOptionsPagerItem(provider: sourceProvider, delegate: paymentDetailsVC)
        ]
        freeDetailsVC.sourceConfigurations = [
                  PaymentOptionsPagerItem(provider: sourceProvider, delegate: freeDetailsVC)
              ]

        switch indexPath.item {
        case 0:
            paymentDetailsVC.destinationConfigurations = [
                PaymentOptionsPagerItem(provider: destinationProvider, delegate: paymentDetailsVC)
            ]
            break
        case 1:
            paymentDetailsVC.destinationConfigurations = [
                CardNumberPagerItem(provider: destinationProviderCardNumber, delegate: paymentDetailsVC),
                AccountNumberPagerItem(provider: destinationProviderAccountNumber, delegate: paymentDetailsVC),
            ]
            break
        case 2:
            paymentDetailsVC.destinationConfigurations = [
                PhoneNumberPagerItem(provider: destinationProviderPhoneNumber, delegate: paymentDetailsVC)
            ]
            break
        case 3:

            freeDetailsVC.sourceConfigurations = [
            PaymentOptionsPagerItem(provider: sourceProvider, delegate: freeDetailsVC)
                
            ]
            
            let rootVC = tableView.parentContainerViewController()
            rootVC?.present(freeDetailsVC, animated: true, completion: nil)
            //    let freeViewController = self.storyboard?.instantiateViewController(withIdentifier: "FreeDetailsController")
            //            self.present(freeViewController!, animated: true)
            break
        default:
            break
        }

        let rootVC = tableView.parentContainerViewController()
        rootVC?.present(paymentDetailsVC, animated: true, completion: nil)
    }
}
