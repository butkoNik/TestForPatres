//
//  PostTableViewCell.swift
//  TestForPatres
//
//  Created by Nikita Chekmarev on 04.07.2025.
//
import UIKit

class PostTableViewCell: UITableViewCell {
    static let identifier = "PostTableViewCell"

    let avatarImageView = UIImageView()
    let titleLabel = UILabel()
    let bodyLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.layer.cornerRadius = 8
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 1

        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.font = UIFont.systemFont(ofSize: 14)
        bodyLabel.numberOfLines = 0

        contentView.addSubview(avatarImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(bodyLabel)

        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            avatarImageView.widthAnchor.constraint(equalToConstant: 48),
            avatarImageView.heightAnchor.constraint(equalToConstant: 48),

            titleLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            bodyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            bodyLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            bodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with post: Post) {
        titleLabel.text = post.title ?? "(No Title)"
        bodyLabel.text = post.body ?? "(No Body)"

        if let data = post.avatarData, let image = UIImage(data: data) {
            avatarImageView.image = image
        } else {
            let url = URL(string: "https://picsum.photos/seed/\(post.userId)/200")!
            avatarImageView.image = nil
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data, let img = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self.avatarImageView.image = img
                }
                CoreDataService.shared.saveAvatarData(for: post, data: data)
            }.resume()
        }
    }
}

private let imageCache = NSCache<NSURL, UIImage>()

extension UIImageView {
    func load(url: URL) {
        if let cached = imageCache.object(forKey: url as NSURL) {
            self.image = cached
            return
        }
        self.image = nil
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let img = UIImage(data: data) {
                imageCache.setObject(img, forKey: url as NSURL)
                DispatchQueue.main.async {
                    self.image = img
                }
            }
        }.resume()
    }
} 
