import SwiftUI

struct PauseMenuView: View {
    let onResume: () -> Void
    let onRestart: () -> Void
    let onChangePets: () -> Void
    let onExit: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image("pause")
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 700)
            
            Button(action: onResume) {
                Image("resume")
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 500)
                    .padding(.top, 50)
            }
            
            Button(action: onRestart) {
                Image("restart")
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 500)
                    .padding(.top, 50)
            }
            
            Button(action: onChangePets) {
                Image("change_pets")
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 500)
                    .padding(.top, 50)
            }

            Button(action: onExit) {
                Image("exit")
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 500)
                    .padding(.top, 50)
            }
            
            Spacer()
        }
        .padding(.top, 30)
    }
}
