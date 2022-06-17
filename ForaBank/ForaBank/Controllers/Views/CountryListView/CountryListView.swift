//
//  CountryListView.swift
//  ForaBank
//
//  Created by Mikhail on 20.07.2021.
//

import UIKit

class CountryListView: UIView {
        
    //MARK: - Property
    let reuseIdentifier = "CountryListCell"
    
    var countryList = [CountriesList]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    var didCountryTapped: ((CountriesList) -> Void)?
    var openAllCountryTapped: (() -> Void)?
    
    let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    
    //MARK: - Viewlifecicle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        self.anchor(width: UIScreen.main.bounds.width, height: 100)
        setupCollectionView()
        isHidden = true
        alpha = 0
        
        let countries = Model.shared.countriesList.value.map { $0.getCountriesList() }
        self.configureVC(with: countries)
    }
    
    //MARK: - Helpers
    private func configureVC(with countries: [CountriesList]) {
        for country in countries {
            if !(country.paymentSystemCodeList?.isEmpty ?? true) {
                self.countryList.append(country)
            }
        }
    }
    private func setupCollectionView() {
        addSubview(collectionView)
        collectionView.anchor(top: self.topAnchor, left: self.leftAnchor,
                              bottom: self.bottomAnchor, right: self.rightAnchor)
        
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CountryListCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        let separatorView = UIView()
        separatorView.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.968627451, alpha: 1)
        addSubview(separatorView)
        separatorView.anchor(left: self.leftAnchor, bottom: self.bottomAnchor,
                             right: self.rightAnchor, height: 2)
    }
    
}

//MARK: - CollectionView DataSource
extension CountryListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return countryList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CountryListCell
        if indexPath.item == 0 {
            cell.countryImageView.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.968627451, alpha: 1)
            cell.countryImageView.image = UIImage(named: "more-horizontal")
            cell.countryNameLabel.text = "См. все"
        } else {
            cell.country = countryList[indexPath.item - 1]
        }
        return cell
    }
    
}

//MARK: - CollectionView FlowLayout
extension CountryListView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 76, height: 96)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
    }
    
}

//MARK: - CollectionView Delegate
extension CountryListView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            openAllCountryTapped?()
        } else {
            let country = countryList[indexPath.item - 1]
            didCountryTapped?(country)
        }
    }
}
