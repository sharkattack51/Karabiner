package Karabiner.Component 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import Karabiner.Component.ScrollPageList;
	import Karabiner.Constant.COMPONENT_BY_NAME;
	import Karabiner.Constant.ON_BUTTON_TYPE;
	
	/**
	 * PageIndicatorButton
	 * 現在ページのインジケーター用ボタン
	 */
	public class PageIndicatorButton extends ToggleButtonBase 
	{
		private var scrollPageList:ScrollPageList;
		private var pageNum:int;
		
		// アクティブ表示
		private var activeMc:MovieClip;
		
		
		public function PageIndicatorButton(scrollPageList:ScrollPageList, pageNum:int):void
		{
			super(ON_BUTTON_TYPE.CLICK);
			
			this.scrollPageList = scrollPageList;
			this.pageNum = pageNum;
		}
		
		
		//////////////////////////////////////////////////////////////// Init
		
		override protected function InitVar():void 
		{
			super.InitVar();
		}
		
		override protected function InitView():void 
		{
			super.InitView();
			
			// アクティブ表示
			activeMc = (this.getChildAt(0) as MovieClip).getChildByName(COMPONENT_BY_NAME.TOGGLE_BTN_ACTIVE) as MovieClip;
			activeMc.visible = false;
		}
		
		override protected function InitEvent():void 
		{
			super.InitEvent();
			
			this.addEventListener(Event.ENTER_FRAME, OnLoop);
		}
		
		
		//////////////////////////////////////////////////////////////// EventListner
		
		//デストラクタ
		override protected function Destructor(e:Event):void 
		{
			super.Destructor(e);
			
			this.removeEventListener(Event.ENTER_FRAME, OnLoop);
			
			scrollPageList = null;
			activeMc = null;
		}
		
		private function OnLoop(e:Event):void 
		{
			// トグル表示
			if (this.BtnState)
				activeMc.visible = true;
			else
				activeMc.visible = false;
		}
		
		// ボタン機能
		override protected function OnButton():void
		{
			super.OnButton();
			
			// ページを遷移させる
			scrollPageList.GotoSetPage(pageNum);
		}
	}
}