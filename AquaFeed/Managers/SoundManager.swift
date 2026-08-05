import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var musicPlayer: AVAudioPlayer?
    private var soundEffectPlayer: AVAudioPlayer?
    private(set) var currentTrack: String?
    
    private init() {}
    
    func playMusic(named fileName: String, loop: Bool = true) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("uih oh")
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
        print("Stop")
        musicPlayer?.stop()
    }
    
    func pauseMusic() {
        print("Pause")
        musicPlayer?.pause()
    }
    
    func resumeMusic() {
        musicPlayer?.play()
    }
    
    func setVolume(_ volume: Float) {
        musicPlayer?.volume = volume
    }
}
