import SwiftUI
import CoreLocation

struct DetailLoadView: View {
    @Environment(\.presentationMode) var presentationMode
    let loadItem: LoadItem

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.primary.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.cardBackground)
                                .shadow(color: Color.cardShadow, radius: 10, x: 0, y: 5)

                            Image("Loads")
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .clipped()
                        }
                        .frame(height: 250)
                        .padding(.horizontal)

                        Text(loadItem.company)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)

                        Text("\(loadItem.origin) → \(loadItem.destination)")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal)

                        HStack {
                            Text("Distance: \(loadItem.distance)")
                            Spacer()
                            Text("Price: \(loadItem.price)")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal)

                        Text("Estimated Time: \(loadItem.time)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal)

                        MapView(origin: loadItem.originCoordinate, destination: loadItem.destinationCoordinate)
                            .frame(height: 300)
                        Spacer()

                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Back")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(LinearGradient.primary)
                                .cornerRadius(12)
                                .shadow(color: Color.primaryGradientEnd.opacity(0.4), radius: 8, x: 0, y: 4)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationBarTitle("Load Details", displayMode: .inline)
        }
    }
}
