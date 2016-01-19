/**
 * -------------------------------------------------------
 * copyright(c). romatica.com
 * @author itoz
 * @version 1.0
 * -------------------------------------------------------
 */
package com.romatica.events
{
	import flash.display.BitmapData;
	import flash.events.Event;

	/**
	 * ImageLoadQueueクラスによってイベントが発生した場合に送出されます。
	 */
	public class ImageLoadQueueEvent extends Event
	{
		/**
		 * @eventType 画像ロード完了された場合のtypeプロパティ
		 */
		public static const COMPLETE:String="COMPLETE";
		/**
		 * @eventType 画像ロードプログレスのtypeプロパティ
		 */		public static const PROGRESS : String = "PROGRESS";
		/**
		 * @eventType 画像ロードエラーのtypeプロパティ
		 */
		public static const ERROR : String = "ERROR";
		/**
		 * @eventType 画像ロードオープンのtypeプロパティ
		 */		public static const OPEN : String = "OPEN";
		
		public var bitmapData:BitmapData;		public var url:String;		public var bytesLoaded:Number;		public var bytesTotal:Number;		public var percent:Number;
		public var text:String;
		

		public function ImageLoadQueueEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false):void
		{
			super( type, bubbles, cancelable );
		}
	}
}
