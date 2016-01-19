package Karabiner.Component 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import Karabiner.Enum.DRAG_DIRECTION;
	import Karabiner.Component.DragInteractionBase;
	import Karabiner.Component.SliderObject;
	
	/**
	 * ScrollListBase
	 * スクロールリスト機能の基本クラス
	 */
	public class ScrollListBase extends DragInteractionBase 
	{
		protected var scrollDir:String;
		protected var maskedScrollSize:Number;
		public function get MaskedScrollSize():Number { return maskedScrollSize; }
		protected var scrollAvailable:Boolean = false;
		public function get ScrollAvailable():Boolean { return scrollAvailable; }
		protected var controllSlider:SliderObject; // スクロール連携用スライダー
		
		// スクロール処理ルート
		protected var scrollRoot:MovieClip;
		public function get ScrollRoot():MovieClip { return scrollRoot; }
		
		// Hit判定用のエリア
		protected var dragHitArea:Sprite;
		
		// 挙動の調整値
		protected var dragPixelTh:Number = 30; // スクロール開始のピクセル閾値
		protected var draggingRatio:Number = 0.3; // ドラッグ中のスムース係数
		protected var movingRatio:Number = 0.15; // ドラッグ終了後移動中のスムース係数
		
		// ドラッグ処理
		protected var startPos:Number = 0;
		protected var targetPos:Number = 0;
		protected var smoothDragRatio:Number = movingRatio;
		protected var isOverDragTh:Boolean = false;
		
		// 位置シフト
		protected var shiftPos:Number;
		
		
		public function ScrollListBase(scrollDir:String, maskedArea:Rectangle = null, controllSlider:SliderObject = null, shiftPos:Number = 0):void
		{
			super();
			
			this.scrollDir = scrollDir;
			
			if (maskedArea != null)
			{
				if (scrollDir == DRAG_DIRECTION.HORIZONTAL)
					maskedScrollSize = maskedArea.width;
				else
					maskedScrollSize = maskedArea.height;
			}
			else
				maskedScrollSize = 0;
			
			this.controllSlider = controllSlider;
			this.shiftPos = shiftPos;
		}
		
		
		//////////////////////////////////////////////////////////////// Init
		
		override protected function InitVar():void
		{
			super.InitVar();
			
			// シフト分で初期化
			targetPos = shiftPos;
		}
		
		override protected function InitView():void
		{
			super.InitView();
			
			// スクロールルート
			scrollRoot = new MovieClip();
			if(scrollDir == DRAG_DIRECTION.HORIZONTAL)
				scrollRoot.x = shiftPos;
			else
				scrollRoot.y = shiftPos;
			this.addChild(scrollRoot);
			
			// ドラッグ操作用のHitエリア
			dragHitArea = new Sprite();
			if(scrollDir == DRAG_DIRECTION.HORIZONTAL)
				dragHitArea.x = shiftPos;
			else
				dragHitArea.y = shiftPos;
			scrollRoot.addChildAt(dragHitArea, 0);
		}
		
		override protected function InitEvent():void
		{
			super.InitEvent();
			
			this.addEventListener(Event.ENTER_FRAME, OnScrollUpdate);
		}
		
		
		//////////////////////////////////////////////////////////////// EventListner
		
		// デストラクタ
		override protected function Destructor(e:Event):void
		{
			super.Destructor(e);
			
			this.removeEventListener(Event.ENTER_FRAME, OnScrollUpdate);
			
			if(controllSlider != null)
				controllSlider = null;
			
			scrollRoot.removeChild(dragHitArea);
			dragHitArea = null;
			
			this.removeChild(scrollRoot);
			scrollRoot = null;
		}
		
		// ドラッグ開始
		override protected function OnDragStart():void
		{
			super.OnDragStart();
			
			// スムース係数を設定
			smoothDragRatio = draggingRatio;
			
			// ドラッグ開始位置を保存
			if(scrollDir == DRAG_DIRECTION.HORIZONTAL)
				startPos = scrollRoot.x;
			else
				startPos = scrollRoot.y;
			
			// スクロールによるスライダー操作を開始する
			if (controllSlider != null)
				controllSlider.LockSliderEvent();
		}
		
		// ドラッグ中
		override protected function OnDragMove():void
		{
			super.OnDragMove();
			
			var dragDelta:Number;
			if (scrollDir == DRAG_DIRECTION.HORIZONTAL)
				dragDelta = this.CurrentDragDelta.x;
			else
				dragDelta = this.CurrentDragDelta.y;
			
			// 閾値以上のドラッグで処理
			if (dragPixelTh < Math.abs(dragDelta) || isOverDragTh)
			{
				isOverDragTh = true;
				
				// 目標座標を更新
				targetPos = startPos + dragDelta;
				
				// スクロール移動更新での処理
				OnScrolled();
			}
		}
		
		// スクロール移動更新
		protected function OnScrolled():void
		{
			// スクロールによるスライダー操作
			if (controllSlider != null)
			{
				if(scrollDir == DRAG_DIRECTION.HORIZONTAL)
					controllSlider.SetSlideValue((scrollRoot.x - shiftPos) / (this.width - maskedScrollSize) * -1);
				else
					controllSlider.SetSlideValue((scrollRoot.y - shiftPos) / (this.height - maskedScrollSize) * -1);
			}
		}
		
		// ドラッグ終了
		override protected function OnDragEnd():void
		{
			super.OnDragEnd();
			
			isOverDragTh = false;
			
			// スムース係数を設定
			smoothDragRatio = movingRatio;
			
			// スクロールによるスライダー操作を終了する
			if (controllSlider != null)
				controllSlider.UnLockSliderEvent();
		}
		
		// 座標更新
		protected function OnScrollUpdate(e:Event):void 
		{	
			// スムース移動
			if (scrollDir == DRAG_DIRECTION.HORIZONTAL)
			{
				scrollRoot.x += (targetPos - scrollRoot.x) * smoothDragRatio;
				
				if (Math.abs(targetPos - scrollRoot.x) < 1.0)
					scrollRoot.x = targetPos;
			}
			else
			{
				scrollRoot.y += (targetPos - scrollRoot.y) * smoothDragRatio;
				
				if (Math.abs(targetPos - scrollRoot.y) < 1.0)
					scrollRoot.y = targetPos;
			}
		}
		
		
		//////////////////////////////////////////////////////////////// PublicFunction
		
		// ドラッグ操作の初期化
		public function InitDrag(hitAreaRect:Rectangle = null):void
		{
			scrollAvailable = true;
			
			if (hitAreaRect == null)
				hitAreaRect = new Rectangle(0, 0, this.width, this.height);
			
			// ドラッグ操作用のHitエリア領域を設定
			dragHitArea.graphics.beginFill(0xff0000, 0);
			dragHitArea.graphics.drawRect(hitAreaRect.x, hitAreaRect.y, hitAreaRect.width, hitAreaRect.height);
			dragHitArea.graphics.endFill();
			
			// ドラッグ操作を開始
			this.DragStart();
		}
		
		// スクロール値をセットする
		public function SetScroll(value:Number, slideSize:Number):void
		{
			if(scrollDir == DRAG_DIRECTION.HORIZONTAL)
				targetPos = -((scrollRoot.width + shiftPos) - slideSize) * value;
			else
				targetPos = -((scrollRoot.height + shiftPos) - slideSize) * value;
		}
	}
}