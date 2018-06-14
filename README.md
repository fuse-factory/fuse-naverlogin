# fuse-naverlogin
Fuse - Uno library for Naver authentication

There is an issue on generating the `build/iOS/Debug/Podfile` when exporting to iOS. After the first build, a line of code should be added at the top of the generated `Podfile`:
```
platform :ios, '9.0'
```
so it should look like this.
```
# Uncomment this line to define a global platform for your project
platform :ios, '9.0'

target 'fuse-naverlogin' do
  pod 'naveridlogin-sdk-ios'
end
```
Build again with editied `Podfile`. Edit the last four line of `build/iOS/Debug/Pods/naveridlogin-sdk-ios/NaverThirdPartyLogin.framework/Headers/NaverThirdPartyConstantsForApp.h` like below:
```
#define kServiceAppUrlScheme    @"FuseNaverLogin"

#define kConsumerKey            @"Y7fuU9kgDacckrJXMWoK"
#define kConsumerSecret         @"f0sHB90Xkw"
#define kServiceAppName         @"퓨즈네이버로그인"
```
