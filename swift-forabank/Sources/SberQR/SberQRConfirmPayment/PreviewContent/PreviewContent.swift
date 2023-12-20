//
//  PreviewContent.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

extension SberQRConfirmPaymentStateOf<Info>.EditableAmount {
    
    static var preview: Self {
        
        .init(
            header: .preview,
            productSelect: .preview,
            brandName: .brandName,
            recipientBank: .recipientBank,
            currency: .preview,
            amount: .preview
        )
    }
}

extension SberQRConfirmPaymentStateOf<Info>.FixedAmount {
    
    static var preview: Self {
        
        .init(
            header: .preview,
            productSelect: .previewExpanded,
            brandName: .brandName,
            amount: .amount,
            recipientBank: .recipientBank,
            bottom: .preview
        )
    }
}

public extension SberQRConfirmPaymentState.EditableAmount {
    
    static var preview: Self {
        
        .init(
            header: .preview,
            productSelect: .preview,
            brandName: .brandName,
            recipientBank: .recipientBank,
            currency: .preview,
            amount: .preview
        )
    }
}

public extension SberQRConfirmPaymentState.FixedAmount {
    
    static var preview: Self {
        
        .init(
            header: .preview,
            productSelect: .previewExpanded,
            brandName: .brandName,
            amount: .amount,
            recipientBank: .recipientBank,
            bottom: .preview
        )
    }
}

extension ProductSelect {
    
    static let preview: Self = .init(selected: .cardPreview)
    static let previewExpanded: Self = .init(
        selected: .accountPreview, 
        products: .allProducts
    )
}

public extension Array where Element == ProductSelect.Product {
    
    static let allProducts: Self = [
        .accountPreview,
        .account2Preview,
        .cardPreview,
        .card2Preview,
        .card3Preview,
    ]
}

extension ProductSelect.Product {
    
    public static let accountPreview: Self = .init(
        id: 234567891,
        type: .account,
        header: "Счет списания",
        title: "Текущий счет",
        footer: "7891",
        amountFormatted: "123 456 ₽",
        balance: 123_456,
        look: .init(
            background: .svg(""),
            color: "orange",
            icon: .svg("")
        )
    )
    
    static let account2Preview: Self = .init(
        id: 2345678912,
        type: .account,
        header: "Счет списания",
        title: "Account 2",
        footer: "8912",
        amountFormatted: "678.09 ₽",
        balance: 678.09,
        look: .init(
            background: .svg(""),
            color: "orange",
            icon: .svg("")
        )
    )
    
    public static let cardPreview: Self = .init(
        id: 123456789,
        type: .card,
        header: "Счет списания",
        title: "Card",
        footer: "6789",
        amountFormatted: "1 234.56 ₽",
        balance: 1_234.56,
        look: .init(
            background: .svg(""),
            color: "orange",
            icon: .svg("")
        )
    )
    
    static let card2Preview: Self = .init(
        id: 1234567892,
        type: .card,
        header: "Счет списания",
        title: "Card 2",
        footer: "7892",
        amountFormatted: "12 345 ₽",
        balance: 12_345,
        look: .init(
            background: .svg(""),
            color: "orange",
            icon: .svg("")
        )
    )
    
    static let card3Preview: Self = .init(
        id: 1234567893,
        type: .card,
        header: "Счет списания",
        title: "Card 3",
        footer: "7893",
        amountFormatted: "123 456.78 ₽",
        balance: 123_456.78,
        look: .init(
            background: .svg(""),
            color: "orange",
            icon: .svg("")
        )
    )
}

extension GetSberQRDataResponse.Parameter.Amount {
    
    static let preview: Self = .init(
        id: .paymentAmount,
        value: 123.45,
        title: "Сумма перевода",
        validationRules: [],
        button: .init(
            title: "Оплатить",
            action: .paySberQR,
            color: .red
        )
    )
}

extension GetSberQRDataResponse.Parameter.Button {
    
    static let preview: Self = .init(
        id: .buttonPay,
        value: "Оплатить",
        color: .red,
        action: .pay,
        placement: .bottom
    )
}

extension GetSberQRDataResponse.Parameter.DataString {
    
    static let preview: Self = .init(
        id: .currency,
        value: "RUB"
    )
}

extension SberQRConfirmPaymentState.Header {
    
    static let preview: Self = .init(
        id: .title,
        value: "Title"
    )
}
