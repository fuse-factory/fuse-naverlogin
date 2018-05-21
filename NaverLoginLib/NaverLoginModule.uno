using Uno;
using Uno.UX;
using Fuse;
using Fuse.Scripting;
using Uno.Collections;
using Uno.Threading;
using Uno.Permissions;

[UXGlobalModule]
public class NaverLoginModule : NativeModule
{
	class NaverLoginPromise : Promise<string>
	{
		readonly NaverLogin _naverLogin;

		public NaverLoginPromise(NaverLogin naverLogin)
		{
			_naverLogin = naverLogin;
			if defined(Android)
			{
				Permissions.Request(Permissions.Android.INTERNET).Then(
					OnPermissionsPermitted,
					OnPermissionsRejected);
			}
			else
			{
				Fuse.UpdateManager.AddOnceAction(Login);
			}
		}

		void Login()
		{
			if defined(iOS || Android)
				_naverLogin.Login(this.Resolve, OnError);
			else
				throw new NotImplementedException();
		}

		void OnError(string error)
		{
			Reject(new Exception(error));
		}

		extern(Android) void OnPermissionsPermitted(PlatformPermission p)
		{
			Fuse.UpdateManager.AddOnceAction(Login);
		}

		extern(Android) void OnPermissionsRejected(Exception e)
		{
			Reject(e);
		}
	}

	static readonly NaverLoginModule _instance;
	readonly NaverLogin _naverLogin;

	public NaverLoginModule()
	{
		if (_instance != null) return;

		_instance = this;
		_naverLogin = new NaverLogin();

		Resource.SetGlobalKey(_instance, "NaverLogin");
		AddMember(new NativePromise<string, object>("doLogin", DoLogin));
	}

	Future<string> DoLogin(object[] args)
	{
		return new NaverLoginPromise(_naverLogin);
	}
}
