//
//  FeedsViewController.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 25/01/2025.
//

import Combine
import SnapKit
import UIKit

final class FeedsViewController: UIViewController {
    // MARK: - Private Properties -
    
    private var cancellables = Set<AnyCancellable>()
    private var isFirstAppearance = true
    private let viewModel = FeedsViewModel()
    
    // MARK: - UI Properties -
    
    private lazy var mainContainerView: UIView = {
        let view = UIView()
        view.addSubviews(feedsCollectionView, loadingView)
        feedsCollectionView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        loadingView.snp.makeConstraints { $0.center.equalToSuperview() }
        
        return view
    }()
    
    private lazy var feedsCollectionView: FeedsCollectionView = {
        let collectionView = FeedsCollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.feedsDelegate = self
        collectionView.refreshControl = refreshControl
        
        return collectionView
    }()
    
    private lazy var loadingView: UIView = {
        let indicatorView = UIActivityIndicatorView(style: .medium)
        indicatorView.color = .systemPink
        indicatorView.startAnimating()
        
        let label = UILabel()
        label.text = "Loading feeds..."
        label.textColor = .black
        
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = .white
        view.layer.cornerCurve = .continuous
        view.layer.cornerRadius = 16
        
        view.addSubviews(indicatorView, label)
        view.snp.makeConstraints { $0.height.equalTo(48) }
        indicatorView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        label.snp.makeConstraints { make in
            make.leading.equalTo(indicatorView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        return view
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .systemPink
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        return refreshControl
    }()
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupBindings()
        fetchVideos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isFirstAppearance {
            feedsCollectionView.togglePlayCurrentPage(to: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        feedsCollectionView.togglePlayCurrentPage(to: false)
    }
}

extension FeedsViewController: FeedsCollectionViewDelegate {
    func didTapLikeButton(video: Video) {
        viewModel.toggleLikeVideo(video)
    }
    
    func didTapShareButton(video: Video) {
        //
    }
}

extension FeedsViewController {
    func beginFeedsRefresh(usingRefreshControl: Bool) async {
        guard !viewModel.isLoading else { return }
        tabBarItem.selectedImage = UIImage(systemName: "arrow.clockwise")
        if usingRefreshControl {
            refreshControl.beginRefreshing()
        }

        do {
            await viewModel.fetchVideos()
        }
        
        refreshControl.endRefreshing()
        tabBarItem.selectedImage = UIImage(systemName: "list.and.film")
        
        if !usingRefreshControl, viewModel.errorMessage == nil {
            scrollFeedsToTop()
        }
    }
}

private extension FeedsViewController {
    func configureUI() {
        navigationItem.title = "Feeds"
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        view.addSubview(mainContainerView)
        mainContainerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        refreshControl.snp.makeConstraints { make in
            make.height.equalTo(100)
            make.centerX.equalToSuperview()
        }
    }
    
    func setupBindings() {
        // Observe the `videos` property
        viewModel.$videos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] videos in
                guard let self = self else { return }
                self.feedsCollectionView.setVideos(videos)
                self.feedsCollectionView.toggleShowEmptyState(to: videos.isEmpty && self.viewModel.errorMessage == nil && !self.viewModel.isLoading && !isFirstAppearance)
                self.isFirstAppearance = false
            }
            .store(in: &cancellables)
        
        // Observe the `isLoading` property
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading, !self.refreshControl.isRefreshing {
                    self.loadingView.fadeIn()
                } else {
                    self.loadingView.fadeOut()
                }
            }
            .store(in: &cancellables)
        
        // Observe the `errorMessage` property
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                guard let self = self else { return }
                if let errorMessage = errorMessage {
                    self.showErrorAlert(message: errorMessage)
                    self.feedsCollectionView.toggleShowEmptyState(to: false)
                } else {
                    self.feedsCollectionView.setError(with: nil)
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchVideos() {
        Task {
            await viewModel.fetchVideos()
        }
    }
    
    func scrollFeedsToTop() {
        feedsCollectionView.scrollFeedsToTop()
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "An Error Occured",
            message: message,
            preferredStyle: .alert
        )
        let closeAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if self.viewModel.videos.isEmpty {
                self.feedsCollectionView.setError(with: message)
            }
        }
        alert.addAction(closeAction)
        
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    @objc
    func handleRefresh() {
        Task {
            await beginFeedsRefresh(usingRefreshControl: true)
        }
    }
}
