import SwiftUI

// MARK: - Grown-ups gate (standard kids-app pattern)
//
// Every purchase / restore action sits behind this: a simple arithmetic
// question a toddler can't answer but a parent can. No accounts, no data.

struct ParentalGateView: View {
    var onPassed: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var a: Int = 4
    @State private var b: Int = 5
    @State private var options: [Int] = []
    @State private var wrongPick: Int? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 26) {
                Spacer()

                Text("Grown-ups only")
                    .font(.system(size: 30, weight: .black))

                Text("To keep purchases safe, please answer this:")
                    .font(.system(size: 17))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Text("\(a) + \(b) = ?")
                    .font(.system(size: 52, weight: .black))
                    .foregroundColor(.orange)

                VStack(spacing: 14) {
                    ForEach(options, id: \.self) { option in
                        Button { answer(option) } label: {
                            Text("\(option)")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(option == wrongPick ? .red : .primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(option == wrongPick
                                            ? Color.red.opacity(0.12)
                                            : Color.blue.opacity(0.10))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                        .disabled(option == wrongPick)
                    }
                }
                .padding(.horizontal, 8)

                if wrongPick != nil {
                    Text("Try again!")
                        .font(.headline)
                        .foregroundColor(.red)
                }

                Spacer()
            }
            .padding(30)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear { newQuestion() }
        }
    }

    private func newQuestion() {
        a = Int.random(in: 3...9)
        b = Int.random(in: 3...9)
        wrongPick = nil
        var set: Set<Int> = [a + b]
        while set.count < 3 {
            let delta = Int.random(in: 1...5) * (Bool.random() ? 1 : -1)
            let candidate = a + b + delta
            if candidate > 0 { set.insert(candidate) }
        }
        options = set.shuffled()
    }

    private func answer(_ option: Int) {
        if option == a + b {
            onPassed()
            dismiss()
        } else {
            wrongPick = option
        }
    }
}
