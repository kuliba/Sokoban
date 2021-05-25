//
//  CollectionViewPaymentViewController.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 02.10.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class CollectionViewPaymentViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {


        @IBOutlet weak var backButton: UIButton!

        @IBAction func backButtonClicked(_ sender: Any) {
            self.navigationController?.popViewController(animated: true)
            if navigationController == nil {
                dismiss(animated: true, completion: nil)
            }
        }
        @IBOutlet weak var tableView: CustomTableView!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.register(UINib(nibName: "PaymentCell", bundle: nil), forCellReuseIdentifier: "PaymentCell")

            if navigationController != nil || tabBarController != nil {
                backButton.isHidden = true
            } else if isModal {
                backButton.isHidden = false
            }
            self.view.backgroundColor = .white
            self.tableView.backgroundColor = UIColor.white

            
        }

        // MARK: - Table view data source

        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 4
        }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
        func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
            return 100.0
        }
        let cellId = "PaymentCell"

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? PaymentCell else {
                       fatalError()
                   }
            cell.backgroundColor = .white
            cell.selectionStyle = .none
            cell.textLabel?.textColor = .black
            cell.imageView?.isHighlighted = true
            
            tableView.separatorColor = .lightGray
            tableView.separatorStyle = .singleLine
            cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
          
            switch indexPath.item {
            case 0:
                cell.iconImageView?.image = UIImage(named: "cardscolor")
                cell.titleLabel?.text = "Между своими счетами"
                break
            case 1:
                cell.iconImageView?.image = UIImage(named: "towncolor")
                cell.titleLabel?.text = "Клиенту Фора-Банка"
                break
    //        case 2:
    //            cell.imageView?.image = UIImage(named: "mobilecolorweight")
    //            cell.textLabel?.text = "По номеру телефона"
    //            break
            case 2:
                cell.iconImageView?.image = UIImage(named: "freecolor")
                cell.titleLabel?.text = "По свободным реквизитам"
                break
            case 3:
                cell.iconImageView?.image = UIImage(named: "sbp-logo")
                cell.titleLabel?.text = "По номеру телефона(СБП)"
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
            guard let SBPVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "SBPViewController") as? SBPViewController else {
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
            SBPVC.sourceConfigurations = [
                             PaymentOptionsPagerItem(provider: sourceProvider, delegate: SBPVC)
                         ]

            switch indexPath.item {
            case 0:
                paymentDetailsVC.destinationConfigurations = [
                    PaymentOptionsPagerItem(provider: destinationProvider, delegate: paymentDetailsVC)
                ]
                paymentDetailsVC.messageRecipientIsHidden = true // убираем поле комментария при переводе между своими счетами
                break
            case 1:
                paymentDetailsVC.destinationConfigurations = [
                    PhoneNumberPagerItem(provider: destinationProviderPhoneNumber, delegate: paymentDetailsVC),
                    CardNumberPagerItem(provider: destinationProviderCardNumber, delegate: paymentDetailsVC),
                    AccountNumberPagerItem(provider: destinationProviderAccountNumber, delegate: paymentDetailsVC),
                    
                ]
                break
    //        case 2:
    //            paymentDetailsVC.destinationConfigurations = [
    //                PhoneNumberPagerItem(provider: destinationProviderPhoneNumber, delegate: paymentDetailsVC)
    //            ]
    //            break
            case 2:

                freeDetailsVC.sourceConfigurations = [
                PaymentOptionsPagerItem(provider: sourceProvider, delegate: freeDetailsVC)
                    
                ]
                
                let rootVC = tableView.parentContainerViewController()
                rootVC?.present(freeDetailsVC, animated: true, completion: nil)
                //    let freeViewController = self.storyboard?.instantiateViewController(withIdentifier: "FreeDetailsController")
                //            self.present(freeViewController!, animated: true)
                break
                case 3:
                    SBPVC.destinationConfigurations = [
                        PhoneNumberPagerItem(provider: destinationProviderPhoneNumber, delegate: SBPVC)
                    ]
                    let rootVC = tableView.parentContainerViewController()
                             rootVC?.present(SBPVC, animated: true, completion: nil)
                    break

            default:
                break
            }

            let rootVC = tableView.parentContainerViewController()
            rootVC?.present(paymentDetailsVC, animated: true, completion: nil)
        }


}
