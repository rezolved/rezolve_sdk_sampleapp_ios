import UIKit
import AVKit

final class VideoCell: UITableViewCell {
    
    @IBOutlet weak var playerView: UIView!
    var player = AVPlayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        player = AVPlayer()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = playerView.bounds
        playerView.layer.addSublayer(playerLayer)
    }
    
    func configure(with url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.soloAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
             print(error)
        }
        
        guard let id = SspActVideo.getYouTubeId(url: url.absoluteString) else {
            return
        }
        SspActVideo.video(withID: id) { [unowned self] (video) in
            print(video.streamURL)
            print(video.thumbnailURL ?? "")
            
            self.player.replaceCurrentItem(with: AVPlayerItem(url: video.streamURL))
            self.player.play()
        }
    }
}
