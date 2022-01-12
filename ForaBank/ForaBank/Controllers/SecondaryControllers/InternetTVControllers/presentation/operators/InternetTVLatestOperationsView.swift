import Foundation
import UIKit

class InternetTVLatestOperationsView: UIView {

    private var latestOpCollectionView = InternetTVCollectionView()
    var viewModel = InternetTVLatestOperationsViewModel()

    private var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.translatesAutoresizingMavarntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        viewModel.controller = self
        configureContents()
        if latestOpCollectionView.items.isEmpty {
            InternetTVMainController.latestOpIsEmpty = true
            InternetTVMainController.iMsg?.handleMsg(what: InternetTVMainController.msgHideLatestOperation)
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
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])
        latestOpCollectionView.set(list: viewModel.getData())
    }
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        InternetTVMainViewModel.latestOp = items[indexPath.item]
        InternetTVMainController.iMsg?.handleMsg(what: InternetTVMainController.msgPerformSegue)
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
        return CGSize(width: 90, height: frame.height * 0.8)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
