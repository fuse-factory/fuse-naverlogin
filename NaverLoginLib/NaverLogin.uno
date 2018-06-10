using Fuse;
using Fuse.Platform;
using Uno;
using Uno.Compiler.ExportTargetInterop;

//[extern(iOS) Require("Xcode.FrameworkDirectory", "@('NaverSDKs-iOS':Path)")]
//[extern(iOS) Require("Xcode.Framework", "@('NaverSDKs-iOS/NaverThirdPartyLogin.framework':Path)")]
//[extern(iOS) ForeignInclude(Language.ObjC, "NaverThirdPartyLogin/NaverThirdPartyLogin.h")]
[extern(iOS) Require("Source.Include", "NaverThirdPartyLogin/NaverThirdPartyLogin.h")]
[extern(iOS) Require("Cocoapods.Platform.Name", "ios")]
[extern(iOS) Require("Cocoapods.Platform.Version", "9.0")]
[extern(iOS) Require("Cocoapods.Podfile.Target", "pod 'naveridlogin-sdk-ios'")]
[Require("Gradle.Repository","mavenCentral()")]
[Require("Gradle.Dependency","compile('com.naver.nid:naveridlogin-android-sdk:4.2.0')")]
[ForeignInclude(Language.Java, "android.content.Intent")]
[ForeignInclude(Language.Java, "android.content.Context")]
[ForeignInclude(Language.Java, "android.util.Log")]
[ForeignInclude(Language.Java, "com.fuse.Activity")]
[ForeignInclude(Language.Java, "com.nhn.android.naverlogin.OAuthLogin")]
[ForeignInclude(Language.Java, "com.nhn.android.naverlogin.OAuthLoginHandler")]
public class NaverLogin
{
	public NaverLogin()
	{
		Lifecycle.Started += Started;
		Lifecycle.EnteringInteractive += OnEnteringInteractive;
		Lifecycle.ExitedInteractive += OnExitedInteractive;
	}

	[Foreign(Language.ObjC)]
	extern(iOS) void Started(ApplicationState state)
	@{
		[[NaverThirdPartyLoginConnection getSharedInstance] setIsInAppOauthEnable:YES];
		[[NaverThirdPartyLoginConnection getSharedInstance] setOnlyPortraitSupportInIphone:YES];

		NaverThirdPartyLoginConnection *thirdConn = [NaverThirdPartyLoginConnection getSharedInstance];
    	[thirdConn setServiceUrlScheme:kServiceAppUrlScheme];
    	[thirdConn setConsumerKey:kConsumerKey];
    	[thirdConn setConsumerSecret:kConsumerSecret];
    	[thirdConn setAppName:kServiceAppName];
    	NSLog(@"MyLog: Started");
	@}

	extern(Android) Java.Object _mOAuthLoginModule;
	extern(Android) Java.Object _mContext;

	[Foreign(Language.Java)]
	extern(Android) void Started(ApplicationState state)
	@{
		OAuthLogin mOAuthLoginModule = OAuthLogin.getInstance();
		Context mContext = Activity.getRootActivity();

		mOAuthLoginModule.init(
			mContext
			,"Y7fuU9kgDacckrJXMWoK"	//	OAUTH_CLIENT_ID
			,"f0sHB90Xkw"			//	OAUTH_CLIENT_SECRET
			,"네이버 아이디로 로그인"		//	OAUTH_CLIENT_NAME
			//,OAUTH_CALLBACK_INTENT
			// SDK 4.1.4 버전부터는 OAUTH_CALLBACK_INTENT변수를 사용하지 않습니다.
		);

		@{NaverLogin:Of(_this)._mOAuthLoginModule:Set(mOAuthLoginModule)};
		@{NaverLogin:Of(_this)._mContext:Set(mContext)};
	@}

	extern(!iOS && !Android) void Started(ApplicationState state)
	{
	}

	[Foreign(Language.ObjC)]
	extern(iOS) void OnEnteringInteractive(ApplicationState state)
	@{
		NSLog(@"MyLog: OnEnteringInteractive");
	@}

	[Foreign(Language.Java)]
	static extern(Android) void OnEnteringInteractive(ApplicationState state)
	@{
	@}

	static extern(!iOS && !Android) void OnEnteringInteractive(ApplicationState state)
	{
	}

	[Foreign(Language.Java)]
	static extern(Android) void OnExitedInteractive(ApplicationState state)
	@{
	@}

	static extern(!Android) void OnExitedInteractive(ApplicationState state)
	{
	}

	[Foreign(Language.ObjC)]
	public extern(iOS) void Login(Action<string> onSuccess, Action<string> onError)
	@{
		NSLog(@"MyLog: Login");
		// NaverThirdPartyLoginConnection의 인스턴스에 
		// 서비스앱의 url scheme와 consumer key, consumer secret, 
		// 그리고 appName을 파라미터로 전달하여 3rd party OAuth 인증을 요청합니다.

    	NaverThirdPartyLoginConnection *tlogin = [NaverThirdPartyLoginConnection getSharedInstance];
    	[tlogin requestThirdPartyLogin];
	@}

	[Foreign(Language.Java)]
	public extern(Android) void Login(Action<string> onSuccess, Action<string> onError)
	@{
		final OAuthLogin mOAuthLoginModule = (OAuthLogin)@{NaverLogin:Of(_this)._mOAuthLoginModule:Get()};
		final Context mContext = (Context)@{NaverLogin:Of(_this)._mContext:Get()};
		
		OAuthLoginHandler mOAuthLoginHandler = new OAuthLoginHandler() {
			@Override
			public void run(boolean success) {
				if (success) 
				{
					String accessToken = mOAuthLoginModule.getAccessToken(mContext);
					String refreshToken = mOAuthLoginModule.getRefreshToken(mContext);
					long expiresAt = mOAuthLoginModule.getExpiresAt(mContext);
					String tokenType = mOAuthLoginModule.getTokenType(mContext);
					String state = mOAuthLoginModule.getState(mContext).toString();

					String message = "Login Success. AT:" + accessToken + ", RT:" + refreshToken + ", State:" + state;
					Log.d("success", message);
				} 
				else 
				{
					String errorCode = mOAuthLoginModule.getLastErrorCode(mContext).getCode();
					String errorDesc = mOAuthLoginModule.getLastErrorDesc(mContext);

					String message = "Login Fail. errorCode:" + errorCode + ", errorDesc:" + errorDesc;
					Log.d("fail", message);
				}
			};
		};

		mOAuthLoginModule.startOauthLoginActivity(Activity.getRootActivity(), mOAuthLoginHandler);
	@}
}