//
//  CoreDataService.swift
//  TestForPatres
//
//  Created by Nikita Chekmarev on 08.07.2025.
//

import Foundation
import CoreData
import UIKit

class CoreDataService {
    static let shared = CoreDataService()
    private let context: NSManagedObjectContext

    private init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }

    func savePosts(_ posts: [PostDTO]) {
        let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
        let existingPosts = (try? context.fetch(fetchRequest)) ?? []
        var postById = [Int64: Post]()
        for post in existingPosts {
            postById[post.id] = post
        }
        
        for dto in posts {
            let postId = Int64(dto.id)
            let post: Post
            if let existing = postById[postId] {
                post = existing
            } else {
                post = Post(context: context)
                post.id = postId
            }
            post.userId = Int64(dto.userId)
            post.title = dto.title
            post.body = dto.body
        }
        try? context.save()
    }

    func fetchPosts() -> [Post] {
        let request: NSFetchRequest<Post> = Post.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }

    func deleteAllPosts() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Post.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? context.execute(deleteRequest)
    }

    func saveAvatarData(for post: Post, data: Data) {
        post.avatarData = data
        do {
            try context.save()
        } catch {
            print("Failed to save avatar data: \(error)")
        }
    }
}

