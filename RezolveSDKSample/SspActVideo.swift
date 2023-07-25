//
//  SspActVideo.swift
//  RezolveSDKSample
//
//  Created by Dennis on 25/7/23.
//  Copyright © 2023 Rezolve. All rights reserved.
//

import Foundation
import XCDYouTubeKit_kbexdev

struct Video: Equatable {
    let thumbnailURL: URL?
    let streamURL: URL
}

class SspActVideo {
    static func getYouTubeId(url: String) -> String? {
        let youtubeRegexPattern = "^.*(youtu\\.be/|v/|u/\\w/|embed/|watch\\?v=|\\&v=)([^#\\&\\?]*).*"
        lazy var youtubeRegex = try! NSRegularExpression(pattern: youtubeRegexPattern, options: .caseInsensitive)
        
        if let youtubeID = youtubeRegex.groupSubstring(at: 2, in: url) {
            return youtubeID
        }
        return nil
    }
    
    static func video(withID id: String, completion: @escaping (Video) -> Void) {
        XCDYouTubeClient.default().getVideoWithIdentifier(id) { (youtube, error) in
            if error != nil {
                print("YouTube: Unexpected error")
                return
            }
            guard let youtube = youtube else {
                print("YouTube: Missing video response")
                return
            }
            let preferredQualities: [AnyHashable] = [
                XCDYouTubeVideoQualityHTTPLiveStreaming,
                XCDYouTubeVideoQuality.medium360.rawValue,
                XCDYouTubeVideoQuality.HD720.rawValue,
                XCDYouTubeVideoQuality.small240.rawValue
            ]
            let prefferedStream = preferredQualities.compactMap({ youtube.streamURLs[$0] }).first
            guard let stream = prefferedStream ?? youtube.streamURLs.first?.value else {
                print("YouTube: Stream not found")
                return
            }
            let thumbnail = youtube.thumbnailURLs?.last
            let video = Video(
                thumbnailURL: thumbnail,
                streamURL: stream
            )
            completion(video)
        }
    }
}

extension NSRegularExpression {
    func groupSubstring(at index: Int, in string: String) -> String? {
        let fullRange = NSRange(string.startIndex..., in: string)
        guard
            let match = firstMatch(in: string, range: fullRange),
            match.numberOfRanges > index,
            let range = Range(match.range(at: index), in: string)
        else {
            return nil
        }
        return String(string[range])
    }
}
