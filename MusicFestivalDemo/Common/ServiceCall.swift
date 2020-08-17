//
//  ServiceCall.swift
//  MusicFestivalDemo
//
//  Created by Anupam Rao on 17/8/20.
//  Copyright © 2020 Serhii Kharauzov. All rights reserved.
//

import Foundation
class ServiceCall : NSObject{

  func loadJson(fromURLString urlString: String,
                            completion: @escaping (Result<Data, Error>) -> Void) {
          if let url = URL(string: urlString) {
              let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                  if let error = error {
                      completion(.failure(error))
                  }
                  if let data = data {
                      completion(.success(data))
                  }
              }
              urlSession.resume()
          }
      }
}


