//
//  FeedsCollectionViewCell.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 25/01/2025.
//

import AVFoundation
import SnapKit
import UIKit

protocol FeedsCollectionViewCellDelegate: AnyObject {
    func didTapLikeButton(video: Video)
    func didTapShareButton(video: Video)
}

final class FeedsCollectionViewCell: UICollectionViewCell {
    // MARK: - Private Properties -
    
    private var chaseTime: CMTime = .zero
    private var isSeekInProgress = false
    private var isPlaying = false
    private var previousIntegerSecond: Int?
    private var video: Video?
    
    // MARK: - Public Properties -
    
    weak var delegate: FeedsCollectionViewCellDelegate?
    
    // MARK: - AV Properties -
    
    private lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer()
        layer.contentsGravity = .center
        layer.videoGravity = .resizeAspect
        
        return layer
    }()
    
    private var player: AVPlayer? {
        didSet {
            playerLayer.player = player
            addObservers()
        }
    }
    private var timeObserver: Any?
    
    // MARK: - UI Properties -
    
    private lazy var mainContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCell)))
        
        view.addSubviews(videoView, activityIndicator, pausedIndicatorImageView, errorView, usernameLabel, buttonsStackView, videoSliderLabel, videoSlider)
        videoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        activityIndicator.snp.makeConstraints { $0.center.equalToSuperview() }
        pausedIndicatorImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(48)
        }
        errorView.snp.makeConstraints { make in
            make.centerY.horizontalEdges.equalToSuperview()
        }
        usernameLabel.snp.makeConstraints { make in
            make.leading.equalTo(view.layoutMarginsGuide).offset(16)
            make.bottom.equalTo(videoSlider.snp.top).offset(-16)
        }
        buttonsStackView.snp.makeConstraints { make in
            make.trailing.equalTo(view.layoutMarginsGuide).inset(16)
            make.bottom.equalTo(videoSlider.snp.top).offset(-16)
        }
        videoSliderLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(videoSlider.snp.top).offset(-8)
        }
        videoSlider.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.layoutMarginsGuide).inset(16)
            make.bottom.equalTo(view.layoutMarginsGuide)
        }
        
        return view
    }()
    
    private lazy var videoView: UIView = {
        let view = UIView()
        view.layer.addSublayer(playerLayer)
        
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        
        return indicator
    }()
    
    private lazy var pausedIndicatorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.alpha = 0
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private lazy var errorView: UIView = {
        let imageView = UIImageView(image: UIImage(systemName: "play.slash.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.numberOfLines = 0
        titleLabel.text = "This video can't be played"
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        
        let view = UIView()
        view.alpha = 0
        
        view.addSubviews(imageView, titleLabel, errorDescriptionLabel)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(48)
            make.top.centerX.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview()
        }
        errorDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        
        return view
    }()
    
    private lazy var errorDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        
        return label
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .white
        
        return label
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, shareButton])
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 24
        
        return stackView
    }()
    
    private lazy var likeButton: LikeButton = {
        let button = LikeButton()
        button.delegate = self
        button.configure(image: UIImage(systemName: "heart")?.withTintColor(.white, renderingMode: .alwaysOriginal), text: "0")
        
        return button
    }()
    
    private lazy var commentButton: FeedButton = {
        let button = FeedButton()
        button.delegate = self
        button.configure(image: UIImage(systemName: "ellipsis.bubble")?.withTintColor(.white, renderingMode: .alwaysOriginal), text: "\(Int.random(in: 0...999))")
        
        return button
    }()
    
    private lazy var shareButton: FeedButton = {
        let button = FeedButton()
        button.delegate = self
        button.configure(image: UIImage(systemName: "square.and.arrow.up")?.withTintColor(.white, renderingMode: .alwaysOriginal))
        
        return button
    }()
    
    private lazy var videoSliderLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .white
        
        return label
    }()
    
    private lazy var videoSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.setThumbImage(nil, for: .normal)
        slider.tintColor = .systemPink
        slider.value = 0
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderTouchEnded), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderTouchEnded), for: .touchUpOutside)
        
        return slider
    }()
    
    private lazy var impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    // MARK: - Lifecycle -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configurePrepareForReuse()
    }
}

extension FeedsCollectionViewCell: FeedButtonDelegate {
    func didTapButton(_ button: FeedButton) {
        guard let video = video else { return }
        switch button {
        case likeButton:
            impactFeedbackGenerator.impactOccurred(intensity: 2)
            delegate?.didTapLikeButton(video: video)
        case shareButton:
            delegate?.didTapShareButton(video: video)
        default:
            break
        }
    }
}

extension FeedsCollectionViewCell {
    func configure(with video: Video) {
        errorView.alpha = 0
        videoSlider.alpha = 1
        videoSlider.value = 0
        isPlaying = false
        
        self.video = video
        likeButton.configure(text: "\(video.likes ?? 0)")
        if let videoId = video.id, UserPreference.shared.likedVideoIds.contains(videoId) {
            likeButton.toggleLiked(to: true)
        }
        usernameLabel.text = video.user?.name
        setupPlayer()
    }
    
    func togglePlayback(
        to isPlaying: Bool,
        showPauseButton: Bool = false,
        stopStreaming: Bool = false
    ) {
        guard errorView.alpha != 1 else { return }
        self.isPlaying = isPlaying
        if showPauseButton {
            if isPlaying {
                pausedIndicatorImageView.image = UIImage(systemName: "play.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
                pausedIndicatorImageView.fadeOut(delay: 0.5)
            } else {
                pausedIndicatorImageView.image = UIImage(systemName: "pause.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
                pausedIndicatorImageView.fadeIn()
            }
        } else {
            pausedIndicatorImageView.alpha = 0
        }
        if isPlaying {
            player?.play()
        } else {
            player?.pause()
            if stopStreaming {
                player?.replaceCurrentItem(with: nil)
            }
        }
    }
    
    func configureToZero() {
        player?.seek(to: .zero)
    }
}

extension FeedsCollectionViewCell {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem else { return }
        
        switch keyPath ?? "" {
        case .status:
            switch playerItem.status {
            case .readyToPlay:
                activityIndicator.stopAnimating()
                setupSliderObserver()
                print("Player is ready to play")
            case .failed:
                if let error = playerItem.error {
                    configurePlaybackError(error)
                    print("Playback failed with error: \(error.localizedDescription)")
                }
            default:
                break
            }
        case .error:
            if let error = playerItem.error {
                configurePlaybackError(error)
                print("Error observed: \(error.localizedDescription)")
            }
        case .isPlaybackLikelyToKeepUp:
            handleBuffering(!playerItem.isPlaybackLikelyToKeepUp)
        case .isPlaybackBufferEmpty:
            handleBuffering(playerItem.isPlaybackBufferEmpty)
        default:
            break
        }
    }
}

private extension FeedsCollectionViewCell {
    func configureUI() {
        contentView.addSubview(mainContainerView)
        mainContainerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        impactFeedbackGenerator.prepare()
    }
    
    func setupPlayer() {
        guard let videoUrlString = video?.videoFiles?.first(where: { $0.quality == UserPreference.shared.playbackQuality.rawValue })?.link,
              let videoUrl = URL(string: videoUrlString) else {
            activityIndicator.stopAnimating()
            let errorDescription = "No asset URL available for this video"
            errorDescriptionLabel.text = errorDescription
            errorView.fadeIn()
            print("Error: \(errorDescription)")
            return
        }
        
        // Initialize player
        // Play from cache if there is any cache
        if let cacheUrl = VideoCache.shared.video(for: videoUrl) {
            print("Using video from local storage")
            player = AVPlayer(url: cacheUrl)
        } else { // play from cloud storage if there is no cache
            player = AVPlayer(url: videoUrl)
            VideoDownloadManager.shared.downloadVideo(from: videoUrl) { cachedUrl in
                guard let cachedUrl = cachedUrl else { return }
                print("Video cached at: \(cachedUrl)")
            }
        }
        
        // Set the playerLayer player
        guard let player = player else { return }
        playerLayer.player = player
        
        // Ensure the player layer fills the video view
        DispatchQueue.main.async {
            self.playerLayer.frame = self.videoView.bounds
            self.videoView.layer.masksToBounds = true
        }
    }
    
    func setupSliderObserver() {
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 60), queue: .main) { [weak self] time in
            guard let self = self,
                  let duration = self.player?.currentItem?.duration
            else { return }
            let currentTime = CMTimeGetSeconds(time)
            let totalTime = CMTimeGetSeconds(duration)
            self.videoSlider.value = Float(currentTime / totalTime)
        }
    }
    
    func addObservers() {
        guard let playerItem = player?.currentItem else { return }
        
        playerItem.addObserver(self, forKeyPath: .status, options: [.new, .initial], context: nil)
        playerItem.addObserver(self, forKeyPath: .error, options: [.old, .new], context: nil)
        playerItem.addObserver(self, forKeyPath: .isPlaybackLikelyToKeepUp, options: [.new], context: nil)
        playerItem.addObserver(self, forKeyPath: .isPlaybackBufferEmpty, options: [.new], context: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidReachEnd(_:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
    }
    
    func removeObservers() {
        guard let playerItem = player?.currentItem else { return }
        
        playerItem.removeObserver(self, forKeyPath: .status)
        playerItem.removeObserver(self, forKeyPath: .error)
        playerItem.removeObserver(self, forKeyPath: .isPlaybackLikelyToKeepUp)
        playerItem.removeObserver(self, forKeyPath: .isPlaybackBufferEmpty)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        timeObserver = nil
        player = nil
    }

    
    func handleBuffering(_ isBuffering: Bool) {
        if isBuffering {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func stopPlayingAndSeekSmoothlyToTime(newChaseTime: CMTime) {
        player?.pause()
        if isSeekInProgress {
            toggleSeekState(to: true)
        }
        
        if CMTimeCompare(newChaseTime, chaseTime) != 0 {
            chaseTime = newChaseTime
            
            if !isSeekInProgress {
                trySeekToChaseTime()
            }
        }
    }
    
    func trySeekToChaseTime() {
        if player?.currentItem?.status == .unknown {
            // wait until item becomes ready (KVO player.currentItem.status)
        } else if player?.currentItem?.status == .readyToPlay {
            actuallySeekToTime()
        }
    }
    
    func actuallySeekToTime() {
        isSeekInProgress = true
        let seekTimeInProgress = chaseTime
        
        videoSliderLabel.text = "\(formatSecondsToTimeString(seconds: Int(seekTimeInProgress.seconds))) / \(formatSecondsToTimeString(seconds: video?.duration ?? 0))"
        player?.seek(to: seekTimeInProgress, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] isFinished in
            guard let self = self else { return }
            if CMTimeCompare(seekTimeInProgress, self.chaseTime) == 0 {
                self.isSeekInProgress = false
            } else {
                self.trySeekToChaseTime()
            }
        }
    }
    
    func toggleSeekState(to isSeeking: Bool) {
        if isSeeking {
            videoSliderLabel.fadeIn()
            usernameLabel.fadeOut()
            buttonsStackView.fadeOut()
            pausedIndicatorImageView.fadeOut()
        } else {
            videoSliderLabel.fadeOut()
            usernameLabel.fadeIn()
            buttonsStackView.fadeIn()
            if !isPlaying {
                pausedIndicatorImageView.fadeIn()
            }
        }
    }
    
    func configurePrepareForReuse() {
        configureToZero()
        activityIndicator.startAnimating()
        likeButton.toggleLiked(to: false)
        videoSlider.value = 0
        pausedIndicatorImageView.alpha = 0
        errorView.alpha = 0
        removeObservers()
    }
    
    func configurePlaybackError(_ error: Error) {
        activityIndicator.stopAnimating()
        errorDescriptionLabel.text = error.localizedDescription
        errorView.fadeIn()
        videoSlider.fadeOut()
    }
    
    @objc
    func sliderValueChanged(_ sender: UISlider) {
        guard errorView.alpha != 1 else { return }
        let totalDuration = player?.currentItem?.asset.duration.seconds ?? 0
        let newSeconds = totalDuration * Double(sender.value)
        let currentIntegerSecond = Int(newSeconds)
        if currentIntegerSecond != previousIntegerSecond {
            impactFeedbackGenerator.impactOccurred()
            previousIntegerSecond = currentIntegerSecond
        }
        stopPlayingAndSeekSmoothlyToTime(newChaseTime: CMTime.init(seconds: newSeconds, preferredTimescale: 1000))
    }
    
    @objc
    func sliderTouchEnded(_ sender: UISlider) {
        videoSliderLabel.fadeOut()
        if isPlaying {
            player?.play()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.toggleSeekState(to: false)
        }
    }
    
    @objc
    func playerDidReachEnd(_ notification: Notification) {
        player?.seek(to: .zero)
        player?.play()
    }
    
    @objc
    func didTapCell() {
        togglePlayback(to: !isPlaying, showPauseButton: true)
    }
}

// MARK: - Observer Key Paths -
private extension String {
    static let status = "status"
    static let error = "error"
    static let isPlaybackLikelyToKeepUp = "isPlaybackLikelyToKeepUp"
    static let isPlaybackBufferEmpty = "isPlaybackBufferEmpty"
}
