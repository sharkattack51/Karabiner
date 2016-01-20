package Karabiner.Component 
{
	import com.romatica.events.ImageLoadQueueEvent;
	import com.romatica.loader.ImageLoadQueue;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import Karabiner.Enum.IMAGE_FIT_TYPE;
	import Karabiner.Util.URLUtil;
	
	/**
	 * ImageObject
	 * 画像データを管理保持するオブジェクト
	 */
	public class ImageObject extends Sprite
	{
		// ロードがエラーだった場合は再度ロードしない為のブラックリスト
		public static var LoadErrorUrlList:Array/*String*/ = new Array();
		
		private var url:String;
		public function get Url():String { return url; }
		
		private var noImage:DisplayObject;
		private var autoLoad:Boolean;
		private var useLoadQueue:Boolean;
		private var useTrimedRedraw:Boolean;
		private var pixelSnapping:String;
		
		private var imageLoadQueue:ImageLoadQueue;
		private var imageLoader:Loader;
		
		private var isLoading:Boolean = false;
		public function get IsLoading():Boolean { return isLoading; }
		
		private var isCached:Boolean = false;
		public function get IsCached():Boolean { return isCached; }
		private var cacheBmp:Bitmap = null;
		
		private var hasImage:Boolean = false;
		public function get HasImage():Boolean { return hasImage; }
		
		private var asNoImage:Boolean = false;
		public function get AsNoImage():Boolean { return asNoImage; }
		
		// 画像リサイズ設定
		private var fitSize:Point = new Point(0, 0);
		private var fitType:String = IMAGE_FIT_TYPE.TRIM_AND_FIT_TO_HEIGHT;
		
		
		public function ImageObject(url:String, noImage:DisplayObject = null,
			autoLoad:Boolean = true, useLoadQueue:Boolean = false, useTrimedRedraw:Boolean = false,
			pixelSnapping:String = PixelSnapping.AUTO):void
		{
			this.url = url;
			this.noImage = noImage;
			this.autoLoad = autoLoad;
			this.useLoadQueue = useLoadQueue;
			this.useTrimedRedraw = useTrimedRedraw;
			this.pixelSnapping = pixelSnapping;
			
			// 画像の読み込みを開始
			if (this.autoLoad)
				LoadImage();
		}
		
		
		//////////////////////////////////////////////////////////////// EventListener
		
		private function OnLoadQueueComplete(e:ImageLoadQueueEvent):void
		{
			isLoading = false;
			
			// 読み込み画像の表示
			var bmp:Bitmap = new Bitmap(e.bitmapData, pixelSnapping, true);
			
			PostLoadFinish(bmp);
			
			bmp.bitmapData.dispose();
			bmp.bitmapData = null;
			bmp = null;
		}
		
		private function OnLoadQueueError(e:ImageLoadQueueEvent):void 
		{
			isLoading = false;
			
			if (url != "")
			{
				trace(e.text);
			}
			
			// エラーのURLをブラックリストに登録
			LoadErrorUrlList.push(url);
			
			// NoImageの表示
			asNoImage = true;
			PostLoadFinish(noImage);
		}
		
		private function OnLoadComplete(e:Event):void 
		{
			isLoading = false;
			
			if (imageLoader != null)
			{
				imageLoader.removeEventListener(Event.COMPLETE, OnLoadComplete);
				imageLoader.removeEventListener(IOErrorEvent.IO_ERROR, OnLoadError);
				
				// 読み込み画像の表示
				PostLoadFinish(imageLoader);
			}
		}
		
		private function OnLoadError(e:IOErrorEvent):void 
		{
			isLoading = false;
			
			if (imageLoader != null)
			{
				imageLoader.removeEventListener(Event.COMPLETE, OnLoadComplete);
				imageLoader.removeEventListener(IOErrorEvent.IO_ERROR, OnLoadError);
			}
			
			// エラーのURLをブラックリストに登録
			LoadErrorUrlList.push(url);
			
			if (url != "")
				trace(e.text);
			
			// NoImageの表示
			asNoImage = true;
			PostLoadFinish(noImage);
		}
		
		
		//////////////////////////////////////////////////////////////// PrivateFunction
		
		// ロード完了の後処理
		private function PostLoadFinish(displayObject:DisplayObject):void
		{
			// 画像を表示
			if(displayObject != null)
				MakeBitmap(displayObject);
			
			// Loaderをクリア
			if (imageLoader != null)
			{
				imageLoader.removeEventListener(Event.COMPLETE, OnLoadComplete);
				imageLoader.removeEventListener(IOErrorEvent.IO_ERROR, OnLoadError);
				imageLoader.unload();
			}
			imageLoader = null;
			
			// ImageLoadQueueをクリア
			imageLoadQueue = null;
			
			// bitmapキャッシュ
			//if (cacheBmp != null)
				//cacheBmp.cacheAsBitmap = true;
			
			isCached = true;
			
			// ロード完了のイベント
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		// Bitmapの表示
		private function MakeBitmap(displayObject:DisplayObject):void
		{
			// スムージング処理の為BitmapDataにDrawする
			var scale:Number = 1.0;
			
			if (fitSize.x > 0 && fitSize.y > 0)
			{
				if (fitType == IMAGE_FIT_TYPE.TRIM_AND_FIT_TO_WIDTH)
				{
					// 幅合わせ
					scale = fitSize.x / displayObject.width;
				}
				
				if (fitType == IMAGE_FIT_TYPE.TRIM_AND_FIT_TO_HEIGHT)
				{
					// 高さ合わせ
					scale = fitSize.y / displayObject.height;
				}
				
				else if (fitType == IMAGE_FIT_TYPE.TRIM_AND_FIT_TO_SHORTER)
				{
					// 短手合わせ
					if (displayObject.width < displayObject.height)
						scale = fitSize.x / displayObject.width;
					else
						scale = fitSize.y / displayObject.height;
				}
				
				else if (fitType == IMAGE_FIT_TYPE.NO_TORIM_AND_FIT_TO_LONGER)
				{
					// 長手合わせ
					if (displayObject.width > displayObject.height)
						scale = fitSize.x / displayObject.width;
					else
						scale = fitSize.y / displayObject.height;
					
					// はみ出し調整
					if (displayObject.width * scale > fitSize.x)
						scale /= (displayObject.width * scale) / fitSize.x;
					if (displayObject.height * scale > fitSize.y)
						scale /= (displayObject.height * scale) / fitSize.y;
				}
			}
			
			if (useTrimedRedraw)
			{
				// リサイズしたサイズで保持
				cacheBmp = new Bitmap(new BitmapData(fitSize.x, fitSize.y, true, 0x00FF0000), pixelSnapping, true);
				cacheBmp.bitmapData.draw(
					displayObject,
					new Matrix(scale, 0, 0, scale, (fitSize.x - (displayObject.width * scale)) / 2.0, (fitSize.y - (displayObject.height * scale)) / 2.0),
					null, null, null, true);
			}
			else
			{
				// オリジナルサイズで保持
				cacheBmp = new Bitmap(new BitmapData(displayObject.width, displayObject.height, true, 0x00FF0000), pixelSnapping, true);
				cacheBmp.bitmapData.draw(displayObject);
				cacheBmp.width *= scale;
				cacheBmp.height *= scale;
			}
			
			cacheBmp.x = - cacheBmp.width / 2.0;
			cacheBmp.y = - cacheBmp.height / 2.0;
			this.addChild(cacheBmp);
			
			hasImage = true;
		}
		
		
		//////////////////////////////////////////////////////////////// PublicFunction
		
		// デストラクタ
		public function Destruct():void
		{
			if (imageLoader != null)
			{
				imageLoader.removeEventListener(Event.COMPLETE, OnLoadComplete);
				imageLoader.removeEventListener(IOErrorEvent.IO_ERROR, OnLoadError);
				imageLoader.unload();
			}
			imageLoader = null;
			
			imageLoadQueue = null;
			
			if (cacheBmp != null)
			{
				cacheBmp.bitmapData.dispose();
				cacheBmp.bitmapData = null;
				
				this.removeChild(cacheBmp);
			}
			cacheBmp = null;
			
			noImage = null;
		}
		
		// 画像の読み込み
		public function LoadImage():void
		{
			if (!isCached)
			{
				// ブラックリストを確認
				if (LoadErrorUrlList.indexOf(url) > -1)
				{
					// NoImageの表示
					asNoImage = true;
					PostLoadFinish(noImage);
					return;
				}
				
				if (useLoadQueue)
				{
					// ImageLoadQueueで読み込み
					imageLoadQueue = ImageLoadQueue.getInstance();
					if (imageLoadQueue.hasLoadedBitmapData(url))
					{
						// 既に読み込み済みの場合は直接取ってくる
						PostLoadFinish(new Bitmap(imageLoadQueue.getBitmapDataFromDictionary(url)));
						return;
					}
					imageLoadQueue.add(url, OnLoadQueueComplete, null, null, OnLoadQueueError);
					imageLoadQueue.load();
				}
				else
				{
					if (imageLoader != null)
						return;
					
					var request:URLRequest = URLUtil.SetNoneCache(new URLRequest());
					request.method = URLRequestMethod.GET;
					request.url = this.url + URLUtil.GetTimeStampQuery();
					
					// Loaderで読み込み
					imageLoader = new Loader();
					imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, OnLoadComplete);
					imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, OnLoadError);
					imageLoader.load(request);
				}
				
				isLoading = true;
			}
			else
			{
				// ロード完了のイベント
				this.dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		// 画像の読み込み停止
		public function StopLoadImage():void
		{
			if (imageLoader != null)
			{
				imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, OnLoadComplete);
				imageLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, OnLoadError);
				imageLoader.unload();
				imageLoader = null;
			}
			
			isLoading = false;
		}
		
		// 画像キャッシュをクリア
		public function UnloadImage():void
		{
			if (isCached)
			{
				cacheBmp.bitmapData.dispose();
				cacheBmp.bitmapData = null;
				
				this.removeChild(cacheBmp);
				cacheBmp = null;
				
				isCached = false;
			}
		}
		
		// 読み込み後の表示サイズを指定する
		public function SetPostLoadSizing(width:Number, height:Number, imgFitType:String = "no_trim_and_fit_to_longer"):void
		{	
			this.fitSize = new Point(width, height);
			this.fitType = imgFitType;
		}
	}
}