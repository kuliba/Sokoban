//
//  jsonStrings.swift
//
//
//  Created by Andryusina Nataly on 05.03.2024.
//

let jsonStringWithBadData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": { "a": "b" }
}
"""

let jsonStringWithEmpty = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {}
}
"""

let jsonStringCardDetails = """
    {
    "statusCode": 0,
    "errorMessage": null,
    "data": {
      "corrAccount": "30101810300000000341",
      "accountNumber": "4081781000000000001",
      "payeeName": "Иванов Иван Иванович",
      "kpp": "770401001",
      "bic": "044525341",
      "inn": "7704113772",
      "cardNumber": "4444555566661122",
      "maskCardNumber": "4444 55** **** 1122",
      "expireDate": "08/25",
      "holderName": "IVAN IVANOV",
      "info": "Реквизиты счета доступны владельцу основной карты. Он сможет их посмотреть в ЛК.",
      "md5hash": "72ffaeb111fbcbd37cb97e0c2886bc89"
        }
    }
    """

let jsonStringCardDetailsWithNull = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
      "corrAccount": null,
      "accountNumber": null,
      "payeeName": null,
      "kpp": null,
      "bic": null,
      "inn": null,
      "cardNumber": "4444555566661122",
      "maskCardNumber": "4444 55** **** 1122",
      "expireDate": "08/25",
      "holderName": "IVAN IVANOV",
      "info": null,
      "md5hash": null
    }
}
"""

let jsonStringAccountDetails = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "accountNumber": "4081781000000000001",
        "bic": "044525341",
        "corrAccount": "30101810300000000341",
        "inn": "7704113772",
        "kpp": "770401001",
        "payeeName": "Иванов Иван Иванович"
    }
}
"""

let jsonStringDepositDetails = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "accountNumber": "4081781000000000001",
        "bic": "044525341",
        "corrAccount": "30101810300000000341",
        "inn": "7704113772",
        "kpp": "770401001",
        "payeeName": "Иванов Иван Иванович",
        "expireDate": "08/25",
    }
}
"""

let jsonStringWithNilData = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": null
}
"""
