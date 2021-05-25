//
//  AboutAppViewController.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 07.07.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class AboutAppViewController: UIViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var collectionViewLinks: UICollectionView!
    
    var arrays: [Service] = [Service(name: "Условия пользования", description: "https://www.forabank.ru/dkbo/dkbo.pdf", iconName: "terms", isPartner: nil),  Service(name: "Последнее обновление", description: "https://www.forabank.ru", iconName: "version", isPartner: nil)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        collectionViewLinks.backgroundColor = .red
        collectionViewLinks.register(UINib(nibName: "ButtonCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ButtonCollectionViewCell")
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
        guard let unwrappedVersion = nsObject else {
            return
        }
        versionLabel.text = "Версия \(unwrappedVersion)"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension AboutAppViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrays.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item  = collectionViewLinks.dequeueReusableCell(withReuseIdentifier: "ButtonCollectionViewCell", for: indexPath) as? ButtonCollectionViewCell
        item?.title.text = arrays[indexPath.item].name
        item?.image.image = UIImage(named: "\(arrays[indexPath.item].iconName ?? "")")
        return item!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionViewLinks.bounds.width, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            let vc =  storyboard?.instantiateViewController(withIdentifier: "WebAboutAppViewController") as! WebAboutAppViewController
                  vc.urlString = arrays[indexPath.item].description!
                  present(vc, animated: true, completion: nil)
        default:
                let vc =  storyboard?.instantiateViewController(withIdentifier: "NewVersionViewController") as! NewVersionViewController
                present(vc, animated: true, completion: nil)
        }
     
    }
    
 
    
    
}
