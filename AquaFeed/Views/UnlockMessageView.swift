import SwiftUI

struct UnlockMessageView: View {
    let message = "You\n unlocked\ntime trial\n mode,\n click play\n to check\n it out!"
    let onFinished: () -> Void
    
    @State private var displayText = ""
    
    var body: some View {
        ZStack() {
            Image("text_box_1")
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 600)
            
            Text(displayText)
                .multilineTextAlignment(.center)
                .font(.custom("Menlo-Bold", size: 70))
                .foregroundStyle(.white)
                .onAppear {
                    for i in 1...message.count {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                            displayText = String(message.prefix(i))
                            
                            if i == message.count {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    onFinished()
                                }
                            }
                        }
                    }
                }
        }
    }
}

#Preview {
    UnlockMessageView {
        print("done")
    }
}
