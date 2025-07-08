//
//  FeedViewModel.swift
//  TestForPatres
//
//  Created by Nikita Chekmarev on 04.07.2025.
//
import Foundation

class FeedViewModel {
    
    var posts: [Post] = []
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?

    private var currentPage = 1
    private let pageSize = 20
    private var isLoading = false
    private var allLoaded = false

    func loadPosts() {
        currentPage = 1
        allLoaded = false
        isLoading = false
        let cached = CoreDataService.shared.fetchPosts()
        if !cached.isEmpty {
            self.posts = cached
            self.onUpdate?()
        }
        loadMorePosts(reset: true)
    }

    func loadMorePosts(reset: Bool = false) {
        guard !isLoading, !allLoaded else { return }
        isLoading = true
        let pageToLoad = reset ? 1 : currentPage
        APIService.shared.fetchPosts(page: pageToLoad, limit: pageSize) { [weak self] result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let dtos):
                    if reset {
                        CoreDataService.shared.savePosts(dtos)
                        self.posts = CoreDataService.shared.fetchPosts()
                    } else {
                        CoreDataService.shared.savePosts(dtos)
                        let newPosts = CoreDataService.shared.fetchPosts().filter { post in
                            !self.posts.contains(where: { $0.id == post.id })
                        }
                        self.posts.append(contentsOf: newPosts)
                    }
                    if dtos.count < self.pageSize {
                        self.allLoaded = true
                    } else {
                        self.currentPage += 1
                    }
                    self.onUpdate?()
                case .failure(let error):
                    self.onError?("Failed to load posts: \(error.localizedDescription)")
                }
            }
        }
    }

    func refreshPosts() {
        loadPosts()
    }
} 
