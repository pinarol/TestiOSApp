import Foundation
import SwiftUI
import GravatarUI

struct ImageResultView: View {
    let image: UIImage
    @State var isGravatarQEPresented: Bool = false
    let email: String = "pinarolguc@gmail.com"
    @State var logoutButtonID: String = ""
    @State var showFullAppAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(uiImage: image)
                .resizable()
                .frame(width: 300, height: 300)
            VStack(alignment: .leading) {
                ScrollView {
                    menuButton(
                        icon: {
                            Image(uiImage: UIImage(named: "gravatar")!.withRenderingMode(.alwaysTemplate))
                                .resizable()
                                .background(Color.white)
                                .foregroundColor(Color(UIColor.gravatarBlue))
                        },
                        title: "Save to Gravatar",
                        action: {
                            isGravatarQEPresented = true
                        }
                    )
                    menuButton(
                        icon: {
                            Image(uiImage: UIImage(named: "apple-photos")!)
                                .resizable()
                                .background(Color.white)
                        },
                        title: "Save to camera roll",
                        action: {
                            showFullAppAlert = true
                        }
                    )
                }
                
            }
            .padding(.top, 24)
            Spacer()
            VStack {
                VStack(alignment: .leading) {
                    Text("Want to access more avatar designs?")
                        .foregroundColor(Color(uiColor: .label))
                        .font(Font.system(size: 23, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.thickMaterial)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 16)
                
                VStack(alignment: .leading)  {
                    Text("Get the full app")
                        .font(.callout.weight(.semibold))
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                    Divider()
                        .background(Color(uiColor: .secondaryLabel))
                    HStack(alignment: .center, spacing: 12) {
                        Image(uiImage: UIImage(named: "full-app-icon")!)
                            .resizable()
                            .frame(width: 52, height: 52)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 3) {
                                Image(uiImage: UIImage(named: "appstore")!.withRenderingMode(.alwaysTemplate))
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                Text("App Store")
                                    .font(.caption)
                            }
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                            .padding(0)
                            
                            Text("Gravatar")
                                .font(.headline.weight(.semibold))
                                .padding(.bottom, 4)
                            
                            Text("Create your global avatar.")
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.footnote)
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                        }
                        Spacer()
                        Button {
                            openFullApp()
                        } label: {
                            Text("GET")
                                .padding(.vertical, 4)
                                .padding(.horizontal, 16)
                                .background(Color(UIColor.tintColor))
                                .font(Font.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(Color(.white))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.vertical, 4)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.systemBackground).opacity(1))
                
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 16)
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.15), radius: 20)
            }
            .padding(.bottom, 8)
            .background(Color(UIColor.secondarySystemBackground).opacity(1))
        }

        .padding(.top, 24)
        .navigationTitle("Save")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if OAuthSession.hasSession(with: .init(email)) {
                    Button("Logout") {
                        OAuthSession.deleteSession(with: .init(email))
                        logoutButtonID = UUID().uuidString
                    }
                    .id(logoutButtonID)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .gravatarQuickEditorSheet(
            isPresented: $isGravatarQEPresented,
            email: email,
            scope: QuickEditorScope.avatarPicker(.horizontalInstrinsicHeight),
            imageToUpload: image
        )
        .alert(isPresented: $showFullAppAlert) {
            Alert(
                title: Text("Get the Full App"),
                message: Text("Unlock all features by downloading the full app."),
                primaryButton: .default(Text("Get the App")) {
                    //openFullApp()
                    openFullApp()
                    showFullAppAlert = false
                },
                secondaryButton: .cancel()
            )
        }
        .preferredColorScheme(.dark)
    }
    func openFullApp() {
        if let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID") {
            UIApplication.shared.open(url)
        }
    }
    func menuButton(icon: () -> some View, title: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                icon()
                    .frame(width: 24, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                Text(title)
            }
            .foregroundStyle(Color(UIColor.label))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

#Preview {
    ImageResultView(image: UIImage(named: "avatar-sample")!)
}

extension UIColor {
    static let gravatarBlue: UIColor = .rgba(29, 79, 196)
    
    static func rgba(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
}
