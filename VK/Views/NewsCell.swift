//
//  NewsCell.swift
//  VK
//
//  Created by Ilyas Tyumenev on 03/09/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import UIKit
import Kingfisher

protocol NewsPostCellCellDelegate: class {
    func didTapShowMore(cell: NewsPostCell)
}

    // MARK: - NewsPostCell

final class NewsPostCell: UITableViewCell {
    
    weak var delegate: NewsPostCellCellDelegate?
    
    var isExpanded = false {
        didSet {
            updatePostLabel()
            updateShowMoreButton()
        }
    }
    
    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var publishedDateLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var showMoreButton: UIButton!
    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var repostsButton: UIButton!
    @IBOutlet weak var viewsButton: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        authorImageView?.makeCircle()
    }
    
    func configure(item: NewsItem, dateFormatter: DateFormatter) {
        authorImageView.kf.setImage(with: ImageResource(downloadURL: item.avatar!))
        authorNameLabel.text = item.author
        publishedDateLabel.text = dateFormatter.string(from: item.date)
        
        switch item.type {
        case let .post(info):
            postLabel.text = info.text
        case .photo:
            break
        }
        let labelSize = getLabelSize(text: postLabel.text ?? "", font: postLabel.font)
        showMoreButton.isHidden = labelSize.height < 200
        
        showMoreButton.setTitle("Show more...", for: .normal)
        likesButton.setTitle("\(item.likesCount)", for: .normal)
        commentsButton.setTitle("\(item.commentsCount)", for: .normal)
        repostsButton.setTitle("\(item.repostsCount)", for: .normal)
        viewsButton.setTitle("\(item.viewsCount)", for: .normal)
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    @IBAction func showMoreButtonTapped(_ sender: UIButton) {
        print(#function)
        delegate?.didTapShowMore(cell: self)
    }
    
    private func updatePostLabel() {
        postLabel.numberOfLines = isExpanded ? 0 : 10
    }
    
    private func updateShowMoreButton() {
        let title = isExpanded ? "Show less..." : "Show more..."
        showMoreButton.setTitle(title, for: .normal)
    }
    
    private func getLabelSize(text: String, font: UIFont) -> CGSize {
        let maxWidth = frame.width - 40
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(
            with: textBlock,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        let width = Double(rect.size.width)
        let height = Double(rect.size.height)
        
        return CGSize(width: ceil(width), height: ceil(height))
    }

}

    // MARK: - NewsPhotoCell

final class NewsPhotoCell: UITableViewCell {

    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var publishedDateLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var repostsButton: UIButton!
    @IBOutlet weak var viewsButton: UIButton!

    override func layoutSubviews() {
        super.layoutSubviews()
        authorImageView?.makeCircle()
    }

    func configure(item: NewsItem, dateFormatter: DateFormatter) {
        authorImageView.kf.setImage(with: ImageResource(downloadURL: item.avatar!))
        authorNameLabel.text = item.author
        publishedDateLabel.text = dateFormatter.string(from: item.date)
        switch item.type {
        case let .photo(info):
            photoImageView.kf.setImage(with: ImageResource(downloadURL: info.photos.first!.photo))
            likesButton.setTitle("\(info.photos.first?.likesCount ?? 0)", for: .normal)
            commentsButton.setTitle("\(info.photos.first?.commentsCount ?? 0)", for: .normal)
            repostsButton.setTitle("\(info.photos.first?.repostsCount ?? 0)", for: .normal)
            viewsButton.setTitle("\(info.photos.first?.viewsCount ?? 0)", for: .normal)
        case .post:
            break
        }
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
    }

}
