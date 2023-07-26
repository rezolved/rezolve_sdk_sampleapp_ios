import UIKit
import AVKit
import Kingfisher

final class VideoCell: UITableViewCell {
    
    @IBOutlet weak var thumbView: UIImageView!
    @IBOutlet weak var playerView: VideoContainerView!
    var player = AVPlayer()
    var isPlaying = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        player = AVPlayer()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = playerView.bounds
        playerView.layer.addSublayer(playerLayer);
        playerView.playerLayer = playerLayer;
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
            self.thumbView.kf.setImage(with: video.thumbnailURL)
            self.player.replaceCurrentItem(with: AVPlayerItem(url: video.streamURL))
        }
    }
    
    func playStop() {
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
            thumbView.isHidden = true
        }
    }
}

class VideoContainerView: UIView {
    var playerLayer: CALayer?
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        playerLayer?.frame = self.bounds
    }
}
