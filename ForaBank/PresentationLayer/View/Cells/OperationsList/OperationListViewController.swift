//
//  OperationListViewController.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 11.06.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class OperationListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var operationList = OperationsList()
    var templateList: GetUserSettings?
    
        var testDeposit = [Deposit]()
    @IBOutlet var activityIndicator: ActivityIndicatorView!
       
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        self.collectionView.reloadData()
    }
    
        override func viewDidLoad() {
            super.viewDidLoad()
            activityIndicator.startAnimation()
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
           
            collectionView.register(UINib(nibName: "OperationsListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "OperationPreviewCell")
            collectionView.reloadData()
    //        self.collectionView.register(UINib(nibName: "HeaderOperationCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderOperations")
            
            NetworkManager.shared().getOperationService { (success, operationList, stringName) in
                if success{
                    self.operationList = operationList!
                         self.collectionView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                } else {
                    print(Error.self)
                }
                
         
            }
            
            NetworkManager.shared().getSettings { (success, templateList, string) in
                self.templateList = templateList
                
            }
            collectionView.reloadData()
        }
        

        // MARK: UICollectionViewDataSource
        
         func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            if (kind == UICollectionView.elementKindSectionFooter) {
                let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CartFooterCollectionReusableView", for: indexPath)
                // Customize footerView here
                return footerView
            } else if (kind == UICollectionView.elementKindSectionHeader) {
               
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "OperationHeader", for: indexPath) as! HeaderOperationCollectionReusableView
                switch indexPath.section {
                case 4:
                    headerView.headerTitile.text = "Мои шаблоны"
                                    return headerView
                default:
                      headerView.headerTitile.text = operationList.data?[indexPath.section].name
                    return headerView

                }
                // Customize headerView here
              
            }
            fatalError()
        }
        let myarray = UserDefaults.standard.object([TemplateOperation].self, with: "TemplatePayments")

//    lazy var myarray = UserDefaults.standard.dictionary(forKey: "TemplatePayments")
    
         func numberOfSections(in collectionView: UICollectionView) -> Int {
//            if myarray!.isEmpty{
//            return operationList.data?.count ?? 0
//            } else{
            var count = 4
            if templateList != nil {
                count = 5
            }
                return count
//            }
            }

    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if myarray.isEmpty == false{
//            return (operationList.data?[section].operators!.count)! + myarray.count
//            }
        switch section {
        case 4:
            return templateList?.data?.count ?? 0
        default:
             return operationList.data?[section].operators?.count ?? 0
        }
           
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
        
         func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            switch indexPath.section {
            case 4:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OperationPreviewCell", for: indexPath) as! OperationsListCollectionViewCell
                                
                cell.label.text =  templateList?.data?[indexPath.row].userSetting?.sysName
                    return cell
            default:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OperationPreviewCell", for: indexPath) as! OperationsListCollectionViewCell
                    
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
        }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
             return CGSize(width: UIScreen.main.bounds.width/2.2, height: UIScreen.main.bounds.height/6)
         }

        
        let sourceProvider = PaymentOptionCellProvider()
        let destinationProvider = PaymentOptionCellProvider()
        let destinationProviderCardNumber = CardNumberCellProvider()
        let destinationProviderAccountNumber = AccountNumberCellProvider()
        let destinationProviderPhoneNumber = PhoneNumberCellProvider()
        
         func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            switch indexPath.section {
            case 4:
                let vc =  storyboard?.instantiateViewController(withIdentifier: "PaymentDetailsViewController") as! PaymentsDetailsViewController
                vc.templateAmount = templateList?.data?[indexPath.row].userSetting?.name
                vc.destinationTemplate = templateList?.data?[indexPath.row].userSetting?.sysName
                vc.sendEnable = true
                navigationController?.pushViewController(vc, animated: true)
                let sourceProvider = PaymentOptionCellProvider()

                vc.sourceConfigurations = [
                    PaymentOptionsPagerItem(provider: sourceProvider, delegate: vc)
                       ]
                destinationProviderPhoneNumber.currentValue = "123"
                vc.destinationConfigurations = [
                             PhoneNumberPagerItem(provider: destinationProviderPhoneNumber, delegate: vc)
                             
                         ]
            default:
                   let vc =  storyboard?.instantiateViewController(withIdentifier: "operationDetail") as! OperationDetailViewController
                   vc.operationList  = (operationList.data?[indexPath.section].operators?[indexPath.item])!
                         navigationController?.pushViewController(vc, animated: true)
                         let sourceProvider = PaymentOptionCellProvider()

                              vc.sourceConfigurations = [
                                         PaymentOptionsPagerItem(provider: sourceProvider, delegate: vc)
                                     ]
            }
        }
}
