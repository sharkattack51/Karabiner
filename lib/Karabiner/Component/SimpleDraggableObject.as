package Karabiner.Component 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Karabiner.Component.Interface.ISwcObject;
	import Karabiner.FrameworkObjectBase;
	
	/**
	 * SimpleDraggableObject
	 * MovieClip.startDrag()を使用したドラッグ操作有効オブジェクトの基本クラス
	 */
	public class SimpleDraggableObject extends FrameworkObjectBase implements ISwcObject
	{
		//　マウスモード
		private static var useMouse:Boolean = true;
		public static function set UseMouse(bool:Boolean):void { useMouse = bool; }
		
		//　ドラッグ時のセンター位置固定
		private var lockDragCenter:Boolean;
		
		//　ドラッグ移動可能範囲
		private var dragMoveArea:Rectangle;
		public function get DragMoveArea():Rectangle { return dragMoveArea; }
		
		//　タッチ操作用ID
		private var touchedID:int = -1;
		
		
		public function SimpleDraggableObject(lockDragCenter:Boolean = false, dragMoveArea:Rectangle = null):void
		{
			super();
			
			this.lockDragCenter = lockDragCenter;
			this.dragMoveArea = dragMoveArea;
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
			
			if (useMouse)
				this.addEventListener(MouseEvent.MOUSE_DOWN, OnDragStart);
			else
				this.addEventListener(TouchEvent.TOUCH_BEGIN, OnDragStart);
		}
		
		
		//////////////////////////////////////////////////////////////// EventListner
		
		//　デストラクタ
		override protected function Destructor(e:Event):void 
		{
			super.Destructor(e);
			
			this.removeEventListener(MouseEvent.MOUSE_DOWN, OnDragStart);
			this.removeEventListener(MouseEvent.MOUSE_UP, OnDragStop);
			this.removeEventListener(MouseEvent.MOUSE_OUT, OnDragStop);
			
			this.removeEventListener(TouchEvent.TOUCH_BEGIN, OnDragStart);
			this.removeEventListener(TouchEvent.TOUCH_END, OnDragStop);
			this.removeEventListener(TouchEvent.TOUCH_OUT, OnDragStop);
		}
		
		//　ドラッグを開始
		protected function OnDragStart(e:Event):void 
		{
			if (useMouse)
			{
				this.removeEventListener(MouseEvent.MOUSE_DOWN, OnDragStart);
				this.addEventListener(MouseEvent.MOUSE_UP, OnDragStop);
				this.addEventListener(MouseEvent.MOUSE_OUT, OnDragStop);
				
				this.startDrag(lockDragCenter, dragMoveArea);
			}
			else
			{
				this.removeEventListener(TouchEvent.TOUCH_BEGIN, OnDragStart);
				this.addEventListener(TouchEvent.TOUCH_END, OnDragStop);
				this.addEventListener(TouchEvent.TOUCH_OUT, OnDragStop);
				
				touchedID = TouchEvent(e).touchPointID;
				this.startTouchDrag(touchedID, lockDragCenter, dragMoveArea);
			}
		}
		
		//　ドラッグを停止
		protected function OnDragStop(e:Event):void 
		{
			if (useMouse)
			{
				this.removeEventListener(MouseEvent.MOUSE_UP, OnDragStop);
				this.removeEventListener(MouseEvent.MOUSE_OUT, OnDragStop);
				this.addEventListener(MouseEvent.MOUSE_DOWN, OnDragStart);
				
				this.stopDrag();
			}
			else
			{
				this.removeEventListener(TouchEvent.TOUCH_END, OnDragStop);
				this.removeEventListener(TouchEvent.TOUCH_OUT, OnDragStop);
				this.addEventListener(TouchEvent.TOUCH_BEGIN, OnDragStart);
				
				this.stopTouchDrag(touchedID);
				touchedID = -1;
			}
		}
		
		
		//////////////////////////////////////////////////////////////// PublicFunction
		
		//　ドラッグエリアを変更する
		public function SetDragMoveArea(dragMoveArea:Rectangle):void
		{
			this.dragMoveArea = dragMoveArea;
		}
		
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
			
			this.name = targetObj.name;
		}
	}
}