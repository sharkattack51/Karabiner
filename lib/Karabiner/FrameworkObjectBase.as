package Karabiner
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * FrameworkObjectBase
	 * フレームワークのオブジェクト基本クラス
	 */
	public class FrameworkObjectBase extends MovieClip 
	{
		public function FrameworkObjectBase() 
		{
			if (stage)
				Init();
			else
				this.addEventListener(Event.ADDED_TO_STAGE, Init);
		}
		
		
		//////////////////////////////////////////////////////////////// Init
		
		private function Init(e:Event = null):void 
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, Init);
			
			PreInit();
			InitVar();
			InitView();
			InitEvent();
			PostInit();
		}
		
		protected function PreInit():void
		{
		
		}
		
		protected function InitVar():void 
		{
		
		}
		
		protected function InitView():void 
		{
		
		}
		
		protected function InitEvent():void 
		{
			this.addEventListener(Event.REMOVED_FROM_STAGE, Destructor);
		}
		
		protected function PostInit():void
		{
		
		}
		
		//////////////////////////////////////////////////////////////// EventListner
		
		// デストラクタ
		protected function Destructor(e:Event):void 
		{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, Destructor);
		}
	}
}