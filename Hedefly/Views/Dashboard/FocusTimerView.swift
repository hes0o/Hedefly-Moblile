import SwiftUI

struct FocusTimerView: View {
    let task: HTask
    let onComplete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var secondsLeft: Int = 25 * 60
    @State private var isRunning  = false
    @State private var showBreak  = false
    @State private var showSummary = false
    @State private var timer: Timer? = nil

    private var minutesLeft: Int { secondsLeft / 60 }
    private var secsDisplay:  Int { secondsLeft % 60 }
    private var progress: Double { 1.0 - Double(secondsLeft) / (25.0 * 60) }

    var body: some View {
        ZStack {
            Color(hex: "0D0D0D").ignoresSafeArea()

            if showSummary {
                summaryView
            } else if showBreak {
                breakView
            } else {
                timerView
            }
        }
        .onDisappear { timer?.invalidate() }
    }

    // MARK: – Timer screen
    private var timerView: some View {
        VStack(spacing: 40) {
            // Task label
            VStack(spacing: 6) {
                Text("Focus Mode").font(.caption).foregroundColor(Color(hex: "A78BFA"))
                Text(task.title)
                    .font(.title2).bold()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Ring timer
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 14)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(colors: [Color(hex: "7C3AED"), Color(hex: "A78BFA")],
                                        center: .center),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                VStack(spacing: 4) {
                    Text(String(format: "%02d:%02d", minutesLeft, secsDisplay))
                        .font(.system(size: 56, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text(isRunning ? "Focusing…" : "Paused")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .frame(width: 240, height: 240)

            // Controls
            HStack(spacing: 24) {
                Button {
                    dismiss()
                } label: {
                    Label("Cancel", systemImage: "xmark.circle")
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.horizontal, 20).padding(.vertical, 12)
                        .background(Color.white.opacity(0.06))
                        .clipShape(Capsule())
                }

                Button {
                    isRunning ? pauseTimer() : startTimer()
                } label: {
                    Label(isRunning ? "Pause" : "Start",
                          systemImage: isRunning ? "pause.fill" : "play.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 28).padding(.vertical, 14)
                        .background(LinearGradient(colors: [Color(hex: "7C3AED"), Color(hex: "4F46E5")],
                                                   startPoint: .leading, endPoint: .trailing))
                        .clipShape(Capsule())
                }
            }

            Button("Mark as Done") {
                pauseTimer()
                onComplete()
                showSummary = true
            }
            .font(.subheadline)
            .foregroundColor(Color(hex: "10B981"))
        }
        .padding()
        .onAppear { startTimer() }
    }

    // MARK: – Break screen
    private var breakView: some View {
        VStack(spacing: 32) {
            Text("☕").font(.system(size: 72))
            Text("Take a Break!")
                .font(.title).bold().foregroundColor(.white)
            Text("You finished a focus session. Rest for 5 minutes.")
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 40)

            HStack(spacing: 16) {
                Button("Skip Break") {
                    showBreak = false
                    secondsLeft = 25 * 60
                    startTimer()
                }
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 20).padding(.vertical, 12)
                .background(Color.white.opacity(0.06))
                .clipShape(Capsule())

                Button("Done for now") {
                    onComplete()
                    showSummary = true
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24).padding(.vertical, 12)
                .background(LinearGradient(colors: [Color(hex: "7C3AED"), Color(hex: "4F46E5")],
                                           startPoint: .leading, endPoint: .trailing))
                .clipShape(Capsule())
            }
        }
        .padding()
    }

    // MARK: – Summary screen
    private var summaryView: some View {
        VStack(spacing: 32) {
            Text("🎉").font(.system(size: 72))
            VStack(spacing: 8) {
                Text("Great Work!")
                    .font(.title).bold().foregroundColor(.white)
                Text("You completed your focus session.")
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("✅  \(task.title)")
                    .foregroundColor(Color(hex: "10B981"))
                    .font(.headline)
            }
            .padding(16)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal)

            Button("Back to Dashboard") { dismiss() }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(LinearGradient(colors: [Color(hex: "7C3AED"), Color(hex: "4F46E5")],
                                           startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 32)
        }
        .padding()
    }

    // MARK: – Helpers
    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if secondsLeft > 0 {
                secondsLeft -= 1
            } else {
                pauseTimer()
                showBreak = true
            }
        }
    }

    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
}
