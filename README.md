# SwipeToWatch

SwipeToWatch is a minimal TikTok-like video feed app designed to showcase short video playback in a vertically scrolling list.

---

## Features

- **Vertical Video Feed**: Display a list of short videos that users can swipe through.
- **Auto-Play**: Videos automatically play when visible and pause when off-screen.
- **User Interaction**: Like button for simple user engagement.
- **Error Handling**: Handles invalid video URLs, invalid JSON file, and failed API requests gracefully with an error message.
- **Caching**: Caches videos to prevent high data usage.
- **Customizable Settings**: Simulate fetching or JSON decoding error, shuffle video list, choose playback quality, and clear cached videos.
- **Unit Testing**: Test existing and new functionalities against new codes.

---

## Requirements

- **iOS Version**: 13.0+
- **Language**: Developed using Swift 6.0.3
- **UI Framework**: UIKit
- **Video Playback**: AVPlayer
- **Xcode Version**: Developed using Xcode 16.2

---

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/rabbanilham/SwipeToWatch/
   cd SwipeToWatch
   ```

2. Install dependencies:
   ```bash
   pod install
   ```

3. Open the project in Xcode:
   ```bash
   open SwipeToWatch.xcworkspace
   ```

4. Build and run the app in the iOS Simulator or your real device.

---

## Architecture

The app uses the MVVM (Model-View-ViewModel) pattern for clear separation of concerns. **MVVM was chosen to simplify data flow between the model and the view**, making it easier to manage state and logic independently of the UI. This ensures scalability and testability while keeping the views lightweight and focused on presentation.

- **Model**: Represents video data (e.g., duration, height, width, URL).
- **ViewModel**: Handles data binding and business logic.
- **View**: Displays the video feed and handles user interactions.

### Data Flow

#### a. From JSON file

1. `FeedsViewController` requests video data to `FeedsViewModel`.
2. `FeedsViewModel` reads JSON data from project file and parses it.
3. (Optional) The video list is shuffled if you choose to.
4. Parsed video list data is assigned to the `FeedsViewModel`'s property `videos` which is observed by `FeedsViewController`.
5. The `FeedsViewModel` provides data to the `FeedsViewController` through data binding.
6. The `AVPlayer` renders each video, while `FeedsCollectionViewCell` listens for changes in playback state.
7. Whenever an error occurs, `FeedsViewModel` will tell `FeedsViewController` to show error alert.

#### b. From API request

1. `FeedsViewController` requests video data to `FeedsViewModel`.
2. `FeedsViewModel` requests video data using `APIService`.
3. `FeedsViewModel` parses the response from the API request.
4. (Optional) The video list is shuffled if you choose to.
5. Parsed video list data is assigned to the `FeedsViewModel`'s property `videos` which is observed by `FeedsViewController`.
6. The `FeedsViewModel` provides data to the `FeedsViewController` through data binding.
7. The `AVPlayer` renders each video, while `FeedsCollectionViewCell` listens for changes in playback state.
8. Whenever an error occurs, `FeedsViewModel` will tell `FeedsViewController` to show error alert.

---

## Data Source

The app uses a locally hardcoded JSON-like structure for video metadata. Example:

```json
{
    "page": 1,
    "per_page": 80,
    "total_results": 8000,
    "next_page": "https://api.pexels.com/v1/videos/search?page=2&per_page=80&query=nature&size=medium",
    "url": "https://api-server.pexels.com/search/videos/nature/"
    "videos": [
        {
            "id": 3571264,
            "width": 3840,
            "height": 2160,
            "duration": 33,
            "full_res": null,
            "tags": [],
            "url": "https://www.pexels.com/video/drone-view-of-big-waves-rushing-to-the-shore-3571264/",
            "image": "https://images.pexels.com/videos/3571264/free-video-3571264.jpg?auto=compress&cs=tinysrgb&fit=crop&h=630&w=1200",
            "avg_color": null,
            "user": {
                "id": 1498112,
                "name": "Enrique Hoyos",
                "url": "https://www.pexels.com/@enrique"
            },
            "video_files": [
                {
                    "id": 9326316,
                    "quality": "uhd",
                    "file_type": "video/mp4",
                    "width": 2560,
                    "height": 1440,
                    "fps": 29.969999313354492,
                    "link": "https://videos.pexels.com/video-files/3571264/3571264-uhd_2560_1440_30fps.mp4",
                    "size": 56038183
                }
          ],
          "video_pictures": [
                {
                    "id": 815098,
                    "nr": 0,
                    "picture": "https://images.pexels.com/videos/3571264/pictures/preview-0.jpg"
                }
          ]
        }
    ]
}
```

### Notes:
- The data was obtained from [Pexels API](https://www.pexels.com/api/documentation/#videos-search)
- If you decide to use API call instead of using JSON file, the returned data object is the array of videos (not wrapped in `VideoListResponse`).
- The JSON file contains 80 videos, while the API response contains only 20.
- The videos from JSON file consists of portrait and landscape videos, while the API response only consists of portrait videos.
- The third video's HD resource URL from JSON file is changed on purpose (to showcase the error state if the URL is invalid)
- Video likes is added after JSON data is parsed, and it will be a random integer between 1 and 999. So everytime you refresh the feeds, the like count will be different.
- Liked video ids are saved locally.

---

## Running the App

1. Ensure you’ve followed the [Installation](#installation) steps.
2. Select a simulator or connected device in Xcode.
3. Press `Cmd + R` or click the **Run** button to launch the app.

---

## Running the Unit Testing

1. Ensure you’ve followed the [Installation](#installation) steps.
2. Select a simulator or connected device in Xcode.
3. Open `SwipeToWatchTests.swift` file (SwipeToWatchTests/SwipeToWatchTests.swift)
4. Run a unit test by tapping the run button next to the test function name.
5. If you want to run the entire test case, tap the button next to the test case class name.
6. If you want to run the all test cases, open to the test navigator (on the upper left of Xcode window) and tap the button next to `SwipeToWatchTests`

---

## Known Issues

1. Using the Ultra HD playback quality hurts performance by a lot. Workaround: use the HD or SD playback quality.
2. ~~On some rare occasions, the video playback slider behaves incorrectly. Workaround: restart the app.~~ Fixed.

---

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests to improve the project.

---

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

