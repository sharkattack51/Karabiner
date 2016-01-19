package Karabiner.Component
{
	import flash.events.Event;
	
	/**
	 * ToggleButtonBase
	 * トグルボタン機能の基本クラス
	 */
	public class ToggleButtonBase extends ButtonBase
	{
		// ボタンState
		private var btnState:Boolean;
		public function get BtnState():Boolean { return btnState; }
		
		// ラジオボタンの場合のグループ参照
		private var radioBtns:Array/*ToggleButtonBase*/;
		
		
		public function ToggleButtonBase(onButtonType:String, defaultState:Boolean = false, buttonMode:Boolean = true, useHandCursor:Boolean = true):void
		{
			super(onButtonType, buttonMode, useHandCursor);
			
			btnState = defaultState;
		}
		
		
		//////////////////////////////////////////////////////////////// Init
		
		override protected function InitVar():void 
		{
			super.InitVar();
			
			radioBtns = new Array();
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
			
			radioBtns = new Array();
			radioBtns = null;
		}
		
		// ボタン処理
		override protected function OnButton():void 
		{
			super.OnButton();
			
			if (radioBtns.length == 0)
			{
				// トグルボタン処理
				btnState = !btnState;
			}
			else
			{
				// ラジオボタン処理
				if (!btnState)
				{
					btnState = true;
					
					for each (var btn:ToggleButtonBase in radioBtns) 
						btn.SetBtnState(false);
				}
			}
		}
		
		
		//////////////////////////////////////////////////////////////// PublicFunction
		
		// 外部からのボタン状態の変更
		public function SetBtnState(state:Boolean):void
		{
			btnState = state;
		}
		
		//ラジオボタンのグループ参照設定
		public function SetRadioBtns(btns:Array/*ToggleButtonBase*/):void
		{
			radioBtns = btns;
		}
	}
}