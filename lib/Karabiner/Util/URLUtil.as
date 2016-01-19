package Karabiner.Util 
{
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	
	/**
	 * URLUtil
	 * URL関係のユーティリティクラス
	 */
	public class URLUtil 
	{
		// キャッシュ日時の設定
		public static function SetNoneCache(request:URLRequest):URLRequest 
		{
			request.requestHeaders.push(new URLRequestHeader("pragma", "no-cache"));
			request.requestHeaders.push(new URLRequestHeader("cache-control", "no-chache"));
			request.requestHeaders.push(new URLRequestHeader("expires", "Sun, 10 Jan 1990 01:01:01 GMT"));
			
			return request;
		}
		
		// タイムスタンプクエリの取得
		public static function GetTimeStampQuery():String 
		{
			return "?timestamp=" + new Date().getTime().toString();
		}
		
		// タイムスタンプの取得
		public static function GetTimeStamp():String 
		{
			return new Date().getTime().toString();
		}
	}
}