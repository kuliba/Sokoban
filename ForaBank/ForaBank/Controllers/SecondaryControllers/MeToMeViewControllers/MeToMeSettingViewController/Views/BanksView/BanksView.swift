//
//  BanksView.swift
//  ForaBank
//
//  Created by Mikhail on 20.09.2021.
//

import UIKit

class BanksView: UIView {
    
    //MARK: - Property
    let kContentXibName = "BanksView"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet var labelArray: [UILabel]!
    
    var banksName: [String]? {
        didSet {
            guard banksName != nil else { return }
            collectionView.reloadData()
        }
    }
    var consentList: [ConsentList]? {
        didSet {
            guard let list = consentList else { return }
            setupList(consentList: list)
        }
    }
    
    @IBOutlet var contentView: UIView!
    
    var didChooseButtonTapped: (() -> Void)?
    
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
        Bundle.main.loadNibNamed(kContentXibName, owner: self, options: nil)
        contentView.fixInView(self)
        self.anchor(height: 130)
        
        let layout = LeftAlignedCollectionViewFlowLayout()
                
        layout.scrollDirection = .vertical
        
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.collectionViewLayout = layout
        
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "BanksCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: BanksCollectionViewCell.refCell)
        
    }
    
    private func setupList(consentList: [ConsentList]) {
        
        DispatchQueue.main.async {
            let allBanks = Model.shared.dictionaryFullBankInfoList()
            
            var banks: [String] = []
            
            consentList.forEach { bank in
                allBanks?.forEach({ fullBank in
                    let fullBankItem = fullBank.fullBankInfoList
                    if fullBankItem.memberID == bank.bankId {
                        banks.append(fullBankItem.rusName ?? "")
                    }
                })
            }
            
            self.banksName = banks
        }
    }
    
    @IBAction private func chooseButtonTapped(_ sender: Any) {
        didChooseButtonTapped?()
    }
    
    
}

extension BanksView: UICollectionViewDelegate,
                     UICollectionViewDataSource,
                     UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return banksName?.count ?? 0
        }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        let cell = collectionView
                    .dequeueReusableCell(withReuseIdentifier: BanksCollectionViewCell.refCell,
                                         for: indexPath)
                    
        if let bankCell = cell as? BanksCollectionViewCell {
                    
            bankCell.configure(with: banksName?[indexPath.item], and: indexPath)
        }
                    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let count = banksName?[indexPath.item].count ?? 0
        return CGSize(width:  count > 22
                      ? 230 : count * 11, height: 32)
    }
    
    class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {

        override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            let attributes = super.layoutAttributesForElements(in: rect)?.map { $0.copy() as! UICollectionViewLayoutAttributes }

            var leftMargin = sectionInset.left
            var maxY: CGFloat = -1.0
            
            attributes?.forEach { layoutAttribute in
                guard layoutAttribute.representedElementCategory == .cell
                else { return }

                if Int(layoutAttribute.frame.origin.y) >= Int(maxY)
                    || layoutAttribute.frame.origin.x == sectionInset.left {
                        leftMargin = sectionInset.left
                }

                if layoutAttribute.frame.origin.x == sectionInset.left {
                    leftMargin = sectionInset.left
                }
                else { layoutAttribute.frame.origin.x = leftMargin
                }

                leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
                maxY = max(layoutAttribute.frame.maxY , maxY)
            }

            return attributes
        }
    }
    
}
