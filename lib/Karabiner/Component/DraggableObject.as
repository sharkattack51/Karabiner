package Karabiner.Component 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Karabiner.Component.DragInteractionBase;
	import Karabiner.Component.Interface.ISwcObject;
	
	/**
	 * DraggableObject
	 * ドラッグ操作有効オブジェクトの基本クラス
	 */
	public class DraggableObject extends DragInteractionBase implements ISwcObject
	{
		// 挙動の調整値
		protected var dragPixelTh:Number = 30; // スクロール開始のピクセル閾値
		protected var draggingRatio:Number = 0.3; // ドラッグ中のスムース係数
		
		// ドラッグ処理
		protected var draggableArea:Rectangle;
		protected var startPos:Point;
		protected var targetPos:Point = new Point();
		protected var isOverDragTh:Boolean = false;
		
		
		public function DraggableObject(draggableArea:Rectangle = null):void 
		{
			super();
			
			this.draggableArea = draggableArea;
		}
		
		
		//////////////////////////////////////////////////////////////// Init
		
		override protected function InitVar():void
		{
			super.InitVar();
		}
		
		override protected function InitView():void
		{
			super.InitView();
			
			// 移動範囲を制限
			LimitMoveArea();
		}
		
		override protected function InitEvent():void
		{
			super.InitEvent();
			
			this.addEventListener(Event.ENTER_FRAME, OnLoop);
		}
		
		
		//////////////////////////////////////////////////////////////// EventListner
		
		// デストラクタ
		override protected function Destructor(e:Event):void
		{
			super.Destructor(e);
			
			this.removeEventListener(Event.ENTER_FRAME, OnLoop);
		}
		
		//ドラッグ開始
		override protected function OnDragStart():void
		{
			super.OnDragStart();
			
			//ドラッグ開始位置を保存
			startPos = new Point(this.x, this.y);
		}
		
		//ドラッグ中
		override protected function OnDragMove():void
		{
			super.OnDragMove();
			
			// 閾値以上のドラッグで処理
			if (dragPixelTh < Math.abs(Point.distance(this.CurrentDragDelta, new Point(0, 0))) || isOverDragTh)
			{
				isOverDragTh = true;
				
				// 目標座標を更新
				targetPos.x = startPos.x + this.CurrentDragDelta.x;
				targetPos.y = startPos.y + this.CurrentDragDelta.y;
				
				// ドラッグ移動更新での処理
				OnMoveUpdate();
			}
		}
		
		// ドラッグ移動更新
		protected function OnMoveUpdate():void { }
		
		// ドラッグ終了
		override protected function OnDragEnd():void
		{
			super.OnDragEnd();
			
			isOverDragTh = false;
		}
		
		// 座標更新
		private function OnLoop(e:Event):void 
		{
			// スムース移動
			this.x += (targetPos.x - this.x) * draggingRatio;
			this.y += (targetPos.y - this.y) * draggingRatio;
			
			// 移動範囲を制限
			LimitMoveArea();
		}
		
		
		//////////////////////////////////////////////////////////////// PrivateFunction
		
		// 移動範囲を制限
		private function LimitMoveArea():void
		{
			if (draggableArea != null)
			{
				// x座標
				if (this.width > draggableArea.width)
				{
					if (this.x <= draggableArea.left) this.x = targetPos.x = draggableArea.left;
					if (this.x >= draggableArea.right) this.x = targetPos.x = draggableArea.right;
				}
				else
				{
					if (this.x <= draggableArea.left + (this.width / 2)) this.x = targetPos.x = draggableArea.left + (this.width / 2);
					if (this.x >= draggableArea.right - (this.width / 2)) this.x = targetPos.x = draggableArea.right - (this.width / 2);
				}
				
				// y座標
				if (this.height > draggableArea.height)
				{
					if (this.y <= draggableArea.top) this.y = targetPos.y = draggableArea.top;
					if (this.y >= draggableArea.bottom) this.y = targetPos.y = draggableArea.bottom;
				}
				else
				{
					if (this.y <= draggableArea.top + (this.height / 2)) this.y = targetPos.y = draggableArea.top + (this.height / 2);
					if (this.y >= draggableArea.bottom - (this.height / 2)) this.y = targetPos.y = draggableArea.bottom - (this.height / 2);
				}
			}
		}
		
		
		//////////////////////////////////////////////////////////////// PublicFunction
		
		// 位置を変更する
		public function SetPosition(position:Point, smooth:Boolean = true):void
		{
			targetPos.x = position.x;
			targetPos.y = position.y;
			
			if (!smooth)
			{
				this.x = position.x;
				this.y = position.y;
			}
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
			
			this.targetPos = new Point(this.x, this.y);
		}
	}
}