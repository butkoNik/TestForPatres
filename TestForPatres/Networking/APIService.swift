//
//  APIService.swift
//  TestForPatres
//
//  Created by Nikita Chekmarev on 04.07.2025.
//
import Foundation
import Alamofire

struct PostDTO: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

class APIService {
    static let shared = APIService()
    private init() {}

    func fetchPosts(completion: @escaping (Result<[PostDTO], Error>) -> Void) {
        let url = "https://jsonplaceholder.typicode.com/posts"
        AF.request(url).validate().responseDecodable(of: [PostDTO].self) { response in
            switch response.result {
            case .success(let posts):
                completion(.success(posts))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchPosts(page: Int, limit: Int, completion: @escaping (Result<[PostDTO], Error>) -> Void) {
        let url = "https://jsonplaceholder.typicode.com/posts?_page=\(page)&_limit=\(limit)"
        AF.request(url).validate().responseDecodable(of: [PostDTO].self) { response in
            switch response.result {
            case .success(let posts):
                completion(.success(posts))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
} 
