//
//  ChooseCountryHeaderView.swift
//  ForaBank
//
//  Created by Mikhail on 19.07.2021.
//

import UIKit

class ChooseCountryHeaderView: UITableViewHeaderFooterView {

    let cellReuseIdentifier = "CountryHeaderCell"
    var didChooseCountryHeaderTapped: ((ChooseCountryHeaderViewModel) -> Void)?
    var lastPaymentsList = [GetPaymentCountriesDatum]()
    
    let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    
    //MARK: - Viewlifecicle
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        self.anchor(width: UIScreen.main.bounds.width, height: 100)
        setupCollectionView()
//        isHidden = true
//        alpha = 0
    }
    
    //MARK: - Helpers
    private func setupCollectionView() {
        addSubview(collectionView)
        collectionView.anchor(top: self.topAnchor, left: self.leftAnchor,
                              bottom: self.bottomAnchor, right: self.rightAnchor)
        
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ChooseCountryHeaderCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
    }
    
}

//MARK: - CollectionView DataSource
extension ChooseCountryHeaderView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return lastPaymentsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! ChooseCountryHeaderCell
        
        let model = ChooseCountryHeaderViewModel(model: lastPaymentsList[indexPath.item])
        cell.viewModel = model
        return cell
    }
    
}

//MARK: - CollectionView FlowLayout
extension ChooseCountryHeaderView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 80, height: 108)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 8)
    }
    
}

//MARK: - CollectionView Delegate
extension ChooseCountryHeaderView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath) as! ChooseCountryHeaderCell
        guard let model = cell.viewModel else { return }
        didChooseCountryHeaderTapped?(model)
//        print(cell.viewModel?.shortName)
        
//            if indexPath.item == 0 {
//                let card = bankList[indexPath.item]
//                didSeeAll?(card)
//            } else {
//                let card = bankList[indexPath.item]
//                didBankTapped?(card)
//            }
        
    }
}
