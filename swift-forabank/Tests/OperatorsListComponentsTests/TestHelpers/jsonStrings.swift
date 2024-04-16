//
//  jsonStrings.swift
//  
//
//  Created by Andryusina Nataly on 12.02.2024.
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

let jsonStringOk = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "bea36075a58954199a6b8980549f6b69",
    "operatorList": [
      {
        "type": "string",
        "atributeList": [
          {
            "md5hash": "md5hash",
            "juridicalName": "title",
            "customerId": "string",
            "serviceList": [],
            "inn": "description"
          }
        ]
      }
    ]
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
