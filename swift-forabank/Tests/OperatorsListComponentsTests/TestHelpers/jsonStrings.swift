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
    "serial": "serial",
    "operatorList": "[
        {
            "type": "housingAndCommunalService",
            "atributeList": {

                "md5hash": "md5hash",
                "customerId": "serviceId",
                "juridicalName": "name",
                "serviceList": [],
                "inn": "inn"
            }
        }
    ]"
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
