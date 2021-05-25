//
//  ServiceListViewController.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 17.09.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class ServiceListViewController: ForaActivityIndicator, UISearchDisplayDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    
    @IBOutlet weak var activityIndicator: ActivityIndicatorView!
    
    @IBOutlet weak var collectionViewLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var staticOpertionsTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var searching = false
    var statusCode: OSStatus?
    var publicKey: SecKey?
    var privateKey: SecKey?
    
    var operationList = OperationsList() {
        didSet{
            activityIndicator.startAnimation()
            tableView.reloadData()
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            collectionViewLabel.isHidden = false
            collectionView.isHidden = false
        
//            let publicKeyAttr: [NSObject: NSObject] = [
//                        kSecAttrIsPermanent:true as NSObject,
//                        kSecAttrApplicationTag:"test".data(using: String.Encoding.utf8)! as NSObject,
//                        kSecClass: kSecClassKey, // added this value
//                        kSecReturnData: kCFBooleanTrue] // added this value
//            let privateKeyAttr: [NSObject: NSObject] = [
//                        kSecAttrIsPermanent:true as NSObject,
//                        kSecAttrApplicationTag:"test".data(using: String.Encoding.utf8)! as NSObject,
//                        kSecClass: kSecClassKey, // added this value
//                        kSecReturnData: kCFBooleanTrue] // added this value
//
//            
//            var keyPairAttr = [NSObject: NSObject]()
//            keyPairAttr[kSecAttrKeyType] = kSecAttrKeyTypeRSA
//            keyPairAttr[kSecAttrKeySizeInBits] = 2048 as NSObject
//            keyPairAttr[kSecPublicKeyAttrs] = publicKeyAttr as NSObject
//            keyPairAttr[kSecPrivateKeyAttrs] = privateKeyAttr as NSObject
//
//            statusCode = SecKeyGeneratePair(keyPairAttr as CFDictionary, &publicKey, &privateKey)
//
//            if statusCode == noErr && publicKey != nil && privateKey != nil {
//                print("Key pair generated OK")
//                var resultPublicKey: AnyObject?
//                var resultPrivateKey: AnyObject?
//                let statusPublicKey = SecItemCopyMatching(publicKeyAttr as CFDictionary, &resultPublicKey)
//                let statusPrivateKey = SecItemCopyMatching(privateKeyAttr as CFDictionary, &resultPrivateKey)
//
//                if statusPublicKey == noErr {
//                    if let publicKey = resultPublicKey as? Data {
//                        print("Public Key: \((publicKey.base64EncodedString()))")
//                    }
//                }
//
//                if statusPrivateKey == noErr {
//                    if let privateKey = resultPrivateKey as? Data {
//                        print("Private Key: \((privateKey.base64EncodedString()))")
//                    }
//                }
//            } else {
//                print("Error generating key pair: \(String(describing: statusCode))")
//            }
        }
    }
    var filteredData = [OperationsDetails]() {
        didSet{
//            filteredData = operationList.data
        }
    }
    
//    @IBOutlet weak var searchBar: UISearchBar!
    
//    @IBOutlet weak var foraPreloader: RefreshView!
    
    override func viewWillDisappear(_ animated: Bool) {
        tableView.reloadData()
    }
//    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
//        print(searchBar.text)
//        self.operationList.data = operationList.data?.filter({($0.name?.lowercased().hasPrefix((searchBar.text?.lowercased())!) ?? true)})
////        self.operationList.data = operationList.data?.filter({($0.operators.nameList)})
//        self.collectionView.reloadData()
//        return true
//    }
//
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.searchBar.endEditing(true)
        searchBar?.tintColor = .black
        searchBar.backgroundImage = UIImage()
        collectionViewLabel.isHidden = true
        collectionView.isHidden = true
        tableView.backgroundColor = .white
        
//        foraPreloader.imgVLogo?.image = UIImage(named: "foralogotype")
        activityIndicator.isHidden = true
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
        
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 10, right: 0)
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.showsHorizontalScrollIndicator = false
        tableView.layoutIfNeeded()
        self.tableView.rowHeight = UITableView.automaticDimension;
        self.indicatorBegin()
        activityIndicator.isHidden = false
        activityIndicator.startAnimation()
        
//        searchBar.delegate = self
        
//        tableView.rowHeight = UITableView.automaticDimension
        NetworkManager.shared().getOperationService { (success, operationList, stringName) in
            if operationList?.result != "ERROR"{
                var operationListNonFilter = operationList
                operationListNonFilter?.data = operationList?.data?.filter({$0.operators?.count != 0})
                          self.operationList = operationListNonFilter!
//                self.operationList.data? = self.operationList.data?.filter({$0.operators?.count != 0}) ?? []

                      }  else {
                        let alert = UIAlertController(title: "Ошибка", message: "\(stringName!)", preferredStyle: UIAlertController.Style.alert)
                  alert.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.default, handler: nil))
                  self.present(alert, animated: true, completion: nil)
            }
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.tableView.reloadData()
            self.collectionView.reloadData()
            
            }
        
        let cellNib = UINib(nibName: "OperationListTableViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "tableviewcellid")
        
        let itemNib = UINib(nibName: "OperationsListCollectionViewCell", bundle: nil)
        self.collectionView.register(itemNib, forCellWithReuseIdentifier: "OperationPreviewCell")
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OperationPreviewCell", for: indexPath) as? OperationsListCollectionViewCell else { return UICollectionViewCell() }
        switch indexPath.item {
                case 0:
                    cell.image?.image = UIImage(named: "cardscolor")
                    cell.label?.text = "Между своими счетами"
                    break
                case 1:
                    cell.image?.image = UIImage(named: "towncolor")
                    cell.label?.text = "Клиенту Фора-Банка"
                    break
                case 3:
                    cell.image?.image = UIImage(named: "freecolor")
                    cell.label?.text = "Переводы ЮЛ/ИП"
                    break
                case 2:
                    cell.image?.image = UIImage(named: "sbp-logo")
                    cell.label?.text = "По номеру телефона(СБП)"
                    break
                default:
                    break
                }
        cell.contentView.layer.cornerRadius = 10.0
        cell.contentView.layer.masksToBounds = true

        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 3, height: 3)//CGSizeMake(0, 2.0);
        cell.layer.shadowRadius = 3.0
        cell.layer.shadowOpacity = 0.4
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
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
                guard let operationsDetails = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "operationDetail") as? OperationDetailViewController else {
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
            operationsDetails.sourceConfigurations = [
                         PaymentOptionsPagerItem(provider: sourceProvider, delegate: operationsDetails)
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
//                case 2:
//                    paymentDetailsVC.destinationConfigurations = [
//                        PhoneNumberPagerItem(provider: destinationProviderPhoneNumber, delegate: paymentDetailsVC)
//                    ]
//                    break
                case 3:

                    freeDetailsVC.sourceConfigurations = [
                    PaymentOptionsPagerItem(provider: sourceProvider, delegate: freeDetailsVC)
                        
                    ]
                    
                    let rootVC = tableView.parentContainerViewController()
                    rootVC?.present(freeDetailsVC, animated: true, completion: nil)
                    //    let freeViewController = self.storyboard?.instantiateViewController(withIdentifier: "FreeDetailsController")
                    //            self.present(freeViewController!, animated: true)
                    break
                    case 2:
                        SBPVC.destinationConfigurations = [
                            PhoneNumberPagerItem(provider: destinationProviderPhoneNumber, delegate: SBPVC)
                        ]
                        let rootVC = tableView.parentContainerViewController()
                                 rootVC?.present(SBPVC, animated: true, completion: nil)
                        break
                case 4:
                    operationsDetails.destinationConfigurations = [
                        PhoneNumberPagerItem(provider: destinationProviderPhoneNumber, delegate: operationsDetails)
                    ]
                    let rootVC = tableView.parentContainerViewController()
                            rootVC?.present(operationsDetails, animated: true, completion: nil)
                    break

                default:
                    break
                }

                let rootVC = tableView.parentContainerViewController()
                rootVC?.present(paymentDetailsVC, animated: true, completion: nil)
            }
    
  
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)

    }
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.endEditing(true)
//
//    }
//    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
//        searchBar.endEditing(true)
//        return true
//
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 0)
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
//      {
//         return CGSize(width: 150 , height: 150)
//      }
    
    
}


extension ServiceListViewController: UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        if searching {
//            return filteredData.count/4
//        } else {
     return 1
//        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == staticOpertionsTableView {
            return 1
        } else if searching{
            return 1
        }else{
            let groupsOperations = operationList.data
            let operationsDontEmpty =  groupsOperations?.filter {$0.name != "СБП" && $0.details.parentCode == nil}
        return operationsDontEmpty?.count ?? 0
        }
     }
    
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          return 150
       }
//
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "tableviewcellid", for: indexPath) as? OperationListTableViewCell else { return UITableViewCell()}
        
        if tableView == staticOpertionsTableView{
            cell.headerLabel.text = "Платежи и переводы"
//            cell.updateCellWith(row: <#T##[Datum]#>)
        } else if searching{
            cell.headerLabel.text = "Поиск"
            let filterSortData = filteredData.filter({$0.parameterList?.count != 0 })
            cell.updateCellWithFilter(row: filterSortData)
//            self.tableView.reloadData()
            }
            else {
            let groupsOperations =  operationList.data?.filter{$0.name != "СБП" && $0.details.parentCode == nil}
                 cell.headerLabel.text = groupsOperations?[indexPath.row].name
                guard let product = groupsOperations?[indexPath.row] else { return UITableViewCell() }
                let notGroupProduct = [product].filter{$0.details.parentCode == nil}
                cell.updateCellWith(row: notGroupProduct)
        }
      
        return cell
     }
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        guard !searchText.isEmpty  else { return }
//        if searchText != ""{
//        self.operationList.data = operationList.data?.filter {$0.details.nameList?[0].value == searchText}
//        tableView.reloadData()
//        } else {
//            self.operationList.data = operationList.data
//            tableView.reloadData()
//        }
//
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.view.endEditing(true)
        self.searchBar.endEditing(true)
        if title == "Отправка адресного перевода"{
            guard let operationsDetails = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "ContactViewController") as? ContactViewController else {
                       return
                   }
            let sourceProvider = PaymentOptionCellProvider()
            operationsDetails.sourceConfigurations = [
                         PaymentOptionsPagerItem(provider: sourceProvider, delegate: operationsDetails)
                     ]

        } else {
            guard let operationsDetails = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "operationDetail") as? OperationDetailViewController else {
                       return
                   }
            let sourceProvider = PaymentOptionCellProvider()
            operationsDetails.sourceConfigurations = [
                         PaymentOptionsPagerItem(provider: sourceProvider, delegate: operationsDetails)
                     ]
    }

    }
    
}

extension ServiceListViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.searching = false
            self.filteredData.removeAll()
            NetworkManager.shared().getOperationService { (success, operationList, stringName) in
                if operationList?.result != "ERROR"{
                    var operationListNonFilter = operationList
                    operationListNonFilter?.data = operationList?.data?.filter({$0.operators?.count != 0})
                              self.operationList = operationListNonFilter!
                    self.searching = false
    //                self.operationList.data? = self.operationList.data?.filter({$0.operators?.count != 0}) ?? []

                          }  else {
                            let alert = UIAlertController(title: "Ошибка", message: "\(stringName!)", preferredStyle: UIAlertController.Style.alert)
                      alert.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.default, handler: nil))
                      self.present(alert, animated: true, completion: nil)
                }
                self.searching = false

                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.tableView.reloadData()
                self.collectionView.reloadData()
                }
        } else {
        NetworkManager.shared().getOperationService { (success, operationList, stringName) in
            if operationList?.result != "ERROR"{
                var operationListNonFilter = operationList
                operationListNonFilter?.data = operationList?.data?.filter({$0.operators?.count != 0})
                          self.operationList = operationListNonFilter!
//                self.operationList.data? = self.operationList.data?.filter({$0.operators?.count != 0}) ?? []

                      }  else {
                        let alert = UIAlertController(title: "Ошибка", message: "\(stringName!)", preferredStyle: UIAlertController.Style.alert)
                  alert.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.default, handler: nil))
                  self.present(alert, animated: true, completion: nil)
            }
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.tableView.reloadData()
            self.collectionView.reloadData()
            
            }
//        print(searchBar.text)
//        let operatorData = self.operationList.data
//        self.operationList.data = self.operationList.data?.filter({($0?.lowercased().hasPrefix((searchBar.text?.lowercased())!) ?? true)})
//        self.operationList.data =  self.operationList.data?.filter({ (datum) -> Bool in
////            let countDatum = datum.operators?.count
////            datum.operators = datum.operators?.filter({($0.nameList?[0].value?.lowercased().hasPrefix((searchBar.text?.lowercased())!) ?? true)})
////            print(filterDatum)
//            return true
//        })
//        self.operationList.data = operationList.data?.filter({($0.operators.nameList)})
        self.filteredData.removeAll()
        guard let operationUnwrapped = operationList.data else {
            return
        }
//        operationList.data?.filter({ (datum) -> Bool in
//             datum.name?.filter({$0.lowercased().hasPrefix(searchText.lowercased()) ?? true})
//            var filteredOperator = datum.operators?.filter({ (operationDetails) -> Bool in
//                let filterDatas = operationDetails.nameList?[0].value?.lowercased().hasPrefix(searchText.lowercased()) ?? true
//                return true
//            })
//            self.filteredData = filteredOperator
        var filteredDataList = [OperationsDetails]()
            for i in operationUnwrapped{
//                print(i.operators)
                guard let operatorList = i.operators else {
                    return
                }
                for a in operatorList {
                    filteredDataList.append(a)
                    self.filteredData.append(a)
                }
            }
        
        
        self.filteredData = filteredData.filter({$0.nameList?[0].value?.lowercased().hasPrefix(searchText.lowercased()) ?? true})
            //            let countFilterd = filteredOperator?.count
            //            self.filteredData?[0].operators = filteredDatum
//            return true
//        })
        searching = true
        self.tableView.reloadData()
        }
    }
    
}
