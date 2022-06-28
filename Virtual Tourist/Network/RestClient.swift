//
//  RestClient.swift
//  Virtual Tourist
//
//  Created by Eyvind on 1/6/22.
//

import Foundation

class RestClient{
    
    struct Auth {
        static let CUSTOMER_KEY = "<YOUR_CUSTOMER_KEY>"
    }
    
    enum Endpoints {
        static let BASE = "https://www.flickr.com/services/rest"
        static let BASE_PHOTOS = "https://live.staticflickr.com"
        static let PAGE_SIZE = 21
        
        case searchPhotos(Double, Double, Int)
        case downloadPhoto(String, String, String)
        
        var stringValue: String{
            switch self {
            case .searchPhotos(let lat, let lon, let page):
                return "\(Endpoints.BASE)/?method=flickr.photos.search&api_key=\(Auth.CUSTOMER_KEY)&lat=\(lat)&lon=\(lon)&radius=15&per_page=\(Endpoints.PAGE_SIZE)&page=\(page)&format=json&nojsoncallback=1"
            case .downloadPhoto(let server, let photoId, let secret):
                return "\(Endpoints.BASE_PHOTOS)/\(server)/\(photoId)_\(secret).jpg"            }
        }
        
        var url : URL{
            return URL(string: stringValue)!
        }
    }
    
    static func searchByLocation(_ lat: Double,_ lon: Double,_ page: Int, completion: @escaping ([PhotoResponse], Error?) -> Void) -> URLSessionDataTask {
        debugPrint("url=\(Endpoints.searchPhotos(lat, lon, page).url)")
        return taskForGETRequest(url: Endpoints.searchPhotos(lat, lon, page).url, responseType: SearchPhotosResponse.self) { data, error in
            guard let data = data else {
                completion([], error)
                return
            }
            
            completion(data.photos.photo, nil)
        }
    }
    
    class func downloadPhoto(server: String, photoId:String, secret: String, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.downloadPhoto(server, photoId, secret).url) { data, response, error in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
        task.resume()
    }
    
    class func downloadAllPhotos(photos: [Photo],
                                 photoLoaded: @escaping (Photo, Data) -> Void,
                                 completion: @escaping (Bool) -> Void) {
        let maxRequests = photos.count
        var currentPhoto = 0
        var errors = 0
        
        if photos.isEmpty {
            completion(true)
            return
        }

        photos.forEach { photo in
            downloadPhoto(server: photo.server!, photoId: photo.photoId!, secret: photo.secret!) { data, error in
                currentPhoto += 1

                if data != nil {
                    DispatchQueue.main.async { photoLoaded(photo, data!) }
                } else {
                    errors += 1
                }

                if currentPhoto == maxRequests {
                    DispatchQueue.main.async { completion(errors == 0) }
                }
            }
        }
    }
    
    private class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
}
