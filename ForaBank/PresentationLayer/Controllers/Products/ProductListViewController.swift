//
//  ProductListViewController.swift
//  ForaBank
//
//  Created by Бойко Владимир on 19.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class ProductListViewController: BaseViewController {

    @IBOutlet weak var collectionViewProducts: UICollectionView!
    
    let arrayProducts = [ProductType.card, ProductType.account, ProductType.deposit, ProductType.loan]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        // Do any additional setup after loading the view.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }

}


extension ProductListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    private func setupCollectionView(){
                
        collectionViewProducts.isPagingEnabled = true
        
        collectionViewProducts.backgroundColor = .clear
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        self.collectionViewProducts?.collectionViewLayout = layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let heightItem = collectionView.frame.size.height * 0.7
        let widthItem = collectionView.frame.size.width * 0.7
        return CGSize(width: widthItem, height: heightItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeInsets = (UIScreen.main.bounds.size.width - (CGFloat(arrayProducts.count) * 50) - (CGFloat(arrayProducts.count) * 10)) / 2
        return UIEdgeInsets(top: 0, left: edgeInsets, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionViewProducts.dequeueReusableCell(withReuseIdentifier: "ItemProductsList", for: indexPath) as? ItemProduct else {return UICollectionViewCell()}
        
        item.imageProduct.image = UIImage(named: arrayProducts[indexPath.item].coloredImageName)
        item.nameProduct.text = arrayProducts[indexPath.item].localizedName
        item.commentProduct.text = arrayProducts[indexPath.item].commentProduct
        
        item.setNeedsLayout()
        return item
    }
    
    
}

//extension ProductListViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return products.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell()
//        cell.backgroundColor = .white
//        cell.selectionStyle = .none
//        cell.textLabel?.text = products[indexPath.item].localizedName
//        cell.imageView?.image = UIImage(named: products[indexPath.item].coloredImageName)
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let product = products[indexPath.item]
//
//        switch product {
//        case .card:
//            guard let url = URL(string: "https://cashback-card.forabank.ru/?metka=mp") else { return }
//            UIApplication.shared.open(url)
//            break
//        default:
//            break
//        }
//    }
//}
