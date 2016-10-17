//
//  APINetworking.swift
//  Flicks
//
//  Created by Aaron on 10/16/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import Foundation
import SwiftyJSON
import AFNetworking

enum NetworkingErrorType: String {
    case UnableToCreateURL = "Failed to construct a valid URL."
    case UnableToParseResponse = "Could not parse the response from the server."
    
    var errorCode: Int {
        switch self {
        case .UnableToCreateURL:
            return 44
        case .UnableToParseResponse:
            return 400
        }
    }
}

class APINetworking {
    typealias NetworkingCompletionBlock = ([JSON]) -> Void
    typealias NetworkingErrorBlock = (NSError) -> Void
    
    static let sharedInstance = APINetworking()

    private let TMDB_API_KEY = "f74debaa29be627b870f6ff8c90f0734"
    private let TMDB_API_BASE_PATH = "https://api.themoviedb.org/3"
    private let configuration: URLSessionConfiguration
    private let manager: AFURLSessionManager
    
    private func buildURLWith(path: String, page: Int = 1) -> URL? {
        return URL(string: "\(TMDB_API_BASE_PATH)\(path)?api_key=\(TMDB_API_KEY)&page=\(page)")
    }
    
    func fetchNowPlayingMovies(page: Int, completionBlock: @escaping NetworkingCompletionBlock, errorBlock: @escaping NetworkingErrorBlock) {
        guard let nowPlayingURL = buildURLWith(path: "/movie/now_playing", page: page) else {
            errorBlock(NSError(domain: NetworkingErrorType.UnableToCreateURL.rawValue, code: NetworkingErrorType.UnableToCreateURL.errorCode, userInfo: nil))
            return
        }
        
        let nowPlayingRequest = URLRequest(url: nowPlayingURL)
    
        let nowPlayingTask: URLSessionDataTask = manager.dataTask(with: nowPlayingRequest, completionHandler: { urlResponse, responseObject, error in
            if let error = error {
                errorBlock(error as NSError)
                return
            }
            
            if let responseObject = responseObject, let results = JSON(responseObject)["results"].array {
                    completionBlock(results)
            } else {
                errorBlock(NSError(domain: NetworkingErrorType.UnableToParseResponse.rawValue, code: NetworkingErrorType.UnableToParseResponse.errorCode, userInfo: nil))
            }
        })
        
        nowPlayingTask.resume()
    }
    
    func fetchMovieDetail(completion: NetworkingCompletionBlock, error: NetworkingErrorBlock) -> JSON? {
        return nil
    }
    
    private init() {
        configuration = URLSessionConfiguration.default
        manager = AFURLSessionManager(sessionConfiguration: configuration)
    }
}
