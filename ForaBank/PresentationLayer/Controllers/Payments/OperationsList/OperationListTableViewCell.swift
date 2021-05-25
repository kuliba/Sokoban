//
//  OperationListTableViewCell.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 17.09.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

protocol CollectionViewCellDelegate: class {
    func collectionView(collectionviewcell: OperationsListCollectionViewCell?, index: Int, didTappedInTableViewCell: OperationListTableViewCell)
    // other delegate methods that you can define to perform action in viewcontroller
}

class OperationListTableViewCell: UITableViewCell {
    
    
    let sourceProvider = PaymentOptionCellProvider()
    let destinationProvider = PaymentOptionCellProvider()
    let destinationProviderCardNumber = CardNumberCellProvider()
    let destinationProviderAccountNumber = AccountNumberCellProvider()
    let destinationProviderPhoneNumber = PhoneNumberCellProvider()
    
    var productCell:[Datum] = []
    var productCellFilter: [OperationsDetails] = []
    weak var cellDelegate: CollectionViewCellDelegate?
    
    @IBOutlet weak var yetListButton: UIButton!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var headerLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
              let flowLayout = UICollectionViewFlowLayout()
              flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
     
          collectionView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 10, right: 0)
              self.collectionView.collectionViewLayout = flowLayout
              self.collectionView.showsHorizontalScrollIndicator = false
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
             
             // Register the xib for collection view cell
             let cellNib = UINib(nibName: "OperationsListCollectionViewCell", bundle: nil)
             self.collectionView.register(cellNib, forCellWithReuseIdentifier: "OperationPreviewCell")
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension OperationListTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    

    func updateCellWith(row: [Datum]) {
        productCellFilter.removeAll()
        self.productCell = row
        self.productCell = productCell.filter{$0.details.parentCode == nil}
        self.collectionView.reloadData()
       }
    func updateCellWithFilter(row: [OperationsDetails]) {
        productCell.removeAll()
        self.productCellFilter = row
//        self.productCellFilter = productCellFilter.filter{$0.parentCode == nil}
        self.collectionView.reloadData()
       }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
//        if productCell[section].operators?.count ?? 0 < 4{
//            yetListButton.isHidden = true
//        }
        if section == 1{
            return 4
        } else if productCellFilter.count != 0{
            return productCellFilter.count
        } else  {
            return productCell[section].operators?.count ?? 00
            }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
         if productCellFilter.count == 0{
            return productCell.count
         } else if productCellFilter.count != 0{
            return 1
         } else {
            return 0
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
    
    // Set the data for each cell (color and color name)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OperationPreviewCell", for: indexPath) as? OperationsListCollectionViewCell {
            
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
            
            if productCellFilter.count == 0, productCell[indexPath.section].operators?.count ?? 0 < 4{
                yetListButton.isHidden = true
            }
            if productCellFilter.count > 0{
                cell.label.text = productCellFilter[indexPath.item].nameList?[0].value
                yetListButton.isHidden = true

            } else {
                cell.label.text = productCell[indexPath.section].operators?[indexPath.row].nameList?[0].value

            }
            if productCellFilter.count == 0, productCell[indexPath.section].operators?[indexPath.row].logotypeList?.isEmpty ?? false {
                cell.image.image = UIImage(named: "feed_current_turn_logo")

                
            } else if productCellFilter.count != 0{
//                cell.image.image = UIImage(named: "feed_current_turn_logo")
                if productCellFilter[indexPath.item].logotypeList?.isEmpty ?? false {
                    cell.image.image = UIImage(named: "feed_current_turn_logo")


//                cell.image.image = UIImage(named: "feed_current_turn_logo")
                } else {
//                    cell.image.image = UIImage(named: "feed_current_turn_logo")
                    guard  let imageHeader = productCellFilter[indexPath.section].logotypeList?[0].content else { return UICollectionViewCell.init() }
                    let imageTry = base64Convert(base64String: imageHeader)
                    cell.image.image = UIImage(data: imageTry.pngData()!)
                }
            } else {
                guard  let imageHeader = productCell[indexPath.section].operators?[indexPath.row].logotypeList?[0].content else { return UICollectionViewCell() }
                let imageTry = base64Convert(base64String: imageHeader)
                cell.image.image = UIImage(data: imageTry.pngData()!)

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
        return UICollectionViewCell()
    }
    
    // Add spaces at the beginning and the end of the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }
    
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
        if productCell[0].operators?[indexPath.item].nameList?[0].value == "Отправка безадресного перевода" || productCell[0].operators?[indexPath.item].nameList?[0].value ==  "Отправка адресного перевода" {
            
               guard let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "ContactViewController") as? ContactViewController else {
                          return
                      }
            vc.headerTitleText = productCell[0].operators?[indexPath.item].nameList?[0].value
            vc.puref = productCell[0].operators?[indexPath.item].code
            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
        } else if productCell[0].operators?[indexPath.item].nameList?[0].value == "Перевод в IDBank по счету" || productCell[0].operators?[indexPath.item].nameList?[0].value == "Перевод в IDBank по карте" || productCell[0].operators?[indexPath.item].nameList?[0].value == "Перевод в IDBank по телефону" ||
                    productCell[0].operators?[indexPath.item].nameList?[0].value == "Перевод в АйДиБанк 11 карта" {
            guard let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetailsViewController") as? PaymentsDetailsViewController else {
                       return
                   }
            vc.textLabelValue = productCell[0].operators?[indexPath.item].nameList?[0].value
            vc.segueId = "ServiceListViewController"
            vc.messageRecipientIsHidden = true
            let sourceProvider = PaymentOptionCellProvider()
            
            let destinationProviderCardNumber = CardNumberCellProvider()
            
            vc.sourceConfigurations = [
                PaymentOptionsPagerItem(provider: sourceProvider, delegate: vc)
            ]
            vc.destinationConfigurations = [
                CardNumberPagerItem(provider: destinationProviderCardNumber, delegate: vc)
                
            ]
//         vc.headerTitleText = productCell[0].operators?[indexPath.item].nameList?[0].value
         vc.puref = productCell[0].operators?[indexPath.item].code
         UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
            
        } else if productCell[0].operators?[indexPath.item].nameList?[0].value == "Перевод в АйДиБанк 11 счет" {
            guard let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetailsViewController") as? PaymentsDetailsViewController else {
                       return
                   }
            vc.textLabelValue = productCell[0].operators?[indexPath.item].nameList?[0].value
            vc.segueId = "ServiceListViewController"
            vc.messageRecipientIsHidden = true
            let sourceProvider = PaymentOptionCellProvider()
            
            let destinationProviderAccountNumber = AccountNumberCellProvider()
            
            vc.sourceConfigurations = [
                PaymentOptionsPagerItem(provider: sourceProvider, delegate: vc)
            ]
            vc.destinationConfigurations = [
                AccountNumberPagerItem(provider: destinationProviderAccountNumber, delegate: vc)
                
            ]
//         vc.headerTitleText = productCell[0].operators?[indexPath.item].nameList?[0].value
         vc.puref = productCell[0].operators?[indexPath.item].code
         UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
        } else if productCell[0].operators?[indexPath.item].nameList?[0].value == "Перевод в АйДиБанк 11 телефон" {
            guard let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetailsViewController") as? PaymentsDetailsViewController else {
                       return
                   }
            vc.textLabelValue = productCell[0].operators?[indexPath.item].nameList?[0].value
            vc.segueId = "ServiceListViewController"
            vc.messageRecipientIsHidden = true
            let sourceProvider = PaymentOptionCellProvider()
            
            let destinationProviderAccountNumber = AccountNumberCellProvider()
            
            vc.sourceConfigurations = [
                PaymentOptionsPagerItem(provider: sourceProvider, delegate: vc)
            ]
            vc.destinationConfigurations = [
                PhoneNumberPagerItem(provider: destinationProviderPhoneNumber, delegate: vc)
                
            ]
//         vc.headerTitleText = productCell[0].operators?[indexPath.item].nameList?[0].value
         vc.puref = productCell[0].operators?[indexPath.item].code
         UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
        } else {
               guard let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "operationDetail") as? OperationDetailViewController else {
                          return
                      }
            
       
//        guard let operatorDetailFilter =  productCellFilter[indexPath.item] else {
//                return
//            }
        if productCellFilter.isEmpty, productCell[indexPath.section].operators?[indexPath.row].logotypeList?.isEmpty ?? false {
         
            print("Don't image")

        } else if productCellFilter.isEmpty {
            guard  let imageHeader = productCell[indexPath.section].operators?[indexPath.row].logotypeList?[0].content else { return }
            let imageTry = base64Convert(base64String: imageHeader)
            vc.image = imageTry

        }
        if productCellFilter.count == 0 {
            guard let operatorDetail =  productCell[0].operators?[indexPath.item] else {
                    return
                }
            vc.operationList  = operatorDetail
        } else {
            vc.operationList  = productCellFilter[indexPath.row]
            if productCellFilter[indexPath.item].logotypeList?.isEmpty ?? false {
//                vc.image = UIImage(named: "feed_current_turn_logo")


//                cell.image.image = UIImage(named: "feed_current_turn_logo")
            } else {
//                    cell.image.image = UIImage(named: "feed_current_turn_logo")
                guard  let imageHeader = productCellFilter[indexPath.section].logotypeList?[0].content else { return }
                let imageTry = base64Convert(base64String: imageHeader)
                vc.image = UIImage(data: imageTry.pngData()!)
            }
        }
            
    
        
            let sourceProvider = PaymentOptionCellProvider()

                vc.sourceConfigurations? =  [ PaymentOptionsPagerItem(provider: sourceProvider, delegate: vc) ]
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)


            print("is not Group")
//        }
         let cell = collectionView.cellForItem(at: indexPath) as? OperationsListCollectionViewCell
         self.cellDelegate?.collectionView(collectionviewcell: cell, index: indexPath.item, didTappedInTableViewCell: self)
        
    }
        
//        AlertService.shared.show(title: "Сервис временно не доступен", message: "Повторите позже", cancelButtonTitle: "Отмена", okButtonTitle: "ОК", cancelCompletion: nil, okCompletion: nil)
     }
    
    
    @IBAction func sendToListOperations(_ sender: UIButton) {
                  let storyboard = UIStoryboard(name: "Payment", bundle: nil)
                              guard let vc = storyboard.instantiateViewController(withIdentifier: "ListOperationViewController") as? ListOperationViewController else { return  }
                      //        vc.titleLabel.text = operationList.data?[selectedHeaderIndex].name ?? "2"
                      vc.titleText = "Выберите услугу"
        var productsCellsOperators: [OperationsDetails]?
        if productCellFilter.count > 0{
            productsCellsOperators = productCellFilter
        } else {
            productsCellsOperators = productCell[0].operators
        }
                      guard let operationDetails = productsCellsOperators else {
                          return
                      }
                      vc.operationList = operationDetails
        
                      UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
        
        
    }
}

