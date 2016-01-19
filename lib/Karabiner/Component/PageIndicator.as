package Karabiner.Component
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import Karabiner.Component.PageIndicatorButton;
	import Karabiner.Component.ScrollPageList;
	import Karabiner.FrameworkObjectBase;
	
	/**
	 * PageIndicator
	 * 現在ページ表示のインジケーター
	 */
	public class PageIndicator extends FrameworkObjectBase
	{
		private var scrollPageList:ScrollPageList;
		private var pageLength:int;
		private var margin:Number;
		private var btnViewMcClass:Class;
		
		private var indicatorBtns:Array/*PageIndicatorButton*/;
		
		
		public function PageIndicator(scrollPageList:ScrollPageList, pageLength:int,
			margin:Number, btnViewMcClass:Class):void
		{
			super();
			
			this.scrollPageList = scrollPageList;
			this.pageLength = pageLength;
			this.margin = margin;
			this.btnViewMcClass = btnViewMcClass;
		}
		
		
		//////////////////////////////////////////////////////////////// Init
		
		override protected function InitVar():void
		{
			super.InitVar();
		}
		
		override protected function InitView():void
		{
			super.InitView();
			
			indicatorBtns = new Array();
			for (var i:int = 0; i < pageLength; i++) 
			{
				var indicatorBtn:PageIndicatorButton = new PageIndicatorButton(scrollPageList, i);
				var cls:Class = getDefinitionByName(getQualifiedClassName(btnViewMcClass)) as Class;
				indicatorBtn.addChild(new cls() as MovieClip);
				indicatorBtns.push(indicatorBtn);
				
				indicatorBtn.x = margin * i;
				this.addChild(indicatorBtn);
			}
			
			// 位置調整
			var adjust:Number = (this.width / 2) - (indicatorBtns[0].width / 2.0);
			for each (var btn:PageIndicatorButton in indicatorBtns) 
				btn.x -= adjust;
			
			// ラジオボタン設定
			for (var j:int = 0; j < indicatorBtns.length; j++) 
			{
				var mainBtn:PageIndicatorButton = indicatorBtns[j];
				var radioBtnArr:Array/*PageIndicatorButton*/ = new Array();
				for (var k:int = 0; k < indicatorBtns.length; k++) 
				{
					var radioBtn:PageIndicatorButton = indicatorBtns[k];
					if (mainBtn != radioBtn)
						radioBtnArr.push(radioBtn);
				}
				mainBtn.SetRadioBtns(radioBtnArr);
			}
			
			// １個目をアクティブ
			indicatorBtns[0].SetBtnState(true);
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
			
			scrollPageList = null;
			
			for (var i:int = 0; i < indicatorBtns.length; i++) 
			{
				this.removeChild(indicatorBtns[i]);
				indicatorBtns[i] = null;
			}
			indicatorBtns = new Array();
			indicatorBtns = null;
		}
		
		private function OnLoop(e:Event):void 
		{
			// アクティブ表示の更新
			SetActiveIndicator(scrollPageList.CurrentPageNum);
		}
		
		
		//////////////////////////////////////////////////////////////// PubicFuncion
		
		// アクティブ表示の更新
		public function SetActiveIndicator(activeIndex:int):void
		{
			for (var i:int = 0; i < indicatorBtns.length; i++) 
			{
				if (i == activeIndex)
					indicatorBtns[i].SetBtnState(true);
				else
					indicatorBtns[i].SetBtnState(false);
			}
		}
	}
}