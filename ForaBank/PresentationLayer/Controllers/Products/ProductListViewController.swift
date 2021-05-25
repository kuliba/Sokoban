//
//  ProductListViewController.swift
//  ForaBank
//
//  Created by Бойко Владимир on 19.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class ProductListViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    let arrayProducts = [ProductType.deposit, ProductType.loan, ProductType.card, ProductType.account]
    
    @IBOutlet weak var collectionViewProducts: UICollectionView!
    @IBOutlet weak var buttonOpenProduct: UIButton!
    @IBOutlet weak var pageView: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        // Do any additional setup after loading the view.
        self.pageView.numberOfPages = arrayProducts.count
        self.pageView.currentPage = 0
    }

    //MARK: Action
    @IBAction func openBrower(_ sender: UIButton) {
        guard let indexPathItemCenter = getIndexPathCenterColView() else {return}
        let productSelect = arrayProducts[indexPathItemCenter.row] //вытаскиваем нужных продукт
        guard let url = Foundation.URL(string: productSelect.urlProduct) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Collection View
extension ProductListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    private func setupCollectionView(){
        let sizeItem = CGSize(width: collectionViewProducts.frame.size.width*0.7, height: collectionViewProducts.frame.size.height) //размер ячейки
        let spacing = collectionViewProducts.frame.size.width*0.15 //расстояние между ячейками
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
        
        if arrayProducts[indexPath.item] == .account{
            let commentProduct = arrayProducts[indexPath.item].commentProduct //получаем полную строку
            let commentProductIndexString = commentProduct.components(separatedBy: " ") //разделяем ее по словам
            let fullComment = NSMutableAttributedString(string: "") //создаем переменную полного комента с атрибутами
            //строка для подчеркивания
            let stringCommentSingleStr = commentProductIndexString[commentProductIndexString.count-2] + " " + commentProductIndexString[commentProductIndexString.count - 1]
            let commentProductNoSingle = commentProduct.replacingOccurrences(of: stringCommentSingleStr, with: "") //удаляем строку для подчеркивания из коммента
            fullComment.append(NSAttributedString(string: commentProductNoSingle)) //добавляем стороку (без подчеткивания) в каммента с атрибутами
            let commentProductSingle = NSAttributedString(string: stringCommentSingleStr, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])//подчеркиваем строку
            fullComment.append(commentProductSingle) //добавляем в общий комментарий
            item.commentProduct.attributedText = fullComment
        }else{
            item.commentProduct.text = arrayProducts[indexPath.item].commentProduct
        }
        item.setNeedsLayout()
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if arrayProducts[indexPath.row] == .account{
            guard let servicesVC = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "ServiceViewController") as? ServicesViewController else {
                print("Не удалось получить доступ к ServicesViewController")
                return
            }
            servicesVC.modalPresentationStyle = .fullScreen
            let rootVC = collectionView.parentContainerViewController()
            rootVC?.present(servicesVC, animated: true, completion: {
                servicesVC.buttonBack.isHidden = false
            })
        }
    }
    
    //MARK: Helpers func CV
    //получаем индекс элемента по координатам view
    private func indexPathForCellContaining( view: UIView) -> IndexPath? {
        let viewCenter = collectionViewProducts.convert(view.center, from: view.superview)
        return collectionViewProducts.indexPathForItem(at: viewCenter)
    }
    
    //функция возвращает индекс ячейки по центру collectionViewProducts
    private func getIndexPathCenterColView()->IndexPath?{
        let visibleRect = CGRect(origin: self.collectionViewProducts.contentOffset, size: self.collectionViewProducts.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = self.collectionViewProducts.indexPathForItem(at: visiblePoint) {
            return visibleIndexPath
        }
        return nil
    }
}

//MARK: - Scroll view
extension ProductListViewController{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let indexPathItemCenter = getIndexPathCenterColView() else {return}
        self.pageView.currentPage = indexPathItemCenter.row
        if arrayProducts[indexPathItemCenter.row] == .account{
            buttonOpenProduct.isHidden = true
        }else{
            buttonOpenProduct.isHidden = false
        }
    }
}


