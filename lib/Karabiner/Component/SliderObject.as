package Karabiner.Component 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Karabiner.Constant.COMPONENT_BY_NAME;
	import Karabiner.Constant.DRAG_DIRECTION;
	import Karabiner.Event.DragEvent;
	import Karabiner.Event.SliderEvent;
	import Karabiner.FrameworkObjectBase;
	import Karabiner.Component.DragInteractionBase;
	import Karabiner.Component.DraggableObject;
	import Karabiner.Component.Interface.ISwcObject;
	
	/**
	 * SliderObject
	 * MovieClipをラップしてスライダーを作成するクラス
	 */
	public class SliderObject extends FrameworkObjectBase implements ISwcObject
	{
		private var sliderDir:String;
		
		// swc
		private var swcMc:MovieClip
		
		// スライダー
		private var sliderThumb:DraggableObject;
		public function get thumbScaleRatio():Number
		{
			if (sliderDir == DRAG_DIRECTION.HORIZONTAL)
				return sliderThumb.width / this.width;
			else
				return sliderThumb.height / this.height;
		}
		private var sliderBase:DragInteractionBase;
		
		// スライダー値
		private var sliderValue:Number;
		public function get SliderValue():Number { return sliderValue; }
		private var prevSliderValue:Number = -1;
		
		// スライダー更新イベントのLock
		private var isLockSliderEvent:Boolean = false;
		private var isScrollOperating:Boolean = false;
		private var prevThumbPos:Point = new Point( -1, -1);
		
		
		public function SliderObject(sliderDir:String):void
		{
			super();
			
			this.sliderDir = sliderDir;
		}
		
		
		//////////////////////////////////////////////////////////////// Init
		
		override protected function InitVar():void 
		{
			super.InitVar();
		}
		
		override protected function InitView():void 
		{
			super.InitView();
			
			// ラップされたターゲット
			swcMc = this.getChildAt(0) as MovieClip;
			
			// スライダーのスケール設定
			var baseScale:Point = new Point(swcMc.scaleX, swcMc.scaleY);
			swcMc.scaleX = 1;
			swcMc.scaleY = 1;
			
			// スライダーBase
			var sliderBaseMc:MovieClip = MovieClip(swcMc.getChildByName(COMPONENT_BY_NAME.SLIDER_BASE));
			var baseDepth:int = swcMc.getChildIndex(sliderBaseMc);
			swcMc.removeChild(sliderBaseMc);
			sliderBase = new DragInteractionBase();
			sliderBaseMc.x = 0;
			sliderBaseMc.y = 0;
			sliderBaseMc.scaleX = baseScale.x;
			sliderBaseMc.scaleY = baseScale.y;
			sliderBase.addChild(sliderBaseMc);
			swcMc.addChildAt(sliderBase, baseDepth);
			
			// スライダーThumb
			var sliderThumbMc:MovieClip = MovieClip(swcMc.getChildByName(COMPONENT_BY_NAME.SLIDER_THUMB));
			var thumbDepth:int = swcMc.getChildIndex(sliderThumbMc);
			swcMc.removeChild(sliderThumbMc);
			if (sliderDir == DRAG_DIRECTION.HORIZONTAL)
			{
				sliderThumb = new DraggableObject(new Rectangle(0, 0, sliderBase.width, 0));
				sliderThumbMc.scaleY = baseScale.y;
			}
			else
			{
				sliderThumb = new DraggableObject(new Rectangle(0, 0, 0, sliderBase.height));
				sliderThumbMc.scaleX = baseScale.x;
			}
			sliderThumbMc.x = 0;
			sliderThumbMc.y = 0;
			sliderThumbMc.scale9Grid = sliderThumb.scale9Grid; // 9グリッド対応
			sliderThumb.addChild(sliderThumbMc);
			swcMc.addChildAt(sliderThumb, thumbDepth);
		}
		
		override protected function InitEvent():void 
		{
			super.InitEvent();
			
			this.addEventListener(Event.ENTER_FRAME, OnLoop);
			sliderBase.addEventListener(DragEvent.DRAG_START, OnSliderBase);
			sliderBase.addEventListener(DragEvent.DRAG_MOVE, OnSliderBase);
			sliderThumb.addEventListener(DragEvent.DRAG_START, OnThumbDragStart);
		}
		
		
		//////////////////////////////////////////////////////////////// EventListner
		
		// デストラクタ
		override protected function Destructor(e:Event):void 
		{
			super.Destructor(e);
			
			this.removeEventListener(Event.ENTER_FRAME, OnLoop);
			sliderBase.removeEventListener(DragEvent.DRAG_START, OnSliderBase);
			sliderBase.removeEventListener(DragEvent.DRAG_MOVE, OnSliderBase);
			sliderThumb.removeEventListener(DragEvent.DRAG_START, OnThumbDragStart);
			sliderThumb.removeEventListener(Event.ENTER_FRAME, OnCheckThumbMove);
			
			swcMc.removeChild(sliderBase);
			sliderBase = null;
			
			swcMc.removeChild(sliderThumb);
			sliderThumb = null;
			
			swcMc = null;
		}
		
		private function OnLoop(e:Event):void 
		{
			// 座標からスライダー値を計算する
			var calcValue:Number;
			if (sliderDir == DRAG_DIRECTION.HORIZONTAL)
				calcValue = (sliderThumb.x - (sliderThumb.width / 2)) / (sliderBase.width - sliderThumb.width);
			else
				calcValue = (sliderThumb.y - (sliderThumb.height / 2)) / (sliderBase.height - sliderThumb.height);
			
			// 小数点第3位でまるめる
			var digitValue:Number = Math.round(Math.floor(calcValue * 10000) / 10) / 1000;
			
			sliderValue = digitValue;
			
			// スライダー更新イベント
			if (!isLockSliderEvent && prevSliderValue != -1 && sliderValue != prevSliderValue)
				this.dispatchEvent(new Event(SliderEvent.CHANGE_SLIDER_VALUE));
			
			prevSliderValue = sliderValue;
		}
		
		private function OnSliderBase(e:Event):void 
		{
			// スライダー更新イベントをUnLock
			ResetLockSliderEvent();
			
			// スライダーBaseからスライダーをコントロールする
			var value:Number;
			if (sliderDir == DRAG_DIRECTION.HORIZONTAL)
				value = ((sliderBase.CurrentDragPoint.x - this.x) - (sliderThumb.width / 2)) / (sliderBase.width - sliderThumb.width);
			else
				value = ((sliderBase.CurrentDragPoint.y - this.y) - (sliderThumb.height / 2)) / (sliderBase.height - sliderThumb.height);
			
			SetSlideValue(value);
		}
		
		private function OnThumbDragStart(e:Event):void 
		{
			// スライダー更新イベントをUnLock
			ResetLockSliderEvent();
		}
		
		private function OnCheckThumbMove(e:Event):void 
		{
			// スライダーThumb移動終了チェック
			if(isLockSliderEvent && Point.distance(new Point(sliderThumb.x, sliderThumb.y), prevThumbPos) == 0)
				ResetLockSliderEvent();
			
			prevThumbPos.x = sliderThumb.x;
			prevThumbPos.y = sliderThumb.y;
		}
		
		
		//////////////////////////////////////////////////////////////// PrivateFunction
		
		private function ResetLockSliderEvent():void
		{
			isLockSliderEvent = false;
			sliderThumb.removeEventListener(Event.ENTER_FRAME, OnCheckThumbMove);
			prevThumbPos = new Point( -1, -1);
		}
		
		
		//////////////////////////////////////////////////////////////// PublicFunction
		
		// ドラッグ操作の初期化
		public function InitDrag(hitTargetThumbObject:DisplayObject = null):void
		{
			// ドラッグ操作を開始
			sliderThumb.DragStart(hitTargetThumbObject);
			sliderBase.DragStart();
		}
		
		// スライダーのリセット
		public function ResetSlider():void
		{
			sliderThumb.SetPosition(new Point(0, 0));
		}
		
		// スライダー値のセット
		public function SetSlideValue(value:Number):void
		{
			// 最大最小制限
			if (value > 1) value = 1;
			if (value < 0) value = 0;
			
			if (sliderDir == DRAG_DIRECTION.HORIZONTAL)
				sliderThumb.SetPosition(new Point(((sliderBase.width - sliderThumb.width) * value) + (sliderThumb.width / 2), 0), true);
			else
				sliderThumb.SetPosition(new Point(0, ((sliderBase.height - sliderThumb.height) * value) + (sliderThumb.height / 2)), true);
		}
		
		// スライダー更新イベントをLockする
		public function LockSliderEvent():void
		{
			isLockSliderEvent = true;
			sliderThumb.removeEventListener(Event.ENTER_FRAME, OnCheckThumbMove);
		}
		
		// スライダー更新イベントをUnLockしてスライダーThumb移動終了チェックを開始する
		public function UnLockSliderEvent():void
		{
			sliderThumb.addEventListener(Event.ENTER_FRAME, OnCheckThumbMove);
		}
		
		// スライダーThumbサイズをセットする
		public function SetThumbSize(scaleRatio:Number, minimumSize:Number = 30):void
		{
			if (sliderDir == DRAG_DIRECTION.HORIZONTAL)
			{
				sliderThumb.scaleX = (sliderThumb.scaleX * sliderBase.width / sliderThumb.width) * scaleRatio;
				if (sliderThumb.width < minimumSize)
				{
					var w:Number = sliderThumb.width;
					sliderThumb.width = minimumSize;
					sliderThumb.x -= (minimumSize - w) / 2;
				}
			}
			else
			{
				sliderThumb.scaleY = (sliderThumb.scaleY * sliderBase.height / sliderThumb.height) * scaleRatio;
				if (sliderThumb.height < minimumSize)
				{
					var h:Number = sliderThumb.height;
					sliderThumb.height = minimumSize;
					sliderThumb.y -= (minimumSize - h) / 2;
				}
			}
			
			ResetSlider();
		}
		
		
		//////////////////////////////////////////////////////////////// PublicFunction
		
		// SWCに配置されたMovieClipをラップする
		public function WrapFromSWC(targetObj:DisplayObject):void
		{
			var parentObj:DisplayObjectContainer = targetObj.parent;
			var position:Point = new Point(targetObj.x, targetObj.y);
			
			var depth:int = parentObj.getChildIndex(targetObj);
			parentObj.removeChild(targetObj);
			
			targetObj.x = 0;
			targetObj.y = 0;
			this.addChild(targetObj);
			
			this.x = position.x;
			this.y = position.y;
			parentObj.addChildAt(this, depth);
		}
	}
}