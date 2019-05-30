//
//  APIController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum NetowrkError: Error {
    case noAuth
    case badAuth
    case otherError
    case badData
    case noDecode
}

class APIController {
    
    private let baseUrl = URL(string: "https://lambdaanimalspotter.vapor.cloud/api")!
    
    var bearer: Bearer?
    
    // create function for sign up
    func signUp(user: User, completion: @escaping (Error?) -> ()) {
        // create endpoint URL
        let signUpURL = baseUrl.appendingPathComponent("users/signup")
        
        // setup request
        var request = URLRequest(url: signUpURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create a encoder
        let jsonEncoder = JSONEncoder()
        
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
        } catch {
            NSLog("Error encoding user object \(error)")
            completion(error)
            return // No point in continuing with an error
        }
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    // create function for sign in
    func signIn(user: User, completion: @escaping (Error?) -> ()) {
        let loginURL = baseUrl.appendingPathComponent("users/login")
        
        var request = URLRequest(url: loginURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
        } catch {
            NSLog("Error encoding user object \(error)")
            completion(error)
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(NSError(domain: " ", code: response.statusCode, userInfo: nil))
            }
            if let error = error {
                completion(error)
                return
            }
            
            guard let data = data else {
                completion(NSError())
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                self.bearer = try decoder.decode(Bearer.self, from: data)
            } catch {
                NSLog("Error decoding bearer object: \(error)")
                completion(error)
                return
            }
            
        }.resume()
    }
    
    // Put an empty [Strings] for .failures
    
    // create function for fetching all animal names
    func fetchAllAnimalNames(completion: @escaping ([String]) -> Void) {
        guard let bearer = self.bearer else {
            completion([String()])//(.failure(.noAuth))
            return
        }
        
        let allAnimalsURL = baseUrl.appendingPathComponent("animals/all")
        
        var request = URLRequest(url: allAnimalsURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 401 {
                completion([String()])
                return
            }
            
            guard let data = data else {
                completion([String()])
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let animalNames = try decoder.decode([String].self, from: data)
                completion([String()])
            } catch {
                NSLog("Error decoding animal objects \(error)")
                completion([String()])
                return
            }
            
        }.resume()
    }
    
    
    
    // create function to fetch details of animal
    func fetchDetailsForAnimal(animalName: String, completion: @escaping (Animal?, Error?) -> Void) {
        guard let bearer = self.bearer else {
            completion(nil, NSError())
            return
        }
        
        let animalURL = baseUrl.appendingPathComponent("animals/\(animalName)")
        
        var request = URLRequest(url: animalURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 401 {
                completion(nil, NSError())
                return
            }
            
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            
            do {
                let animal = try decoder.decode(Animal.self, from: data)
                completion(nil, NSError())
            } catch {
                NSLog(" Error decoding animal object: \(error)")
                completion(nil, NSError())
                return
            }
        }.resume()
    }
    
    // create function to fetch image
    func fetchImage(urlString: String, completion: @escaping ( UIImage?, NSError?) -> Void) {
        let imageUrl = URL(string: urlString)!
        
        var request = URLRequest(url: imageUrl)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                completion(nil, NSError())
                return
            }
            
            guard let data = data else {
                completion(nil, NSError())
                return
            }
            let image = UIImage(data: data)
            completion(image, nil)
            
        }.resume()
    }
}

