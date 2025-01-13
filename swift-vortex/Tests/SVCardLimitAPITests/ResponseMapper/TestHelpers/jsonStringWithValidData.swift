//
//  jsonStringWithValidData.swift
//
//
//  Created by Andryusina Nataly on 18.06.2024.
//

let jsonStringWithValidData = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "limitsList": [
      {
        "limitType": "DEBIT_OPERATIONS",
        "limit": [
          {
            "name": "LMTTZ01",
            "value": 1000.01,
            "currency": 810,
            "currentValue": 900.09
          }
        ]
      },
      {
        "limitType": "WITHDRAWAL",
        "limit": [
          {
            "name": "LMTTZ03",
            "value": 100,
            "currency": 810,
            "currentValue": 90
          }
        ]
      }
    ]
  }
}
"""

let jsonStringWithValidDataWithOutValues = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "limitsList": [
      {
        "limitType": "DEBIT_OPERATIONS",
        "limit": [
          {
            "name": "LMTTZ01",
            "currency": 810,
          }
        ]
      },
      {
        "limitType": "WITHDRAWAL",
        "limit": [
          {
            "name": "LMTTZ03",
            "currency": 810,
          }
        ]
      }
    ]
  }
}
"""
