//
//  OperationsListCollectionViewController.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 18.05.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit


class OperationsListCollectionViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout{

    var operationList = OperationsList()
    var testDeposit = [Deposit]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
       
        collectionView.register(UINib(nibName: "OperationsListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "OperationPreviewCell")
//        self.collectionView.register(UINib(nibName: "HeaderOperationCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderOperations")
    
        
        NetworkManager.shared().getOperationService { (success, operationList, stringName) in
            if success{
                self.operationList = operationList!
                     self.collectionView.reloadData()
            } else {
                print(Error.self)
            }
     
        }
        collectionView.reloadData()
    }
    

 
    
  


    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionView.elementKindSectionFooter) {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CartFooterCollectionReusableView", for: indexPath)
            // Customize footerView here
            return footerView
        } else if (kind == UICollectionView.elementKindSectionHeader) {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "OperationHeader", for: indexPath) as! HeaderOperationCollectionReusableView
            // Customize headerView here
            headerView.headerTitile.text = operationList.data?[indexPath.section].name
            return headerView
        }
        fatalError()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return operationList.data?.count ?? 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1{
            return operationList.data?[section].operators?.count ?? 0 + 4
        }
        return operationList.data?[section].operators?.count ?? 0
    }
    
//    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let header = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderOperations", for: indexPath) as? HeaderOperationCollectionReusableView
//        header?.headerLabel.text = "123"
////        let headerOption = collectionView.dequeueReusableSupplementaryView(ofKind: <#T##String#>, withReuseIdentifier: <#T##String#>, for: <#T##IndexPath#>)
////        header?.headerLabel.text = "Header123"
//        return header!
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width/2.2, height: UIScreen.main.bounds.height/6)
    }
    
    
    func base64Convert(base64String: String?) -> UIImage{
      if (base64String?.isEmpty)! {
          return #imageLiteral(resourceName: "no_image_found")
      }else {
          // !!! Separation part is optional, depends on your Base64String !!!
          let temp = base64String?.components(separatedBy: ",")
          let dataDecoded : Data = Data(base64Encoded: temp![0], options: .ignoreUnknownCharacters)!
          let decodedimage = UIImage(data: dataDecoded)
          return decodedimage!
      }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OperationPreviewCell", for: indexPath) as! OperationsListCollectionViewCell
        if indexPath.section == 1 {
        switch indexPath.item {
                case 0:
                    cell.image?.image = UIImage(named: "cardscolor")
                    cell.label?.text = "Между своими счетами"
                    break
                case 1:
                    cell.image?.image = UIImage(named: "towncolor")
                    cell.label?.text = "Клиенту Фора-Банка"
                    break
                case 2:
                    cell.image?.image = UIImage(named: "freecolor")
                    cell.label?.text = "По свободным реквизитам"
                    break
                case 3:
                    cell.image?.image = UIImage(named: "sbp-logo")
                    cell.label?.text = "По номеру телефона(СБП)"
                    break
                default:
                    break
                }
        }
        
        cell.label.text = operationList.data?[indexPath.section].operators?[indexPath.item].nameList?[0].value!
        if (operationList.data?[indexPath.section].operators?[indexPath.item].logotypeList!.isEmpty)! {
            let imageData = operationList.data?[0].operators?[1].logotypeList![0].content!
            let _ = base64Convert(base64String: imageData)
        } else{
            let imageData = operationList.data?[indexPath.section].operators?[indexPath.item].logotypeList![0].content!


            let imageTry = base64Convert(base64String: imageData)
            cell.image.image = UIImage(data: imageTry.pngData()!)
        }
        return cell
    }

    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
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
                        
                        let rootVC = collectionView.parentContainerViewController()
                        rootVC?.present(freeDetailsVC, animated: true, completion: nil)
                        //    let freeViewController = self.storyboard?.instantiateViewController(withIdentifier: "FreeDetailsController")
                        //            self.present(freeViewController!, animated: true)
                        break
                        case 3:
                            SBPVC.destinationConfigurations = [
                                PhoneNumberPagerItem(provider: destinationProviderPhoneNumber, delegate: SBPVC)
                            ]
                            let rootVC = collectionView.parentContainerViewController()
                                     rootVC?.present(SBPVC, animated: true, completion: nil)
                            break

                    default:
                        break
                    }

                    let rootVC = collectionView.parentContainerViewController()
                    rootVC?.present(paymentDetailsVC, animated: true, completion: nil)
        }
        let vc =  storyboard?.instantiateViewController(withIdentifier: "operationDetail") as! OperationDetailViewController
        vc.operationList  = (operationList.data?[indexPath.section].operators?[indexPath.item] as OperationsDetails?)!
        navigationController?.pushViewController(vc, animated: true)
        let sourceProvider = PaymentOptionCellProvider()

        vc.sourceConfigurations = [
                   PaymentOptionsPagerItem(provider: sourceProvider, delegate: vc)
               ]
        
    }
    
    
    
    // MARK: UICollectionViewDelegate

}
