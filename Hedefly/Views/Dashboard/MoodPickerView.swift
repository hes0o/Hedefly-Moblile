import SwiftUI

struct MoodPickerView: View {
    let onSelect: (Mood) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "0D0D0D").ignoresSafeArea()

            VStack(spacing: 32) {
                // Header
                VStack(spacing: 10) {
                    Text("Good morning ☀️")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("How are you feeling today?")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.top, 40)

                // Mood cards
                VStack(spacing: 16) {
                    ForEach(Mood.allCases, id: \.rawValue) { mood in
                        Button {
                            onSelect(mood)
                            dismiss()
                        } label: {
                            HStack(spacing: 16) {
                                Text(mood.emoji)
                                    .font(.system(size: 40))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(mood.label)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(mood.description)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.5))
                                        .lineLimit(2)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(hex: "A78BFA").opacity(0.6))
                            }
                            .padding(20)
                            .background(Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                Text("You can change this anytime from the dashboard")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.bottom, 24)
            }
        }
        .interactiveDismissDisabled()
    }
}
