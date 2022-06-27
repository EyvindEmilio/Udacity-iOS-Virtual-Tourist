//
//  Photos.swift
//  Virtual Tourist
//
//  Created by Eyvind on 5/6/22.
//

import Foundation

struct PageResponse: Codable{
    let page: Int
    let pages: Int
    let perPage: Int
    let total: Int
    let photo: [PhotoResponse]
    
    enum CodingKeys: String, CodingKey {
        case page = "page"
        case pages = "pages"
        case perPage = "perpage"
        case total = "total"
        case photo = "photo"
    }
    
}
