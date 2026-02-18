import SwiftUI

struct DiceRollerView: View {
    @Environment(\.dismiss) private var dismiss

    let diceSides = [4, 6, 8, 10, 12, 20, 100]

    @State private var result: Int? = nil
    @State private var selectedDie: Int = 20
    @State private var isRolling = false
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            Color(white: 0.06).ignoresSafeArea()

            VStack(spacing: 32) {

                // Result display
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 140, height: 140)
                    if let result {
                        VStack(spacing: 2) {
                            Text("\(result)")
                                .font(.system(size: 56, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Text("d\(selectedDie)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                        .rotationEffect(.degrees(rotation))
                    } else {
                        Text("d\(selectedDie)")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.white.opacity(0.3))
                    }
                }

                // Die selector
                HStack(spacing: 10) {
                    ForEach(diceSides, id: \.self) { sides in
                        Button(action: { selectedDie = sides; result = nil }) {
                            Text("d\(sides)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(selectedDie == sides ? .black : .white)
                                .frame(width: 44, height: 36)
                                .background(selectedDie == sides ? Color.white : Color.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }

                // Roll button
                Button(action: roll) {
                    Text("Roll")
                        .font(.system(size: 17, weight: .black))
                        .foregroundColor(.black)
                        .frame(width: 140, height: 50)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                .disabled(isRolling)
            }
            .padding(.vertical, 40)
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.fraction(0.5)])
    }

    private func roll() {
        isRolling = true
        // Quick shake animation
        withAnimation(.easeInOut(duration: 0.08).repeatCount(5, autoreverses: true)) {
            rotation = 15
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring()) {
                rotation = 0
                result = Int.random(in: 1...selectedDie)
                isRolling = false
            }
        }
    }
}
