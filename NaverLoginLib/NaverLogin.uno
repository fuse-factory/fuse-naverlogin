using Fuse;
using Fuse.Platform;
using Uno;
using Uno.Compiler.ExportTargetInterop;

[Require("Gradle.Repository","mavenCentral()")]
[Require("Gradle.Dependency","compile('com.naver.nid:naveridlogin-android-sdk:4.2.0')")]
[ForeignInclude(Language.Java, "android.content.Intent")]
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
	@}

	extern(Android) Java.Object _mOAuthLoginModule;

	[Foreign(Language.Java)]
	extern(Android) void Started(ApplicationState state)
	@{
		OAuthLogin mOAuthLoginModule = OAuthLogin.getInstance();
		mOAuthLoginModule.init(
			Activity.getRootActivity()
			,"Y7fuU9kgDacckrJXMWoK"	//	OAUTH_CLIENT_ID
			,"f0sHB90Xkw"			//	OAUTH_CLIENT_SECRET
			,"네이버 아이디로 로그인"		//	OAUTH_CLIENT_NAME
			//,OAUTH_CALLBACK_INTENT
			// SDK 4.1.4 버전부터는 OAUTH_CALLBACK_INTENT변수를 사용하지 않습니다.
		);
		@{NaverLogin:Of(_this)._mOAuthLoginModule:Set(mOAuthLoginModule)};

	@}

	extern(!iOS && !Android) void Started(ApplicationState state)
	{
	}

	[Foreign(Language.ObjC)]
	extern(iOS) void OnEnteringInteractive(ApplicationState state)
	@{
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
	@}

	[Foreign(Language.Java)]
	public extern(Android) void Login(Action<string> onSuccess, Action<string> onError)
	@{
		OAuthLogin mOAuthLoginModule = (OAuthLogin)@{NaverLogin:Of(_this)._mOAuthLoginModule:Get()};
		
		OAuthLoginHandler mOAuthLoginHandler = new OAuthLoginHandler() {
			@Override
			public void run(boolean success) {
				if (success) 
				{

				} 
				else 
				{

				}
			};
		};

		mOAuthLoginModule.startOauthLoginActivity(Activity.getRootActivity(), mOAuthLoginHandler);
	@}
}