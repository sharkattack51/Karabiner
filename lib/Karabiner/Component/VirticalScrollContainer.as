package Karabiner.Component 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Karabiner.Constant.DRAG_DIRECTION;
	import Karabiner.Component.DragInteractionBase;
	import Karabiner.Component.ScrollListBase;
	import Karabiner.Component.SliderObject;
	import Karabiner.Component.Interface.ISwcObject;
	
	/**
	 * VirticalScrollContainer
	 * ドラッグで縦スクロールするコンテナクラス
	 */
	public class VirticalScrollContainer extends ScrollListBase implements ISwcObject 
	{	
		public function VirticalScrollContainer(maskedArea:Rectangle = null, controllSlider:SliderObject = null, shiftPos:Number = 0):void
		{
			super(DRAG_DIRECTION.VIRTICAL, maskedArea, controllSlider, shiftPos);
		}
		
		
		//////////////////////////////////////////////////////////////// Init
		
		override protected function InitVar():void
		{
			super.InitVar();
		}
		
		override protected function InitView():void
		{
			super.InitView();
		}
		
		override protected function InitEvent():void
		{
			super.InitEvent();
			
			if (DragInteractionBase.UseMouse && this.controllSlider != null)
			{
				this.addEventListener(MouseEvent.MOUSE_WHEEL, OnMouseWheel);
				this.controllSlider.addEventListener(MouseEvent.MOUSE_WHEEL, OnMouseWheel);
			}
		}
		
		
		//////////////////////////////////////////////////////////////// EventListner
		
		// デストラクタ
		override protected function Destructor(e:Event):void
		{
			super.Destructor(e);
			
			if (DragInteractionBase.UseMouse && this.controllSlider != null)
			{
				this.removeEventListener(MouseEvent.MOUSE_WHEEL, OnMouseWheel);
				this.controllSlider.removeEventListener(MouseEvent.MOUSE_WHEEL, OnMouseWheel);
			}
		}
		
		// マウスホイールでのスクロール
		private function OnMouseWheel(e:MouseEvent):void 
		{
			if (this.scrollAvailable)
				this.controllSlider.SetSlideValue(this.controllSlider.SliderValue - (e.delta * 0.1 * this.controllSlider.thumbScaleRatio));
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
			
			// リリース地点の座標でスプリング処理する
			if (this.targetPos >= this.shiftPos)
				this.targetPos = this.shiftPos;
			else
			{
				if (this.height <= this.maskedScrollSize)
					this.targetPos = this.shiftPos;
				else
				{
					if (this.targetPos + this.height + this.shiftPos <= this.maskedScrollSize)
						this.targetPos = this.maskedScrollSize - this.height - this.shiftPos;
				}
			}
		}
		
		// 座標更新
		override protected function OnScrollUpdate(e:Event):void 
		{
			super.OnScrollUpdate(e);
		}
		
		
		//////////////////////////////////////////////////////////////// PublicFunction
		
		// SWCに配置されたMovieClipをラップする
		public function WrapFromSWC(targetObj:DisplayObject):void
		{
			var parentObj:DisplayObjectContainer = targetObj.parent;
			var position:Point = new Point(targetObj.x, targetObj.y);
			
			var depth:int = parentObj.getChildIndex(targetObj);
			parentObj.removeChild(targetObj);
			
			this.x = position.x;
			this.y = position.y;
			parentObj.addChildAt(this, depth);
			
			targetObj.x = 0;
			targetObj.y = 0;
			this.scrollRoot.addChild(targetObj); // thisをaddChild後、scrollRootにアクセス可能
			
			this.name = targetObj.name;
		}
	}
}