import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text("iOS Demo")
                .font(.largeTitle).bold()
            Text("Built on GitHub Actions macos-latest")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
