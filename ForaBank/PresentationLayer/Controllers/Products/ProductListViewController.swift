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
    
    let arrayProducts = [ProductType.deposit, ProductType.loan, ProductType.card, ProductType.account]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        // Do any additional setup after loading the view.
    }

    //MARK: Action
    @IBAction func openBrower(_ sender: UIButton) {
        guard let indexPathSelected = indexPathForCellContaining(view: sender) else {return} //получаем индекс ячейки на экране
        let productSelect = arrayProducts[indexPathSelected.row] //вытаскиваем нужных продукт
        guard let url = URL(string: productSelect.urlProduct) else { return }
        UIApplication.shared.open(url)
        
    }
    
    //получаем индекс элемента по координатам view
    private func indexPathForCellContaining( view: UIView) -> IndexPath? {
        let viewCenter = collectionViewProducts.convert(view.center, from: view.superview)
        return collectionViewProducts.indexPathForItem(at: viewCenter)
    }
}

// MARK: - Collection View
extension ProductListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    private func setupCollectionView(){
        let sizeItem = CGSize(width: collectionViewProducts.frame.size.width*0.8, height: collectionViewProducts.frame.size.height*0.8) //размер ячейки
        let spacing = collectionViewProducts.frame.size.width*0.125 //расстояние между ячейками
        let activeDistance = (collectionViewProducts.frame.size.width*0.8)/2 //дистанция анимации
        let flowLayout = ZoomAndSnapFlowLayout()
        flowLayout.setupFlowLayout(minimumLineSpacing: spacing, sizeItem: sizeItem, scrollDirection: .horizontal, activeDistance: activeDistance, zoomFactor: nil)
        collectionViewProducts.backgroundColor = .clear
        collectionViewProducts.collectionViewLayout = flowLayout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayProducts.count
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

