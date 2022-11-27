//
//  APIManager.swift
//  WaIE-APOD
//
//  Created by Kibbcom India on 26/11/22.
//

import Foundation
import Alamofire

enum Result <T> {
case Success(T)
case Error(String)
}

class APIManager {
    
    let query = "dogs"
    lazy var endPoint: String = { return "https://api.nasa.gov/planetary/apod?api_key=eM1yQWWgSsnyONzaAxC607AGkYdOgMv7o7CiZpUY" }()
    
    
    func getDataWith(completion: @escaping (Result<[String: AnyObject]>) -> Void) {
        
        guard let url = URL(string: endPoint) else { return
        completion(.Error("Invalid URL, we can't update your feed")) }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else { return
                completion(.Error(error!.localizedDescription))}
            guard let data = data else { return
                completion(.Error(error?.localizedDescription ?? "There are no new Items to show"))}
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: AnyObject] {
                    
                    DispatchQueue.main.async {
                        completion(.Success(json))
                    }
                }
            } catch let error {
                return completion(.Error(error.localizedDescription))
            }
        }.resume()
    }
}
