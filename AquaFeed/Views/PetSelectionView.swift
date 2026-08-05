import SwiftUI
import SpriteKit

struct PetSelectionView: View {
    let MaxPetsToSpawn: Int = 3
    @State private var petsToSpawn: [PetType] = []
    @State private var petName: String = ""
    @State private var petDescription: String = ""
    let onContinue: ([PetType]) -> Void
    
    var body: some View {
        ZStack() {
            Color(
                red: 16 / 255,
                green: 111 / 255,
                blue: 146 / 255
            )
            .scaledToFill()

            VStack() {
                Text("Choose Pet")
                    .font(.custom("Menlo-Bold", size: 80))
                    .foregroundStyle(.white)
                
                HStack {
                    ForEach(GameState.shared.pets.filter { $0.unlocked }) { pet in
                        ZStack() {
                            Rectangle()
                                .fill(petsToSpawn.contains(pet.type)
                                      ? Color.gray
                                      : Color.clear
                                )
                                .stroke(Color.yellow, lineWidth: 5)
                                .frame(width: 200, height: 200)
                            
                            let cgImage = pet.texture.cgImage()
                            
                            Button(action: {
                                addToPetsToSpawn(pet.type)
                            }) {
                                Image(uiImage: UIImage(cgImage: cgImage))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150)
                                    .padding(50)
                            }
                        }
                    }
                }
                
                Text(petName)
                    .font(.custom("Menlo-Bold", size: 70))
                    .foregroundStyle(.white)
                    .padding()
                Text(petDescription)
                    .font(.custom("Menlo-Bold", size: 50))
                    .foregroundStyle(.white)

                Button {
                    sendPetsToSpawnList()
                    onContinue(petsToSpawn)
                } label: {
                    Image("continue")
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 600)

                }
                .offset(y: 80)
            }
        }
        .aspectRatio(contentMode: .fill)
        .onAppear {
            if SoundManager.shared.currentTrack != "menu_music" {
                SoundManager.shared.playMusic(named: "menu_music")
            }
        }
    }
    
    func addToPetsToSpawn(_ pet: PetType) {
        if let index = petsToSpawn.firstIndex(of: pet) {
            petsToSpawn.remove(at: index)
        } else if petsToSpawn.count < MaxPetsToSpawn {
            petsToSpawn.append(pet)
        }
        
        petName = pet.displayName
        petDescription = pet.description
    }
    
    func sendPetsToSpawnList() {
        if let index = petsToSpawn.firstIndex(of: PetType.niko) {
            petsToSpawn.insert(petsToSpawn.remove(at: index), at: 0)
        }
        
        onContinue(petsToSpawn)
    }
}

#Preview {
    PetSelectionView { pets in
        print("Selected pets:", pets)
    }
}

