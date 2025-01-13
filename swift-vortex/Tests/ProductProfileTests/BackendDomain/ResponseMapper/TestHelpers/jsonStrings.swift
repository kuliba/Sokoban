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
    "statusDescription": "statusDescription",
    "statusBrief": "statusBrief"
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
