import SwiftUI

struct ScoreOverlayView: View {
    let totalTime: TimeInterval
    let onFinished: () -> Void
    
    init(totalTime: TimeInterval, onFinished: @escaping () -> Void) {
        self.totalTime = totalTime
        self.onFinished = onFinished
    }
    
    var body: some View {
        ZStack() {
            Image("text_box_2")
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 700)
            
            VStack {
                Text("Current Score: " +  formatTime(totalTime))
                    .multilineTextAlignment(.center)
                    .font(.custom("Menlo-Bold", size: 40))
                    .foregroundStyle(.white)
                    .padding()
                Text("High Score: " + formatTime(GameState.shared.timeTrialHighScore))
                    .multilineTextAlignment(.center)
                    .font(.custom("Menlo-Bold", size: 40))
                    .foregroundStyle(.white)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onFinished()
            }
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let hundredths = Int((time * 100).truncatingRemainder(dividingBy: 100))

        return String(
            format: "%02d:%02d.%02d",
            minutes,
            seconds,
            hundredths
        )
    }
}

#Preview {
    ScoreOverlayView(
        totalTime: 1.0,
        onFinished: {
            print("finished")
        }
    )
}
