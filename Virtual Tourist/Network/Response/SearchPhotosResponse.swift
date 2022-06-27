//
//  SearchPhotosResponse.swift
//  Virtual Tourist
//
//  Created by Eyvind on 5/6/22.
//

import Foundation

struct SearchPhotosResponse: Codable{
    let stat: String
    let photos: PageResponse
    
    enum CodingKeys: String, CodingKey{
        case stat = "stat"
        case photos = "photos"
    }
}
