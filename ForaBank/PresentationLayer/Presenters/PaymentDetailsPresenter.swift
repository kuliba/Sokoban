import Foundation

class PaymentDetailsPresenter: IPaymentDetailsPresenter {
    weak var delegate: PaymentDetailsPresenterDelegate?

    private var sourcePaymentOption: PaymentOptionType? {
        didSet {
            onSomeValueUpdated()
        }
    }
    private var destinaionPaymentOption: PaymentOptionType? {
        didSet {
            onSomeValueUpdated()
        }
    }
    private var preparePaymentData: DataClassPayment? {
        didSet {
            onSomeValueUpdated()
        }
    }
    
    private var amount: Double? {
        didSet {
            onSomeValueUpdated()
        }
    }

    private var isLoading = false
    private var canAskFee = false
    private var canMakePayment = false

    init(delegate: PaymentDetailsPresenterDelegate) {
        self.delegate = delegate
    }
}

extension PaymentDetailsPresenter {

    private func onSomeValueUpdated() {
        guard let destination = destinaionPaymentOption, let source = sourcePaymentOption else {
            return
        }

        let isValidDestination = isValid(paymentOption: destination)
        let isValidSource = isValid(paymentOption: source)

        let canStartWithOptions = isValidSource && isValidDestination && amount != nil
        canAskFee = canStartWithOptions

        delegate?.didUpdate(isLoading: isLoading, canAskFee: canAskFee, canMakePayment: canMakePayment)
    }

    private func isValid(paymentOption: PaymentOptionType) -> Bool {
        switch paymentOption {
        case .option(_):
            return true
        case .accountNumber(let accountNumber):
            return accountNumber.count >= 14
        case .cardNumber(let cardNumber):
            return cardNumber.count == 16
        case .phoneNumber(let phoneNumber):
            return phoneNumber.count == 11
        }
    }
}

extension PaymentDetailsPresenter: PaymentsDetailsViewControllerDelegate {

    func didChangeSource(paymentOption: PaymentOptionType) {
        print(paymentOption)
        sourcePaymentOption = paymentOption
    }

    func didChangeDestination(paymentOption: PaymentOptionType) {
        print(paymentOption)
        destinaionPaymentOption = paymentOption
    }

    func didChangeAmount(amount: Double?) {
        self.amount = amount
    }

    func didPressPrepareButton() {
        preparePayment()
    }

    func didPressPaymentButton() {

    }
}

private extension PaymentDetailsPresenter {
    func preparePayment() {

        guard let amount = self.amount, let nonNilsourcePaymentOption = sourcePaymentOption, let nonNilDestinaionPaymentOption = destinaionPaymentOption else {
            return
        }
        delegate?.didUpdate(isLoading: true, canAskFee: canAskFee, canMakePayment: canMakePayment)

        let completion: (Bool, String?, DataClassPayment?) -> Void = { [weak self] (success, token, preparePaymentData) in
            guard let canAskFee = self?.canAskFee, let canMakePayment = self?.canMakePayment else {
                return
            }
            self?.delegate?.didUpdate(isLoading: false, canAskFee: canAskFee, canMakePayment: canMakePayment)
            self?.delegate?.didFinishPreparation(success: success,data: preparePaymentData)
            self?.delegate?.didPrepareData(data: preparePaymentData)
        }
        
        let handler = PaymentRequestHandler(amount: amount, completion: completion)
        handler.preparePayment(sourcePaymentOption: nonNilsourcePaymentOption, destinaionPaymentOption: nonNilDestinaionPaymentOption, prepareData: preparePaymentData)
    }
}
