package Karabiner.Component
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import Karabiner.Enum.ON_BUTTON_TYPE;
	import Karabiner.Event.ButtonEvent;
	import Karabiner.FrameworkObjectBase;
	import Karabiner.Component.Interface.ISwcObject;
	
	/**
	 * ButtonBase
	 * ボタン機能の基本クラス
	 */
	public class ButtonBase extends FrameworkObjectBase implements ISwcObject
	{
		// モード
		private static var useMouse:Boolean = true;
		public static function set UseMouse(bool:Boolean):void { useMouse = bool; }
		public static function get UseMouse():Boolean { return useMouse; }
		
		// ボタンの実行タイプ
		private var onButtonType:String;
		
		// タッチ操作用ID
		private var touchedID:int = -1;
		
		// ボタンダウン判定
		private var isDown:Boolean = false;
		
		
		public function ButtonBase(onButtonType:String, buttonMode:Boolean = true, useHandCursor:Boolean = true):void
		{
			super();
			
			this.onButtonType = onButtonType;
			
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
			
			if (useMouse)
			{
				this.addEventListener(MouseEvent.CLICK, OnClick);
				this.addEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
				this.addEventListener(MouseEvent.ROLL_OVER, OnRollOver);
			}
			else
			{
				this.addEventListener(TouchEvent.TOUCH_TAP, OnTouchTap);
				this.addEventListener(TouchEvent.TOUCH_BEGIN, OnTouchBegin);
				this.addEventListener(TouchEvent.TOUCH_ROLL_OVER, OnTouchRollOver);
			}
		}
		
		
		//////////////////////////////////////////////////////////////// EventListner
		
		// デストラクタ
		override protected function Destructor(e:Event):void 
		{
			super.Destructor(e);
			
			this.removeEventListener(MouseEvent.CLICK, OnClick);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			this.removeEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, OnMouseUpOutSide);
			this.removeEventListener(MouseEvent.ROLL_OVER, OnRollOver);
			this.removeEventListener(MouseEvent.ROLL_OUT, OnRollOut);
			
			this.removeEventListener(TouchEvent.TOUCH_TAP, OnTouchTap);
			this.removeEventListener(TouchEvent.TOUCH_BEGIN, OnTouchBegin);
			this.removeEventListener(TouchEvent.TOUCH_END, OnTouchEnd);
			this.stage.removeEventListener(TouchEvent.TOUCH_END, OnTouchEndOutSide);
			this.removeEventListener(TouchEvent.TOUCH_ROLL_OVER, OnTouchRollOver);
			this.removeEventListener(TouchEvent.TOUCH_ROLL_OUT, OnTouchRollOut);
		}
		
		// マウス
		private function OnClick(e:MouseEvent):void
		{
			if (onButtonType == ON_BUTTON_TYPE.CLICK)
				OnButton();
		}
		
		private function OnMouseDown(e:MouseEvent):void 
		{
			this.removeEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, OnMouseUpOutSide);
			
			OnButtonDown();
			
			if (onButtonType == ON_BUTTON_TYPE.DOWN)
				OnButton();
			
			isDown = true;
		}
		
		private function OnMouseUp(e:MouseEvent):void 
		{
			this.removeEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, OnMouseUpOutSide);
			this.addEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			
			OnButtonUp();
			
			if (onButtonType == ON_BUTTON_TYPE.UP)
				OnButton();
			
			isDown = false;
		}
		
		private function OnMouseUpOutSide(e:MouseEvent):void 
		{
			this.removeEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, OnMouseUpOutSide);
			this.addEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			
			OnButtonUp();
			
			isDown = false;
		}
		
		private function OnRollOver(e:MouseEvent):void 
		{
			this.removeEventListener(MouseEvent.ROLL_OVER, OnRollOver);
			this.addEventListener(MouseEvent.ROLL_OUT, OnRollOut);
			
			if (isDown)
				OnButtonDownOver();
			OnButtonOver();
		}
		
		private function OnRollOut(e:MouseEvent):void 
		{
			this.removeEventListener(MouseEvent.ROLL_OUT, OnRollOut);
			this.addEventListener(MouseEvent.ROLL_OVER, OnRollOver);
			
			OnButtonOut();
		}
		
		// タッチ
		private function OnTouchTap(e:TouchEvent):void
		{
			if (onButtonType == ON_BUTTON_TYPE.CLICK)
				OnButton();
		}
		
		private function OnTouchBegin(e:TouchEvent):void 
		{
			this.removeEventListener(TouchEvent.TOUCH_BEGIN, OnTouchBegin);
			this.addEventListener(TouchEvent.TOUCH_END, OnTouchEnd);
			this.stage.addEventListener(TouchEvent.TOUCH_END, OnTouchEndOutSide);
			
			OnButtonDown();
			
			if (onButtonType == ON_BUTTON_TYPE.DOWN)
				OnButton();
			
			touchedID = e.touchPointID;
			isDown = true;
		}
		
		private function OnTouchEnd(e:TouchEvent):void 
		{
			if (touchedID == e.touchPointID)
			{
				this.removeEventListener(TouchEvent.TOUCH_END, OnTouchEnd);
				this.stage.removeEventListener(TouchEvent.TOUCH_END, OnTouchEndOutSide);
				this.addEventListener(TouchEvent.TOUCH_BEGIN, OnTouchBegin);
				
				OnButtonUp();
				
				if (onButtonType == ON_BUTTON_TYPE.UP)
					OnButton();
				
				touchedID = -1;
				isDown = false;
			}
		}
		
		private function OnTouchEndOutSide(e:TouchEvent):void 
		{
			if (touchedID == e.touchPointID)
			{
				this.removeEventListener(TouchEvent.TOUCH_END, OnTouchEnd);
				this.stage.removeEventListener(TouchEvent.TOUCH_END, OnTouchEndOutSide);
				this.addEventListener(TouchEvent.TOUCH_BEGIN, OnTouchBegin);
				
				OnButtonUp();
				
				touchedID = -1;
				isDown = false;
			}
		}
		
		private function OnTouchRollOver(e:TouchEvent):void 
		{
			if (touchedID == e.touchPointID)
			{
				this.removeEventListener(TouchEvent.TOUCH_ROLL_OVER, OnTouchRollOver);
				this.addEventListener(TouchEvent.TOUCH_ROLL_OUT, OnTouchRollOut);
				
				if (isDown)
					OnButtonDownOver();
				OnButtonOver();
			}
		}
		
		private function OnTouchRollOut(e:TouchEvent):void 
		{
			if (touchedID == e.touchPointID)
			{
				this.removeEventListener(TouchEvent.TOUCH_ROLL_OUT, OnTouchRollOut);
				this.addEventListener(TouchEvent.TOUCH_ROLL_OVER, OnTouchRollOver);
				
				OnButtonOut();
			}
		}
		
		// ボタン処理
		protected function OnButton():void { this.dispatchEvent(new Event(ButtonEvent.ON_BUTTON)); }
		protected function OnButtonDown():void { this.dispatchEvent(new Event(ButtonEvent.DOWN)); }
		protected function OnButtonUp():void { this.dispatchEvent(new Event(ButtonEvent.UP)); }
		protected function OnButtonDownOver():void { this.dispatchEvent(new Event(ButtonEvent.DOWN_OVER)); }
		protected function OnButtonOver():void { this.dispatchEvent(new Event(ButtonEvent.OVER)); }
		protected function OnButtonOut():void { this.dispatchEvent(new Event(ButtonEvent.OUT)); }
		
		
		//////////////////////////////////////////////////////////////// Public Function
		
		// SWCに配置されたSimpleButtonをラップする
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