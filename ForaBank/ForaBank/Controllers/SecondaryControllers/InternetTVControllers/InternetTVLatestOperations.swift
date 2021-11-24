import Foundation
import UIKit
import RealmSwift

class InternetTVLatestOperationsView: UIView {

    private var latestOpCollectionView = InternetTVCollectionView()

    private var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureContents()
        if latestOpCollectionView.items.isEmpty {
            InternetTVMainController.latestOpIsEmpty = true
            InternetTVMainController.iMsg?.handleMsg(what: -1)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureContents() {
        latestOpCollectionView.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        addSubview(latestOpCollectionView)
        addSubview(lineView)
        NSLayoutConstraint.activate([
            latestOpCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            latestOpCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            latestOpCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            latestOpCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
//            caruselCollectionView.heightAnchor.constraint(equalToConstant: 200),
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])
        latestOpCollectionView.set(list: getData())
    }

    func getData() -> [InternetLatestOpsDO] {
        var resultArr = [InternetLatestOpsDO]()
        var amount = ""
        var name = ""
        var image: UIImage!

        let realm = try? Realm()
        let payModelArray = realm?.objects(InternetTVLatestOperationsModel.self)
        let operatorsArray = realm?.objects(GKHOperatorsModel.self)

        payModelArray?.forEach({ operation in
            operatorsArray?.forEach({ op in
                if operation.puref == op.puref {
                    name = op.name?.capitalizingFirstLetter() ?? ""
                    amount = String(operation.amount) + " ₽"
                    if let tempImage = op.logotypeList.first?.content, tempImage != "" {
                        let dataDecoded: Data = Data(base64Encoded: tempImage, options: .ignoreUnknownCharacters)!
                        image = UIImage(data: dataDecoded)
                    }
                }
            })
            if image != nil {
                let ob = InternetLatestOpsDO(mainImage: image, name: name, amount: amount)
                resultArr.append(ob)
            }
        })
        return resultArr
    }
}

struct InternetLatestOpsDO {
    var mainImage: UIImage
    var name: String
    var amount: String
}

struct InternetTVConstants {
    static let leftDistanceToView: CGFloat = 20
    static let rightDistanceToView: CGFloat = 20
    static let galleryMinimumLineSpacing: CGFloat = 10
    static let galleryItemWidth = (UIScreen.main.bounds.width - GKHConstants.leftDistanceToView - GKHConstants.rightDistanceToView - (GKHConstants.galleryMinimumLineSpacing / 2)) / 2
}

class InternetTVCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var items = [InternetLatestOpsDO]()

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)

        backgroundColor = .clear
        delegate = self
        dataSource = self
        register(GKHCaruselCollectionViewCell.self, forCellWithReuseIdentifier: GKHCaruselCollectionViewCell.reuseId)

        translatesAutoresizingMaskIntoConstraints = false
        layout.minimumLineSpacing = GKHConstants.galleryMinimumLineSpacing
        contentInset = UIEdgeInsets(top: 0, left: GKHConstants.leftDistanceToView, bottom: 0, right: GKHConstants.rightDistanceToView)

        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }

    func set(list: [InternetLatestOpsDO]) {
        items = list
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: GKHCaruselCollectionViewCell.reuseId, for: indexPath) as! GKHCaruselCollectionViewCell
        if !items.isEmpty {
            cell.mainImageView.image = items[indexPath.row].mainImage
            cell.nameLabel.text = items[indexPath.row].name
            cell.smallDescriptionLabel.text = items[indexPath.row].amount
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: GKHConstants.galleryItemWidth, height: frame.height * 0.8)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
