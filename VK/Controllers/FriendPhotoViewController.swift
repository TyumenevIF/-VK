//
//  FriendPhotoViewController.swift
//  VK
//
//  Created by Ilyas Tyumenev on 13/07/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import UIKit
import Kingfisher

class FriendPhotoViewController: UIViewController, UITableViewDelegate {    
    var photos: [Photo] = []
    var currentIndex: Int = 0    
    var animator: UIViewPropertyAnimator!
    
    enum Direction {
        case left, right
        
        init(x: CGFloat) {
            self = x > 0 ? .right : .left
        }
    }
    
    lazy var nextFriendPhoto = UIImageView()
    
    // MARK: - Outlets
    @IBOutlet weak var friendPhotoImage: UIImageView!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: photos[currentIndex].imageUrl) {
            let resource = ImageResource(downloadURL: url)
            friendPhotoImage.kf.setImage(with: resource)
        }
        
        nextFriendPhoto.contentMode = .scaleAspectFit
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan))
        view.addGestureRecognizer(pan)
    }
    
    // MARK: - UIPanGestureRecognizer
    @objc func onPan(_ sender: UIPanGestureRecognizer) {
        guard let panView = sender.view else { return }
        
        let translation = sender.translation(in: panView)
        let direction = Direction(x: translation.x)
        
        switch sender.state {
        case .began:
            animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeIn, animations: {
                self.friendPhotoImage.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                self.friendPhotoImage.alpha = 0
            })
            
            if canSlide(direction) {
                let nextIndex = direction == .left ? currentIndex + 1 : currentIndex - 1
                
                if let url = URL(string: photos[nextIndex].imageUrl) {
                    let resource = ImageResource(downloadURL: url)
                    nextFriendPhoto.kf.setImage(with: resource)
                }
                
                view.addSubview(nextFriendPhoto)
                let offSetX = direction == .left ? view.bounds.width : -view.bounds.width
                nextFriendPhoto.frame = view.bounds.offsetBy(dx: offSetX, dy: 0)
                
                animator.addAnimations({
                    self.nextFriendPhoto.center = self.friendPhotoImage.center
                    self.nextFriendPhoto.alpha = 1
                    
                }, delayFactor: 0.15)
                
                animator.addCompletion { (position) in
                    guard position == .end else { return }
                    self.currentIndex = direction == .left ? self.currentIndex + 1 : self.currentIndex - 1
                    self.friendPhotoImage.alpha = 1
                    self.friendPhotoImage.transform = .identity
                    
                    if let url = URL(string: self.photos[self.currentIndex].imageUrl) {
                        let resource = ImageResource(downloadURL: url)
                        self.friendPhotoImage.kf.setImage(with: resource)
                    }
                    
                    self.nextFriendPhoto.removeFromSuperview()
                }
                
                animator.pauseAnimation()                
            }
            
        case .changed:
            animator.fractionComplete = abs(translation.x) / panView.frame.width
            
        case .ended:
            if canSlide(direction), animator.fractionComplete > 0.6 {
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            } else {
                animator.stopAnimation(true)
                UIView.animate(withDuration: 0.25) {
                    self.friendPhotoImage.transform = .identity
                    self.friendPhotoImage.alpha = 1
                    let offSetX = direction == .left ? self.view.bounds.width : -self.view.bounds.width
                    self.nextFriendPhoto.frame = self.view.bounds.offsetBy(dx: offSetX, dy: 0)
                }
            }
            
        default:
            break
        }        
    }
    
    func canSlide(_ direction: Direction) -> Bool {
        if direction == .left {
            return currentIndex < photos.count - 1
        } else {
            return currentIndex > 0
        }
    }
}
