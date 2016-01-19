package Karabiner.Component 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import Karabiner.Event.DragEvent;
	import Karabiner.FrameworkObjectBase;
	
	/**
	 * DragInteractionBase
	 * ドラッグ処理の基本クラス
	 */
	public class DragInteractionBase extends FrameworkObjectBase 
	{
		// モード
		private static var useMouse:Boolean = true;
		public static function set UseMouse(bool:Boolean):void { useMouse = bool; }
		public static function get UseMouse():Boolean { return useMouse; }
		
		// hit判定用オブジェクト
		private var hitTargetObject:DisplayObject;
		
		// タッチ操作用ID
		private var touchedID:int = -1;
		
		// タッチ座標
		private var startPoint:Point = new Point(-1, -1);
		private var currentPoint:Point = new Point( -1, -1);
		public function get CurrentDragPoint():Point { return currentPoint; }
		public function get CurrentDragDelta():Point { return new Point(currentPoint.x - startPoint.x, currentPoint.y - startPoint.y); }
		
		
		public function DragInteractionBase(buttonMode:Boolean = true, useHandCursor:Boolean = true):void
		{
			super();
			
			// ハンドカーソルの使用
			this.buttonMode = buttonMode;
			this.useHandCursor = useHandCursor;
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
		}
		
		
		//////////////////////////////////////////////////////////////// EventListner
		
		// デストラクタ
		override protected function Destructor(e:Event):void
		{
			super.Destructor(e);
			
			if (hitTargetObject != null)
			{
				hitTargetObject.removeEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
				if (hitTargetObject.stage != null)
				{
					hitTargetObject.stage.removeEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
					hitTargetObject.stage.removeEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
				}
				
				hitTargetObject.removeEventListener(TouchEvent.TOUCH_BEGIN, OnTouchBegin);
				if (hitTargetObject.stage != null)
				{
					hitTargetObject.stage.removeEventListener(TouchEvent.TOUCH_MOVE, OnTouchMove);
					hitTargetObject.stage.removeEventListener(TouchEvent.TOUCH_END, OnTouchEnd);
				}
				
				hitTargetObject = null;
			}
		}
		
		// マウス
		private function OnMouseDown(e:MouseEvent):void 
		{
			startPoint.x = e.stageX;
			startPoint.y = e.stageY;
			currentPoint.x = e.stageX;
			currentPoint.y = e.stageY;
			
			hitTargetObject.removeEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			if (hitTargetObject.stage != null)
			{
				hitTargetObject.stage.addEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
				hitTargetObject.stage.addEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
			}
			
			OnDragStart();
		}
		
		private function OnMouseMove(e:MouseEvent):void 
		{
			currentPoint.x = e.stageX;
			currentPoint.y = e.stageY;
			
			OnDragMove();
		}
		
		private function OnMouseUp(e:MouseEvent):void 
		{
			if (hitTargetObject.stage != null)
			{
				hitTargetObject.stage.removeEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
				hitTargetObject.stage.removeEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
			}
			hitTargetObject.addEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			
			OnDragEnd();
			
			// イベント後に変数を初期化する
			startPoint = new Point(-1, -1);
			currentPoint = new Point( -1, -1);
		}
		
		// タッチ
		private function OnTouchBegin(e:TouchEvent):void 
		{
			touchedID = e.touchPointID;
			startPoint.x = e.stageX;
			startPoint.y = e.stageY;
			currentPoint.x = e.stageX;
			currentPoint.y = e.stageY;
			
			hitTargetObject.removeEventListener(TouchEvent.TOUCH_BEGIN, OnTouchBegin);
			if (hitTargetObject.stage != null)
			{
				hitTargetObject.stage.addEventListener(TouchEvent.TOUCH_MOVE, OnTouchMove);
				hitTargetObject.stage.addEventListener(TouchEvent.TOUCH_END, OnTouchEnd);
			}
			
			OnDragStart();
		}
		
		private function OnTouchMove(e:TouchEvent):void 
		{
			if (touchedID == e.touchPointID)
			{
				currentPoint.x = e.stageX;
				currentPoint.y = e.stageY;
				
				OnDragMove();
			}
		}
		
		private function OnTouchEnd(e:TouchEvent):void 
		{
			if (touchedID == e.touchPointID)
			{
				if (hitTargetObject.stage != null)
				{
					hitTargetObject.stage.removeEventListener(TouchEvent.TOUCH_MOVE, OnTouchMove);
					hitTargetObject.stage.removeEventListener(TouchEvent.TOUCH_END, OnTouchEnd);
				}
				hitTargetObject.addEventListener(TouchEvent.TOUCH_BEGIN, OnTouchBegin);
				
				OnDragEnd();
				
				// イベント後に変数を初期化する
				touchedID = -1;
				startPoint = new Point(-1, -1);
				currentPoint = new Point( -1, -1);
			}
		}
		
		// ドラッグイベント
		protected function OnDragStart():void{ this.dispatchEvent(new Event(DragEvent.DRAG_START)); }
		protected function OnDragMove():void{ this.dispatchEvent(new Event(DragEvent.DRAG_MOVE)); }
		protected function OnDragEnd():void{ this.dispatchEvent(new Event(DragEvent.DRAG_END)); }
		
		
		//////////////////////////////////////////////////////////////// PublicFunction
		
		// ドラッグを開始
		public function DragStart(hitTargetObject:DisplayObject = null):void
		{
			if (hitTargetObject == null)
				hitTargetObject = this;
			
			this.hitTargetObject = hitTargetObject;
			
			if (useMouse)
				this.hitTargetObject.addEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			else
				this.hitTargetObject.addEventListener(TouchEvent.TOUCH_BEGIN, OnTouchBegin);
		}
	}
}