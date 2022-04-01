import UIKit
import RealmSwift


class C2BDetailsFormViewController: UIViewController {

//
//        when (answer.operationStatus) {
//"IN_PROGRESS" -> detailsArr.add(DetailsDO(R.drawable.ic_waiting2,"Статус операции", "в обработке"))
//"REJECTED" -> detailsArr.add(DetailsDO(R.drawable.ic_transfer_reject2,"Статус операции", "отказ"))
//"COMPLETE" -> detailsArr.add(DetailsDO(R.drawable.ic_success2,"Статус операции", "успешно"))
//"FAILED" -> detailsArr.add(DetailsDO(-1,"Статус операции", answer.operationStatus))
//}
//detailsArr.add(DetailsDO(-1, "source", ""))

    var amountField = ForaInput(
            viewModel: ForaInputModel(
                    title: "Сумма перевода",
                    text: C2BDetailsViewModel.operationDetail?.amount?.description ?? "",
                    image: #imageLiteral(resourceName: "Phone"),
                    type: .phone,
                    isEditable: false))

    var dateOperation = ForaInput(
            viewModel: ForaInputModel(
                    title: "Дата и время операции (МСК)",
                    text: C2BDetailsViewModel.operationDetail?.dateForDetail ?? "",
                    image: #imageLiteral(resourceName: "accountImage"),
                    isEditable: false))

    var nameOfRecipientField = ForaInput(
            viewModel: ForaInputModel(
                    title: "Наименование ТСП",
                    text: C2BDetailsViewModel.operationDetail?.merchantSubName ?? "",
                    image: #imageLiteral(resourceName: "BankIcon"),
                    isEditable: false))

    var nameOfRecipient2Field = ForaInput(
            viewModel: ForaInputModel(
                    title: "Получатель",
                    text: C2BDetailsViewModel.operationDetail?.payeeFullName ?? "",
                    image: UIImage(named: "map-pin")!,
                    isEditable: false))

    var bankField = ForaInput(
            viewModel: ForaInputModel(
                    title: "Банк",
                    image: UIImage(named: "hash")!,
                    isEditable: false))

    var commentField = ForaInput(
            viewModel: ForaInputModel(
                    title: "Сообщение получателю",
                    text: C2BDetailsViewModel.operationDetail?.comment ?? "",
                    image: UIImage(named: "hash")!,
                    isEditable: false))

    var numberTransactionField = ForaInput(
            viewModel: ForaInputModel(
                    title: "Идентификатор операции",
                    text: C2BDetailsViewModel.operationDetail?.transferNumber ?? "",
                    image: UIImage(named: "hash")!,
                    isEditable: false))

    var cardFromField = CardChooseView()
    

    let doneButton = UIButton(title: "Оплатить")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
        hideKeyboardWhenTappedAround()
    }


    func setupData() {
        dismissActivity()
        cardFromField.model = C2BDetailsViewModel.sourceModel
        cardFromField.isHidden = false
        cardFromField.choseButton.isHidden = true
        cardFromField.balanceLabel.isHidden = true
        cardFromField.titleLabel.text = "Счет списания"
        cardFromField.leftTitleAncor.constant = 64
    }

    fileprivate func setupUI() {
        view.backgroundColor = .white

        let stackView = UIStackView(
                arrangedSubviews: [amountField,
                                   dateOperation,
                                   nameOfRecipientField,
                                   nameOfRecipient2Field,
                                   numberTransactionField,
                                   cardFromField])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        view.addSubview(stackView)

        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20)

        view.addSubview(doneButton)
        doneButton.anchor(left: stackView.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: stackView.rightAnchor,
                paddingLeft: 20, paddingBottom: 20, paddingRight: 20, height: 44)
    }
}
