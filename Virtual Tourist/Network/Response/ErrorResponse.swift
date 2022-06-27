//
//  SearchPhotosFailResponse.swift
//  Virtual Tourist
//
//  Created by Eyvind on 5/6/22.
//

import Foundation

struct ErrorResponse: Codable {
    let stat: String
    let code: Int
    let message: String
    
    enum CodingKeys: String, CodingKey{
        case stat = "stat"
        case code = "code"
        case message = "message"
    }
}


extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
