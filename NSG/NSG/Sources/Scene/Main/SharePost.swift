//
//  SharePost.swift
//  NSG
//
//  Created by Codex on 3/26/26.
//
import Foundation

struct SharePost {
    let id: String?
    let author: String?
    let title: String
    let content: String
    let category: String
    let likeCount: Int
    let commentCount: Int
    let hasImages: Bool
    let createdAt: String?
    let place: String?
    let isAnonymous: Bool?
    let isLiked: Bool?
    let imageURLs: [String]

    init(
        id: String? = nil,
        author: String? = nil,
        title: String,
        content: String,
        category: String,
        likeCount: Int = 0,
        commentCount: Int = 0,
        hasImages: Bool = false,
        createdAt: String? = nil,
        place: String? = nil,
        isAnonymous: Bool? = nil,
        isLiked: Bool? = nil,
        imageURLs: [String] = []
    ) {
        self.id = id
        self.author = author
        self.title = title
        self.content = content
        self.category = category
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.hasImages = hasImages
        self.createdAt = createdAt
        self.place = place
        self.isAnonymous = isAnonymous
        self.isLiked = isLiked
        self.imageURLs = imageURLs
    }

    init(category: String, title: String, content: String) {
        self.init(
            title: title,
            content: content,
            category: category
        )
    }
}
