
import SwiftUI
import SpriteKit

struct ReadySetGoView: View {
    @State private var showReady = false
    @State private var showSet = false
    @State private var showGo = false
    @State private var showPauseDirection = false
    
    let onFinished: () -> Void
    
    var body: some View {
        ZStack() {
            Image("aquarium")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("Ready")
                        .font(.custom("Menlo-Bold", size: 70))
                        .foregroundStyle(
                            Color(
                                red: 188 / 255,
                                green: 27 / 255,
                                blue: 27 / 255
                            )
                        )
                        .opacity(showReady ? 1: 0)
                        .padding(5)
                    Text("Set")
                        .font(.custom("Menlo-Bold", size: 70))
                        .foregroundStyle(
                            Color(
                                red: 238 / 255,
                                green: 155 / 255,
                                blue: 0
                            )
                        )
                        .opacity(showSet ? 1: 0)
                        .padding(5)
                    Text("Go")
                        .font(.custom("Menlo-Bold", size: 70))
                        .foregroundStyle(
                            Color(
                                red: 120 / 255,
                                green: 153 / 255,
                                blue: 73 / 255
                            )
                        )
                        .opacity(showGo ? 1: 0)
                }
                Text("Tap and hold to pause...")
                    .font(.custom("Menlo-Bold", size: 30))
                    .foregroundStyle(.white)
                    .opacity(showPauseDirection ? 1: 0)
            }
        }
        .task {
            await startCountdown()
        }
        .onAppear {
            if SoundManager.shared.currentTrack == "menu_music" {
                SoundManager.shared.pauseMusic()
            }
        }
    }
    
    private func startCountdown() async {
        try? await Task.sleep(for: .milliseconds(700))
        showReady = true
         
        try? await Task.sleep(for: .milliseconds(700))
        showSet = true
         
        try? await Task.sleep(for: .milliseconds(700))
        showGo = true
         
        try? await Task.sleep(for: .milliseconds(700))
        showPauseDirection = true
        
        try? await Task.sleep(for: .milliseconds(700))
        
        onFinished()
    }
}


//#Preview {
//    ReadySetGoView()
//}
