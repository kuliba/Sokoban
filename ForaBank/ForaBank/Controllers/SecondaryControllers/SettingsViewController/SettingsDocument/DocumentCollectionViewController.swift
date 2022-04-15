//
//  DocumentCollectionViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.04.2022.
//

import UIKit

class DocumentCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var data = [DocumentSettingModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSpinningWheel(_:)), name: NSNotification.Name(rawValue: "settingDocument"), object: nil)
    }
    
    @objc func showSpinningWheel(_ notification: NSNotification) {

      if let key = notification.userInfo?["value"] as? [DocumentSettingModel] {
          data = key
      }
        self.collectionView.reloadData()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewID", for: indexPath) as! DocumentCollectionViewCell
        
        cell.addData(indexPath.row, data: data)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 132, height: 134)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 2 {
            let selectedItem = self.data[indexPath.row]
            let document = DocumentInfoModel(icon: selectedItem.icon, description: selectedItem.subtitle)
            let documentView = DocumentInfoView(model: document)
            let controller = DocumentInfoViewController(model: documentView)
            
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .custom
            navController.transitioningDelegate = self
            self.present(navController, animated: true)
        }
        
    }
}


extension DocumentCollectionViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        presenter.height = 400
        return presenter
    }
}
