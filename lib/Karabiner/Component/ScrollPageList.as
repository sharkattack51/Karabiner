package Karabiner.Component
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	import Karabiner.Component.ScrollListBase;
	import Karabiner.Enum.DRAG_DIRECTION;
	
	/**
	 * ScrollPageList
	 * ドラッグして1ページづつスクロールするページリスト
	 */
	public class ScrollPageList extends ScrollListBase
	{
		private var pages:Array/*MovieClip*/;
		public function get Pages():Array/*MovieClip*/ { return pages; }
		
		private var currentPageNum:int = 0;
		public function get CurrentPageNum():int { return currentPageNum; }
		
		private var pageWidth:Number; // ページ幅
		private var pageMargin:Number; // ページマージン
		
		private var pageFlipRatio:Number = 0.25; // ページ遷移閾値
		
		
		public function ScrollPageList(pages:Array/*MovieClip*/,
			pageWidth:Number, pageMargin:Number = 0, pageFlipRatio:Number = 0.25):void
		{
			super(DRAG_DIRECTION.HORIZONTAL);
			
			this.pages = pages;
			this.pageWidth = pageWidth;
			this.pageMargin = pageMargin;
			this.pageFlipRatio = pageFlipRatio;
		}
		
		
		//////////////////////////////////////////////////////////////// Init
		
		override protected function InitVar():void
		{
			super.InitVar();
		}
		
		override protected function InitView():void
		{
			super.InitView();
			
			// ページを配置
			for (var i:int = 0; i < pages.length; i++) 
			{
				pages[i].x = i * pageWidth;
				pages[i].y = 0;
				
				this.scrollRoot.addChild(pages[i]);
			}
		}
		
		override protected function InitEvent():void
		{
			super.InitEvent();
		}
		
		override protected function PostInit():void
		{
			super.PostInit();
			
			// ドラッグ操作を初期化
			this.InitDrag(new Rectangle(
				0, 0,
				this.stage.stageWidth * pages.length,
				this.stage.stageHeight));
		}
		
		
		//////////////////////////////////////////////////////////////// EventListner
		
		// デストラクタ
		override protected function Destructor(e:Event):void
		{
			super.Destructor(e);
			
			pages = new Array();
			pages = null;
		}
		
		// ドラッグ開始
		override protected function OnDragStart():void
		{
			super.OnDragStart();
		}
		
		// ドラッグ中
		override protected function OnDragMove():void
		{
			super.OnDragMove();
		}
		
		// スクロール移動中
		override protected function OnScrolled():void
		{
			super.OnScrolled();
		}
		
		// ドラッグ終了
		override protected function OnDragEnd():void
		{	
			super.OnDragEnd();
			
			// リリース地点の座標で次ページか前ページのターゲット座標を設定
			if (this.targetPos <= ((currentPageNum * -(pageWidth + pageMargin)) - ((pageWidth + pageMargin) * pageFlipRatio)))
				currentPageNum++;
			else if (this.targetPos >= ((currentPageNum * -(pageWidth + pageMargin)) + ((pageWidth + pageMargin) * pageFlipRatio)))
				currentPageNum--;
			
			// ページをスクロール移動する
			GotoPage();
		}
		
		// 座標更新
		override protected function OnScrollUpdate(e:Event):void 
		{
			super.OnScrollUpdate(e);
		}
		
		
		//////////////////////////////////////////////////////////////// PrivateFunction
		
		// ページをスクロール移動する
		private function GotoPage():void
		{
			currentPageNum = Math.min(Math.max(0, currentPageNum), pages.length - 1);
			this.targetPos = currentPageNum * -(pageWidth + pageMargin);
		}
		
		
		//////////////////////////////////////////////////////////////// PublicFunction
		
		// 次ページにスクロール移動する
		public function GotoNextPage():void
		{
			currentPageNum++;
			GotoPage();
		}
		
		// 前ページにスクロール移動する
		public function GotoPrevPage():void
		{
			currentPageNum--;
			GotoPage();
		}
		
		// 指定ページにスクロール移動する
		public function GotoSetPage(pageNum:int):void
		{
			currentPageNum = pageNum;
			GotoPage();
		}
	}
}