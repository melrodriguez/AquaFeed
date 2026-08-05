import SwiftUI

struct DiedView: View {
    let onPlayAgain: () -> Void
    let onExit: () -> Void
    @State private var showImage = false
    @State private var showMenu = false
    
    var body: some View {
        ZStack() {
            Color.black
            
            Image("you_died")
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 800)
                .opacity(showImage ? 1: 0)
                .scaleEffect(showImage ? 1 : 0.5)
                .animation(.easeInOut(duration: 5.0), value: showImage)
            
            VStack() {
                Button(action: onPlayAgain) {
                    Image("play_again")
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 600)
                        .padding(50)
                        .opacity(showMenu ? 1: 0)
                }

                Button(action: onExit) {
                    Image("exit")
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 600)
                        .opacity(showMenu ? 1: 0)

                }
            }
            .allowsHitTesting(showMenu)
        }
        .aspectRatio(contentMode: .fill)
        .onAppear {
            SoundManager.shared.playMusic(named: "death", loop: false)
            
            showImage = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                showImage = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    showMenu = true
                }
            }
        }
    }
}

#Preview {
    DiedView (
        onPlayAgain: {
            print("play again")
        },
        onExit: {
           print("exit")
        }
    )
}
