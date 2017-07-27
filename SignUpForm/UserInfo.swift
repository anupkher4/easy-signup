//
//  UserInfo.swift
//  SignUpForm
//
//  Created by Anup Kher on 7/26/17.
//  Copyright © 2017 amprojects. All rights reserved.
//

import Foundation

enum JSONError: Error {
    case incompleteInputData
    case serializationError
    // More error cases
}

class UserInfo: NSObject {
    var firstName: String?
    var lastName: String?
    var street: String?
    var city: String?
    var state: String?
    var zip: String?
    
    init(fname: String? = nil, lname: String? = nil, street: String? = nil, city: String? = nil, state: String? = nil, zip: String? = nil) {
        self.firstName = fname
        self.lastName = lname
        self.street = street
        self.city = city
        self.state = state
        self.zip = zip
    }
    
    func sendToServer(result: (Any) -> Void) throws {
        var infoDict: [String: String] = [:]
        
        guard let fname = firstName, let lname = lastName, let street = street, let city = city, let state = state, let zip = zip else {
            throw JSONError.incompleteInputData
        }
        
        infoDict = [
            "firstname": fname,
            "lastname": lname,
            "street": street,
            "city": city,
            "state": state,
            "zip": zip
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: infoDict, options: .prettyPrinted)
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            result(json)
        } catch {
            throw JSONError.serializationError
        }
        
    }
}
