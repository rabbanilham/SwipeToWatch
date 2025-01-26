//
//  FeedsCollectionView.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 25/01/2025.
//

import UIKit

enum ScrollDestination {
    case next, current, previous
}

protocol FeedsCollectionViewDelegate: AnyObject {
    func didTapLikeButton(video: Video)
    func didTapShareButton(video: Video)
}

final class FeedsCollectionView: UICollectionView {
    // MARK: - Private Properties -
    
    private var videos = [Video]()
    private var currentShownVideoIndex: Int = 0
    private var lastScrollDestination = ScrollDestination.current
    private var errorMessage: String?
    private var isError: Bool {
        return errorMessage != nil && errorMessage?.isEmpty == false && videos.isEmpty
    }
    
    // MARK: - Public Properties -
    
    weak var feedsDelegate: FeedsCollectionViewDelegate?
    
    // MARK: - UI Properties -
    
    private lazy var emptyStateView = createEmptyStateView()
    
    // MARK: - Lifecycle -
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0), // Full width
                heightDimension: .fractionalHeight(1.0) // Full height of the screen
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0), // Full width
                heightDimension: .fractionalHeight(1.0) // Full height
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)

            return section
        })
        backgroundColor = .black
        contentInsetAdjustmentBehavior = .never
        decelerationRate = .fast
        delegate = self
        dataSource = self
        isPagingEnabled = true
        scrollsToTop = false
        showsVerticalScrollIndicator = false
        register(FeedsCollectionViewCell.self, forCellWithReuseIdentifier: "\(FeedsCollectionViewCell.self)")
        register(FeedsErrorCell.self, forCellWithReuseIdentifier: "\(FeedsErrorCell.self)")
        
        addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { make in
            make.horizontalEdges.centerY.centerX.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
        dataSource = self
    }
}

extension FeedsCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isError ? 1 : videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isError {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(FeedsErrorCell.self)", for: indexPath) as? FeedsErrorCell else { return UICollectionViewCell() }
            cell.configure(message: errorMessage ?? "")
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(FeedsCollectionViewCell.self)", for: indexPath) as? FeedsCollectionViewCell else { return UICollectionViewCell() }
            let index = indexPath.item
            cell.delegate = self
            cell.configure(with: videos[index])
            if index == 0 {
                cell.togglePlayback(to: true)
            }
            
            return cell
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageHeight = scrollView.frame.height
        var destination = ScrollDestination.current
        
        // Calculate target page index
        let targetIndex = Int(round(targetContentOffset.pointee.y / pageHeight))
        
        if targetIndex > currentShownVideoIndex {
            destination = .next
        } else if targetIndex < currentShownVideoIndex {
            destination = .previous
        }
        
        switch destination {
        case .next:
            guard let currentCell = cellForItem(at: IndexPath(item: currentShownVideoIndex, section: 0)) as? FeedsCollectionViewCell,
                  let nextCell = cellForItem(at: IndexPath(item: currentShownVideoIndex + 1, section: 0)) as? FeedsCollectionViewCell
            else { return }
            currentCell.togglePlayback(to: false)
            nextCell.togglePlayback(to: true)
        case .current:
            break
        case .previous:
            guard let currentCell = cellForItem(at: IndexPath(item: currentShownVideoIndex, section: 0)) as? FeedsCollectionViewCell,
                  let previousCell = cellForItem(at: IndexPath(item: currentShownVideoIndex - 1, section: 0)) as? FeedsCollectionViewCell
            else { return }
            currentCell.togglePlayback(to: false)
            previousCell.togglePlayback(to: true)
        }
        
        lastScrollDestination = destination
        
        // Update the current index
        currentShownVideoIndex = targetIndex
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        switch lastScrollDestination {
        case .next:
            guard let previousCell = cellForItem(at: IndexPath(item: currentShownVideoIndex - 1, section: 0)) as? FeedsCollectionViewCell
            else { return }
            previousCell.configureToZero()
        case .previous:
            guard let nextCell = cellForItem(at: IndexPath(item: currentShownVideoIndex + 1, section: 0)) as? FeedsCollectionViewCell
            else { return }
            nextCell.configureToZero()
        default:
            break
        }
    }
}

extension FeedsCollectionView: FeedsCollectionViewCellDelegate {
    func didTapLikeButton(video: Video) {
        feedsDelegate?.didTapLikeButton(video: video)
    }
    
    func didTapShareButton(video: Video) {
        feedsDelegate?.didTapShareButton(video: video)
    }
}

extension FeedsCollectionView {
    func setVideos(_ videos: [Video]) {
        self.videos = videos
        self.reloadData()
    }
    
    func togglePlayCurrentPage(to isPlaying: Bool) {
        guard let currentCell = cellForItem(at: IndexPath(item: currentShownVideoIndex, section: 0)) as? FeedsCollectionViewCell else { return }
        currentCell.togglePlayback(to: isPlaying, showPauseButton: true)
    }
    
    func setError(with message: String?) {
        self.errorMessage = message
        reloadData()
    }
    
    func toggleShowEmptyState(to isShown: Bool) {
        if isShown {
            emptyStateView.fadeIn()
        } else {
            emptyStateView.fadeOut()
        }
    }
}

private extension FeedsCollectionView {
    func createEmptyStateView() -> UIView {
        let emoticonLabel = UILabel()
        emoticonLabel.font = .systemFont(ofSize: 36)
        emoticonLabel.text = "🥱"
        emoticonLabel.textAlignment = .center
        
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.text = "No videos for now..."
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        
        let descriptionLabel = UILabel()
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = "Try refresh the feeds again simply by pulling down"
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [emoticonLabel, titleLabel, descriptionLabel])
        stackView.alignment = .center
        stackView.alpha = 0
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        
        return stackView
    }
}
