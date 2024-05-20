import UIKit
import RealmSwift


class C2BDetailsFormViewController: UIViewController {

    var getUImage: (Md5hash) -> UIImage? = { _ in UIImage() }
    
    var amountField = C2BDetailsInputView(
            viewModel: C2BDetailsInputViewModel(
                    title: "Сумма перевода",
                    text: C2BDetailsViewModel.operationDetail?.amount?.currencyFormatter() ?? "",
                    image: #imageLiteral(resourceName: "coins"),
                    isEditable: false))

    var nameOfRecipientField = C2BDetailsInputView(
            viewModel: C2BDetailsInputViewModel(
                    title: "Наименование ТСП",
                    text: C2BDetailsViewModel.operationDetail?.merchantSubName ?? "",
                    image: C2BDetailsViewModel.recipientIcon,
                    isEditable: false))

    var dateOperation = C2BDetailsInputView(
            viewModel: C2BDetailsInputViewModel(
                    title: "Дата и время операции (МСК)",
                    text: C2BDetailsViewModel.operationDetail?.dateForDetail ?? "",
                    image: #imageLiteral(resourceName: "date"),
                    isEditable: false))

    var stateOfOperation = C2BDetailsInputView(
            viewModel: C2BDetailsInputViewModel(
                    title: "Статус операции",
                    text: C2BSuccessView.statusText,
                    image: C2BSuccessView.statusImg!,
                    isEditable: false))

    var cardFromField = CardChooseView()

    var nameOfRecipient2Field = C2BDetailsInputView(
            viewModel: C2BDetailsInputViewModel(
                    title: "Получатель",
                    text: C2BDetailsViewModel.operationDetail?.payeeFullName ?? "",
                    image: UIImage(named: "fio")!,
                    isEditable: false))

    var bankField = C2BDetailsInputView(
            viewModel: C2BDetailsInputViewModel(
                    title: "Банк получателя",
                    text: C2BSuccessView.bankName,
                    image: C2BSuccessView.bankImg,
                    isEditable: false))

    var commentField = C2BDetailsInputView(
            viewModel: C2BDetailsInputViewModel(
                    title: "Сообщение получателю",
                    text: C2BDetailsViewModel.operationDetail?.comment ?? "",
                    image: UIImage(named: "message"),
                    isEditable: false))

    var numberTransactionField = C2BDetailsInputView(
            viewModel: C2BDetailsInputViewModel(
                    title: "Идентификатор операции",
                    text: C2BDetailsViewModel.operationDetail?.transferNumber ?? "",
                    image: UIImage(named: "hash")!,
                    isEditable: false))

    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
        hideKeyboardWhenTappedAround()
    }

    func setupData() {
        dismissActivity()
        cardFromField.getUImage = getUImage
        cardFromField.model = C2BDetailsViewModel.sourceModel
        cardFromField.isHidden = false
        cardFromField.choseButton?.isHidden = true
        cardFromField.balanceLabel.isHidden = true
        cardFromField.titleLabel.text = "Счет списания"
        cardFromField.leftTitleAncor.constant = 64
    }

    fileprivate func setupUI() {
        let imageViewRight = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        imageViewRight.contentMode = .scaleAspectFit
        imageViewRight.image = UIImage(named: "sbp-logo")
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageViewRight)

        view.backgroundColor = .white
        cardFromField.model = C2BDetailsViewModel.sourceModel

        let image = UIImage(named: "sbptext")
        let imageViewSBP = UIImageView(image: image!)

        let viewImg = UIView()
        viewImg.addSubview(imageViewSBP)

        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        let stackView = UIStackView(
                arrangedSubviews: [amountField,
                                   nameOfRecipientField,
                                   dateOperation,
                                   stateOfOperation,
                                   cardFromField,
                                   nameOfRecipient2Field,
                                   bankField,
                                   commentField,
                                   numberTransactionField,
                                   viewImg])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.anchor(top: view.topAnchor,
                left: view.leftAnchor,
                bottom: view.bottomAnchor,
                right: view.rightAnchor)
        stackView.anchor(top: stackView.topAnchor,
                left: stackView.leftAnchor,
                right: stackView.rightAnchor,
                height: 750)
        scrollView.contentSize.width = UIScreen.main.bounds.width
        scrollView.contentSize.height = 750
        viewImg.anchor(left: view.leftAnchor,
                right: view.rightAnchor,
                paddingBottom: 100)
        imageViewSBP.centerX(inView: viewImg)
        imageViewSBP.anchor(top: viewImg.topAnchor, paddingTop: 10)
    }
}
