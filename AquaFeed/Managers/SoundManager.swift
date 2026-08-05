import AVFoundation
import SpriteKit

class SoundManager {
    static let shared = SoundManager()
    
    private var musicPlayer: AVAudioPlayer?
    private(set) var currentTrack: String?

    private init() {}
    
    func playMusic(named fileName: String, loop: Bool = true) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            return
        }
        currentTrack = fileName
        
        do {
            print("play")
            print("volume:", musicPlayer?.volume ?? -1)
            print("duration:", musicPlayer?.duration ?? 0)
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = loop ? -1 : 0
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
        } catch {
            print(error)
        }
    }
    
    func stopMusic() {
        musicPlayer?.stop()
    }
    
    func pauseMusic() {
        musicPlayer?.pause()
    }
    
    func resumeMusic() {
        musicPlayer?.play()
    }
    
    func setVolume(_ volume: Float) {
        musicPlayer?.volume = volume
    }
}
